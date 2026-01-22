; avr-gcc -mmcu=atmega2560 -nostartfiles -nodefaultlibs -g -Wl,--emit-relocs -o avr_relocs.elf avr_relocs.s

.section .text
.global _start
.weak sym  ; ensuring relocations are emitted

_start:
    nop

    ldi r16, lo8(sym)       ; R_AVR_LO8_LDI (6)
    ldi r16, hi8(sym)       ; R_AVR_HI8_LDI (7)
    ldi r16, hh8(sym)       ; R_AVR_HH8_LDI (8)
    
    .reloc ., R_AVR_MS8_LDI, sym
    ldi r16, 0              ; R_AVR_MS8_LDI (35)

    ldi r16, lo8(-(sym))    ; R_AVR_LO8_LDI_NEG (9)
    ldi r16, hi8(-(sym))    ; R_AVR_HI8_LDI_NEG (10)
    ldi r16, hh8(-(sym))    ; R_AVR_HH8_LDI_NEG (11)

    ldi r16, lo8(pm(sym))   ; R_AVR_LO8_LDI_PM (12)
    ldi r16, hi8(pm(sym))   ; R_AVR_HI8_LDI_PM (13)
    ldi r16, hh8(pm(sym))   ; R_AVR_HH8_LDI_PM (14)

    ldi r16, lo8(-(pm(sym))) ; R_AVR_LO8_LDI_PM_NEG (15)
    ldi r16, hi8(-(pm(sym))) ; R_AVR_HI8_LDI_PM_NEG (16)
    ldi r16, hh8(-(pm(sym))) ; R_AVR_HH8_LDI_PM_NEG (17)


    rjmp sym                ; R_AVR_13_PCREL (3)
    
    clz
    breq sym                ; R_AVR_7_PCREL (2)
    
    call sym                ; R_AVR_CALL (18)


.section .data

    .long sym               ; R_AVR_32 (1)
    .word sym               ; R_AVR_16 (4)
    .word pm(sym)           ; R_AVR_16_PM (5)
    .byte sym               ; R_AVR_8 (27)
    
/* Forced Relocations */
    .reloc ., R_AVR_8_LO8, sym
    .byte 0                 ; R_AVR_8_LO8 (28)
    
    .reloc ., R_AVR_8_HI8, sym
    .byte 0                 ; R_AVR_8_HI8 (29)
    
    .reloc ., R_AVR_8_HLO8, sym
    .byte 0                 ; R_AVR_8_HLO8 (30)


.section .text

    .reloc ., R_AVR_6, sym
    std Z+0, r16

    .reloc ., R_AVR_6_ADIW, sym
    adiw r24, 0

    .reloc ., R_AVR_DIFF8, sym
    .byte 0
    .reloc ., R_AVR_DIFF16, sym
    .word 0
    .reloc ., R_AVR_DIFF32, sym
    .long 0
