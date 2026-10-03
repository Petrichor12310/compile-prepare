# Handwritten RV64, LP64D. Keep sp 16-byte aligned at each call.
.text
.globl main
.type main, @function
main:
    addi sp, sp, -16
    sd ra, 8(sp)
    call getint
    call putint
    li a0, 10
    call putch
    li a0, 0
    ld ra, 8(sp)
    addi sp, sp, 16
    ret
.size main, .-main
.section .note.GNU-stack,"",@progbits
