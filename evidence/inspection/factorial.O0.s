	.file	"factorial.sy"
	.option pic
	.text
	.globl	limit
	.section	.rodata
	.align	2
	.type	limit, @object
	.size	limit, 4
limit:
	.word	12
	.text
	.align	1
	.globl	factorial
	.type	factorial, @function
factorial:
	addi	sp,sp,-48
	sd	s0,40(sp)
	addi	s0,sp,48
	mv	a5,a0
	sw	a5,-36(s0)
	lw	a5,-36(s0)
	sext.w	a5,a5
	blt	a5,zero,.L2
	li	a4,12
	lw	a5,-36(s0)
	sext.w	a5,a5
	ble	a5,a4,.L3
.L2:
	li	a5,-1
	j	.L4
.L3:
	li	a5,1
	sw	a5,-24(s0)
	li	a5,2
	sw	a5,-20(s0)
	j	.L5
.L6:
	lw	a5,-24(s0)
	mv	a4,a5
	lw	a5,-20(s0)
	mulw	a5,a4,a5
	sw	a5,-24(s0)
	lw	a5,-20(s0)
	addiw	a5,a5,1
	sw	a5,-20(s0)
.L5:
	lw	a5,-20(s0)
	mv	a4,a5
	lw	a5,-36(s0)
	sext.w	a4,a4
	sext.w	a5,a5
	ble	a4,a5,.L6
	lw	a5,-24(s0)
.L4:
	mv	a0,a5
	ld	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	factorial, .-factorial
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sd	ra,24(sp)
	sd	s0,16(sp)
	addi	s0,sp,32
	call	getint@plt
	mv	a5,a0
	sw	a5,-20(s0)
	lw	a5,-20(s0)
	mv	a0,a5
	call	factorial
	mv	a5,a0
	mv	a0,a5
	call	putint@plt
	li	a0,10
	call	putch@plt
	li	a5,0
	mv	a0,a5
	ld	ra,24(sp)
	ld	s0,16(sp)
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
