# Include nios_macros.s to workaround a bug in the movia pseudo-instruction.
.include "C:/altera/lego_project/nios_macros.s"

.equ VGA_ADDR, 0x08000000		# Base address of VGA pixel buffer
.equ X_PIXELS, 320				# Number of x pixels = 320
.equ Y_PIXELS, 240				# Number of y pixels = 240
.equ PERIOD_PLAY, 250000000		# 5 seconds
.equ PUSH_BUTTONS, 0x10000050
.equ TIMER, 0x10002000
.equ PERIOD, 0x989680 
.equ RED_LEDS, 0x10000000
.equ GREEN_LEDS, 0x10000010
.equ MOUSE_ADDR, 0x10000100


.global _main
.global robot_status
.global human_status
.global robot_wins
.global tie


#-------------------------------------------------------------------------------------------------------
# Global registers usage:
# r16 --- saves the previous color of the pixel
# r17 --- saves the previous cursor address
# r18 --- screen array address
# r19 --- timed (0) or classic (1)
# r20 --- signals whether mode has been selected (1) or not (0)
# r21 --- mouse x position
# r22 --- mouse y posiiton
#-------------------------------------------------------------------------------------------------------
.section .exceptions, "ax"

I_HANDLER:
  /* To handle multiple interrupts, store ea, et and ctl1 */
	subi sp, sp, 40
	stw et, 0(sp)
	rdctl et, ctl1
	stw et, 4(sp)
	stw ea, 8(sp)
	stw r9, 12(sp)
	stw r10, 16(sp)
	stw r11, 20(sp)
	stw r12, 24(sp)
	stw r13, 28(sp)
	stw r14, 32(sp)
	stw r15, 36(sp)
  
	rdctl et, ctl4
	srli et, et, 0x1
	andi et, et, 0x1		# check if interrupt pending for KEY[1]
	bne et, r0, HANDLE_PUSH_BUTTON
  
	rdctl et, ctl4
	andi et, et, 0x1		# check if interrupt pending for timer
	bne et, r0, TIMER_HANDLER
  
	rdctl et, ctl4
	srli et, et, 7
	andi et, et, 0b1		# check if interrupt pending for mouse
	bne et, r0, MOUSE_HANDLER
  
	br EXIT_HANDLER
  
 HANDLE_PUSH_BUTTON:
	movia r18, WELCOME_ARRAY
	mov r4, r18
	call draw_screen
	#reset timer
	movia r8, TIMER
	stwio r0, 0(r8)
	#reset game variables
	movia r8, robot_wins
	stw r0, 0(r8)
	movia r8, tie
	stw r0, 0(r8)
	movia r8, robot_status
	stw r0, 0(r8)
	movia r8, human_status
	stw r0, 0(r8)
	#reset mode selection flag
	mov r20, r0
	#reset the algo's variables
	call reset
	movi r20, 0x4

 EXIT_PUSH_BUTTON_HANDLER:
	movia et, PUSH_BUTTONS
	stwio r0, 12(et)			#clear edge capture register / ack interrupt
	br EXIT_HANDLER
  
 MOUSE_HANDLER:
   # Load the first byte of data packet
	FIRST_BYTE:
		movia et, MOUSE_ADDR
		ldwio r9, 0(et)
		#srli r10, r9, 15
		andi r10, r9, 0x8000
		beq r10, r0, FIRST_BYTE
		srli r10, r9, 3
		andi r10, r10, 0x1
		beq r10, r0, FIRST_BYTE
	   
		andi r11, r9, 0x1		#r11 contains bit 0 --> left button click
		srli r9, r9, 4
		andi r12, r9, 0x1		#r12 contains bit 4 --> X sign bit
		srli r9, r9, 1
		andi r13, r9, 0x1		#r13 contains bit 5 --> Y sign bit
	   
	SECOND_BYTE:
		ldwio r9, 0(et)
		srli r10, r9, 15
		andi r10, r10, 0x1
		beq r10, r0, SECOND_BYTE
		andi r14, r9, 0x00FF	#r14 contains 8 bits ---> delta X

	THIRD_BYTE:
		ldwio r9, 0(et)
		srli r10, r9, 15
		andi r10, r10, 0x1
		beq r10, r0, THIRD_BYTE
		andi r15, r9, 0x00FF	#r15 contains 8 bits ---> delta Y
		
	bne r12, r0, COMPLEMENT_2_X
	BACK:
	bne r13, r0, COMPLEMENT_2_Y
	br AFTER_COMPLEMENTING
	
	COMPLEMENT_2_X:
		xori r14, r14, 0x00FF
		addi r14, r14, 0x1
		br BACK
	COMPLEMENT_2_Y:
		xori r15, r15, 0x00FF
		addi r15, r15, 0x1
	
	AFTER_COMPLEMENTING:	# check the sign bit to update the global mouse position
		bne r12, r0, SUB_X
		add r14, r21, r14
		br CHECK_Y
	SUB_X:
		sub r14, r21, r14
	
	CHECK_Y:
		bne r13, r0, ADD_Y
		sub r15, r22, r15
		br AFTER_UPDATING_POSITION
	ADD_Y:
		add r15, r22, r15
		
	AFTER_UPDATING_POSITION:
	
	blt r14, r0, EXIT_MOUSE_HANDLER
	blt r15, r0, EXIT_MOUSE_HANDLER
	movia r12, X_PIXELS
	bgt r14, r12, EXIT_MOUSE_HANDLER
	movia r12, Y_PIXELS
	bgt r15, r12, EXIT_MOUSE_HANDLER
	
	mov r21, r14		#global x mouse position
	mov r22, r15		#global y mouse position
	
	
	beq r11, r0, EXIT_MOUSE_HANDLER
	
	#left mouse button has been clicked
	
	movia r8, robot_wins
	ldw r9, 0(r8)
	bne r9, r0, EXIT_MOUSE_HANDLER
	
	movia r8, tie
	ldw r9, 0(r8)
	bne r9, r0, EXIT_MOUSE_HANDLER
	
	bne r20, r0, CHECK_MOVE_0
	
	mov r4, r21
	mov r5, r22
	call onTimed_assembly
	
	beq r2, r0, CHECK_ON_CLASSIC
	
	movia r18, BOARD_ARRAY
	mov r19, r0
	mov r4, r18
	call draw_screen
	movi r20, 0x1
	br EXIT_MOUSE_HANDLER
	
	CHECK_ON_CLASSIC:
	call onClassic_assembly
	beq r2, r0, EXIT_MOUSE_HANDLER
	
	movia r18, BOARD_ARRAY_CLASSIC
	movi r19, 0x1
	mov r4, r18
	call draw_screen
	movi r20, 0x1
	
	br EXIT_MOUSE_HANDLER
	
	CHECK_MOVE_0:
		mov r4, r21
		mov r5, r22
		call onBox0
		beq r2, r0, CHECK_MOVE_1
		mov r10, r0
		br DRAW_MOVE
	CHECK_MOVE_1:
		mov r4, r21
		mov r5, r22
		call onBox1
		beq r2, r0, CHECK_MOVE_2
		movi r10, 0x1
		br DRAW_MOVE
	CHECK_MOVE_2:
		mov r4, r21
		mov r5, r22
		call onBox2
		beq r2, r0, CHECK_MOVE_3
		movi r10, 0x2
		br DRAW_MOVE
	CHECK_MOVE_3:
		mov r4, r21
		mov r5, r22
		call onBox3
		beq r2, r0, CHECK_MOVE_4
		movi r10, 0x3
		br DRAW_MOVE
	CHECK_MOVE_4:
		mov r4, r21
		mov r5, r22
		call onBox4
		beq r2, r0, CHECK_MOVE_5
		movi r10, 0x4
		br DRAW_MOVE
	CHECK_MOVE_5:
		mov r4, r21
		mov r5, r22
		call onBox5
		beq r2, r0, CHECK_MOVE_6
		movi r10, 0x5
		br DRAW_MOVE
	CHECK_MOVE_6:
		mov r4, r21
		mov r5, r22
		call onBox6
		beq r2, r0, CHECK_MOVE_7
		movi r10, 0x6
		br DRAW_MOVE
	CHECK_MOVE_7:
		mov r4, r21
		mov r5, r22
		call onBox7
		beq r2, r0, CHECK_MOVE_8
		movi r10, 0x7
		br DRAW_MOVE
	CHECK_MOVE_8:
		mov r4, r21
		mov r5, r22
		call onBox8
		beq r2, r0, EXIT_MOUSE_HANDLER
		movi r10, 0x8
		br DRAW_MOVE
	DRAW_MOVE:
		#updating the status register
		movia r8, robot_status
		ldw r9, 0(r8)
		
		movi r11, 0x1
		sll r11, r11, r10
		and r14, r9, r11
		
		bne r14, r0, EXIT_MOUSE_HANDLER
		
		movia r8, human_status
		ldw r9, 0(r8)
		and r14, r9, r11
		bne r14, r0, EXIT_MOUSE_HANDLER
		
		or r9, r9, r11
		stw r9, 0(r8)
		ori r20, r20, 0x2

	EXIT_MOUSE_HANDLER:	
		mov r4, r18
		
		#----drawing the mouse cursor----#
		movia et, VGA_ADDR

		#redraw the old pixel
		sthio r16, 0(r17)		#draw the pixel that existed before at the previous cursor address
		
		srli r9, r20, 0x2
		bne r9, r0, AFTER_DRAW_MOVES
		
		movia r8, WELCOME_ARRAY
		beq r18, r8, AFTER_DRAW_MOVES
		call draw_moves
		
		AFTER_DRAW_MOVES:
		beq r9, r0, DRAW_PIXEL
		subi r20, r20, 0x4
		DRAW_PIXEL:
		#draw the cursor pixel
		movui r9, 0xffff
		
		mov r14, r21
		slli r14, r14, 1
		mov r15, r22
		slli r15, r15, 10
		
		add r14, r14, r15
		add r14, et, r14
		
		sthio r9, 0(r14)
		
		#update the position of the 'previous' pixel
		mov r17, r14
		
		#update the previous color of the pixel at the previous mouse cursor position
		mov r15, r22		# r15 = y
		mov r16, r22		# r16 = y
		slli r15, r15, 8	# multiplying by 2^8 = 256 ---> r15 = 256*y
		slli r16, r16, 6	# multiplying by 2^6 = 64  ---> r16 = 64*y
		add r16, r15, r16	# r16 = 320*y
		add r16, r16, r21	# r16 = x+ 320*y
		slli r16, r16, 1	# r16 *= 2
		add r15, r16, r18	# r16 = screen address + offset
		ldh r16, 0(r15)		# content of the pixel value at center
