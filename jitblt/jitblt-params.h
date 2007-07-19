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

/* jitblt compositing operators */
static const char *const JITBLT_OP_CLEAR         = "CLEAR";
static const char *const JITBLT_OP_SOURCE        = "SOURCE";
static const char *const JITBLT_OP_DEST          = "DEST";
static const char *const JITBLT_OP_OVER          = "OVER";
static const char *const JITBLT_OP_DEST_OVER     = "DEST_OVER";
static const char *const JITBLT_OP_IN            = "IN";
static const char *const JITBLT_OP_DEST_IN       = "DEST_IN";
static const char *const JITBLT_OP_OUT           = "OUT";
static const char *const JITBLT_OP_DEST_OUT      = "DEST_OUT";
static const char *const JITBLT_OP_ATOP          = "ATOP";
static const char *const JITBLT_OP_DEST_ATOP     = "DEST_ATOP";
static const char *const JITBLT_OP_XOR           = "XOR";
static const char *const JITBLT_OP_ADD           = "ADD";
static const char *const JITBLT_OP_SATURATE      = "SATURATE";
static const char *const JITBLT_OP_COMPONENT_IN  = "COMPONENT_IN";

/* jitblt supported pixel formats */
static const char *const JITBLT_NONE     = "NONE";
static const char *const JITBLT_SOLID    = "SOLID";
static const char *const JITBLT_A8R8G8B8 = "A8R8G8B8";
static const char *const JITBLT_X8R8G8B8 = "X8R8G8B8";
static const char *const JITBLT_A8B8G8R8 = "A8B8G8R8";
static const char *const JITBLT_X8B8G8R8 = "X8B8G8R8";
static const char *const JITBLT_R5G6B5   = "R5G6B5";
static const char *const JITBLT_B5G6R5   = "B5G6R5";
static const char *const JITBLT_A1R5G5B5 = "A1R5G5B5";
static const char *const JITBLT_X1R5G5B5 = "X1R5G5B5";
static const char *const JITBLT_A1B5G5R5 = "A1B5G5R5";
static const char *const JITBLT_X1B5G5R5 = "X1B5G5R5";
static const char *const JITBLT_A4R4G4B4 = "A4R4G4B4";
static const char *const JITBLT_X4R4G4B4 = "X4R4G4B4";
static const char *const JITBLT_A4B4G4R4 = "A4B4G4R4";
static const char *const JITBLT_X4B4G4R4 = "X4B4G4R4";
static const char *const JITBLT_A8       = "A8";
static const char *const JITBLT_R3G3B2   = "R3G3B2";
static const char *const JITBLT_B2G3R3   = "B2G3R3";
static const char *const JITBLT_A2R2G2B2 = "A2R2G2B2";
static const char *const JITBLT_A2B2G2R2 = "A2B2G2R2";
static const char *const JITBLT_X4A4     = "X4A4";
