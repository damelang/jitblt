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

; Code generation objects for pixel formats
(define-type PixelFormat Object (var))

; 'var' is a symbol with the name of the variable for which we are
; generating format-specific code
(define [PixelFormat variable: var]
  (let ((pixel-format [self new]))
    [pixel-format var: var]
    pixel-format))

; default color channel values
(define [PixelFormat a] '1.0)
(define [PixelFormat r] [self a])
(define [PixelFormat g] [self a])
(define [PixelFormat b] [self a])

(define [PixelFormat advance: var by: amount]
  `(set ,var (+ ,var ,amount)))

(define [PixelFormat advance: var]
  [self advance: var by: [self bytes-per-pixel]])

(define [PixelFormat swapR&B]
  (let ((swapped-format [self _delegated]))
    (define [swapped-format r] (super 'b))
    (define [swapped-format b] (super 'r))
    (define [swapped-format store: pixel-source]
      (super 'store: [pixel-source swapR&B]))
    swapped-format))

; The null pixel format
(define-type NONE PixelFormat ())
(define [NONE advance: var by: amount] '0)
(define [NONE bytes-per-pixel] '0)

; 32-bit pixel format
(define-type PixelFormat-32Bit PixelFormat ())
(define [PixelFormat-32Bit bytes-per-pixel] '4)
(define [PixelFormat-32Bit @] `(int@ ,[self var]))

; 16-bit pixel format
(define-type PixelFormat-16Bit PixelFormat ())
(define [PixelFormat-16Bit bytes-per-pixel] '2)
(define [PixelFormat-16Bit @] `(short@ ,[self var]))

; 8-bit Pixel Format
(define-type PixelFormat-8Bit PixelFormat ())
(define [PixelFormat-8Bit bytes-per-pixel] '1)
(define [PixelFormat-8Bit @] `(uchar@ ,[self var]))

; X8R8G8B8
(define-type X8R8G8B8 PixelFormat-32Bit ())

(define [X8R8G8B8 store: pixel-source]
  `(set ,[self @]
        (| (<< ,[pixel-source r] 16) 
           (<< ,[pixel-source g]  8) 
               ,[pixel-source b])))

(define [X8R8G8B8 r] `(& (>> ,[self @] 16) 0xff))
(define [X8R8G8B8 g] `(& (>> ,[self @]  8) 0xff))
(define [X8R8G8B8 b] `(&     ,[self @]     0xff))

; A8R8G8B8
(define-type A8R8G8B8 X8R8G8B8 ())

(define [A8R8G8B8 store: pixel-source]
  `(set ,[self @]
        (| (<< ,[pixel-source a] 24)
           (<< ,[pixel-source r] 16) 
           (<< ,[pixel-source g]  8) 
               ,[pixel-source b])))

(define [A8R8G8B8 a] `(& (>> ,[self @] 24) 0xff))

; SOLID
(define-type SOLID A8R8G8B8 ())
(define [SOLID advance: var by: amount] '0)

; A8B8G8R8
(define A8B8G8R8 [A8R8G8B8 swapR&B])

; X8B8G8R8
(define X8B8G8R8 [X8R8G8B8 swapR&B])

; TODO: the GdkPixbuf (non-premultipled reverse) format

; TODO: R8G8B8
; TODO: B8G8R8

; R5G6B5
(define-type R5G6B5 PixelFormat-16Bit ())

(define [R5G6B5 store: pixel-source]
  `(set ,[self @]
        (| (<< (& ,[pixel-source r] 0xf8) 8) 
           (<< (& ,[pixel-source g] 0xfc) 3) 
           (>>    ,[pixel-source b]       3))))

(define [R5G6B5 r]
  `(let ((__r (& (>> ,[self @] 8) 0xf8)))
     (| __r (>> __r 5))))

(define [R5G6B5 g]
  `(let ((__g (& (>> ,[self @] 3) 0xfc)))
     (| __g (>> __g 6))))

(define [R5G6B5 b]
  `(let ((__b (& (<< ,[self @] 3) 0xf8)))
     (| __b (>> __b 5))))

; B5G6R5
(define B5G6R5 [R5G6B5 swapR&B])

; X1R5G5B5
(define-type X1R5G5B5 PixelFormat-16Bit ())

(define [X1R5G5B5 store: pixel-source]
  `(set ,[self @]
        (| (<< (& ,[pixel-source r] 0xf8) 7)
           (<< (& ,[pixel-source g] 0xf8) 2)
           (>>    ,[pixel-source b]       3))))

(define [X1R5G5B5 r]
  `(let ((__r (& (>> ,[self @] 7) 0xf8)))
     (| __r (>> __r 5))))
(define [X1R5G5B5 g]
  `(let ((__g (& (>> ,[self @] 2) 0xf8)))
     (| __g (>> __g 5))))
(define [X1R5G5B5 b]
  `(let ((__b (& (<< ,[self @] 3) 0xf8)))
     (| __b (>> __b 5))))

; A1R5G5B5
(define-type A1R5G5B5 X1R5G5B5 ())

(define [A1R5G5B5 store: pixel-source]
  `(set ,[self @]
        (| (<< (& ,[pixel-source a] 0x80) 8)
           (<< (& ,[pixel-source r] 0xf8) 7)
           (<< (& ,[pixel-source g] 0xf8) 2)
           (>>    ,[pixel-source b]       3))))

(define [A1R5G5B5 a]
  `(& (- 0 (>> (& ,[self @] 0x8000) 15)) 0xff))

; A1B5G5R5
(define A1B5G5R5 [A1R5G5B5 swapR&B])

; X1B5G5R5
(define X1B5G5R5 [X1R5G5B5 swapR&B])

; X4R4G4B4
(define-type X4R4G4B4 PixelFormat-16Bit ())

(define [X4R4G4B4 store: pixel-source]
  `(set ,[self @]
        (| (<< (& ,[pixel-source r] 0xf0) 4)
               (& ,[pixel-source g] 0xf0)
           (>>    ,[pixel-source b]       4))))

(define [X4R4G4B4 r]
  `(let ((__r (& (>> ,[self @] 4) 0xf0)))
     (| __r (>> __r 4))))
(define [X4R4G4B4 g]
  `(let ((__g (& ,[self @] 0xf0)))
     (| __g (>> __g 4))))
(define [X4R4G4B4 b]
  `(let ((__b (& ,[self @] 0x0f)))
     (| __b (<< __b 4))))

; A4R4G4B4
(define-type A4R4G4B4 X4R4G4B4 ())

(define [A4R4G4B4 store: pixel-source]
  `(set ,[self @]
        (| (<< (& ,[pixel-source a] 0xf0) 8)
           (<< (& ,[pixel-source r] 0xf0) 4)
               (& ,[pixel-source g] 0xf0)
           (>>    ,[pixel-source b]       4))))

(define [A4R4G4B4 a]
  `(let ((__a (& (>> ,[self @] 8) 0xf0)))
     (| __a (>> __a 4))))

; A4B4G4R4
(define A4B4G4R4 [A4R4G4B4 swapR&B])

; X4B4G4R4
(define X4B4G4R4 [X4R4G4B4 swapR&B])

; A8
(define-type A8 PixelFormat-8Bit ())

(define [A8 store: pixel-source]
  `(set ,[self @] ,[pixel-source a]))

(define [A8 a] [self @])

; R3G3B2
(define-type R3G3B2 PixelFormat-8Bit ())

(define [R3G3B2 store: pixel-source]
  `(set ,[self @]
        (|     (& ,[pixel-source r] 0xe0)
           (>> (& ,[pixel-source g] 0xe0) 3)
           (>>    ,[pixel-source b]       6))))

(define [R3G3B2 r]
  `(let ((__r (& ,[self @] 0xe0)))
     (| __r (>> __r 3) (>> __r 6))))

(define [R3G3B2 g]
  `(let ((__g (& ,[self @] 0x1c)))
     (| (<< __g 3) __g (>> __g 3))))

(define [R3G3B2 b]
  `(let ((__b (& ,[self @] 0x03)))
     (| __b (<< __b 2) (<< __b 4) (<< __b 6))))

; B2G3R3
(define-type B2G3R3 PixelFormat-8Bit ())

(define [B2G3R3 store: pixel-source]
  `(set ,[self @]
        (| (>>    ,[pixel-source r]       5)
           (>> (& ,[pixel-source g] 0xe0) 2)
               (& ,[pixel-source b] 0xc0))))

(define [B2G3R3 r]
  `(let ((__r (& (<< ,[self @] 5) 0xe0)))
     (| __r (>> __r 3) (>> __r 6))))

(define [B2G3R3 g]
  `(let ((__g (& (<< ,[self @] 2) 0xe0)))
     (| __g (>> __g 3) (>> __g 6))))

(define [B2G3R3 b]
  `(let ((__b (& ,[self @] 0xc0)))
     (| __b (>> __b 2) (>> __b 4) (>> __b 6))))

; A2R2G2B2

(define-type A2R2G2B2 PixelFormat-8Bit ())

(define [A2R2G2B2 store: pixel-source]
  `(set ,[self @]
        (|     (& ,[pixel-source a] 0xc0)
           (>> (& ,[pixel-source r] 0xc0) 2)
           (>> (& ,[pixel-source g] 0xc0) 4)
           (>>    ,[pixel-source b]       6))))

(define [A2R2G2B2 a]
  `(let ((__a (& ,[self @] 0xc0)))
     (| __a (>> __a 2) (>> __a 4) (>> __a 6))))

(define [A2R2G2B2 r]
  `(let ((__r (& ,[self @] 0x30)))
     (| (<< __r 2) __r (>> __r 2) (>> __r 4))))

(define [A2R2G2B2 g]
  `(let ((__g (& ,[self @] 0x0c)))
     (| (<< __g 4) (<< __g 2) __g (>> __g 2))))

(define [A2R2G2B2 b]
  `(let ((__b (& ,[self @] 0x03)))
     (| (<< __b 6) (<< __b 4) (<< __b 2) __b)))

; A2B2G2R2
(define A2B2G2R2 [A2R2G2B2 swapR&B])

; X4A4

(define-type X4A4 PixelFormat-8Bit ())

(define [X4A4 store: pixel-source]
  `(set ,[self @] (>> ,[pixel-source a] 4)))

(define [X4A4 a]
  `(let ((__a (& ,[self @] 0x0f)))
     (| (<< __a 4) __a)))

; TODO: C8
; TODO: G8
; TODO: X4C4
; TODO: X4G4

; TODO: A4
; TODO: R1G2B1
; TODO: B1G2R1
; TODO: A1R1G1B1
; TODO: A1B1G1R1
; TODO: C4
; TODO: G4

; TODO: A1
; TODO: G1
