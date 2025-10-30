clc; clear; close all; warning('off')
addpath('dataset\data');
addpath('algorithms\SIFT');
addpath('algorithms\common');

run('D:\UearnLive\vlfeat-0.9.21\toolbox\vl_setup.m');

RES = [];

base_path = 'D:\Code\MatchPro\CMIMv1.0\Data';
hou_path = 'O-O-block';
a_path = 'SIFT';

if ~exist(fullfile(base_path, hou_path, a_path), 'dir')
    mkdir(fullfile(base_path, hou_path, a_path));

end

for i = 1:10
    fprintf('---- Processing image pair %d ----\n', i);

    str1 = fullfile(base_path, hou_path, [num2str(i) '-1.jpg']);
    str2 = fullfile(base_path, hou_path, [num2str(i) '-2.jpg']);
    mmc = [num2str(i) '.pts'];
    ptFile = fullfile(base_path, hou_path, a_path, [hou_path '-' 'SIFT-' mmc]);
%     gtstr = fullfile(base_path,hou_path, [num2str(i) '.txt']);

    % ---------- check file existence ----------
%     if ~exist(str1, 'file') || ~exist(str2, 'file') || ~exist(gtstr, 'file')
%         fprintf('Image %d: missing file, skip\n', i);
%         continue;
%     end

    % ---------- load data ----------
%     gt = load(gtstr); % ground truth transform
    im1 = im2uint8(imread(str1));
    im2 = im2uint8(imread(str2));
    im1 = im2uint8(imread(str1));
    im2 = im2uint8(imread(str2));
    
    if size(im1,3)==1
        im1 = repmat(im1,[1 1 3]);
    end
    if size(im2,3)==1
        im2 = repmat(im2,[1 1 3]);
    end
    
    % ---------- ensure grayscale ----------
    if size(im1,3)==3, im1_gra = rgb2gray(im1); else, im1_gra = im1; end
    if size(im2,3)==3, im2_gra = rgb2gray(im2); else, im2_gra = im2; end
    im1_gra = im2double(im1_gra);
    im2_gra = im2double(im2_gra);

    % ---------- feature detection & matching ----------
    t1 = clock();
    [matchedPoints1, matchedPoints2] = sift_match(im1_gra, im2_gra, 1);

    if isempty(matchedPoints1)
        fprintf('Image %d: no matches found\n', i);
        continue;
    end

    % ---------- FSC robust model ----------
    H = FSC(matchedPoints1, matchedPoints2, 'affine', 2);
    if size(H,1)==2 && size(H,2)==3
        H = [H; 0 0 1]; % make homogeneous
    end
    if size(H,1)~=3 || size(H,2)~=3
        fprintf('Image %d: invalid FSC matrix, skip\n', i);
        continue;
    end

    Y_ = H*[matchedPoints1'; ones(1,size(matchedPoints1,1))];
    Y_(1,:) = Y_(1,:)./Y_(3,:);
    Y_(2,:) = Y_(2,:)./Y_(3,:);
    E = sqrt(sum((Y_(1:2,:)-matchedPoints2').^2));

    inliersIndex = E<2;
    cleanedPoints1 = matchedPoints1(inliersIndex,:);
    cleanedPoints2 = matchedPoints2(inliersIndex,:);

    t2 = clock();
    time = etime(t2,t1);
    fprintf('Image %d: inliers after FSC = %d\n', i, size(cleanedPoints1,1));

    if isempty(cleanedPoints1)
        continue;
    end
    % ---------- save correct matches ----------
    [cleanedPoints2, IA] = unique(cleanedPoints2,'rows');
    cleanedPoints1 = cleanedPoints1(IA,:);
    cleanedPoints = double([cleanedPoints1 cleanedPoints2]);
    
    corrPT = [cleanedPoints1, cleanedPoints2];
    Wenvifile1(corrPT', ptFile);

    % ---------- GT evaluation ----------
    T = H;
    if size(T,1)==2 && size(T,2)==3
        Y_ = T*[cleanedPoints(:,1:2)'; ones(1,size(cleanedPoints,1))];
    elseif size(T,1)==3 && size(T,2)==3
        Y_ = T*[cleanedPoints(:,1:2)'; ones(1,size(cleanedPoints,1))];
        Y_(1,:) = Y_(1,:)./Y_(3,:);
        Y_(2,:) = Y_(2,:)./Y_(3,:);
    else
        fprintf('Image %d: invalid GT matrix, skip\n', i);
        continue;
    end

    E = sqrt(sum((Y_(1:2,:)-cleanedPoints(:,3:4)').^2));
    if numel(E)<10
        rmse = 10;
    else
        rmse = sqrt(sum(E.^2)/numel(E));
    end

    timeres = double([time rmse sum(E<2) size(cleanedPoints,1) size(matchedPoints1,1)]);
    RES = [RES; timeres];
    fprintf('Image %d: RMSE = %.3f, correct matches = %d\n', i, rmse, size(cleanedPoints,1));

%     ---------- visualization ----------
    if ~isempty(cleanedPoints)
        plotid = randperm(size(cleanedPoints,1),min(size(cleanedPoints,1)));
        out_path = fullfile(base_path, hou_path, a_path, [hou_path '-SIFT-' num2str(i) '-Mat.png']);
        cp_showMatch(im1, im2, cleanedPoints(plotid,1:2), cleanedPoints(plotid,3:4), E(plotid), out_path);
    end
    out_path = fullfile(base_path, hou_path, a_path, [hou_path '-SIFT-' num2str(i) '-Reg.png']);
    image_fusion(im2, im1, double(H), out_path);
end
save(fullfile(base_path, hou_path, a_path, ['RES_' hou_path '-SIFT.mat']), 'RES');
fprintf('All results saved to "%s"\n', fullfile(base_path, hou_path, a_path, ['RES_' hou_path '-SIFT.mat']));