br EXIT_HANDLER


 TIMER_HANDLER:
	movia r18, I_WIN_ARRAY
	movia et, robot_wins
	movi r9, 0x1
	stw r9, 0(et)
	call robot_won
	#Restting all variables-----------------
	#reset timer
	movia et, TIMER
	stwio r0, 0(et)
	movia et, robot_status
	stw r0, 0(et)
	movia et, human_status
	stw r0, 0(et)
	#reset mode selection flag
	mov r20, r0
	#reset the algo's variables
	call reset
	movia et, RED_LEDS
	stwio r0, 0(et)	

 EXIT_TIMER_HANDLER:
	movia et, TIMER
	stwio r0, 0(et)			#clear timer / ack interrupt
	br EXIT_HANDLER
  
   
EXIT_HANDLER:
  ldw et, 0(sp)
  rdctl et, ctl1
  ldw et, 4(sp)
  ldw ea, 8(sp)
  ldw r9, 12(sp)
  ldw r10, 16(sp)
  ldw r11, 20(sp)
  ldw r12, 24(sp)
  ldw r13, 28(sp)
  ldw r14, 32(sp)
  ldw r15, 36(sp)
  addi sp, sp, 40
  
  subi ea, ea, 4			#we want to get to the intruction that was interrupted
eret


