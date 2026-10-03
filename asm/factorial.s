# Handwritten RV64. SysY int remains 32 bits: use mulw/addiw.
.section .rodata
.p2align 2
.globl limit
.type limit, @object
limit:
    .word 12
.size limit, 4
.text
.globl factorial
.type factorial, @function
factorial:
    bltz a0, .Linvalid
    la t0, limit
    lw t0, 0(t0)
    bgt a0, t0, .Linvalid
    li t0, 2
    li t1, 1
.Lcondition:
    bgt t0, a0, .Ldone
    mulw t1, t1, t0
    addiw t0, t0, 1
    j .Lcondition
.Ldone:
    mv a0, t1
    ret
.Linvalid:
    li a0, -1
    ret
.size factorial, .-factorial
.globl main
.type main, @function
main:
    addi sp, sp, -16
    sd ra, 8(sp)
    call getint
    call factorial
    call putint
    li a0, 10
    call putch
    li a0, 0
    ld ra, 8(sp)
    addi sp, sp, 16
    ret
.size main, .-main
.section .note.GNU-stack,"",@progbits
