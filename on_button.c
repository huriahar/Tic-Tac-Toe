bool onClassic(int x, int y){
	return(x>28 && x<130 && y>142 && y<191);
}

bool onTimed(int x, int y){
	return(x>188 && x<289 && y>142 && y<191);
}


void main(){

asm ("call _start\n");
return;
}