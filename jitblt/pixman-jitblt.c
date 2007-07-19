/*
 * Copyright © 2007 Dan Amelang
 *
 * Permission to use, copy, modify, distribute, and sell this software and its
 * documentation for any purpose is hereby granted without fee, provided that
 * the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation, and that the name of the authors not be used in advertising
 * or publicity pertaining to distribution of the software without specific,
 * written prior permission. The authors make no representations about the
 * suitability of this software for any purpose. It is provided "as is"
 * without express or implied warranty.
 *
 * THE AUTHORS DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING
 * ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL THE
 * AUTHORS BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY
 * DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
 * AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * Authors: Dan Amelang <dan@amelang.net>
 */

#include "config.h"
#include "pixman-private.h"

/* TODO move this typedef from pixman-pict.c to pixman-private.h so I don't
 * have to define it here
 */
typedef void (* CompositeFunc) (pixman_op_t,
				pixman_image_t *, pixman_image_t *, pixman_image_t *,
				int16_t, int16_t, int16_t, int16_t, int16_t, int16_t,
				uint16_t, uint16_t);

#include "pixman-jitblt.h"
#include "jitblt-params.h"
#include "jitblt-sources.h"
#include "jolt.h"

typedef CompositeFunc (*libjolt_t) (const char *);

#define CACHE_SIZE (32)

typedef struct {
    const char *src_format;
    const char *op1;
    const char *mask_format;
    const char *op2;
    const char *dst_format;
} jitblt_params_t;

/* FIXME not thread safe */
static struct {
    jitblt_params_t params;
    CompositeFunc func;
} cache[CACHE_SIZE];

static CompositeFunc
get_composite_func_for (const char *src_format,  const char *op1,
                        const char *mask_format, const char *op2,
                        const char *dst_format);

static CompositeFunc
cache_lookup (const jitblt_params_t *params);

static void
cache_insert (const jitblt_params_t *params, CompositeFunc func);

static const char *
pixman_op_to_jitblt_op (pixman_op_t op);

static const char *
pixman_format_to_jitblt_format (pixman_format_code_t format);

