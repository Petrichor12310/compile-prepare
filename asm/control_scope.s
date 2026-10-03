# Handwritten RV64. s0/s1/s2 survive tick and runtime calls.
.bss
.p2align 2
.globl probes
.type probes, @object
probes:
    .zero 4
.size probes, 4
.text
.globl tick
.type tick, @function
tick:
    la t0, probes
    lw t1, 0(t0)
    addiw t1, t1, 1
    sw t1, 0(t0)
    li a0, 1
    ret
.size tick, .-tick
.globl main
.type main, @function
main:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    sd s1, 8(sp)
    sd s2, 0(sp)
    call getint
    mv s0, a0                         # Outer n
    li s1, 0                          # total
    li s2, 0                          # i
.Lcondition:
    bge s2, s0, .Land_left
    addiw s2, s2, 1
    li t0, 2
    remw t1, s2, t0
    beqz t1, .Lcondition              # continue
    li t0, 9
    bgt s2, t0, .Land_left            # break
    mv t0, s2                         # Inner n has separate storage
    addw s1, s1, t0
    j .Lcondition
.Land_left:
    blez s0, .Lor_left                # Skip tick when n <= 0
    call tick
    beqz a0, .Lor_left
    addiw s1, s1, 100
.Lor_left:
    bltz s0, .Ladd_ten                # Skip tick when n < 0
    call tick
    beqz a0, .Lnot_check
.Ladd_ten:
    addiw s1, s1, 10
.Lnot_check:
    bnez s0, .Loutput
    addiw s1, s1, 1
.Loutput:
    mv a0, s1
    call putint
    li a0, 32
    call putch
    la t0, probes
    lw a0, 0(t0)
    call putint
    li a0, 10
    call putch
    li a0, 0
    ld s2, 0(sp)
    ld s1, 8(sp)
    ld s0, 16(sp)
    ld ra, 24(sp)
    addi sp, sp, 32
    ret
.size main, .-main
.section .note.GNU-stack,"",@progbits
