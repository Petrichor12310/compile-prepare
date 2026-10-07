	.text
	.attribute	4, 16
	.attribute	5, "rv64i2p0_m2p0_a2p0_f2p0_d2p0_c2p0"
	.file	"array_float.ll"
	.globl	sum                             # -- Begin function sum
	.p2align	1
	.type	sum,@function
sum:                                    # @sum
	.cfi_startproc
# %bb.0:                                # %entry
	li	a2, 0
	fmv.w.x	fa0, zero
	sext.w	a1, a1
	bge	a2, a1, .LBB0_2
.LBB0_1:                                # %body
                                        # =>This Inner Loop Header: Depth=1
	slli	a3, a2, 2
	add	a3, a3, a0
	flw	ft0, 0(a3)
	fadd.s	fa0, fa0, ft0
	addiw	a2, a2, 1
	blt	a2, a1, .LBB0_1
.LBB0_2:                                # %done
	ret
.Lfunc_end0:
	.size	sum, .Lfunc_end0-sum
	.cfi_endproc
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	1
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	addi	sp, sp, -64
	.cfi_def_cfa_offset 64
	sd	ra, 56(sp)                      # 8-byte Folded Spill
	sd	s0, 48(sp)                      # 8-byte Folded Spill
	sd	s1, 40(sp)                      # 8-byte Folded Spill
	fsd	fs0, 32(sp)                     # 8-byte Folded Spill
	.cfi_offset ra, -8
	.cfi_offset s0, -16
	.cfi_offset s1, -24
	.cfi_offset fs0, -32
	lui	a0, 265216
	sw	a0, 28(sp)
	lui	a0, 264704
	sw	a0, 24(sp)
	lui	a0, 264192
	sw	a0, 20(sp)
	lui	a0, 263168
	sw	a0, 16(sp)
	lui	a0, 262144
	sw	a0, 12(sp)
	lui	a0, 260096
	sw	a0, 8(sp)
	addi	s0, sp, 20
	call	getint@plt
	mv	s1, a0
	call	getfloat@plt
	fsw	fa0, 24(sp)
	li	a1, 3
	mv	a0, s0
	call	sum@plt
	fcvt.s.w	ft0, s1
	fadd.s	fs0, fa0, ft0
	fmv.s	fa0, fs0
	call	putfloat@plt
	li	a0, 10
	call	putch@plt
	fcvt.w.s	a0, fs0, rtz
	call	putint@plt
	li	a0, 10
	call	putch@plt
	li	a0, 0
	ld	ra, 56(sp)                      # 8-byte Folded Reload
	ld	s0, 48(sp)                      # 8-byte Folded Reload
	ld	s1, 40(sp)                      # 8-byte Folded Reload
	fld	fs0, 32(sp)                     # 8-byte Folded Reload
	addi	sp, sp, 64
	ret
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.section	".note.GNU-stack","",@progbits
