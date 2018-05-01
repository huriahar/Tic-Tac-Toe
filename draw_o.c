#define OFFSET 10
#define VGA_ADDR 0x08000000
void draw_o(int index){
	int color = 0x1F;
	int xl, xu, yl, yu, x, y;
	int address;
	if(index==0){
		xl = 129;
		xu = 180;
		yl = 155;
		yu = 196;
	}
	else if(index==1){
		xl = 79;
		xu = 123;
		yl = 155;
		yu = 196;
	}
	else if(index==2){
		xl = 36;
		xu = 73;
		yl = 155;
		yu = 196;
	}
	else if(index==3){
		xl = 129;
		xu = 180;
		yl = 102;
		yu = 149;
	}
	else if(index==4){
		xl = 79;
		xu = 123;
		yl = 102;
		yu = 149;
	}
	else if(index==5){
		xl = 36;
		xu = 73;
		yl = 102;
		yu = 149;
	}
	else if(index==6){
		xl = 129;
		xu = 180;
		yl = 64;
		yu = 95;
	}
	else if(index==7){
		xl = 79;
		xu = 123;
		yl = 64;
		yu = 95;
	}
	else if(index==8){
		xl = 36;
		xu = 73;
		yl = 64;
		yu = 95;
	}
	y = yl+OFFSET;
	int i;
	for(i=xl+OFFSET;i<xl+3*OFFSET;i++){
		address = VGA_ADDR + i*2+y*1024;
		draw_pixel(color,address);
	}
	y = yl+3*OFFSET;
	for(i=xl+OFFSET;i<xl+3*OFFSET;i++){
		address = VGA_ADDR + i*2+y*1024;
		draw_pixel(color,address);
	}
	x = xl+OFFSET;
	for(i=yl+OFFSET;i<yl+3*OFFSET;i++){
		address = VGA_ADDR + x*2+i*1024;
		draw_pixel(color,address);
	}	
	x = xl+3*OFFSET;
	for(i=yl+OFFSET;i<yl+3*OFFSET;i++){
		address = VGA_ADDR + x*2+i*1024;
		draw_pixel(color,address);
	}
	return;
}
