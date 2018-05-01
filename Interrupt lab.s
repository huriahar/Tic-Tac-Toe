 .include "nios_macros.s"
 
  .equ TIMER, 0x10002000
  .equ PERIOD, 50000000
  .equ JTAG_TERMINAL, 0x10001000
  .equ JTAG_UART, 0x10001020
  .equ GREEN_LEDS, 0x10000010
  .equ RED_LEDS, 0x10000000
 .section .exceptions, "ax"
 
 
 I_HANDLER:
   subi sp, sp, 28 #save ea, et, ctl1
   stw et, 0(sp)	#save et
   rdctl et, ctl1
   stw et, 4(sp)	#save ctl1
   stw ea, 8(sp)	#save ea
   stw r9, 12(sp)
   stw r10, 16(sp)
   stw r11, 20(sp)
   stw r12, 24(sp)  

   /* decide what is calling the interrupt handler*/
   
   rdctl et, ctl4
   andi et, et, 0x100		 #check for pending interrupts from IRQ8 (JTAG UART)
   movia r20, GREEN_LEDS	#-------------debugging-----------#
   stwio et, 0(r20)
   bne et, r0, JTAG_HANDLER	 #JTAG has higher priority
   
   
   rdctl et, ctl4
   andi et, et, 0x1			 #check for pending interrupts from IRQ0 (timer)
   movia r20, RED_LEDS	#-------------debugging-----------#
   stwio et, 0(r20)
   bne et, r0, TIMER_HANDLER #timer has lower priority   
   
   
   br EXIT_HANDLER

   
###################################################################################################################

 JTAG_HANDLER:
   
 #CHECK_VALIDITY---------------------------------------------------------------------------------------------

   movia r9, JTAG_TERMINAL
   ldwio r10, 0(r9)			#read the data from the terminal to get the character that the user pressed
   andi r11, r10, 0x8000
   beq r11, r0, EXIT_JTAG_HANDLER

   andi r11, r10, 0x00FF	#mask other bits
   movi r12, 0x72			#ascii of r
   movia r20, GREEN_LEDS	#-------------debugging-----------#
   stwio r11, 0(r20)
   beq r11, r12, WRITE_SENSOR
   
   
   movi r12, 0x73			#ascii of s
   beq r11, r12, WRITE_SPEED
   
   br EXIT_JTAG_HANDLER

   #-----------------------------------------------------------------------------------------------------
   
   WRITE_SENSOR:
   #sensor data stored in r13

    mov r15, r0                     /* Sensor value is currently being displayed*/
    /* Clearing the line <ESC>[2K */
  WRITE_SENSOR_1:

    ldwio r10, 4(r9)               /* Load from the JTAG */
    srli  r10, r10, 16              /* check that the FIFO is not full (check bits from 31:16) */
    beq   r10, r0, WRITE_SENSOR_1    /* If all bits 31:16 0 (branch true), data cannot be sent */
    movi r11, 0x1B                # ESC
    stwio r11, 0(r9)

  WRITE_SENSOR_2:

    ldwio r10, 4(r9)               /* Load from the JTAG */
    srli  r10, r10, 16              /* check that the FIFO is not full (check bits from 31:16) */
    beq   r10, r0, WRITE_SENSOR_2    /* If all bits 31:16 0 (branch true), data cannot be sent */
    movi r11, 0x5B                # [
    stwio r11, 0(r9)

  WRITE_SENSOR_3:

    ldwio r10, 4(r9)               /* Load from the JTAG */
    srli  r10, r10, 16              /* check that the FIFO is not full (check bits from 31:16) */
    beq   r10, r0, WRITE_SENSOR_3    /* If all bits 31:16 0 (branch true), data cannot be sent */
    movi r11, 0x32                # 2
    stwio r11, 0(r9)


  WRITE_SENSOR_4:

    ldwio r10, 4(r9)               /* Load from the JTAG */
    srli  r10, r10, 16              /* check that the FIFO is not full (check bits from 31:16) */
    beq   r10, r0, WRITE_SENSOR_4    /* If all bits 31:16 0 (branch true), data cannot be sent */
    movi r11, 0x4A                # K
    stwio r11, 0(r9)

   WRITE_SENSOR_VALUE:

    ldwio r10, 4(r9)               /* Load from the JTAG */
    srli  r10, r10, 16              /* check that the FIFO is not full (check bits from 31:16) */
    beq   r10, r0, WRITE_SENSOR_VALUE    /* If all bits 31:16 0 (branch true), data cannot be sent */
    stwio r13, 0(r9)                #the value of the sensor in r13
	stwio r14, 0(r9)
    br EXIT_JTAG_HANDLER

