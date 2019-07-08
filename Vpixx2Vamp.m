function colour_out= Vpixx2Vamp(desired_trigger)

%Vpixx2Vamp.m - 2015 - Kyle Mathewson and Sayeed Devraj-Kizuk
%takes as input the desired trigger value for recorder software and outputs
%the colour values necessary to change the top left pixel in the Vpixx
%monitor

des = desired_trigger;
bin = dec2bin(des,8); %convert to binary
bin = str2num(bin(:))';%turn into vector
bin = bin(end:-1:1); %reverse order
parts = pow2(4:7); %16 32 64 128

red_bin = bin(1:4); %pull out red and green parts
green_bin = bin(5:8);

red_out = red_bin*parts'; %multiply the vectors and sum
green_out = green_bin*parts';
colour_out = [red_out green_out 0];





