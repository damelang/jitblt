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

(define apply-syntax
  (lambda (exp)
    (if [exp isKindOf: Expression] [exp applySyntax] exp)))

(define if-div-zero
  (lambda (exp)
    (if [exp isKindOf: Expression] [exp ifDivideByZero: '1.0] exp)))

(define optimize-for-AI
  (lambda (exp)
    (if [exp isKindOf: Expression] [exp optimizeForAlgebraicIdentities] exp)))

(define to-fixed-point
  (lambda (exp) [exp toFixedPoint]))

(define fold-constants
  (lambda (exp)
    (if [exp isKindOf: Expression] [exp foldConstants] exp)))

(define prepare-composite-exp
  (lambda (exp)
    (set exp [exp map!*_: apply-syntax])
    (set exp [exp map!*_: if-div-zero])
    (set exp [exp map!*_: optimize-for-AI])
    (set exp [exp map!*_: to-fixed-point])
    (set exp [exp map!*_: fold-constants])
    exp))

(define jitblt-compile
  (lambda (src-format operator-1 mask-format operator-2 dst-format)
    (let ((s-op1-m [operator-1 x: [src-format  variable: 's]
                               y: [mask-format variable: 'm]])
          (d [dst-format variable: 'd])
          (s-op1-m-op2-d [operator-2 x: s-op1-m y: d])
          (composite-exp (prepare-composite-exp [d store: s-op1-m-op2-d])))
      `(lambda (op src-image mask-image dst-image
                src-x src-y mask-x mask-y dst-x dst-y width height)
        (let ((src-stride  (pixman-strideof src-image))
              (mask-stride (pixman-strideof mask-image))
              (dst-stride  (pixman-strideof dst-image))
              (src  (pixman-startof src-image  src-x  src-y))
              (mask (pixman-startof mask-image mask-x mask-y))
              (dst  (pixman-startof dst-image  dst-x  dst-y)))
          (while height
            (let ((w width) (s src) (m mask) (d dst))
              (while w
                ,composite-exp
                ,[src-format  advance: 's]
                ,[mask-format advance: 'm]
                ,[dst-format  advance: 'd]
                (set w (- w 1))))
            ,[src-format  advance: 'src  by: 'src-stride]
            ,[mask-format advance: 'mask by: 'mask-stride]
            ,[dst-format  advance: 'dst  by: 'dst-stride]
            (set height (- height 1))))))))
