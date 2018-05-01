By the HomieDuckies

// What to do:
// 1. Create an image in Microsoft paint (or other program). The image must be 320 pixels wide, 240 pixels high and
//	  use 24-bits to represent colour information.
// 2. Once you create the image you need, flip it up-side down and then flip horizontal. Then save the BMP file. (example: foo.bmp)
// 3. Run this converter in command prompt using the name of the BMP file you created as a command-line parameter.
//    For example:
//		bmp2assembly foo.bmp
// 4. The program generates one file:
//		image.s - a file that stores all the colors for each pixel in an array holding all the pixels
//	  You can change the file name once it is created, but it should still have the .s extension.
//
// 5. Copy the proper assembly file to the directory where your design is located and include it on your main assembly file (AFTER       .data!!).
//      ex: .include "image.s"

// A helper .s file is included to (I guess) give you the code to present the image on screen! :D