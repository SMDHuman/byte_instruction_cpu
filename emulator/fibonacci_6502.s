; 6502 Assembly: Generate Fibonacci numbers until carry
; Memory layout:
; $00 = x (first number)
; $01 = y (second number)
; $02 = z (sum/result)
; $03 = pointer (index for fib_list)
; $04 = final_list_size
; $10 = fib_list (starting address for storing fibonacci numbers)

            .org $8000

; Initialize variables
; x = 0
            lda #0
            sta $00

; y = 1
            lda #1
            sta $01

; z = 0
            lda #0
            sta $02

; pointer = 0
            lda #0
            sta $03

; Generate loop (address $16)
FGEN_LOOP:
            ; z = x + y
            lda $00        ; load x into A
            clc            ; clear carry
            adc $01        ; add y to A, result in A
            sta $02        ; store result in z
            bcs FGEN_EXIT  ; if carry set, jump to exit

            ; x = y
            lda $01        ; load y into A
            sta $00        ; store y into x

            ; y = z
            lda $02        ; load z into A
            sta $01        ; store z into y

            ; fib_list[pointer] = z
            ldy $03        ; load pointer into Y
            lda $02        ; load z into A
            sta $10,y      ; store z at fib_list[pointer]

            ; pointer += 1
            inc $03        ; increment pointer

            ; continue loop
            jmp FGEN_LOOP

; Exit when carry is set (number exceeds 255)
FGEN_EXIT:
; Output to x6000 of all Fibonacci numbers generated
            lda #$00
            sta $6000      ; Initialize output address
            lda $03        ; load pointer into A
            sta $04        ; store final_list_size
            ldy #$00       ; initialize index Y to 0
OUTPUT_LOOP:
            cpy $04        ; compare index Y with final_list_size
            beq OUTPUT_DONE ; if equal, done outputting
            lda $10,y      ; load fib_list[Y] into A
            sta $6000    ; store A to output address
            iny            ; increment index Y
            jmp OUTPUT_LOOP ; repeat loop
OUTPUT_DONE:
            brk

            .org $FFFC
RESET_VECTOR: .word $8000