#-----------------------------------------------------------------------------------------------------------------#
      
   WRITE_SPEED:
   #speed data stored in r16, and r17

    movi r15, 1                     /* Speed value is currently being displayed*/
    /* Clearing the line <ESC>[2K */

  WRITE_SPEED_1:
    ldwio r10, 4(r9)               /* Load from the JTAG */
    srli  r10, r10, 16              /* check that the FIFO is not full (check bits from 31:16) */
    beq   r10, r0, WRITE_SPEED_1    /* If all bits 31:16 0 (branch true), data cannot be sent */
    movi r11, 0x1B                # ESC
    stwio r11, 0(r9)

  WRITE_SPEED_2:

    ldwio r10, 4(r9)               /* Load from the JTAG */
    srli  r10, r10, 16              /* check that the FIFO is not full (check bits from 31:16) */
    beq   r10, r0, WRITE_SPEED_2    /* If all bits 31:16 0 (branch true), data cannot be sent */
    movi r11, 0x5B                # [
    stwio r11, 0(r9)

  WRITE_SPEED_3:

    ldwio r10, 4(r9)               /* Load from the JTAG */
    srli  r10, r10, 16              /* check that the FIFO is not full (check bits from 31:16) */
    beq   r10, r0, WRITE_SPEED_3    /* If all bits 31:16 0 (branch true), data cannot be sent */
    movi r11, 0x32                # 2
    stwio r11, 0(r9)


  WRITE_SPEED_4:

    ldwio r10, 4(r9)               /* Load from the JTAG */
    srli  r10, r10, 16              /* check that the FIFO is not full (check bits from 31:16) */
    beq   r10, r0, WRITE_SPEED_4    /* If all bits 31:16 0 (branch true), data cannot be sent */
    movi r11, 0x4A                # J
    stwio r11, 0(r9)

   WRITE_SPEED_VALUE:

    ldwio r10, 4(r9)               /* Load from the JTAG */
    srli  r10, r10, 16              /* check that the FIFO is not full (check bits from 31:16) */
    beq   r10, r0, WRITE_SENSOR_VALUE    /* If all bits 31:16 0 (branch true), data cannot be sent */
    stwio r16, 0(r9)                #the value of the speed in r16 and
	stwio r17, 0(r9)                #the value of the speed in r17
	
#-------------------------------------------------------------------------------------------------------------------
   EXIT_JTAG_HANDLER:
   #NO NEED TO ACKNOWLEDGE THE JTAG HANDLER... ACK IS DONE JUST BY READING

   br EXIT_HANDLER

#####################################################################################################################
   
 TIMER_HANDLER:
    #movi et, 0x1				# re-enable interrupts
    #wrctl ctl0, et
   /* Clear line first!! */
   CLEAR_SCREEN_1:
    ldwio r10, 4(r9)               /* Load from the JTAG */
    srli  r10, r10, 16              /* check that the FIFO is not full (check bits from 31:16) */
    beq   r10, r0, CLEAR_SCREEN_1    /* If all bits 31:16 0 (branch true), data cannot be sent */
    movi r11, 0x1B                # ESC
    stwio r11, 0(r9)

  CLEAR_SCREEN_2:

    ldwio r10, 4(r9)               /* Load from the JTAG */
    srli  r10, r10, 16              /* check that the FIFO is not full (check bits from 31:16) */
    beq   r10, r0, CLEAR_SCREEN_2    /* If all bits 31:16 0 (branch true), data cannot be sent */
    movi r11, 0x5B                # [
    stwio r11, 0(r9)

  CLEAR_SCREEN_3:

    ldwio r10, 4(r9)               /* Load from the JTAG */
    srli  r10, r10, 16              /* check that the FIFO is not full (check bits from 31:16) */
    beq   r10, r0, CLEAR_SCREEN_3    /* If all bits 31:16 0 (branch true), data cannot be sent */
    movi r11, 0x32                # 2
    stwio r11, 0(r9)


  CLEAR_SCREEN_4:

    ldwio r10, 4(r9)               /* Load from the JTAG */
    srli  r10, r10, 16              /* check that the FIFO is not full (check bits from 31:16) */
    beq   r10, r0, CLEAR_SCREEN_4    /* If all bits 31:16 0 (branch true), data cannot be sent */
    movi r11, 0x4A                # J
    stwio r11, 0(r9)

    beq r15, r0, TIMER_SENSOR_DISPLAY
    
  TIMER_SPEED_DISPLAY:

    ldwio r10, 4(r9)               /* Load from the JTAG */
    srli  r10, r10, 16              /* check that the FIFO is not full (check bits from 31:16) */
    beq   r10, r0, TIMER_SPEED_DISPLAY    /* If all bits 31:16 0 (branch true), data cannot be sent */
    stwio r16, 0(r9)                #the value of the speed in r16
	stwio r17, 0(r9)                #the value of the speed in r17
    br ACK_TIMER

  TIMER_SENSOR_DISPLAY:

    ldwio r10, 4(r9)               /* Load from the JTAG */
    srli  r10, r10, 16              /* check that the FIFO is not full (check bits from 31:16) */
    beq   r10, r0, TIMER_SENSOR_DISPLAY    /* If all bits 31:16 0 (branch true), data cannot be sent */
    stwio r13, 0(r9)                #the value of the sensor in r13
	stwio r14, 0(r9)                #the value of the sensor in r14
	
	
  ACK_TIMER:

   movia et, TIMER
   stwio r0, 0(et)			#clear timer / ack interrupt
 
   br EXIT_HANDLER
  
 
 EXIT_HANDLER: 
  ldw r12, 24(sp)
  ldw r11, 20(sp)
  ldw r10, 16(sp)
  ldw r9, 12(sp)
  ldw ea, 8(sp)
  ldw et, 4(sp)
  wrctl ctl1, et
  ldw et, 0(sp)
  addi sp, sp, 28
  subi ea, ea, 4			#we want to get to the intruction that was interrupted
  eret

