.global draw_screen

.equ VGA_ADDR, 0x08000000		# Base address of VGA pixel buffer
.equ X_PIXELS, 320				# Number of x pixels = 320
.equ Y_PIXELS, 240				# Number of y pixels = 240

draw_screen:

	subi sp, sp, 40
	stw ra, 0(sp)
	stw r4, 4(sp)
	stw r8, 8(sp)
	stw r9, 12(sp)
	stw r10, 16(sp)
	stw r11, 20(sp)
	stw r12, 24(sp)
	stw r13, 28(sp)
	stw r14, 32(sp)
	stw r15, 36(sp)

	#r4 --> COLOR_ARRAY
	movia r8, VGA_ADDR
	mov r10, r0 #THIS IS X VALUE
	mov r11, r0 #THIS IS Y VALUE
	
	movia r12, X_PIXELS
	movia r13, Y_PIXELS
	
	
DRAW_PIXEL:
	ldhio r9, 0(r4)
	
	mov r14, r10
	slli r14, r14, 1
	mov r15, r11
	slli r15, r15, 10
	
	add r14, r14, r15
	add r14, r8, r14
	
	sthio r9, 0(r14)
	
	addi r4, r4, 2
	
INCREMENT_X:
	addi r10, r10, 1
	bge r10, r12, INCREMENT_Y
	br DRAW_PIXEL
	
INCREMENT_Y:
	mov r10, r0
	addi r11, r11, 1
	bge r11, r13, AFTER_SCREEN
	br DRAW_PIXEL

	
AFTER_SCREEN: 
	ldw ra, 0(sp)
	ldw r4, 4(sp)
	ldw r8, 8(sp)
	ldw r9, 12(sp)
	ldw r10, 16(sp)
	ldw r11, 20(sp)
	ldw r12, 24(sp)
	ldw r13, 28(sp)
	ldw r14, 32(sp)
	ldw r15, 36(sp)
	addi sp, sp, 40
ret
