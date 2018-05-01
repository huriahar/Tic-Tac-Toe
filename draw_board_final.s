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



r20 stores users moves
r21 stores robots moves
*/


 
.equ LEGO_CONTROLLER 0x10000060 			#JP1


.section .text

#enable key interrupt



WAIT_FOR_PLAYER_CHOICE:
br WAIT_FOR_PLAYER_CHOICE

AFTER:

movia  r8, LEGO_CONTROLLER

mov r20, r20			/*Set the user and robot register to empty (no value on board)*/
mov r21, r0

DRAW_BOARD:
	#reset pen?
	call pen_down
	call move forward
	call move_forward
	call move_forward
	call pen_up
	call move_left
	call pen_down
	call move_backward
	call move_backward
	call move_backward
	call pen_up
	call move_left
	call move_forward
	call pen_down
	call move_right
	call move_right
	call move_right
	call pen_up
	call move_forward
	call pen_down
	call move_left
	call move_left
	call move_left
	call pen_up
	call move_backward
	call move_backward

READ_BOARD:

	call move_forward
	#mov r4, r20				/*users register*/
	#mov r5, r21				/*robots register*/
	call read_sensors
	mov r20, r2
	mov r21, r3

	call move_forward
	#mov r4, r20				/*users register*/
	#mov r5, r21				/*robots register*/
	call read_sensors
	slli r2, r2, 0x3
	slli r3, r3, 0x3
	mov r20, r2
	mov r21, r3
	
	call move_forward
	#mov r4, r20				/*users register*/
	#mov r5, r21				/*robots register*/
	call read_sensors
	slli r2, r2, 0x6
	slli r3, r3, 0x6
	mov r20, r2
	mov r21, r3

	call move_backward
	call move_backward
	call move_backward