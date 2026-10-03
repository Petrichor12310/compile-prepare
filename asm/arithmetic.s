# Handwritten RV64/LP64D. divw/remw operate on signed SysY int32 values.
.text
.globl emit
.type emit, @function
emit:
    addi sp, sp, -16
    sd ra, 8(sp)
    call putint
    li a0, 10
    call putch
    ld ra, 8(sp)
    addi sp, sp, 16
    ret
.size emit, .-emit

.globl main
.type main, @function
main:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    sd s1, 8(sp)
    call getint
    mv s0, a0
    call getint
    mv s1, a0
    beqz s1, .Lzero
    addw a0, s0, s1
    call emit
    subw a0, s0, s1
    call emit
    mulw a0, s0, s1
    call emit
    divw a0, s0, s1
    call emit
    remw a0, s0, s1
    call emit
    negw a0, s0
    call emit
    mv a0, s0
    call emit
    slt a0, s0, s1
    call emit
    slt a0, s1, s0
    xori a0, a0, 1
    call emit
    slt a0, s1, s0
    call emit
    slt a0, s0, s1
    xori a0, a0, 1
    call emit
    xor a0, s0, s1
    seqz a0, a0
    call emit
    xor a0, s0, s1
    snez a0, a0
    call emit
    j .Ldone
.Lzero:
    li a0, -1
    call emit
.Ldone:
    li a0, 0
    ld s1, 8(sp)
    ld s0, 16(sp)
    ld ra, 24(sp)
    addi sp, sp, 32
    ret
.size main, .-main
.section .note.GNU-stack,"",@progbits
