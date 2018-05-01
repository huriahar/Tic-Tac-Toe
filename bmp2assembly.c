// (karimov 2005) modified by (HomieDuckies 2015)
// This program was originally written by one of the ECE241 students to convert an image
// supplied in a BMP file into an MIF file format for use with Quartus II.
// This program has recently been modified to work with the new VGA controller used with the DE2
// board.
//
// BUT THEN IT GOT MODIFIED FOR ECE243 DAYUMMMMMMMMM
//
// What to do:
// 1. Create an image in Microsoft paint (or other program). The image must be 320 pixels wide, 240 pixels high and
//	  use 24-bits to represent colour information.
// 2. Once you create the image you need, flip it up-side down and then flip horizontal. Then save the BMP file. (example: foo.bmp)
// 3. Run this converter in command prompt using the name of the BMP file you created as a command-line parameter.
//    For example:
//		bmp2assembly foo.bmp
// 4. The program generates two files:
//		image.s - a file that stores all the colors for each pixel in an array holding all the pixels
//	  You can change the file names once they are created, but they should still have the .s extension.
//
// 5. Copy the proper assembly file to the directory where your design is located and include it on your main assembly file (AFTER .data!!).
//      ex: .include "image.s"

#include <stdio.h>
#include <stdlib.h>

#define FLIP_INT(c) ((c >> 24) & 0x000000FF) | ((c & 0x00FF0000) >> 8) | ((c & 0x0000FF00) << 8) | ((c & 0x000000FF) << 24)
#define FLIP_SHORT(c) ((c & 0xFF00) >> 8) | ((c & 0x00FF) << 8)

typedef struct s_header {
	unsigned short bfType;
	unsigned int bfSize;
	unsigned short reserved1;
	unsigned short reserved2;
	unsigned int offset;
} t_bmp_header;


typedef struct s_bmp_info {
	unsigned int biSize;
	unsigned int biWidth;
	unsigned int biHeight;
	unsigned short biPlanes;
	unsigned short biBitCount;
	unsigned int biCompression;
	unsigned int biSizeImage;
 	unsigned int biXPelsPerMeter;
	unsigned int biYPelsPerMeter;
	unsigned int biClrUsed;
	unsigned int biClrImportant;
} t_bmp_info;


int faprint(FILE *fcol, const char *pattern) {
	return fprintf(fcol, pattern);
}

int main(int argc, char* argv[]) {
	FILE *f, *fcol;
	int y;
	unsigned int x, c, r, g, b;
	unsigned int width, height;

	if (argc != 2)
	{
		printf("Usage: bmp2assembly <bitmap file>\n");
		return 0;
	}
	else
	{
		printf("Input file is: %s\n", argv[1]);
	}
	printf("This program converts n x m 24-bit .BMP image to text file\n");
	printf("There is 1 file produced:\n");
	printf("\timage.s\n");

	f = fopen(argv[1], "rb");
	fcol = fopen("image.s", "wb");
        
        fprintf(fcol, ".ifndef image\n\n");
        fprintf(fcol, ".equ image,1\n\n");
        fprintf(fcol, "COLOR_ARRAY:\n");

	if (f) {
		t_bmp_header header; 
		t_bmp_info info;

		fread(&header, 14, 1, f); /* sizeof(t_bmp_header) returns 16 instead of 14. Should be 14. */
		fread(&info, sizeof(t_bmp_info), 1, f);

#if !defined (WIN32)
		header.bfSize = FLIP_INT(header.bfSize);
		header.bfType = FLIP_SHORT(header.bfType);
		header.offset = FLIP_INT(header.offset);
		header.reserved1 = FLIP_SHORT(header.reserved1);
		header.reserved2 = FLIP_SHORT(header.reserved2);
		info.biSize = FLIP_INT(info.biSize);
		info.biWidth = FLIP_INT(info.biWidth);
		info.biHeight = FLIP_INT(info.biHeight);
		info.biPlanes = FLIP_SHORT(info.biPlanes);
		info.biBitCount = FLIP_SHORT(info.biBitCount);
		info.biCompression = FLIP_INT(info.biCompression);
		info.biSizeImage = FLIP_INT(info.biSizeImage);
		info.biXPelsPerMeter = FLIP_INT(info.biXPelsPerMeter);
		info.biYPelsPerMeter = FLIP_INT(info.biYPelsPerMeter);
		info.biClrUsed = FLIP_INT(info.biClrUsed);
		info.biClrImportant = FLIP_INT(info.biClrImportant);
#endif
		printf("Input file is %ix%i %i-bit depth\n", info.biWidth, info.biHeight, info.biBitCount);

		if (info.biBitCount == 24) {
			char temp[100];

			width = info.biWidth;
			height = info.biHeight;

			printf("Converting...\n");

			fseek(f, 54, SEEK_SET);
			for(y=height-1; y >=0; y--) {
				x = 0;
				for(x=0; x < width; x++) {
					c = 0;
					fread(&c, 3, 1, f);
#if defined (WIN32)
					c = ((c >> 24) & 0x000000FF) | ((c & 0x00FF0000) >> 8) | ((c & 0x0000FF00) << 8) | ((c & 0x000000FF) << 24);
#endif
					c >>= 8;
					b = (c & 0xFF0000) >> 16;
					g = (c & 0x00FF00) >>  8;
					r = (c & 0x0000FF);
					
					r = ( r * 249 + 1014 ) >> 11; //converts 8bit to 5
                                        r = r << 11;
                                        r = r & 0xF800;
					g = ( g * 253 +  505 ) >> 10; //converts 8bit to 6
                                        g = g << 5;
                                        g = g & 0x0FE0;
                                        b = ( b * 249 + 1014 ) >> 11; //converts 8bit to 5
                                        b = b & 0x001F;
	
					c = r + g + b; //holds 16 bit rgb value

					fprintf(fcol, ".hword %i\n", c);
				}
				if ((x*3) % 4 != 0)
				{
					fread(&c, 4-((x*3) % 4), 1, f);
				}
			}
		} else printf("Input file image.bmp is not in a 24-bit colour format!\n");
		fprintf(fcol, "\n.endif\n");
                fclose(fcol);
		fclose(f);
		printf("All done.\n");
	} else printf("Cannot open input file. Check for input.bmp\n");
}
