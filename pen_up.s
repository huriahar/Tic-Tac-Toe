.global pen_up
pen_up:

.equ LEGO_CONTROLLER, 0x10000060		/*Address GPIO JP1*/
.equ PERIOD, 0xDBBA0						/*1 ms*/

subi sp, sp, 16
stw ra, 0(sp)
stw r8, 4(sp)
stw r9, 8(sp)
stw r4, 12(sp)

movia r8, LEGO_CONTROLLER
movia r9, 0x07f557ff		/* set direction for motors and sensors to output and sensor data register to inputs*/
stwio r9, 4(r8)
movia r9, 0xFFFFFFEF		/*turning motor 3 on reverse direction 11111111111111111111111111101111*/
stwio r9, 0(r8)


movia r4, PERIOD
call timer

movia r9, 0xFFFFFFFF		/* turn motor off*/
stwio r9, 0(r8)

#movia r4, PERIOD
#call timer


ldw ra, 0(sp)
ldw r8, 4(sp)
ldw r9, 8(sp)
ldw r4, 12(sp)
addi sp, sp, 16

ret