/* ---------------------------------------------------------------------------------------------------------------------------------------------- */


 .text
 .global _start
 
 _start:



movia r8, 0x10001020							/* r8 has the base address of JTAG UART */

movi r15, 0x1										#display speed initially

TIMER_CONFIGURATION:
  movia r9, TIMER
  #configure device
  movui r10, %lo(PERIOD)
  stwio r10, 8(r9)
  
  movui r10, %hi(PERIOD)
  stwio r10, 12(r9)
  
  stwio r0, 0(r9)
  
  movi r10, 0b111								#start timer, continue after time out, enable interrupts
  stwio r10, 4(r9)
  
  #enable IRQ line 0
  movi r10, 0b1									#IRQ0 for timer
  wrctl ctl3, r10
  #enable external interrupts
  movi r10, 0b1
  wrctl ctl0, r10								#pie bit = 1 (enables interrupts)

JTAG_TERMINAL_CONFIGURATION:
  movia r9, JTAG_TERMINAL
  #enable IRQ line 8
  ori r10, r10, 0x101								#IRQ8 for JTAG TERMINAL
  wrctl ctl3, r10
  
  movi r10, 0x1
  stwio r10, 4(r9)								#enable read interrupts for JTAG_TERMINAL

  
POLLING_W:
  ldwio r3, 4(r8)								/* Load from the JTAG */
  srli  r3, r3, 16								/* check that the FIFO is not full (check bits from 31:16) */
  beq   r3, r0, POLLING_W						/* If all bits 31:16 0 (branch true), data cannot be sent */
  movi r2, 0x02									/* writing 2 to JTAG so as to read the sensor data and speed*/
  stwio r2, 0(r8)								/* Write the byte to the JTAG */


POLLING_R:
  ldwio r2, 0(r8)								/* Load from the JTAG */
  andi  r3, r2, 0x8000							/* Mask other bits but bit 15 (which indicates if read data is valid)*/
  beq   r3, r0, POLLING_R						/* If bit 15 is 0, data is not valid */
  andi  r3, r2, 0x00FF							/* First byte sent by UART */
  bne r3, r0, POLLING_R							/* If not 0, keep looping */
  

  
  
  
READ_SENSOR_DATA:

  ldwio r2, 0(r8)								/* Load from the JTAG */
  andi  r3, r2, 0x8000							/* Mask other bits but bit 15 (which indicates if read data is valid)*/
  beq   r3, r0, READ_SENSOR_DATA				/* If bit 15 is 0, data is not valid */
  andi  r3, r2, 0x00FF							/* Second byte sent by UART */
  
  br INIT_ANGLE
 


 
