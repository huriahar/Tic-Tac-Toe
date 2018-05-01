clear all;
close all;
image = imread('new.bmp');
red = image(:,:,1);
green = image(:,:,2);
blue = image(:,:,3);
[row,col] = size(red);
out = zeros(row*col*2,1);
counter = 1;
for i = 1:row
    for j = 1:col
        first_part = bitget(red(i,j),8:-1:4,'uint8');
        middle_part = bitget(green(i,j),8:-1:3,'uint8');
        last_part = bitget(blue(i,j),8:-1:4,'uint8');
        out(counter+1) = b2d(([first_part,middle_part(1:3)]));
        out(counter) = b2d(([middle_part(4:6),last_part]));
        counter = counter + 2;
    end
end
outfile = fopen('out','w');
fwrite(outfile,out);
fclose(outfile);