CompositeFunc
pixman_jitblt_get_composite_func_for (pixman_op_t      pixop,
                                      pixman_image_t * pSrc,
                                      pixman_image_t * pMask,
                                      pixman_image_t * pDst,
                                      int16_t      xSrc,
                                      int16_t      ySrc,
                                      int16_t      xMask,
                                      int16_t      yMask,
                                      int16_t      xDst,
                                      int16_t      yDst,
                                      uint16_t     width,
                                      uint16_t     height)
{
    const char *src_format, *op1, *mask_format, *op2, *dst_format;

    /* Check for all the cases that we don't handle yet */

    /* No linear gradients yet */
    if (pSrc->type == LINEAR || (pMask && pMask->type == LINEAR))
        return NULL;

    /* No conical gradients yet */
    if (pSrc->type == CONICAL || (pMask && pMask->type == CONICAL))
        return NULL;

    /* No radial gradients yet */
    if (pSrc->type == CONICAL || (pMask && pMask->type == CONICAL))
        return NULL;

    /* No transformations yet */
    if (pSrc->common.transform)
        return NULL;

    /* TODO there are no mask transforms, right? The mask transform matrix
     * appears to be used for the convolution matrix.
     */

    /* No read/write function callbacks (yet?) */
    if (pSrc->common.read_func || pSrc->common.write_func ||
        pDst->common.read_func || pDst->common.write_func ||
        (pMask && (pMask->common.read_func || pMask->common.write_func)))
        return NULL;

    /* No repeating src or mask yet */
    if (pSrc->common.repeat != PIXMAN_REPEAT_NONE ||
        (pMask && pMask->common.repeat != PIXMAN_REPEAT_NONE))
        return NULL;

    /* No alpha maps yet */
    if (pSrc->common.alpha_map || pDst->common.alpha_map ||
        (pMask && pMask->common.alpha_map))
        return NULL;

    /* No convolution filters yet */
    if (pSrc->common.filter == PIXMAN_FILTER_CONVOLUTION ||
        (pMask && pMask->common.filter == PIXMAN_FILTER_CONVOLUTION))
        return NULL;

    if (pSrc->type == SOLID)
        src_format = JITBLT_SOLID;
    else
        src_format = pixman_format_to_jitblt_format (pSrc->bits.format);

    if (pMask)
    {
        /* TODO clarify exactly how we should be detecting GdkPixbuf format */
        if (pMask && pSrc->bits.bits == pMask->bits.bits &&
            xSrc == xMask && ySrc == yMask &&
            !pMask->common.component_alpha &&
            pMask->common.repeat != PIXMAN_REPEAT_NORMAL)
        {
            /* TODO change this once jitblt supports the GdkPixbuf format */
            src_format = NULL;  /* = JITBLT_A8B8G8R8_NP; */
            op1 = JITBLT_OP_SOURCE;
            mask_format = JITBLT_NONE;
        }
        else
        {
            /* PIXMAN_OP_IN is the only pixman operation that can be applied to
             * source and mask. PIXMAN_OP_IN can map to either jitblt op "IN" or
             * "COMPONENT_IN", depending on if component_alpha is set on the mask.
             */
            op1 = pMask->common.component_alpha ?
                    JITBLT_OP_COMPONENT_IN : JITBLT_OP_IN;
            if (pMask->type == SOLID)
                mask_format = JITBLT_SOLID;
            else
                mask_format = pixman_format_to_jitblt_format (pMask->bits.format);
        }
    }
    else
    {
        op1 = JITBLT_OP_SOURCE;
        mask_format = JITBLT_NONE;
    }

    if (pixop == PIXMAN_OP_IN && pDst->common.component_alpha)
        op2 = JITBLT_OP_COMPONENT_IN;
    else
        op2 = pixman_op_to_jitblt_op (pixop);

    dst_format = pixman_format_to_jitblt_format (pDst->bits.format);

    /* Make sure that jitblt supports all the input operations and formats */
    if (!(src_format && op1 && mask_format && op2 && dst_format))
        return NULL;

    return get_composite_func_for (src_format, op1, mask_format, op2, dst_format);
}

static CompositeFunc
get_composite_func_for (const char *src_format,  const char *op1,
                        const char *mask_format, const char *op2,
                        const char *dst_format)
{
    /* FIXME this is obviously not thread-safe */
    static libjolt_t libjolt;
    char exp[128] = {0};
    CompositeFunc func;
    jitblt_params_t params;

    if (!libjolt)
    {
        int argc = 0;
        char **argv = {0};
        char **envp = {0};
        libjolt = (libjolt_t) libjolt_init (&argc, &argv, &envp);
        libjolt (jitblt_sources);
    }

    params.src_format = src_format;
    params.op1 = op1;
    params.mask_format = mask_format;
    params.op2 = op2;
    params.dst_format = dst_format;

    func = cache_lookup (&params);
    if (!func)
    {
        snprintf (exp, sizeof (exp), "[(jitblt-compile %s %s %s %s %s) _eval]",
                  src_format, op1, mask_format, op2, dst_format);
        func = libjolt (exp);
        cache_insert (&params, func);
    }

    return func;
}

static CompositeFunc
cache_lookup (const jitblt_params_t *params)
{
    int i;

    for (i = 0; i < CACHE_SIZE; i++)
        if (!memcmp (&cache[i].params, params, sizeof (*params)))
            return cache[i].func;

    return NULL;
}

static void
cache_insert (const jitblt_params_t *params, CompositeFunc func)
{
    int i;

    /* Look for an empty entry */
    for (i = 0; i < CACHE_SIZE; i++)
    {
        if (!cache[i].func)
        {
            cache[i].params = *params;
            cache[i].func = func;
            return;
        }
    }

    /* "If it doesn't fit, you must evict" */
    i = ((((unsigned long) func) +
          ((unsigned long) params->op2) +
          ((unsigned long) params->dst_format)) >> 1) % CACHE_SIZE;

    /* Jolt lambdas aren't automatically GC'ed (at the moment) */
    free (cache[i].func);

    cache[i].params = *params;
    cache[i].func = func;
}

