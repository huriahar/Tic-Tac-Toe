.include "C:/altera/lego_project/nios_macros.s"
.global robot_won
.equ RED_LEDS, 0x10000000
.equ GREEN_LEDS, 0x10000010
.equ PERIOD_BLINKING_LEDS, 25000000


robot_won:
# change the screen to the winning screen

subi sp, sp, 16
stw ra, 0(sp)
stw r8, 4(sp)
stw r9, 8(sp)
stw r10, 12(sp)

movi r10, 5

mov r4, r18
call draw_screen

BLINK:

movia r8, RED_LEDS
movia r9, 0b101010101010101010
stwio r9, 0(r8)

movia r4, PERIOD_BLINKING_LEDS
call timer

movia r8, RED_LEDS
movia r9, 0b010101010101010101
stwio r9, 0(r8)

movia r4, PERIOD_BLINKING_LEDS
call timer

subi r10, r10, 0x1
bne r10, r0, BLINK


ldw ra, 0(sp)
ldw r8, 4(sp)
ldw r9, 8(sp)
ldw r10, 12(sp)
addi sp, sp, 16

ret
