.global _start
_start:

/*
KEY[0] = Reset
KEY[1] = User
KEY[2] = Robot
Read the sensor values
Read sensor values 0, 1 ad 2 at an interval of each block in the tic tac toe board.
Once you read the value, store it in the robot and user registers.
Divide the range 0-F in three regions. 0-T1 (Black), T1-T2(Blue), T2-F(White) (T1 = 5, T2 = 9)
Set threshold to T2 for all 3 sensors. Read all 3 sensors. For each sensor, if bit = 1, do nothing.
If input is 0 (value<threshold T2)
Reset threshold to T1. If bit = 1, (blue) => set the user register at index = sensor index+3*line index to 1
else set the robot register at same index to 1
After reading all sensors for 
*/  

movia sp, 0x00800000

.equ PUSH_BUTTONS, 0x10000050
.equ LEGO_CONTROLLER, 0x10000060 			#JP1
.equ PERIOD, 0x989680 

.section .exceptions, "ax"

/*-----------------------------------------------------------------------------*/
I_HANDLER:
  /* To handle multiple interrupts, store ea, et and ctl1 */
  subi sp, sp, 12
  stw et, 0(sp)
  rdctl et, ctl1
  stw et, 4(sp)
  stw ea, 8(sp)
  
  rdctl et, ctl4
  andi et, et, 0b10		# check if interrupt pending for KEY[1]
  bne et, r0, HANDLE_PUSH_BUTTON
  
  br EXIT_HANDLER
  
 HANDLE_PUSH_BUTTON:
  /* Handle the push button to restart the game*/
  # Move 5 steps forward
  call move_forward
  call move_forward
  call move_forward
  call move_forward
  call move_forward
   
  # Redraw the board
 DRAW_BOARD:

 EXIT_PUSH_BUTTON_HANDLER:
   movia et, PUSH_BUTTONS
   stwio r0, 0(et)			#clear edge capture register / ack interrupt
   
EXIT_HANDLER:
  ldw ea, 8(sp)
  ldw et, 4(sp)
  wrctl ctl1, et
  ldw et, 0(sp)
  addi sp, sp, 12
  
  subi ea, ea, 4			#we want to get to the intruction that was interrupted
  eret

/*-----------------------------------------------------------------------------*/
.section .text

 subi sp, sp, 16
 stw ra, 0(sp)
 stw r8, 4(sp)
 stw r9, 8(sp)
 stw r4, 12(sp)

/*
#enable interrupts
  movi r9, 0b1
  wrctl ctl0, r9			#pie bit = 1 (enables interrupts)
  

PUSH_BUTTON_CONFIGURATION:
  movia r8, PUSH_BUTTONS
  #Enable interrupt on KEY[1] (reset key)
  movia r9, 0x2
  stwio r9, 8(r8)
  
  #Enable IRQ line 1 for push buttons
  movi r9, 0b10
  wrctl ctl3, r9
  */

  call move_forward
  
  movia r4, PERIOD
  call timer
  
  call move_left
  
  movia r4, PERIOD
  call timer
	


ldw ra, 0(sp)
ldw r8, 4(sp)
ldw r9, 8(sp)
ldw r4, 12(sp)
addi sp, sp, 16


loop:
br loop