READ_SPEED:
  ldwio r2, 0(r8)								/* Load from the JTAG */
  andi  r5, r2, 0x8000							/* Mask other bits but bit 15 (which indicates if read data is valid) */
  beq   r5, r0, READ_SPEED						/* If bit 15 is 0, data is not valid */
  andi  r5, r2, 0x00FF							/* Third byte sent by UART */
  andi r16, r5, 0xF0							# second hex digit
  andi r17, r5, 0x0F							# first hex digit
  srli r16, r16, 4
  
  movi r18, 10
  
  bge r16, r18, ALPHA_NUM_1
  addi r16, r16, 0x30							# first speed digit is a number between 0 and 9
  br SECOND_DIGIT
  
  ALPHA_NUM_1:
  addi r16, r16, 0x37
  
  SECOND_DIGIT:
  bge r17, r18, ALPHA_NUM_2
  addi r17, r17, 0x30							# first speed digit is a number between 0 and 9
  br AFTER
  
  ALPHA_NUM_2:
  addi r17, r17, 0x37
  
  AFTER:
  movi  r4, 45po  								/* set speed  saved in r4 to 30 */
  blt   r5, r4, ACCELERATE						/* if current speed is less than desired speed, accelerate */
  bgt   r5, r4, DECELERATE						/* if current speed is greater than desired speed, decelerate */
  br POLLING_W
  
  
  
  
  
INIT_ANGLE:
  ldwio r6, 4(r8)								/* Load from the JTAG */
  srli  r6, r6, 16								/* check that the FIFO is not full (check bits from 31:16) */
  beq   r6, r0, INIT_ANGLE						/* If all bits 31:16 are 0, data cannot be sent */
  movi r2, 0x5            						/* writing 2 to JTAG */
  stwio r2, 0(r8)          						/* Write the byte to the JTAG */

  
  
  
SEND_ANGLE:

  ldwio r6, 4(r8)								/* Load from JTAG*/
  srli r6, r6, 16								/* check that the FIFO is not full (check bits from 31:16) */
  beq r6, r0, SEND_ANGLE						/* If all bits 31:16 are 0, data cannot be sent */

  movi r2,0x1f									/* all sensors are on the road*/
  beq r3,r2,STEER_STRAIGHT
  movi r2,0x1e									/* left most sensor off the road*/
  beq r3,r2,STEER_RIGHT
  movi r2,0x1c									/* two left sensors off the road*/
  beq r3,r2,STEER_HARDRIGHT
  movi r2,0x0f									/* the right most sensor off the road*/
  beq r3,r2,STEER_LEFT
  movi r2,0x07									/* the two right sensors off the road*/
  beq r3,r2,STEER_HARDLEFT
  br POLLING_W

POLL_POSITION:
  ldwio r3, 4(r8)								/* Load from the JTAG */
  srli  r3, r3, 16								/* check that the FIFO is not full (check bits from 31:16) */
  beq   r3, r0, POLL_POSITION					/* If all bits 31:16 0 (branch true), data cannot be sent */
  movi r7, 0x03									/* writing 3 to JTAG so as to read the position data and speed*/
  stwio r7, 0(r8)								/* Write the byte to the JTAG */
	
	
STEER_STRAIGHT:
  ldwio r6, 4(r8)								/* Load from the JTAG */
  srli  r6, r6, 16								/* check that the FIFO is not full (check bits from 31:16) */
  beq   r6, r0, STEER_STRAIGHT					/* If all bits 31:16 are 0, data cannot be sent */
  movi r13, 0x31								# 1
  movi r14, 0x46								# F
  movi r2, 0
  stwio r2, 0(r8)								/* Write the byte to the JTAG */
  br READ_SPEED  
  
  
  
  
STEER_RIGHT:
  ldwio r6, 4(r8)          						/* Load from the JTAG */
  srli  r6, r6, 16         						/* check that the FIFO is not full (check bits from 31:16) */
  beq   r6, r0, STEER_RIGHT 					/* If all bits 31:16 are 0, data cannot be sent */
  movi r13, 0x31								# 1
  movi r14, 0x45								# E
  movi r2, 100
  stwio r2, 0(r8)          						/* Write the byte to the JTAG */
  br READ_SPEED

  
  
  
STEER_HARDRIGHT:
  ldwio r6, 4(r8)          						/* Load from the JTAG */
  srli  r6, r6, 16         						/* check that the FIFO is not full (check bits from 31:16) */
  beq   r6, r0, STEER_HARDRIGHT 				/* If all bits 31:16 are 0, data cannot be sent */
  movi r13, 0x31								# 1
  movi r14, 0x43								# C
  movi r2, 127
  stwio r2, 0(r8)          						/* Write the byte to the JTAG */
  br READ_SPEED
  
  
  
  
