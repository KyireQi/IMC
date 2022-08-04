% ================================================================================
% SSIM Main Function
% This file is written by Kyrie Qi From CUC-IMC
% Please contact with my by my e-mail : cuc_qzl@cuc.edu.cn
% End Data : 2022-8-4 11:58
% Explaination:
%   refnames_all_dir : All distorted images' reference images list
%   dmos_dir : All distorted images' value of DMOS
%   ref_dir : The dir of reference image.
%   dis_dir : The dir of distorted image.
%   ssim_csv : The dir of the csv that memories the value of mssim
% ================================================================================
clc;

refnames_all_dir = 'C:\\Users\\sdlwq\\Desktop\\Github\\IMC-QA\\Databases\\LIVE\\refnames_all.mat';
dmos_dir = 'C:\\Users\\sdlwq\\Desktop\\Github\\IMC-QA\\Databases\\LIVE\\dmos.mat';
ref_dir = 'C:\\Users\\sdlwq\\Desktop\\Github\\IMC-QA\\Databases\\LIVE\\refimgs\\';
load (refnames_all_dir);
load (dmos_dir);
ssim_csv = fopen('mssim.csv', 'w');
score = [];

% 前227幅图像为JPEG2K压缩后的图
dis_files = dir(fullfile('C:\\Users\\sdlwq\\Desktop\\Github\\IMC-QA\\Databases\\LIVE\\jp2k\\', '*.bmp'));
dis_files = sort_nat({dis_files.name});
Len = length(dis_files);

for i = 1 : 1 : 227
    nm_ref = [ref_dir refnames_all{i}];
    img1 = rgb2gray(imread(nm_ref));
    img2 = rgb2gray(imread(strcat('C:\\Users\\sdlwq\\Desktop\\Github\\IMC-QA\\Databases\\LIVE\\jp2k\\', dis_files{i})));
    [mssim, ssim_map] = ssim (img1, img2);
    score = [score, mssim];
    fprintf(ssim_csv, "%f", mssim);
    fprintf(ssim_csv, "\n");
end

% JPEG压缩，223幅
dis_files = dir(fullfile('C:\\Users\\sdlwq\\Desktop\\Github\\IMC-QA\\Databases\\LIVE\\jpeg\\', '*.bmp'));
dis_files = sort_nat({dis_files.name});
Len = length(dis_files);

for i = 228 : 1 : 460
    nm_ref = [ref_dir refnames_all{i}];
    img1 = rgb2gray(imread(nm_ref));
    img2 = rgb2gray(imread(strcat('C:\\Users\\sdlwq\\Desktop\\Github\\IMC-QA\\Databases\\LIVE\\jpeg\\', dis_files{i - 227})));
    [mssim, ssim_map] = ssim (img1, img2);
    score = [score, mssim];
    fprintf(ssim_csv, "%f", mssim);
    fprintf(ssim_csv, "\n");
end

% 白噪声
dis_files = dir(fullfile('C:\\Users\\sdlwq\\Desktop\\Github\\IMC-QA\\Databases\\LIVE\\wn\\', '*.bmp'));
dis_files = sort_nat({dis_files.name});
Len = length(dis_files);

for i = 461 : 1 : 634
    nm_ref = [ref_dir refnames_all{i}];
    img1 = rgb2gray(imread(nm_ref));
    img2 = rgb2gray(imread(strcat('C:\\Users\\sdlwq\\Desktop\\Github\\IMC-QA\\Databases\\LIVE\\wn\\', dis_files{i - 460})));
    [mssim, ssim_map] = ssim (img1, img2);
    score = [score, mssim];
    fprintf(ssim_csv, "%f", mssim);
    fprintf(ssim_csv, "\n");
end

% 高斯模糊
dis_files = dir(fullfile('C:\\Users\\sdlwq\\Desktop\\Github\\IMC-QA\\Databases\\LIVE\\gblur\\', '*.bmp'));
dis_files = sort_nat({dis_files.name});
Len = length(dis_files);

for i = 635 : 1 : 808
    nm_ref = [ref_dir refnames_all{i}];
    img1 = rgb2gray(imread(nm_ref));
    img2 = rgb2gray(imread(strcat('C:\\Users\\sdlwq\\Desktop\\Github\\IMC-QA\\Databases\\LIVE\\gblur\\', dis_files{i - 634})));
    [mssim, ssim_map] = ssim (img1, img2);
    score = [score, mssim];
    fprintf(ssim_csv, "%f", mssim);
    fprintf(ssim_csv, "\n");
end

% 快速衰落
dis_files = dir(fullfile('C:\\Users\\sdlwq\\Desktop\\Github\\IMC-QA\\Databases\\LIVE\\fastfading\\', '*.bmp'));
dis_files = sort_nat({dis_files.name});
Len = length(dis_files);

for i = 809 : 1 : 982
    nm_ref = [ref_dir refnames_all{i}];
    img1 = rgb2gray(imread(nm_ref));
    img2 = rgb2gray(imread(strcat('C:\\Users\\sdlwq\\Desktop\\Github\\IMC-QA\\Databases\\LIVE\\fastfading\\', dis_files{i - 808})));
    [mssim, ssim_map] = ssim (img1, img2);
    score = [score, mssim];
    fprintf(ssim_csv, "%f", mssim);
    fprintf(ssim_csv, "\n");
end

fclose(ssim_csv);