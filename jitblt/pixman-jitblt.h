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
#ifndef PIXMAN_JITBLT_H
#define PIXMAN_JITBLT_H

CompositeFunc
pixman_jitblt_get_composite_func_for (pixman_op_t      op,
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
                                      uint16_t     height);

#endif
