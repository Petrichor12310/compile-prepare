	.text
	.attribute	4, 16
	.attribute	5, "rv64i2p0_m2p0_a2p0_f2p0_d2p0_c2p0"
	.file	"factorial.ll"
	.globl	factorial                       # -- Begin function factorial
	.p2align	1
	.type	factorial,@function
factorial:                              # @factorial
	.cfi_startproc
# %bb.0:                                # %entry
	sext.w	a1, a0
	bltz	a1, .LBB0_2
# %bb.1:                                # %upper
	lui	a0, %hi(limit)
	lw	a0, %lo(limit)(a0)
	bge	a0, a1, .LBB0_3
.LBB0_2:                                # %invalid
	li	a0, -1
	ret
.LBB0_3:                                # %loop.preheader
	li	a0, 1
	li	a2, 2
	blt	a1, a2, .LBB0_5
.LBB0_4:                                # %body
                                        # =>This Inner Loop Header: Depth=1
	mulw	a0, a0, a2
	addiw	a2, a2, 1
	bge	a1, a2, .LBB0_4
.LBB0_5:                                # %done
	ret
.Lfunc_end0:
	.size	factorial, .Lfunc_end0-factorial
	.cfi_endproc
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	1
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	addi	sp, sp, -16
	.cfi_def_cfa_offset 16
	sd	ra, 8(sp)                       # 8-byte Folded Spill
	.cfi_offset ra, -8
	call	getint@plt
	call	factorial@plt
	call	putint@plt
	li	a0, 10
	call	putch@plt
	li	a0, 0
	ld	ra, 8(sp)                       # 8-byte Folded Reload
	addi	sp, sp, 16
	ret
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.type	limit,@object                   # @limit
	.section	.rodata,"a",@progbits
	.globl	limit
	.p2align	2
limit:
	.word	12                              # 0xc
	.size	limit, 4

	.section	".note.GNU-stack","",@progbits