#------------------------------------------------------------------------------------------

.section .data                  # "data" section for input and output lists

.align 2

robot_status: .space 4
robot_wins: .space 4
human_status: .space 4
tie: .space 4

.include "C:/altera/lego_project/welcome.s"
.include "C:/altera/lego_project/board.s"
.include "C:/altera/lego_project/board_classic.s"
.include "C:/altera/lego_project/i_win.s"

#------------------------------------------------------------------------------------------

.section .text                  

_main:
	movia sp, 0x800000	# Initializing stack pointer
	call init_mouse

	movia r8, robot_status
	movia r8, human_status
	
WELCOME_SCREEN:
	movia r4, WELCOME_ARRAY
	call draw_screen
	
	movia r8, VGA_ADDR
	movi r21, 160
	movi r22, 120
	
	#initialize r18 to the welcome screen
	movia r18, WELCOME_ARRAY
	
	#initialize r17 to the address of the center pixel
	mov r14, r21
	slli r14, r14, 1
	mov r15, r22
	slli r15, r15, 10
	add r14, r14, r15
	add r14, r8, r14
	mov r17, r14
	
	#initialize r16 to the color of the pixel at r17 (center pixel address)
	mov r15, r22		# r15 = y
	mov r16, r22		# r16 = y
	slli r15, r15, 8	# multiplying by 2^8 = 256 ---> r15 = 256*y
	slli r16, r16, 6	# multiplying by 2^6 = 64  ---> r16 = 64*y
	add r16, r15, r16	# r16 = 320*y
	add r16, r16, r21	# r16 = x+ 320*y
	slli r16, r16, 1	# r16 *= 2
	add r15, r16, r18	# r16 = screen_address + offset
	ldh r16, 0(r15)		# content of the pixel value at center
	
	#initialize r20 to 0 (r20 signals whether the mode has been selected)
	mov r20, r0
	
	#reset game variables
	movia r8, robot_wins
	stw r0, 0(r8)
	movia r8, tie
	stw r0, 0(r8)
	movia r8, robot_status
	stw r0, 0(r8)
	movia r8, human_status
	stw r0, 0(r8)
	
	call reset
