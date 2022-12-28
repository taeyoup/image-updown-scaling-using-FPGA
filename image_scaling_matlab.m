% It works on R2020a, R2021a versions

clear all
close all
delete(instrfindall)

lenna_original = imread('lenna_256.bmp');

figure(1);
subplot(1,2,1);
imshow(lenna_original);
title('Original Image', 'fontsize', 20);


subplot(1,2,2);

% Important!!
% you should check your COM port number!!
s = serialport("COM12", 115200);

disp('fopen(s)'); 

t_data = read(s, 256 * 256 * 3, "uint8");

receive_data = zeros(256,256,3);

idx = 1;
for row = 1 : 256
    for col = 1 : 256
        for ch = 1 : 3
            receive_data(257-row, col, ch) = t_data(idx);
            idx = idx + 1;
        end
    end   
end

disp('fclose(s)');

lenna_us = uint8(receive_data);
psnr_tmp = psnr(lenna_us, lenna_original);

imshow(lenna_us);
title(['Upsampled Image'; 'PSNR: ', num2str(psnr_tmp), ' dB'], 'fontsize', 20);
fprintf('psnr: %f\n', psnr_tmp);
