# restart interrupt > i'm done interrupt > timer interrupt
.equ TIMER, 0x10002000
.equ PUSH_BUTTONS, 0x10000050
.equ PERIOD, 0x08F0D180  # 30s delay (30*50,000,000)

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
  andi et, et, 0x2		# check if interrupt pending for KEY[1]
  bne et, r0, HANDLE_PUSH_BUTTON
  
  
  
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
# timer needs to be configured only in timed mode and needs to be stopped as soon as the user presses done key
#enable interrupts
  movi r9, 0b1
  wrctl ctl0, r9			#pie bit = 1 (enables interrupts)
/*
TIMER_CONFIGURATION:
  movia r8, TIMER
  #configure device
  movui r9, %lo(PERIOD)
  stwio r9, 8(r8)		#lower hword of the period
  
  movui r9, %hi(PERIOD)
  stwio r9, 12(r8)		# upper hword of the period
  
  stwio r0, 0(r8)		# reset the timer
  
  movi r9, 0b101		#start timer, don't continue after time out, enable interrupts
  stwio r9, 4(r8)
  
  #enable IRQ line 0
  movi r9, 0b1			#IRQ0 for timer
  wrctl ctl3, r9
  #enable interrupts
  movi r9, 0b1
  wrctl ctl0, r9			#pie bit = 1 (enables interrupts)
*/

PUSH_BUTTON_CONFIGURATION:
  movia r8, PUSH_BUTTONS
  #Enable interrupt on KEY[1] (reset key)
  movia r9, 0xA
  stwio r9, 8(r8)
  
  #Enable IRQ line 1 for push buttons
  mov r9, 0x1
  wrctl ctl3, r9
  

  
  
  
 
