#------------------------------------------------------------------------------------------------------------------------------------#
# draw_moves checks every bit of the human and robot status "words" and calls draw_o and draw_x if a move exists at that bit		 #
# draw_moves is called by the mouse interrupt exit handler																			 #
#------------------------------------------------------------------------------------------------------------------------------------#

.global draw_moves
.include "C:/altera/lego_project/nios_macros.s"

draw_moves:
	subi sp, sp, 16
	stw ra, 0(sp)
	stw r8, 4(sp)
	stw r9, 8(sp)
	stw r10, 12(sp)
	
DRAW_HUMAN_MOVES:
	movia r8, human_status
	ldw r9, 0(r8)
	andi r10, r9, 0x1
	beq r10, r0, CHECK_1
	mov r4, r0
	call draw_o
	CHECK_1:
	srli r9, r9, 0x1
	andi r10, r9, 0x1
	beq r10, r0, CHECK_2
	movi r4, 0x1
	call draw_o
	CHECK_2:
	srli r9, r9, 0x1
	andi r10, r9, 0x1
	beq r10, r0, CHECK_3
	movi r4, 0x2
	call draw_o
	CHECK_3:
	srli r9, r9, 0x1
	andi r10, r9, 0x1
	beq r10, r0, CHECK_4
	movi r4, 0x3
	call draw_o
	CHECK_4:
	srli r9, r9, 0x1
	andi r10, r9, 0x1
	beq r10, r0, CHECK_5
	movi r4, 0x4
	call draw_o
	CHECK_5:
	srli r9, r9, 0x1
	andi r10, r9, 0x1
	beq r10, r0, CHECK_6
	movi r4, 0x5
	call draw_o
	CHECK_6:
	srli r9, r9, 0x1
	andi r10, r9, 0x1
	beq r10, r0, CHECK_7
	movi r4, 0x6
	call draw_o
	CHECK_7:
	srli r9, r9, 0x1
	andi r10, r9, 0x1
	beq r10, r0, CHECK_8
	movi r4, 0x7
	call draw_o
	CHECK_8:
	srli r9, r9, 0x1
	andi r10, r9, 0x1
	beq r10, r0, DRAW_ROBOT_MOVES
	movi r4, 0x8
	call draw_o
DRAW_ROBOT_MOVES:
	movia r8, robot_status
	ldw r9, 0(r8)
	andi r10, r9, 0x1
	beq r10, r0, CHECK_11
	mov r4, r0
	call draw_x
	CHECK_11:
	srli r9, r9, 0x1
	andi r10, r9, 0x1
	beq r10, r0, CHECK_22
	movi r4, 0x1
	call draw_x
	CHECK_22:
	srli r9, r9, 0x1
	andi r10, r9, 0x1
	beq r10, r0, CHECK_33
	movi r4, 0x2
	call draw_x
	CHECK_33:
	srli r9, r9, 0x1
	andi r10, r9, 0x1
	beq r10, r0, CHECK_44
	movi r4, 0x3
	call draw_x
	CHECK_44:
	srli r9, r9, 0x1
	andi r10, r9, 0x1
	beq r10, r0, CHECK_55
	movi r4, 0x4
	call draw_x
	CHECK_55:
	srli r9, r9, 0x1
	andi r10, r9, 0x1
	beq r10, r0, CHECK_66
	movi r4, 0x5
	call draw_x
	CHECK_66:
	srli r9, r9, 0x1
	andi r10, r9, 0x1
	beq r10, r0, CHECK_77
	movi r4, 0x6
	call draw_x
	CHECK_77:
	srli r9, r9, 0x1
	andi r10, r9, 0x1
	beq r10, r0, CHECK_88
	movi r4, 0x7
	call draw_x
	CHECK_88:
	srli r9, r9, 0x1
	andi r10, r9, 0x1
	beq r10, r0, AFTER
	movi r4, 0x8
	call draw_x
AFTER:
	ldw ra, 0(sp)
	ldw r8, 4(sp)
	ldw r9, 8(sp)
	ldw r10, 12(sp)
	addi sp, sp, 16
ret
