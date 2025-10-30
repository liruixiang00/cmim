function  RIFT_demo_FUN(ref_file,sen_file,ptFile)


% This is a simplest implementation of the proposed RIFT algorithm. In this implementation,...
% rotation invariance part and corner point detection are not included.

% clc;clear all;close all;
% warning('off')

% addpath sar-optical   % type of multi-modal data

% str1='pair1.jpg';   % image pair
% str2='pair2.jpg';

t1=clock;
disp('Start RIFT algorithm processing, please waiting...');

im1 = im2uint8(imread(ref_file));
im2 = im2uint8(imread(sen_file));

if size(im1,3)==1
    temp=im1;
    im1(:,:,1)=temp;
    im1(:,:,2)=temp;
    im1(:,:,3)=temp;
end

if size(im2,3)==1
    temp=im2;
    im2(:,:,1)=temp;
    im2(:,:,2)=temp;
    im2(:,:,3)=temp;
end

disp('RIFT feature detection and description')
% RIFT feature detection and description
[des_m1,des_m2] = RIFT_no_rotation_invariance(im1,im2,4,6,96);

disp('nearest matching')
% nearest matching
[indexPairs,matchmetric] = matchFeatures(des_m1.des,des_m2.des,'MaxRatio',1,'MatchThreshold', 100);
matchedPoints1 = des_m1.kps(indexPairs(:, 1), :);
matchedPoints2 = des_m2.kps(indexPairs(:, 2), :);
[matchedPoints2,IA]=unique(matchedPoints2,'rows');
matchedPoints1=matchedPoints1(IA,:);

disp('outlier removal')
%outlier removal
H=FSC(matchedPoints1,matchedPoints2,'affine',2);
Y_=H*[matchedPoints1';ones(1,size(matchedPoints1,1))];
Y_(1,:)=Y_(1,:)./Y_(3,:);
Y_(2,:)=Y_(2,:)./Y_(3,:);
E=sqrt(sum((Y_(1:2,:)-matchedPoints2').^2));
inliersIndex=E<3;
cleanedPoints1 = matchedPoints1(inliersIndex, :);
cleanedPoints2 = matchedPoints2(inliersIndex, :);

corrPT = [cleanedPoints1,cleanedPoints2];  %correct match

[row,col] = size(corrPT); % 判断点的个数是否存在： row行其实就是个数  cqian 23.2.20
if row==0
    return;
end
path = ptFile;
Wenvifile1(corrPT',path);

% disp('Show matches')
% % Show results
% figure; showMatchedFeatures(im1, im2, cleanedPoints1, cleanedPoints2, 'montage');

% % % 关闭融合
% % % disp('registration result')
% % % % registration
% % % image_fusion(im2,im1,double(H));

t2=clock;
disp(['RIFT算法匹配总共花费时间  :',num2str(etime(t2,t1)),' S']);     

end
