.include "C:/altera/lego_project/nios_macros.s"
.global timer_interrupt
timer_interrupt:

.equ TIMER, 0x10002000				/* Define Constants */

subi sp, sp, 16
stw ra, 0(sp)
stw r4, 4(sp)
stw r9, 8(sp)
stw r16, 12(sp)

/* Configure Timer */

movia r16, TIMER

andi r9, r4, 0x0000ffff
stwio r9, 8(r16)			#lower hword of the period

andi r9, r4, 0xffff0000
srli r9, r9, 16
stwio r9, 12(r16)			#lower hword of the period

stwio r0, 0(r16)			#reset the timer
movi r9, 0b101        		#0101, don't want to restart timer after timeout
stwio r9, 4(r16)			#start the timer

ldw ra, 0(sp)
ldw r4, 4(sp)
ldw r9, 8(sp)
ldw r16, 12(sp)
addi sp, sp, 16

ret

