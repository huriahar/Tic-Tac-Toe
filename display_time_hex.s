.global display_time_hex

.equ HEX_ADDR, 0x10000020
.equ DISPLAY_HEX_TIME, 15000000
display_time_hex:

subi sp, sp, 16
stw ra, 0(sp)
stw r8, 4(sp)
stw r9, 8(sp)
stw r10, 12(sp)

DISPLAY_4:
	movi r9, 0b1100110
	movia r8, HEX_ADDR
	stwio r9, 0(r8)
	
movia r10, DISPLAY_HEX_TIME

LOOP4:
	subi r10, r10, 0x1
	bne r10, r0, LOOP4

srli r9, r20, 0x2				#user pressed reset
bne r9, r0, AFTER
srli r9, r20, 0x1
bne r9, r0, AFTER				#user played a move
	
DISPLAY_3:
	movi r9, 0b1001111
	movia r8, HEX_ADDR	
	stwio r9, 0(r8)
	
movia r10, DISPLAY_HEX_TIME
LOOP3:
	subi r10, r10, 0x1
	bne r10, r0, LOOP3

srli r9, r20, 0x2				#user pressed reset
bne r9, r0, AFTER
srli r9, r20, 0x1
bne r9, r0, AFTER				#user played a move

DISPLAY_2:
	movi r9, 0b1011011
	movia r8, HEX_ADDR
	stwio r9, 0(r8)
	
movia r10, DISPLAY_HEX_TIME
LOOP2:
	subi r10, r10, 0x1
	bne r10, r0, LOOP2

srli r9, r20, 0x2				#user pressed reset
bne r9, r0, AFTER
srli r9, r20, 0x1
bne r9, r0, AFTER				#user played a move
	
DISPLAY_1:
	movi r9, 0b0000110
	movia r8, HEX_ADDR
	stwio r9, 0(r8)
	
movia r10, DISPLAY_HEX_TIME

LOOP1:
	subi r10, r10, 0x1
	bne r10, r0, LOOP1
	
srli r9, r20, 0x2				#user pressed reset
bne r9, r0, AFTER
srli r9, r20, 0x1
bne r9, r0, AFTER				#user played a move

DISPLAY_0:
	movi r9, 0b0111111
	movia r8, HEX_ADDR
	stwio r9, 0(r8)
	
AFTER:
ldw ra, 0(sp)
ldw r8, 4(sp)
ldw r9, 8(sp)
ldw r10, 12(sp)
addi sp, sp, 16
	
ret

	
	
	

	
