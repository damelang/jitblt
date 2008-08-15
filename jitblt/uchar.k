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

; Support for unsigned char pointers (Quick Hack (TM) version)
(define SyntaxTable (import "SyntaxTable"))

[SyntaxTable at: 'uchar@ put: 'xUChar:]
[SyntaxTable at: 'set-uchar@ put: 'xSetChar:]

(define [Compiler xUChar: form]
  `(& (char@ ,@[form copyFrom: '1]) 0xff))