ENABLE_INTERRUPTS:
  movi r9, 0b1
  wrctl ctl0, r9			#pie bit = 1 (enables interrupts)
  
PUSH_BUTTON_CONFIGURATION:
  movia r8, PUSH_BUTTONS
  
  #Enable interrupt on KEY[1] (reset key)
  movi r9, 0x2
  stwio r9, 8(r8)
  
MOUSE_CONFIGURATION:
	movia r8, MOUSE_ADDR
	movi r9, 0x1
	stwio r9, 4(r8)   # Enable read interrupts on the mouse
	
	#Enable IRQ line 7 for mouse and line 1 for push buttons and 0 for timer
    movi r9, 0b10000011
    wrctl ctl3, r9
	
WAIT_FOR_MODE_SELECTION:
	srli r9, r20, 0x2
	bne r9, r0, HANDLE_RESET
	andi r9, r20, 0x1
	bne r9, r0, AFTER_MODE_SELECTION
	br WAIT_FOR_MODE_SELECTION
	
AFTER_MODE_SELECTION:
	
movia r8, RED_LEDS
movi r9, 0x1
stwio r9, 0(r8)


GAME_ON:
	srli r9, r20, 0x2
	bne r9, r0, HANDLE_RESET
	call robot_first

	bne r19, r0, WAIT_FOR_PLAYER_MOVE
	
	movia r4, PERIOD_PLAY
	call timer_interrupt
	call display_time_hex
	
	WAIT_FOR_PLAYER_MOVE:
		srli r9, r20, 0x2
		bne r9, r0, HANDLE_RESET
		srli r9, r20, 0x1
		bne r9, r0, AFTER_PLAYER_MOVE
		
		movia r8, robot_wins
		ldw r9, 0(r8)
		bne r9, r0, AFTER_GAME
		
		movia r8, tie
		ldw r9, 0(r8)
		bne r9, r0, AFTER_GAME
	br WAIT_FOR_PLAYER_MOVE:

	AFTER_PLAYER_MOVE:
	subi r20, r20, 0x2

br GAME_ON

AFTER_GAME:
	srli r9, r20, 0x2
	bne r9, r0, HANDLE_RESET
	br AFTER_GAME
HANDLE_RESET:
	subi r20, r20, 0x4
	br WAIT_FOR_MODE_SELECTION
	
ret
