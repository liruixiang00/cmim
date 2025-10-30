%----------------------------POS-GIFT------------------------

clc;clear;close all;
warning('off')
run('D:/UearnLive/vlfeat-0.9.21/toolbox/vl_setup');

% path1 = 'D:\Code\MatchPro\sRIFD\LC09\1_B10.tif';
% path2 = 'D:\Code\MatchPro\sRIFD\LC09\1_RGB.tif';

% read two images 
file_image='D:\Paper\CMIMv2.0\Data\RS-OO\';
[filename,pathname]=uigetfile({'*.*','All Files(*.*)'},'Select reference image',...
                          file_image);
image1=imread(strcat(pathname,filename));
[filename,pathname]=uigetfile({'*.*','All Files(*.*)'},'Select the image to be registered',...
                          file_image);
image2=imread(strcat(pathname,filename));

%% Parameter

scale = 1;
Log_Gabor_s = 4;
Log_Gabor_o = 6;
max_point_number = 5000;
is_Rotation = 3;
k = 20;

%% Input Image Pair
[DescriptorForImage1_cell,DescriptorForImage2_cell,eo_gauss1,eo_gauss2] = MultiScale_DetectAndComputer(image1 ...
    ,image2,scale,Log_Gabor_s,Log_Gabor_o,max_point_number,is_Rotation);


DescriptorForImage1 = DescriptorForImage1_cell{1};
DescriptorForImage2 = DescriptorForImage2_cell{1};

des1 = DescriptorForImage1.des;
kpts1 = DescriptorForImage1.kps;
des2 = DescriptorForImage2.des;
kpts2 = DescriptorForImage2.kps;
[indexPairs, ~] = matchFeatures(des1, des2, 'MaxRatio', 1, 'MatchThreshold', 100);
matchedPoints1 = kpts1(indexPairs(:, 1), :);
matchedPoints2 = kpts2(indexPairs(:, 2), :);
[matchedPoints2, IA] = unique(matchedPoints2, 'rows');
matchedPoints1 = matchedPoints1(IA, :);
disp('特征匹配完成。');
disp('开始离群值剔除...');
H = FSC(matchedPoints1, matchedPoints2, 'similarity', 3);
Y_ = H * [matchedPoints1'; ones(1, size(matchedPoints1, 1))];
Y_(1, :) = Y_(1, :) ./ Y_(3, :);
Y_(2, :) = Y_(2, :) ./ Y_(3, :);
E = sqrt(sum((Y_(1:2, :) - matchedPoints2').^2));
inliersIndex = E < 3; % 设置一个阈值，例如 3 像素

cleanedPoints1 = matchedPoints1(inliersIndex, :);
cleanedPoints2 = matchedPoints2(inliersIndex, :);

disp('离群值剔除完成。');
disp(['正确匹配数量：', num2str(size(cleanedPoints1, 1))]);
figure;
showMatchedFeatures(image1, image2, cleanedPoints1, cleanedPoints2, "montage")

%% Feature Detect and Match
% [DescriptorForImage1,DescriptorForImage2,eo_gauss1,eo_gauss2] = MultiScale_DetectAndComputer(image1 ...
%     ,image2,scale,Log_Gabor_s,Log_Gabor_o,max_point_number,is_Rotation);
% 
% %% Feature Matching
% 
% [cleanedPoints1,cleanedPoints2] = MultiScale_match(DescriptorForImage1,DescriptorForImage2, ...
%     eo_gauss1,eo_gauss2,k);
% 
% %% Show Match Reault
% disp(['正确匹配数量：',num2str(size(cleanedPoints1,1))]);
% 
% figure;showMatchedFeatures(image1,image2,cleanedPoints1,cleanedPoints2,"montage");