static const char *
pixman_op_to_jitblt_op (pixman_op_t op)
{
    switch (op)
    {
        case PIXMAN_OP_CLEAR:           return JITBLT_OP_CLEAR;
        case PIXMAN_OP_SRC:             return JITBLT_OP_SOURCE;
        case PIXMAN_OP_DST:             return JITBLT_OP_DEST;
        case PIXMAN_OP_OVER:            return JITBLT_OP_OVER;
        case PIXMAN_OP_OVER_REVERSE:    return JITBLT_OP_DEST_OVER;
        case PIXMAN_OP_IN:              return JITBLT_OP_IN;
        case PIXMAN_OP_IN_REVERSE:      return JITBLT_OP_DEST_IN;
        case PIXMAN_OP_OUT:             return JITBLT_OP_OUT;
        case PIXMAN_OP_OUT_REVERSE:     return JITBLT_OP_DEST_OUT;
        case PIXMAN_OP_ATOP:            return JITBLT_OP_ATOP;
        case PIXMAN_OP_ATOP_REVERSE:    return JITBLT_OP_DEST_ATOP;
        case PIXMAN_OP_XOR:             return JITBLT_OP_XOR;
        case PIXMAN_OP_ADD:             return JITBLT_OP_ADD;
        case PIXMAN_OP_SATURATE:        return JITBLT_OP_SATURATE;
        default:                        return NULL;
    }
}

static const char *
pixman_format_to_jitblt_format (pixman_format_code_t format)
{
    switch (format)
    {
        case PIXMAN_a8r8g8b8:   return JITBLT_A8R8G8B8;
        case PIXMAN_x8r8g8b8:   return JITBLT_X8R8G8B8;
        case PIXMAN_a8b8g8r8:   return JITBLT_A8B8G8R8;
        case PIXMAN_x8b8g8r8:   return JITBLT_X8B8G8R8;
        case PIXMAN_r5g6b5:     return JITBLT_R5G6B5;
        case PIXMAN_b5g6r5:     return JITBLT_B5G6R5;
        case PIXMAN_a1r5g5b5:   return JITBLT_A1R5G5B5;
        case PIXMAN_x1r5g5b5:   return JITBLT_X1R5G5B5;
        case PIXMAN_a1b5g5r5:   return JITBLT_A1B5G5R5;
        case PIXMAN_x1b5g5r5:   return JITBLT_X1B5G5R5;
        case PIXMAN_a4r4g4b4:   return JITBLT_A4R4G4B4;
        case PIXMAN_x4r4g4b4:   return JITBLT_X4R4G4B4;
        case PIXMAN_a4b4g4r4:   return JITBLT_A4B4G4R4;
        case PIXMAN_x4b4g4r4:   return JITBLT_X4B4G4R4;
        case PIXMAN_a8:         return JITBLT_A8;
        case PIXMAN_r3g3b2:     return JITBLT_R3G3B2;
        case PIXMAN_b2g3r3:     return JITBLT_B2G3R3;
        case PIXMAN_a2r2g2b2:   return JITBLT_A2R2G2B2;
        case PIXMAN_a2b2g2r2:   return JITBLT_A2B2G2R2;
        case PIXMAN_x4a4:       return JITBLT_X4A4;
    
        /* These formats aren't supported yet */
        case PIXMAN_r8g8b8:
        case PIXMAN_b8g8r8:
        case PIXMAN_c8:
        case PIXMAN_g8:
        /* case PIXMAN_x4c4: TODO find out why this has the same enum value as c8 */
        /* case PIXMAN_x4g4: TODO find out why this has the same enum value as g8 */
        case PIXMAN_a4:
        case PIXMAN_r1g2b1:
        case PIXMAN_b1g2r1:
        case PIXMAN_a1r1g1b1:
        case PIXMAN_a1b1g1r1:
        case PIXMAN_c4:
        case PIXMAN_g4:
        case PIXMAN_a1:
        case PIXMAN_g1:
        default:
            return NULL;
    }
}
