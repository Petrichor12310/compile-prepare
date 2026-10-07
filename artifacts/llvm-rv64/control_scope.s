	.text
	.attribute	4, 16
	.attribute	5, "rv64i2p0_m2p0_a2p0_f2p0_d2p0_c2p0"
	.file	"control_scope.ll"
	.globl	tick                            # -- Begin function tick
	.p2align	1
	.type	tick,@function
tick:                                   # @tick
	.cfi_startproc
# %bb.0:                                # %entry
	lui	a1, %hi(probes)
	lw	a0, %lo(probes)(a1)
	addiw	a2, a0, 1
	li	a0, 1
	sw	a2, %lo(probes)(a1)
	ret
.Lfunc_end0:
	.size	tick, .Lfunc_end0-tick
	.cfi_endproc
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	1
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	addi	sp, sp, -32
	.cfi_def_cfa_offset 32
	sd	ra, 24(sp)                      # 8-byte Folded Spill
	sd	s0, 16(sp)                      # 8-byte Folded Spill
	.cfi_offset ra, -8
	.cfi_offset s0, -16
	call	getint@plt
	sext.w	s0, a0
	sw	zero, 12(sp)
	sw	zero, 8(sp)
	li	a0, 9
.LBB1_1:                                # %condition
                                        # =>This Inner Loop Header: Depth=1
	lw	a2, 8(sp)
	bge	a2, s0, .LBB1_5
# %bb.2:                                # %body
                                        #   in Loop: Header=BB1_1 Depth=1
	addiw	a1, a2, 1
	addi	a2, a2, 1
	srliw	a3, a1, 31
	add	a3, a3, a2
	andi	a3, a3, -2
	subw	a3, a2, a3
	sw	a2, 8(sp)
	beqz	a3, .LBB1_1
# %bb.3:                                # %break.check
                                        #   in Loop: Header=BB1_1 Depth=1
	blt	a0, a1, .LBB1_5
# %bb.4:                                # %inner.scope
                                        #   in Loop: Header=BB1_1 Depth=1
	lw	a2, 12(sp)
	sw	a1, 4(sp)
	addw	a1, a1, a2
	sw	a1, 12(sp)
	j	.LBB1_1
.LBB1_5:                                # %and.left
	blez	s0, .LBB1_8
# %bb.6:                                # %and.right
	call	tick@plt
	sext.w	a0, a0
	beqz	a0, .LBB1_8
# %bb.7:                                # %add.hundred
	lw	a0, 12(sp)
	addiw	a0, a0, 100
	sw	a0, 12(sp)
.LBB1_8:                                # %or.left
	bltz	s0, .LBB1_10
# %bb.9:                                # %or.right
	call	tick@plt
	sext.w	a0, a0
	beqz	a0, .LBB1_11
.LBB1_10:                               # %add.ten
	lw	a0, 12(sp)
	addiw	a0, a0, 10
	sw	a0, 12(sp)
.LBB1_11:                               # %not.check
	bnez	s0, .LBB1_13
# %bb.12:                               # %add.one
	lw	a0, 12(sp)
	addiw	a0, a0, 1
	sw	a0, 12(sp)
.LBB1_13:                               # %output
	lw	a0, 12(sp)
	call	putint@plt
	li	a0, 32
	call	putch@plt
	lui	a0, %hi(probes)
	lw	a0, %lo(probes)(a0)
	call	putint@plt
	li	a0, 10
	call	putch@plt
	li	a0, 0
	ld	ra, 24(sp)                      # 8-byte Folded Reload
	ld	s0, 16(sp)                      # 8-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.type	probes,@object                  # @probes
	.section	.sbss,"aw",@nobits
	.globl	probes
	.p2align	2
probes:
	.word	0                               # 0x0
	.size	probes, 4

	.section	".note.GNU-stack","",@progbits
