.global onBox6

onBox6:
	subi sp, sp, 8
	stw ra, 0(sp)
	stw r8, 4(sp)

	mov r2, r0
	CHECK_XL:
		movi r8, 129
		bgt r4, r8, CHECK_XU
		br AFTER_CLASSIC
	CHECK_XU:
		movi r8, 180
		blt r4, r8, CHECK_YL
		br AFTER_CLASSIC
	CHECK_YL:
		movi r8, 64
		bgt r5, r8, CHECK_YU
		br AFTER_CLASSIC
	CHECK_YU:
		movi r8, 95
		blt r5, r8,MODIFY_RET
		br AFTER_CLASSIC
	MODIFY_RET:
		movi r2, 0x1
		
	AFTER_CLASSIC:
		stw ra, 0(sp)
		stw r8, 4(sp)
		addi sp, sp, 8
ret
