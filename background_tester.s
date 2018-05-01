# Include nios_macros.s to workaround a bug in the movia pseudo-instruction.
.include "nios_macros.s"

.equ ADDR_VGA, 0x08000000		# Base address of VGA pixel buffer
.equ X_PIXELS, 320				# Number of x pixels = 320
.equ Y_PIXELS, 240				# Number of y pixels = 240

.data                  # "data" section for input and output lists

.align 2

.include "image.s"
#-----------------------------------------

.text                  

.global main
main:
	movia r22, COLOR_ARRAY
	movia sp, 0x800000	# Initializing stack pointer
	
	mov r16, r0 #THIS IS X VALUE
	mov r17, r0 #THIS IS Y VALUE
	
INCREMENT_Y:
	movi r18, Y_PIXELS
	bge r17, r18, CHILL
	br INCREMENT_X
INCREMENT:
	mov r16, r0
	addi r17, r17, 1
	br INCREMENT_Y
	
INCREMENT_X:	
	movi r18, X_PIXELS
	bge r16, r18, INCREMENT
	
	mov r4, r16
	mov r5, r17
	call GET_PIXEL_ADDRESS
	mov r21, r2
	
	ldh r3, 0(r22)
	
	sthio r3, 0(r21)
	
	addi r16, r16, 1
	addi r22, r22, 2
	br INCREMENT_X
	
CHILL:
	br CHILL
	
GET_PIXEL_ADDRESS:
	movia r7, VGA_ADDR
	
	add r4, r4, r4		# x = x*2
	
	slli r5, r5, 10			# y = y*(2^10 = 1024)

	add r5, r4, r5		# x*2 + y*1024
	add r2, r5, r7		# (x*2 + y*1024) + VGA_ADDR
	
	ret
	