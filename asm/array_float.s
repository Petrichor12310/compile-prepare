# Handwritten RV64GC/LP64D. float arguments/results use fa0.
.text
.globl sum
.type sum, @function
sum:
    fmv.w.x fa0, zero
    li t0, 0
.Lsum_condition:
    bge t0, a1, .Lsum_done
    slli t1, t0, 2
    add t1, a0, t1
    flw ft0, 0(t1)
    fadd.s fa0, fa0, ft0
    addiw t0, t0, 1
    j .Lsum_condition
.Lsum_done:
    ret
.size sum, .-sum
.globl main
.type main, @function
main:
    addi sp, sp, -64
    sd ra, 56(sp)
    sd s0, 48(sp)
    sd s1, 40(sp)
    # Local row-major float a[2][3], exact IEEE-754 bit patterns.
    li t0, 0x3f800000
    sw t0, 0(sp)
    li t0, 0x40000000
    sw t0, 4(sp)
    li t0, 0x40400000
    sw t0, 8(sp)
    li t0, 0x40800000
    sw t0, 12(sp)
    li t0, 0x40a00000
    sw t0, 16(sp)
    li t0, 0x40c00000
    sw t0, 20(sp)
    call getint
    mv s0, a0
    call getfloat
    fsw fa0, 16(sp)
    addi a0, sp, 12                    # Address of row a[1]
    li a1, 3
    call sum
    fcvt.s.w ft0, s0
    fadd.s fa0, fa0, ft0
    fsw fa0, 24(sp)                    # Preserve result across calls
    fcvt.w.s s1, fa0, rtz              # C/SysY truncation toward zero
    sext.w s1, s1
    call putfloat
    li a0, 10
    call putch
    mv a0, s1
    call putint
    li a0, 10
    call putch
    li a0, 0
    ld s1, 40(sp)
    ld s0, 48(sp)
    ld ra, 56(sp)
    addi sp, sp, 64
    ret
.size main, .-main
.section .note.GNU-stack,"",@progbits
