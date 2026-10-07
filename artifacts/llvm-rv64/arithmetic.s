	.text
	.attribute	4, 16
	.attribute	5, "rv64i2p0_m2p0_a2p0_f2p0_d2p0_c2p0"
	.file	"arithmetic.ll"
	.globl	emit                            # -- Begin function emit
	.p2align	1
	.type	emit,@function
emit:                                   # @emit
	.cfi_startproc
# %bb.0:                                # %entry
	addi	sp, sp, -16
	.cfi_def_cfa_offset 16
	sd	ra, 8(sp)                       # 8-byte Folded Spill
	.cfi_offset ra, -8
	call	putint@plt
	li	a0, 10
	call	putch@plt
	ld	ra, 8(sp)                       # 8-byte Folded Reload
	addi	sp, sp, 16
	ret
.Lfunc_end0:
	.size	emit, .Lfunc_end0-emit
	.cfi_endproc
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	1
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	addi	sp, sp, -48
	.cfi_def_cfa_offset 48
	sd	ra, 40(sp)                      # 8-byte Folded Spill
	sd	s0, 32(sp)                      # 8-byte Folded Spill
	sd	s1, 24(sp)                      # 8-byte Folded Spill
	sd	s2, 16(sp)                      # 8-byte Folded Spill
	sd	s3, 8(sp)                       # 8-byte Folded Spill
	.cfi_offset ra, -8
	.cfi_offset s0, -16
	.cfi_offset s1, -24
	.cfi_offset s2, -32
	.cfi_offset s3, -40
	call	getint@plt
	mv	s0, a0
	call	getint@plt
	sext.w	s1, a0
	beqz	s1, .LBB1_2
# %bb.1:                                # %calculate
	sext.w	s0, s0
	addw	a0, s0, s1
	call	emit@plt
	subw	a0, s0, s1
	call	emit@plt
	mulw	a0, s0, s1
	call	emit@plt
	divw	a0, s0, s1
	call	emit@plt
	remw	a0, s0, s1
	call	emit@plt
	negw	a0, s0
	call	emit@plt
	mv	a0, s0
	call	emit@plt
	slt	s2, s0, s1
	mv	a0, s2
	call	emit@plt
	slt	s3, s1, s0
	xori	a0, s3, 1
	call	emit@plt
	mv	a0, s3
	call	emit@plt
	xori	a0, s2, 1
	call	emit@plt
	xor	s0, s0, s1
	seqz	a0, s0
	call	emit@plt
	snez	a0, s0
	j	.LBB1_3
.LBB1_2:                                # %invalid
	li	a0, -1
.LBB1_3:                                # %invalid
	call	emit@plt
	li	a0, 0
	ld	ra, 40(sp)                      # 8-byte Folded Reload
	ld	s0, 32(sp)                      # 8-byte Folded Reload
	ld	s1, 24(sp)                      # 8-byte Folded Reload
	ld	s2, 16(sp)                      # 8-byte Folded Reload
	ld	s3, 8(sp)                       # 8-byte Folded Reload
	addi	sp, sp, 48
	ret
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.section	".note.GNU-stack","",@progbits
