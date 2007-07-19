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

; TODO error-check the node size (saturate should only take one arg)
(syntax saturate
  (lambda (node compiler)
    `(let ((__tmp ,[node at: '1]))
       (if (> __tmp 1.0) 1.0 __tmp))))

; CompositingOperator
(define-type CompositingOperator Object (x y))

(define [CompositingOperator x: x y: y]
  (let ((operator [self new]))
    [operator x: x]
    [operator y: y]
    operator))

(define [CompositingOperator swapR&B]
  (let ((swapped-op [self _delegated]))
    (define [swapped-op r] (super 'b))
    (define [swapped-op b] (super 'r))
    [swapped-op x: [self x] y: [self y]]))

; TODO I want to just do this: (compositing-operator IN "x * y.a")
;      But that might make it harder for code optimizations later
(define-type IN CompositingOperator ())

; x * y.a
; (* x y.a)
; (* ,[self x] ,[[self y] a])
(define [IN a] `(* ,[[self x] a] ,[[self y] a]))
(define [IN r] `(* ,[[self x] r] ,[[self y] a]))
(define [IN g] `(* ,[[self x] g] ,[[self y] a]))
(define [IN b] `(* ,[[self x] b] ,[[self y] a]))

(define-type DEST_IN CompositingOperator ())

; x.a * y
; (* x.a y)
; (* ,[[self x] a] ,[self y])
(define [DEST_IN a] `(* ,[[self x] a] ,[[self y] a]))
(define [DEST_IN r] `(* ,[[self x] a] ,[[self y] r]))
(define [DEST_IN g] `(* ,[[self x] a] ,[[self y] g]))
(define [DEST_IN b] `(* ,[[self x] a] ,[[self y] b]))

(define-type OUT CompositingOperator ())

; x * (1.0 - y.a)
; (* x (- 1.0 y.a))
; (* ,[self x] (- 1.0 ,[[self y] a]))
(define [OUT a] `(* ,[[self x] a] (- 1.0 ,[[self y] a])))
(define [OUT r] `(* ,[[self x] r] (- 1.0 ,[[self y] a])))
(define [OUT g] `(* ,[[self x] g] (- 1.0 ,[[self y] a])))
(define [OUT b] `(* ,[[self x] b] (- 1.0 ,[[self y] a])))

(define-type DEST_OUT CompositingOperator ())

; (1.0 - x.a) * y
; (* (- 1.0 x.a) y)
; (* (- 1.0 ,[[self x] a]) ,[self y])
(define [DEST_OUT a] `(* (- 1.0 ,[[self x] a]) ,[[self y] a]))
(define [DEST_OUT r] `(* (- 1.0 ,[[self x] a]) ,[[self y] r]))
(define [DEST_OUT g] `(* (- 1.0 ,[[self x] a]) ,[[self y] g]))
(define [DEST_OUT b] `(* (- 1.0 ,[[self x] a]) ,[[self y] b]))

(define-type ATOP CompositingOperator ())

; x * y.a + y * (1.0 - x.a)
; (+ (* x y.a) (* y (- 1.0 x.a)))
; (+ (* ,[self x] ,[[self y] a]) (* ,[self y] (- 1.0 ,[[self x] a])))
(define [ATOP a]
  `(+ (* ,[[self x] a] ,[[self y] a])
      (* ,[[self y] a] (- 1.0 ,[[self x] a]))))

(define [ATOP r]
  `(+ (* ,[[self x] r] ,[[self y] a])
      (* ,[[self y] r] (- 1.0 ,[[self x] a]))))

(define [ATOP g]
  `(+ (* ,[[self x] g] ,[[self y] a])
      (* ,[[self y] g] (- 1.0 ,[[self x] a]))))

(define [ATOP b]
  `(+ (* ,[[self x] b] ,[[self y] a])
      (* ,[[self y] b] (- 1.0 ,[[self x] a]))))

(define-type DEST_ATOP CompositingOperator ())

; x * (1.0 - y.a) + y * x.a
; (+ (* x (- 1.0 y.a)) (* y x.a))
; (+ (* ,[self x] (- 1.0 ,[[self y] a])) (* ,[self y] ,[[self x] a]))
(define [DEST_ATOP a]
  `(+ (* ,[[self x] a] (- 1.0 ,[[self y] a]))
      (* ,[[self y] a] ,[[self x] a])))

(define [DEST_ATOP r]
  `(+ (* ,[[self x] r] (- 1.0 ,[[self y] a]))
      (* ,[[self y] r] ,[[self x] a])))

(define [DEST_ATOP g]
  `(+ (* ,[[self x] g] (- 1.0 ,[[self y] a]))
      (* ,[[self y] g] ,[[self x] a])))

(define [DEST_ATOP b]
  `(+ (* ,[[self x] b] (- 1.0 ,[[self y] a]))
      (* ,[[self y] b] ,[[self x] a])))

(define-type OVER CompositingOperator ())

; x + y * (1.0 - x.a)
; (+ x (* y (- 1.0 x.a)))
; (+ ,[self x] (* ,[self y] (- 1.0 ,[[self x] a])))
(define [OVER a]
  `(+ ,[[self x] a] (* ,[[self y] a] (- 1.0 ,[[self x] a]))))
(define [OVER r]
  `(+ ,[[self x] r] (* ,[[self y] r] (- 1.0 ,[[self x] a]))))
(define [OVER g]
  `(+ ,[[self x] g] (* ,[[self y] g] (- 1.0 ,[[self x] a]))))
(define [OVER b]
  `(+ ,[[self x] b] (* ,[[self y] b] (- 1.0 ,[[self x] a]))))

(define-type COMPONENT_IN CompositingOperator ())

; x * y
; (* x y)
; (* ,[self x] ,[self y])
(define [COMPONENT_IN a] `(* ,[[self x] a] ,[[self y] a]))
(define [COMPONENT_IN r] `(* ,[[self x] r] ,[[self y] r]))
(define [COMPONENT_IN g] `(* ,[[self x] g] ,[[self y] g]))
(define [COMPONENT_IN b] `(* ,[[self x] b] ,[[self y] b]))

(define-type CLEAR CompositingOperator ())

; 0.0
(define [CLEAR a] '0.0)
(define [CLEAR r] '0.0)
(define [CLEAR g] '0.0)
(define [CLEAR b] '0.0)

(define-type SOURCE CompositingOperator ())

; x
; x
; ,[self x]
(define [SOURCE a] [[self x] a])
(define [SOURCE r] [[self x] r])
(define [SOURCE g] [[self x] g])
(define [SOURCE b] [[self x] b])

(define-type DEST CompositingOperator ())

; y
; y
; ,[self y]
(define [DEST a] [[self y] a])
(define [DEST r] [[self y] r])
(define [DEST g] [[self y] g])
(define [DEST b] [[self y] b])

(define-type DEST_OVER CompositingOperator ())

; x * (1.0 - y.a) + y
; (+ (* x (- 1.0 y.a)) y)
; (+ (* ,[self x] (- 1.0 ,[[self y] a])) ,[self y])
(define [DEST_OVER a]
  `(+ (* ,[[self x] a] (- 1.0 ,[[self y] a])) ,[[self y] a]))
(define [DEST_OVER r]
  `(+ (* ,[[self x] r] (- 1.0 ,[[self y] a])) ,[[self y] r]))
(define [DEST_OVER g]
  `(+ (* ,[[self x] g] (- 1.0 ,[[self y] a])) ,[[self y] g]))
(define [DEST_OVER b]
  `(+ (* ,[[self x] b] (- 1.0 ,[[self y] a])) ,[[self y] b]))

(define-type ADD CompositingOperator ())

; saturate (x + y)
; (saturate (+ x y))
; (saturate (+ ,[self x] ,[self y]))
(define [ADD a]
  `(saturate (+ ,[[self x] a] ,[[self y] a])))
(define [ADD r]
  `(saturate (+ ,[[self x] r] ,[[self y] r])))
(define [ADD g]
  `(saturate (+ ,[[self x] g] ,[[self y] g])))
(define [ADD b]
  `(saturate (+ ,[[self x] b] ,[[self y] b])))

(define-type XOR CompositingOperator ())

; saturate (x * (1.0 - y.a) + y * (1.0 - x.a))
; (saturate (+ (* x (- 1.0 y.a)) (* y (- 1.0 x.a))))
; (saturate (+ (* ,[self x] (- 1.0 ,[[self y] a])) 
;              (* ,[self y] (- 1.0 ,[[self x] a]))))
(define [XOR a]
  `(saturate (+ (* ,[[self x] a] (- 1.0 ,[[self y] a])) 
                (* ,[[self y] a] (- 1.0 ,[[self x] a])))))
(define [XOR r]
  `(saturate (+ (* ,[[self x] r] (- 1.0 ,[[self y] a])) 
                (* ,[[self y] r] (- 1.0 ,[[self x] a])))))
(define [XOR g]
  `(saturate (+ (* ,[[self x] g] (- 1.0 ,[[self y] a])) 
                (* ,[[self y] g] (- 1.0 ,[[self x] a])))))
(define [XOR b]
  `(saturate (+ (* ,[[self x] b] (- 1.0 ,[[self y] a])) 
                (* ,[[self y] b] (- 1.0 ,[[self x] a])))))

(define-type SATURATE CompositingOperator ())

; NOTE: SATURATE and saturate() are two different things. One is a
; compositing operator, the other is a shader function.
;
; saturate (x * ((1.0 - y.a) / x.a) + y)
; (saturate (+ (* x (/ (- 1.0 y.a) x.a)) y))
; (saturate (+ (* ,[self x] (/ (- 1.0 ,[[self y] a]) ,[[self x] a])) ,[self y]))
(define [SATURATE a]
  `(saturate (+ (* ,[[self x] a] (/ (- 1.0 ,[[self y] a]) ,[[self x] a]))
                ,[[self y] a])))
(define [SATURATE r]
  `(saturate (+ (* ,[[self x] r] (/ (- 1.0 ,[[self y] a]) ,[[self x] a]))
                ,[[self y] r])))
(define [SATURATE g]
  `(saturate (+ (* ,[[self x] g] (/ (- 1.0 ,[[self y] a]) ,[[self x] a]))
                ,[[self y] g])))
(define [SATURATE b]
  `(saturate (+ (* ,[[self x] b] (/ (- 1.0 ,[[self y] a]) ,[[self x] a]))
                ,[[self y] b])))
