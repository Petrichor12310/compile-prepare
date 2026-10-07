	.file	"factorial.sy"
	.option pic
	.text
	.align	1
	.globl	factorial
	.type	factorial, @function
factorial:
	li	a5,12
	sext.w	a4,a0
	bgtu	a0,a5,.L4
	li	a5,1
	ble	a0,a5,.L5
	addiw	a4,a4,1
	li	a5,2
	li	a0,1
.L3:
	mulw	a0,a5,a0
	addiw	a5,a5,1
	bne	a4,a5,.L3
	ret
.L5:
	li	a0,1
	ret
.L4:
	li	a0,-1
	ret
	.size	factorial, .-factorial
	.section	.text.startup,"ax",@progbits
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16
	sd	ra,8(sp)
	call	getint@plt
	sext.w	a4,a0
	li	a5,12
	bgtu	a4,a5,.L11
	li	a5,1
	ble	a0,a5,.L12
	addiw	a4,a4,1
	li	a5,2
	li	a0,1
.L10:
	mulw	a0,a0,a5
	addiw	a5,a5,1
	bne	a4,a5,.L10
.L9:
	call	putint@plt
	li	a0,10
	call	putch@plt
	ld	ra,8(sp)
	li	a0,0
	addi	sp,sp,16
	jr	ra
.L12:
	li	a0,1
	j	.L9
.L11:
	li	a0,-1
	j	.L9
	.size	main, .-main
	.globl	limit
	.section	.rodata
	.align	2
	.type	limit, @object
	.size	limit, 4
limit:
	.word	12
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
