	.file	"main.c"
	.option pic
	.text
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
	call	factorial_ref@plt
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
