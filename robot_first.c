#include <stdio.h>

extern int robot_wins;
extern int tie;
extern int robot_status;
extern int human_status;

int status_local[9];
int move = 1;
int available = 9;
int played_edge;

void reset(){
	move = 1;
	available = 9;
	played_edge = 0;
	unsigned int i;
	for(i=0;i<9;i++)
		status_local[i] = 0;
	return;
}

int find_available_block(){
	unsigned int i;
	for(i=0;i<9;i++)
		if(status_local[i]==0){
			return i;
		}
	return -1;
}

int find_move(){
	int cnt = 0, ret;
	unsigned int i;
	for(i=0;i<9;i++)
		if(status_local[i]==0 && ((human_status>>i)&1)==1){
			if(cnt==0){
				ret = i;
				cnt++;
			}
			else{
				printf("you made two moves!!! that's cheating!\n");
				tie = 1;
				return -1;
			}
		}
	if(cnt==1)return ret;
	return -1;
}

void robot_first(){
	if(robot_wins==1 || tie==1){
		printf("game already over\n");
		return;
	}
	if(move==1){
		//play corner
		robot_status = 1;
		status_local[0] = 1;
		move++;
		available--;
	}
	else{
		int human_move = find_move();
		if(human_move==-1)
			printf("human hasn't played!!!!\n");
		else{
			status_local[human_move] = 2;
			available--;
			if(move==2){
				if(human_move==3 || human_move==6){
					status_local[2] = 1;
					robot_status |= (1<<2);
				}
				else if(human_move==4){
					status_local[8] = 1;
					robot_status |= (1<<8);
				}
				else{	//if the human plays anywhere else
					status_local[6] = 1;
					robot_status |= (1<<6);
				}
				move++;
				available--;
			}
			else if(move==3){
				if(status_local[2]==1){
					if(((human_status>>1)&1)==1){
						status_local[8] = 1;
						robot_status |= (1<<8);
					}
					else{
						status_local[1] = 1;
						robot_status |= (1<<1);
						robot_wins = 1;
					}
				}
				else if(status_local[6]==1){
					if(((human_status>>3)&1)==0){
						status_local[3] = 1;
						robot_status |= (1<<3);
						robot_wins = 1;						
					}
					else{
						if(status_local[1]==2 || status_local[2]==2){
							status_local[8] = 1;
							robot_status |= (1<<8);
						}
						else{
							status_local[2] = 1;
							robot_status |= (1<<2);
						}
					}
				}
				else if(status_local[8]==1){
					if(((human_status>>6)&1)==1){
						status_local[2] = 1;
						robot_status |= (1<<2);
					}
					else if(((human_status>>2)&1)==1){
						status_local[6] = 1;
						robot_status |= (1<<6);
					}
					else if(((human_status>>1)&1)==1){
						status_local[7] = 1;
						robot_status |= (1<<7);
					}
					else if(((human_status>>7)&1)==1){
						status_local[1] = 1;
						robot_status |= (1<<1);
					}
					else if(((human_status>>3)&1)==1){
						status_local[5] = 1;
						robot_status |= (1<<5);
					}
					else if(((human_status>>5)&1)==1){
						status_local[3] = 1;
						robot_status |= (1<<3);
					}
					else{
						printf("wth!!\n");
					}
				}
				move++;
				available--;
			}//end of move 3
			else if(move==4){
				if(status_local[4]==0){
					status_local[4] = 1;
					robot_status |= (1<<4);						
					robot_wins = 1;
				}
				else if(status_local[8]==1 && status_local[6]==1){
					if(status_local[7]!=2){
						status_local[7] = 1;
						robot_status |= (1<<7);						
						robot_wins = 1;
					}
					else{
						status_local[3] = 1;
						robot_status |= (1<<3);
						robot_wins = 1;
					}
				}
				else if(status_local[8]==1 && status_local[2]==1){
					if(status_local[5]!=2){
						status_local[5] = 1;
						robot_status |= (1<<5);
						robot_wins = 1;
					}
					else{
						status_local[1] = 1;
						robot_status |= (1<<1);
						robot_wins = 1;					
					}
				}
				else if(status_local[0]==1 && status_local[2]==1){
					if(status_local[1]!=2){
						status_local[1] = 1;
						robot_status |= (1<<1);
						robot_wins = 1;
					}
					else{
						status_local[5] = 1;
						robot_status |= (1<<5);
						robot_wins = 1;
					}
				}
				else{
					if((status_local[8]==1 && status_local[5]==1) || (status_local[0]==1 && status_local[1]==1)){
						if(((human_status>>2)&1)==0){
							status_local[2] = 1;
							robot_status |= (1<<2);
							robot_wins = 1;
						}
						else if(status_local[6]!=2){
							status_local[6] = 1;
							robot_status |= (1<<6);
						}
					}
					else if((status_local[8]==1 && status_local[7]==1) || (status_local[0]==1 && status_local[3]==1)){
						if(((human_status>>6)&1)==0){
							status_local[6] = 1;
							robot_status |= (1<<6);
							robot_wins = 1;
						}
						else{
							status_local[2] = 1;
							robot_status |= (1<<2);
						}
					}
				}
				move++;
				available--;
			}//end of move 4
			else if(move==5){
				int next_move = find_available_block();
				if(next_move==-1)
					printf("WTH!\n");
				else{
					status_local[next_move] = 1;
					robot_status |= (1<<next_move);
					tie = 1;
					robot_wins = 1;
				}
				/*
				if(status_local[0]==1 && status_local[6]==1){
					if(((human_status>>3)&1)==1){
						status_local[5] = 1;
						robot_status |= (1<<5);
						tie = 1;
					}
					else{
						status_local[3] = 1;
						robot_status |= (1<<3);
						robot_wins = 1;
					}
				}
				else if(status_local[8]==1 && status_local[6]==1){
					if(((human_status>>7)&1)==1){
						status_local[1] = 1;
						robot_status |= (1<<1);
						tie = 1;
					}
					else{
						status_local[7] = 1;
						robot_status |= (1<<7);
						robot_wins = 1;
					}
				}
				else if(status_local[8]==1 && status_local[2]==1){
					if(((human_status>>5)&1)==1){
						status_local[3] = 1;
						robot_status |= (1<<3);
						tie = 1;
					}
					else{
						status_local[5] = 1;
						robot_status |= (1<<5);
						robot_wins = 1;
					}
				}
				else if(status_local[0]==1 && status_local[2]==1){
					if(((human_status>>1)&1)==1){
						status_local[7] = 1;
						robot_status |= (1<<7);
						tie = 1;
					}
					else{
						status_local[1] = 1;
						robot_status |= (1<<1);
						robot_wins = 1;
					}
				}
				*/
				move++;
				available--;
			}
		}
	}
	return;
}
