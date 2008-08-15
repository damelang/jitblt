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

(define TheGlobalEnvironment (import "TheGlobalEnvironment"))
(define Float (import "Float"))

(define [Expression applySyntax]
  (let ((head [self at: '0]))
    (if [head isSymbol]
      (let ((syntax [TheGlobalEnvironment lookupSyntax: head]))
        (if syntax [Compiler applySyntax: syntax with: self] self))
      self)))

(define [Expression ifDivideByZero: use-this-instead]
  (if (== [self at: '0] '/)
    `(let ((denominator ,[self at: '2]))
       (if denominator (/ ,[self at: '1] denominator) ,use-this-instead))
    self))

; This is how we convert an expression from floating point to 0.8 fixed point
; (via constant substitution and arithmetic operation adjustments).
;
; TODO: in some situations, we'll want to do this differently to be more
;   mathematically correct at the cost of speed
(define [Object toFixedPoint] self)

(define [Float toFixedPoint]
  [[self * '255] asInteger]) ; scale to fixed-point integer (0.8 fixed point)

(define [Expression toFixedPoint]
  (let ((head [self at: '0]))
    (cond ; FIXME: we assume two operands (which isn't always true!)
      ((== head '*) ; fixed-point multiplication
       ;`(>> ,self 8)) ; the fast, incorrect version
       `(let ((t (+ (* ,[self at: '1] ,[self at: '2]) 128)))
          (& (>> (+ (>> t 8) t) 8) 255)))
      ((== head '/) ; fixed-point division
       `(/ (<< ,[self at: '1] 8) ,[self at: '2]))
      (1 self))))

(define [Expression foldConstants]
  (if (== [self size] '3)
    (let ((head [self at: '0])
          (arg1 [self at: '1])
          (arg2 [self at: '2]))
      (if (and [arg1 isKindOf: SmallInteger]
               [arg2 isKindOf: SmallInteger]
               (or (== head '+)  (== head '-)  (== head '*) (== head '&)
                   (== head '<<) (== head '>>) (== head '|)))
          [SmallInteger value_: [self _eval]]
          self))
    self))

; We cover the following identities:
;
;   x + 0 = x
;   0 + x = x
;   x - 0 = x
;   1.0 * x = x
;   x * 1.0 = x
;   x / 1.0 = x (?)
;   x & 0 = 0
;   0 & x = 0
;   x | 0 = x
;   0 | x = x
;   x >> 0 = x
;   0 >> x = 0
;   x << 0 = x
;   0 << x = 0
;   
(define [Expression optimizeForAlgebraicIdentities]
  (if (== [self size] '3)
    (let ((head [self at: '0])
          (arg1 [self at: '1])
          (arg2 [self at: '2])
          (literal  (if [arg1 isNumber] arg1 (if [arg2 isNumber] arg2 0)))
          (variable (if (== literal arg1) arg2 arg1)))
      (if literal
        (let ((literal-is-0   (== literal '0))
              (literal-is-1.0 [literal = '1.0]))
          (cond ((and (== head '+) literal-is-0) variable)
                ((and (== head '-) literal-is-0 (== arg2 literal)) variable)
                ((and (== head '*) literal-is-1.0) variable)
                ((and (== head '/) literal-is-1.0 (== arg2 literal)) variable)
                ((and (== head '&) literal-is-0) '0)
                ((and (== head '|) literal-is-0) variable)
                ((and (or (== head '>>) (== head '<<)) literal-is-0)
                  (if (== literal arg1) '0 variable))
                (1 self)))
        self))
    self))
