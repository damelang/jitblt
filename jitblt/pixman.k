;
; Copyright © 2007 Dan Amelang
;
; Permission to use, copy, modify, distribute, and sell this software and its
; documentation for any purpose is hereby granted without fee, provided that
; the above copyright notice appear in all copies and that both that
; copyright notice and this permission notice appear in supporting
; documentation, and that the name of the authors not be used in advertising
; or publicity pertaining to distribution of the software without specific,
; written prior permission. The authors make no representations about the
; suitability of this software for any purpose. It is provided "as is"
; without express or implied warranty.
;
; THE AUTHORS DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING
; ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL THE
; AUTHORS BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY
; DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
; AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
; OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
;
; Authors: Dan Amelang <dan@amelang.net>

; TODO
;   - Make all this portable (don't assume sizeof(void *), etc)
;   - We should probably generate this from the pixman header files, so
;     we stay in sync with pixman internals

(define pixman_image_t->bits.bits
  (lambda (image) (long@ (+ image  96))))
(define pixman_image_t->bits.rowstride
  (lambda (image) (int@  (+ image 104))))
(define pixman_image_t->type
  (lambda (image) (int@     image)))
(define pixman_image_t->bits.format
  (lambda (image) (int@  (+ image  80))))
(define &pixman_image_t->solid.color
  (lambda (image)        (+ image  84)))

(define pixman-BITS 0) ; from enum image_type_t

; The ">> 3" part is to convert from bits-per-pixel to bytes-per-pixel
(define pixman-bytes-per-pixel ; from PIXMAN_FORMAT_BPP
  (lambda (image)
    (if image (>> (>> (pixman_image_t->bits.format image) 24) 3) 0)))

; Pixman's stride unit is stride_in_bytes / 4, so we have to multiply
; the pixman stride by 4 to get the stride in terms of bytes (which is what
; we want for jitblt)
(define pixman-strideof
  (lambda (image)
    (if image (* (pixman_image_t->bits.rowstride image) 4) 0)))

(define pixman-startof
  (lambda (image x y)
    (if image
      (if (== (pixman_image_t->type image) pixman-BITS)
        (+ (pixman_image_t->bits.bits image)
          (* y (pixman-strideof image))
          (* x (pixman-bytes-per-pixel image)))
        (&pixman_image_t->solid.color image)) ; SOLID
      0)))
