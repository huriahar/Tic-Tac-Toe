#include <stdio.h>

int status_local[9];
int move = 1;
int available = 9;
bool played_edge = false;

void reset(){
	move = 1;
	available = 9;
	played_edge = false;
	for(unsigned i=0;i<9;i++)
		status_local[i] = 0;
	return;
}

bool empty_board(bool *status){
	for(unsigned i=0;i<9;i++)
		if(*(status+i)==1)
			return false;
	return true;
}

int find_move(bool *status, bool *tie){
	int cnt = 0, ret;
	for(unsigned i=0;i<9;i++)
		if(status_local[i]==0 && *(status+i)==1){
			if(cnt==0){
				ret = i;
				cnt++;
			}
			else{
				cout << "you made two moves!!! that's cheating!\n"
				*tie = 1;
				return -1;
			}
		}
	if(cnt==1)return ret;
	return -1;
}

void robot_first(){
	if(*robot_wins==1){
		cout << "robot already won\n";
		return;
	}
	if(move==1){
		//play corner
		*(status) = 1;
		status_local[0] = 1;
		move++;
		available--;
	}
	else{
		int human_move = find_move(status);
		if(human_move==-1)
			cout << "human hasn't played!!!!\n"
		else{
			status_local[human_move] = 2;
			available--;
			if(move==2){
				if(human_move==3 || human_move==6){
					status_local[2] = 1;
					*(status+2) = 1;
				}
				else if(human_move==4){
					status_local[8] = 1;
					*(status+8) = 1;
				}
				else{	//if the human plays anywhere else
					status_local[6] = 1;
					*(status+6) = 1;
				}
				move++;
				available--;
			}
			else if(move==3){
				if(status_local[2]==1){
					if(human_move==1){
						status_local[8] = 1;
						*(status+8) = 1;
					}
					else{
						status_local[1] = 1;
						*(status+1) = 1;						
						*(robot_wins) = 1;
					}
				}
				else if(status_local[6]==1){
					if(human_move!=3){
						status_local[3] = 1;
						*(status+3) = 1;						
						*(robot_wins) = 1;						
					}
					else{
						if(status_local[1]==2 || status_local[2]==2){
							status_local[8] = 1;
							*(status+8) = 1;
						}
						else{
							status_local[2] = 1;
							*(status+2) = 1;
						}
					}
				}
				else if(status_local[8]==1){
					if(human_move==6){
						status_local[2] = 1;
						*(status+2) = 1;
					}
					else if(human_move==2){
						status_local[6] = 1;
						*(status+6) = 1;
					}
					else if(human_move==1){
						status_local[7] = 1;
						*(status+7) = 1;
					}
					else if(human_move==7){
						status_local[1] = 1;
						*(status+1) = 1;
					}
					else if(human_move==1){
						status_local[7] = 1;
						*(status+7) = 1;
					}
					else if(human_move==3){
						status_local[5] = 1;
						*(status+5) = 1;
					}
					else if(human_move==5){
						status_local[3] = 1;
						*(status+3) = 1;
					}
					else{
						cout << "wth!!\n";
					}
				}
				move++;
				available--;
			}
			else if(move==4){
				if(status_local[4]==0){
					status_local[4] = 1;
					*(status+4) = 1;						
					*(robot_wins) = 1;
				}
				else if(status_local[8]==1 && status_local[6]==1){
					status_local[7] = 1;
					*(status+7) = 1;						
					*(robot_wins) = 1;
				}
				else if(status_local[8]==1 && status_local[2]==1){
					status_local[5] = 1;
					*(status+5) = 1;						
					*(robot_wins) = 1;
				}
				else if(status_local[0]==1 && status_local[2]==1){
					status_local[1] = 1;
					*(status+1) = 1;						
					*(robot_wins) = 1;
				}
				else{
					if((status_local[8]==1 && status_local[5]==1) || (status_local[0]==1 && status_local[1]==1)){
						if(human_move!=2){
							status_local[2] = 1;
							*(status+2) = 1;						
							*(robot_wins) = 1;
						}
						else{
							status_local[6] = 1;
							*(status+6) = 1;
						}
					}
					else if((status_local[8]==1 && status_local[7]==1) || (status_local[0]==1 && status_local[3]==1)){
						if(human_move!=6){
							status_local[6] = 1;
							*(status+6) = 1;						
							*(robot_wins) = 1;
						}
						else{
							status_local[2] = 1;
							*(status+2) = 1;
						}
					}
				}
				move++;
				available--;
			}
			else if(move==5){
				if(status_local[0]===1 && status_local[6]==1){
					if(human_move==3){
						status_local[5] = 1;
						*(status+5) = 1;						
						*(tie) = 1;
					}
					else{
						status_local[3] = 1;
						*(status+3) = 1;						
						*(robot_wins) = 1;
					}
				}
				else if(status_local[8]===1 && status_local[6]==1){
					if(human_move==7){
						status_local[1] = 1;
						*(status+1) = 1;						
						*(tie) = 1;
					}
					else{
						status_local[7] = 1;
						*(status+7) = 1;						
						*(robot_wins) = 1;
					}
				}
				else if(status_local[8]===1 && status_local[2]==1){
					if(human_move==5){
						status_local[3] = 1;
						*(status+3) = 1;						
						*(tie) = 1;
					}
					else{
						status_local[5] = 1;
						*(status+5) = 1;						
						*(robot_wins) = 1;
					}
				}
				else if(status_local[0]===1 && status_local[2]==1){
					if(human_move==1){
						status_local[7] = 1;
						*(status+7) = 1;						
						*(tie) = 1;
					}
					else{
						status_local[1] = 1;
						*(status+1) = 1;						
						*(robot_wins) = 1;
					}
				}
				move++
				available--;
			}
		}
	}


}