STEER_LEFT:

  ldwio r6, 4(r8)          						/* Load from the JTAG */
  srli  r6, r6, 16         						/* check that the FIFO is not full (check bits from 31:16) */
  beq   r6, r0, STEER_LEFT 						/* If all bits 31:16 are 0, data cannot be sent */
  movi r13, 0x30								# 0
  movi r14, 0x46								# F
  movi r2, -100
  stwio r2, 0(r8)          						/* Write the byte to the JTAG */
  br READ_SPEED

  
  
  
  
STEER_HARDLEFT:

  ldwio r6, 4(r8)          						/* Load from the JTAG */
  srli  r6, r6, 16         						/* check that the FIFO is not full (check bits from 31:16) */
  beq   r6, r0, STEER_HARDLEFT 					/* If all bits 31:16 are 0, data cannot be sent */
  movi r13, 0x30								# 0
  movi r14, 0x37								# 7
  movi r2, -127
  stwio r2, 0(r8)          						/* Write the byte to the JTAG */
  br READ_SPEED

  
  
ACCELERATE:
  ldwio r6, 4(r8)          						/* Load from the JTAG */
  srli  r6, r6, 16         						/* check that the FIFO is not full (check bits from 31:16) */
  beq   r6, r0, ACCELERATE 						/* If all bits 31:16 are 0, data cannot be sent */
  movui r2, 0x04            					/* writing 2 to JTAG */
  stwio r2, 0(r8)          						/* Write the byte to the JTAG */
  
  
  
ACCELERATION_VALUE:
  ldwio r6, 4(r8)          						/* Load from the JTAG */
  srli  r6, r6, 16         						/* check that the FIFO is not full (check bits from 31:16) */
  beq   r6, r0, ACCELERATION_VALUE 				/* If all bits 31:16 are 0, data cannot be sent */
  movi r2, 127
  stwio r2, 0(r8)					          	/* Write the byte to the JTAG */
  br POLLING_W

  
DECELERATE:

  ldwio r6, 4(r8)          						/* Load from the JTAG */
  srli  r6, r6, 16         						/* check that the FIFO is not full (check bits from 31:16) */
  beq   r6, r0, DECELERATE 						/* If all bits 31:16 are 0, data cannot be sent */
  movui r2, 0x04            					/* writing 2 to JTAG */
  stwio r2, 0(r8)          						/* Write the byte to the JTAG */
  
    
DECELERATION_VALUE:
  ldwio r6, 4(r8)          						/* Load from the JTAG */
  srli  r6, r6, 16         						/* check that the FIFO is not full (check bits from 31:16) */
  beq   r6, r0, DECELERATION_VALUE 				/* If all bits 31:16 are 0, data cannot be sent */
  movi r2, -127
  stwio r2, 0(r8)          						/* Write the byte to the JTAG */
  br POLLING_W


  
POLL_READ_POSITION:
  movi r11, 1
  ldwio r2, 0(r8)								/* Load from the JTAG */
  andi  r3, r2, 0x8000							/* Mask other bits but bit 15 (which indicates if read data is valid)*/
  beq   r3, r0, POLL_READ_POSITION				/* If bit 15 is 0, data is not valid */
  andi  r3, r2, 0x00FF							/* First byte sent by UART */
  bne r3, r11, POLL_READ_POSITION				/* If not 0, keep looping */

  
  
  
  
  
 /* For hard the hard level. */ 
  
READ_X_COORDINATE:

  ldwio r2, 0(r8)								/* Load from the JTAG */
  andi  r3, r2, 0x8000							/* Mask other bits but bit 15 (which indicates if read data is valid)*/
  beq   r3, r0, READ_X_COORDINATE				/* If bit 15 is 0, data is not valid */
  andi  r3, r2, 0x00FF							/* Second byte sent by UART */
  br READ_Y_COORDINATE	
  
  
  
READ_Y_COORDINATE:

  ldwio r2, 0(r8)								/* Load from the JTAG */
  andi  r3, r2, 0x8000							/* Mask other bits but bit 15 (which indicates if read data is valid)*/
  beq   r3, r0, READ_Y_COORDINATE				/* If bit 15 is 0, data is not valid */
  andi  r3, r2, 0x00FF							/* Second byte sent by UART */
  br READ_Z_COORDINATE
  
  
  
READ_Z_COORDINATE:

  ldwio r2, 0(r8)								/* Load from the JTAG */
  andi  r3, r2, 0x8000							/* Mask other bits but bit 15 (which indicates if read data is valid)*/
  beq   r3, r0, READ_Z_COORDINATE				/* If bit 15 is 0, data is not valid */
  andi  r3, r2, 0x00FF							/* Second byte sent by UART */
  br READ_Z_COORDINATE
