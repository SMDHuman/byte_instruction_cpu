; Generate all fibonacci numbers until 255 in a ram and output all in one
; ram[0] == x
; ram[1] == y
; ram[2] == z
; ram[3] == pointer
; ram[4] == final_list_size
; ram[16] == fib_list

; Initialize variables
        ; x = 0
                pha 0
                pha 0
                tab
                sta 
        ; y = 1
                pha 0
                pha 1
                tab
                pha 0
                pha 1
                sta 
        ; z = 0
                pha 0
                pha 2
                tab
                pha 0
                pha 0
                sta 
        ; pointer = 0
                pha 0
                pha 3
                tab
                pha 0
                pha 0
                sta 

;not.geci
; Generater loop address 0x16
        ; z = x + y
                ; load x to reg_a
                        pha 0
                        pha 0
                        tab
                        lda
                ; load y to reg_b
                        sax
                        pha 0
                        pha 1
                        tab
                        lda 
                        tab
                        sax
                ; add reg_a and reg_b
                        add
                ; store reg_a to z
                        sax
                        pha 0
                        pha 2
                        tab
                        sax
                        sta
        ; x = y
                ; load y to reg_a
                        pha 0
                        pha 1
                        tab
                        lda
                ; store reg_a to x
                        sax
                        pha 0
                        pha 0
                        tab
                        sax
                        sta
        ; y = z
                ; load z to reg_a
                        pha 0
                        pha 2
                        tab
                        lda
                ; store reg_a to y
                        sax
                        pha 0
                        pha 1
                        tab
                        sax
                        sta
        ; if carry exit_loop
                pha 0 ; Absolute jump exit address upper byte
                pha 0
                tab
                pha 6 ; Absolute jump exit address lower byte
                pha 3
                jmp.c
        ; fib_list[pointer] = z
                ; load z to reg_a
                        pha 0
                        pha 2
                        tab
                        lda
                ; store reg_a to fib_list[pointer]
                        sax
                        pha 0
                        pha 3
                        tab
                        lda ; load pointer
                        tab
                        pha 1 ; fib_list position
                        pha 0 
                        add ; reorient pointer
                        tab
                        sax
                        sta ; store  
        ; pointer += 1
                ; load pointer to reg_a
                        pha 0
                        pha 3
                        tab
                        lda
                ; incriment reg_a
                        inc
                ; store reg_a to pointer
                        sax
                        pha 0
                        pha 3
                        tab
                        sax
                        sta
        ; loop
                pha 0 ; Absolute jump loop address upper byte
                pha 0
                tab
                pha 1 ; Absolute jump loop address lower byte
                pha 6
                jmp
; Output all numbers that generated. address 0x63
        ; final_list_size = pointer
                ; load pointer to reg_a
                        pha 0
                        pha 3
                        tab
                        lda
                ; store reg_a to final_list_size
                        sax
                        pha 0
                        pha 4
                        tab
                        sax
                        sta
        ; pointer = 0
                ; store reg_a to pointer
                        pha 0
                        pha 3
                        tab
                        pha 0
                        pha 0
                        sta
; print_loop address 0x73
        ; output_port0( fib_list[pointer] )
                ; load fib_list[pointer] to reg_a
                        pha 0
                        pha 3
                        tab
                        lda ; load pointer
                        tab
                        pha 1 ; fib_list position
                        pha 0 
                        add ; reorient pointer
                        tab
                        lda ; fib_list[pointer]
                ; output a_reg to port 0
                        out 0  
        ; pointer += 1
                ; load pointer to reg_a
                        pha 0
                        pha 3
                        tab
                        lda
                ; incriment reg_a
                        inc
                ; store reg_a to pointer
                        sax
                        pha 0
                        pha 3
                        tab
                        sax
                        sta
        ; if pointer == final_list_size then halt
                ; load pointer to reg_a
                        pha 0
                        pha 3
                        tab
                        lda
                ; load final_list_size to reg_b
                        sax
                        pha 0
                        pha 4
                        tab
                        lda
                        tab
                        sax
                ; compare reg_a and reg_b
                        sub
                ; jump if result zero
                        pha 0x0 ; Absolute jump HALT address upper byte
                        pha 0x0
                        tab
                        pha 0xa ; Absolute jump HALT address lower byte
                        pha 0x1
                        jmp.z
        ; else jump print_loop
                pha 0 ; Absolute jump HALT address upper byte
                pha 0
                tab
                pha 7 ; Absolute jump HALT address lower byte
                pha 3
                jmp

; HALT jumps to 0xffff
                pha 0xf 
                pha 0xf
                tab
                jmp
