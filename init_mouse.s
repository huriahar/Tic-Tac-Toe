.global init_mouse

.equ MOUSE_ADDR, 0x10000100

init_mouse:

subi sp, sp, 16
stw ra, 0(sp)
stw r8, 4(sp)
stw r9, 8(sp)
stw r10, 12(sp)

# reset mouse
 movia r8, MOUSE_ADDR
 movi r9, 0xFF
 stwio r9, 0(r8)

#acknowledge and waiting for 0xFA
ACKNOWLEDGE:
 ldwio r9, 0(r8)
 andi r9, r9, 0xFF
 movi r10, 0xFA
 bne r9, r10, ACKNOWLEDGE
 
SELF_TEST:
 ldwio r9, 0(r8)
 andi r9, r9, 0xFF
 movi r10, 0xAA
 bne r9, r10, SELF_TEST
 
MOUSE_ID:
 ldwio r9, 0(r8)
 andi r9, r9, 0xFF
 movi r10, 0x00
 bne r9, r10, MOUSE_ID

 movi r9, 10000
 
DELAY:
 subi r9, r9, 1
 bne r9, r0, DELAY
 
ENABLE:
 movia r8, MOUSE_ADDR
 movi r9, 0xF4
 stwio r9, 0(r8)
 
ACKNOWLEDGE_ENABLE:
 ldwio r9, 0(r8)
 andi r9, r9, 0xFF
 movi r10, 0xFA
 bne r9, r10, ACKNOWLEDGE_ENABLE

ldw ra, 0(sp)
ldw r8, 4(sp)
ldw r9, 8(sp)
ldw r10, 12(sp)
addi sp, sp, 16
 
ret
	