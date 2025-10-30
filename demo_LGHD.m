clc; clear; close all;
warning('off')
addpath('dataset\data');
addpath('algorithms\LGHD');
addpath('algorithms\common');

RES = [];

base_path = 'D:\Code\MatchPro\CMIMv1.0\Data';
hou_path = 'O-S';
a_path = 'LGHD';

if ~exist(fullfile(base_path, hou_path, a_path), 'dir')
    mkdir(fullfile(base_path, hou_path, a_path));
end

for i = 1:10
    fprintf('---- Processing image pair %d ----\n', i);

    str1 = fullfile(base_path, hou_path, [num2str(i) '_1.tif']);
    str2 = fullfile(base_path, hou_path, [num2str(i) '_2.tif']);
    mmc = [num2str(i) '.pts'];
    ptFile = fullfile(base_path, hou_path, a_path, [hou_path '-' 'LGHD-' mmc]);
    gtstr = fullfile(base_path,hou_path, [num2str(i) '.txt']);

    % ---------- check file existence ----------
    if ~exist(str1, 'file') || ~exist(str2, 'file') || ~exist(gtstr, 'file')
        fprintf('Image %d: missing file, skip\n', i);
        continue;
    end

    % ---------- load data ----------
    gt = load(gtstr); % ground truth transform
    im1 = im2uint8(imread(str1));
    im2 = im2uint8(imread(str2));

    % ---------- ensure RGB ----------
    if size(im1,3)==1
        im1 = repmat(im1,[1 1 3]);
    end
    if size(im2,3)==1
        im2 = repmat(im2,[1 1 3]);
    end
    
    im1_gray = rgb2gray(im1);
    im2_gray = rgb2gray(im2);
    descriptor = 'LGHD';
    
    t1 = clock();   
    rgb_points  = detectFASTFeatures(im1_gray, 'MinContrast',  0.1);
    lwir_points = detectFASTFeatures(im2_gray, 'MinContrast',  0.1); % 0.1
    rgb_points  = rgb_points.selectStrongest(5000);
    lwir_points = lwir_points.selectStrongest(5000);

    fd = FeatureDescriptor(descriptor);
    res_fd_rgb  = fd.compute(im1_gray, rgb_points.Location);
    res_fd_lwir = fd.compute(im2_gray, lwir_points.Location);
    
    [indexPairs, ~] = matchFeatures(res_fd_rgb.des, res_fd_lwir.des, 'MaxRatio', 1, 'MatchThreshold', 100);
    
    matchedPoints1 = res_fd_rgb.kps(indexPairs(:, 1), :);
    matchedPoints2 = res_fd_lwir.kps(indexPairs(:, 2), :);
    
    % ---------- remove duplicates ----------
    [matchedPoints2,IA] = unique(matchedPoints2,'rows');
    matchedPoints1 = matchedPoints1(IA,:);

    if isempty(matchedPoints1)
        fprintf('Image %d: no matches found\n', i);
        continue;
    end

    % ---------- FSC robust model ----------
    H = FSC(matchedPoints1,matchedPoints2,'affine',3);
    if size(H,1)==2 && size(H,2)==3
        H = [H;0 0 1]; % make homogeneous
    end
    if size(H,1)~=3 || size(H,2)~=3
        fprintf('Image %d: invalid FSC matrix, skip\n', i);
        continue;
    end

    Y_ = H*[matchedPoints1';ones(1,size(matchedPoints1,1))];
    Y_(1,:) = Y_(1,:)./Y_(3,:);
    Y_(2,:) = Y_(2,:)./Y_(3,:);
    E = sqrt(sum((Y_(1:2,:)-matchedPoints2').^2));

    inliersIndex = E<3;
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

    T = gt;
    if size(T,1)==2 && size(T,2)==3
        Y_ = T*[cleanedPoints(:,1:2)';ones(1,size(cleanedPoints,1))];
    elseif size(T,1)==3 && size(T,2)==3
        Y_ = T*[cleanedPoints(:,1:2)';ones(1,size(cleanedPoints,1))];
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


    timeres = double([time rmse sum(E<3) size(cleanedPoints,1) size(matchedPoints1,1)]);
    RES = [RES;timeres];

    fprintf('Image %d: RMSE = %.3f, correct matches = %d\n', i, rmse, size(cleanedPoints,1));

    % ---------- visualization ----------
    if ~isempty(cleanedPoints)
        plotid = randperm(size(cleanedPoints,1),min(size(cleanedPoints,1)));
        out_path = fullfile(base_path, hou_path, a_path, [hou_path '-LGHD-' num2str(i) '-Mat.png']);
        cp_showMatch(im1, im2, cleanedPoints(plotid,1:2), cleanedPoints(plotid,3:4), E(plotid), out_path);
    end
    out_path = fullfile(base_path, hou_path, a_path, [hou_path '-LGHD-' num2str(i) '-Reg.png']);
    image_fusion(im2, im1, double(H), out_path);
end
save(fullfile(base_path, hou_path, a_path, ['RES_' hou_path '-LGHD.mat']), 'RES');
fprintf('All results saved to "%s"\n', fullfile(base_path, hou_path, a_path, ['RES_' hou_path '-LGHD.mat']));