%% Clear, close
clear; close all;

%% Add folders to path
folder = {'descriptor','external_code'};
for i=1:length(folder)
    p = genpath(folder{i});
    addpath(p);
end


%% Settings
descriptor = 'LGHD';  %  'LGHD'|'EHD'|'PCEHD'

%% RGB-LWIR sample
im_num = 3;
im1 = imread('vis'+string(im_num)+'_v2.jpg');
im2 = imread('ir'+string(im_num)+'.jpg');
H_init = [];
% [im2, PPP, H_init] = coarse_reg_point_serch(im1, im2);
im_rgb = rgb2gray(im1);
im_lwir = im2uint8(im2);
im_lwir = rgb2gray(im_lwir);

% Detect features
rgb_points = detectFASTFeatures(im_rgb);
lwir_points = detectFASTFeatures(im_lwir,'MinContrast',0.1);

% Compute descriptors
fd = FeatureDescriptor(descriptor);
res_fd_rgb = fd.compute(im_rgb, rgb_points.Location);
res_fd_lwir = fd.compute(im_lwir, lwir_points.Location);

% Matching
[indexPairs,matchmetric] = matchFeatures(res_fd_rgb.des,res_fd_lwir.des,'MaxRatio',1,'MatchThreshold', 100,'Unique',true); %100 in paper
matchedPoints1 = res_fd_rgb.kps(indexPairs(:, 1), :);
matchedPoints2 = res_fd_lwir.kps(indexPairs(:, 2), :);
% Filter result using RANSAC
[F,inliersIndex] = estimateFundamentalMatrix(matchedPoints1,matchedPoints2);
matchedPoints1 = matchedPoints1(inliersIndex, :);
matchedPoints2 = matchedPoints2(inliersIndex, :);

% Show images
figure; showMatchedFeatures(im1, im_lwir, matchedPoints1, matchedPoints2,'method', 'montage');

H=FSC(matchedPoints1,matchedPoints2,'similarity',2);
image_fusion(im1,im2,double(inv(H)));
%%%%%%%%%%%%%%%%%%%%%%%
load c_points.mat
eval(['IR_ = round(IR_',num2str(im_num),')']);
eval(['VIS_ = round(VIS_',num2str(im_num),')']);
k_in_5 = 0;
k_in_10 = 0;
for i = 1:50 
%     [pre_x, pre_y, ~] = H.*[IR_(i,2),IR_(i,1),1];
    temp = [IR_(i,1),IR_(i,2),1];
    if isempty(H_init)
        ppp = inv(H)*temp';
    else
        ppp = inv(H)*(H_init*temp');
    end   
    distance(i) = sqrt((VIS_(i,1)-ppp(1,:))^2+(VIS_(i,2)-ppp(2,:))^2);
    if distance(i)<10
        k_in_10 = k_in_10 + 1;
        if distance(i)<5
            k_in_5 = k_in_5 + 1;
        end
    end   
end
mean_dis = mean(distance(:));
disp(mean_dis);
disp(k_in_5);
disp(k_in_10);



