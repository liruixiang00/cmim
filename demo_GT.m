clc; clear; close all;
warning('off')
addpath('algorithms\common');

base_path = 'D:\Code\MatchPro\CMIMv1.0\Data';
hou_path = 'O-S';
txt_path = fullfile(base_path, hou_path, 'minima');

if ~exist(fullfile(base_path, hou_path), 'dir')
    mkdir(fullfile(base_path, hou_path));
end

RES = [];

for i = 8:8
    fprintf('---- Processing image pair %d ----\n', i);

    str1 = fullfile(base_path, hou_path, [num2str(i) '_1.tif']);
    str2 = fullfile(base_path, hou_path, [num2str(i) '_2.tif']);
    cmim_file = fullfile(txt_path, ['CMIM-' num2str(i) '.pts']);
    gtstr = fullfile(base_path, hou_path, [num2str(i) '.txt']); % ground truth

    if ~exist(str1,'file') || ~exist(str2,'file') || ~exist(cmim_file,'file')
        fprintf('Image %d: missing file or CMIM file, skip\n', i);
        continue;
    end

    im1 = im2uint8(imread(str1));
    im2 = im2uint8(imread(str2));

    if size(im1,3)==1, im1 = repmat(im1,[1 1 3]); end
    if size(im2,3)==1, im2 = repmat(im2,[1 1 3]); end

    fid = fopen(cmim_file,'r');
    if fid == -1
        error('Cannot open CMIM file: %s', cmim_file);
    end

    data = [];
    tline = fgetl(fid);
    while ischar(tline)
        tline = strtrim(tline);
        if isempty(tline) || tline(1) == ';'
            tline = fgetl(fid);
            continue;
        end
        nums = sscanf(tline, '%f');
        if numel(nums) == 4
            data = [data; nums'];
        end
        tline = fgetl(fid);
    end
    fclose(fid);

%     while ischar(tline)
%         tline = strtrim(tline);
%         nums = sscanf(tline, '%f');
%         if numel(nums) == 4
%             data = [data; nums'];
%         end
%         tline = fgetl(fid);
%     end
%     fclose(fid);

    t1 = clock();
    cleanedPoints1 = data(:,1:2); % Base Image (x,y)
    cleanedPoints2 = data(:,3:4); % Warp Image (x,y)
    
%     tranFlag=0;
%     tform = [];
%     if tranFlag == 0
%         tform = cp2tform(cleanedPoints1,cleanedPoints2,'affine'); 
%         T = tform.tdata.T;
%     elseif tranFlag == 1
%         tform = cp2tform(cleanedPoints1,cleanedPoints2,'projective');
%         T = tform.tdata.T;
%         else
%         T = solvePoly(cleanedPoints1,cleanedPoints2,tranFlag);
%     end
%     T1 = T';%the geometric transformation parameters from im_Ref to im_Sen

%     H = FSC(matchedPoints1,matchedPoints2,'affine',3);
%     Y_ = H*[matchedPoints1';ones(1,size(matchedPoints1,1))];
%     Y_(1,:) = Y_(1,:)./Y_(3,:);
%     Y_(2,:) = Y_(2,:)./Y_(3,:);
%     E = sqrt(sum((Y_(1:2,:)-matchedPoints2').^2));
% 
%     inliersIndex = E<3;
%     cleanedPoints1 = matchedPoints1(inliersIndex,:);
%     cleanedPoints2 = matchedPoints2(inliersIndex,:);

    % ---------- RMSE 计算 ----------
    cleanedPoints = double([cleanedPoints1 cleanedPoints2]);
    T = load(gtstr); % ground truth
    if size(T,1)==2 && size(T,2)==3
        Y_ = T*[cleanedPoints(:,1:2)'; ones(1,size(cleanedPoints,1))];
    elseif size(T,1)==3 && size(T,2)==3
        Y_ = T*[cleanedPoints(:,1:2)'; ones(1,size(cleanedPoints,1))];
        Y_(1,:) = Y_(1,:) ./ Y_(3,:);
        Y_(2,:) = Y_(2,:) ./ Y_(3,:);
    else
        fprintf('Image %d: invalid GT matrix, skip\n', i);
        continue;
    end
    
    E = sqrt(sum((Y_(1:2,:) - cleanedPoints(:,3:4)').^2));
    if numel(E)<10
        rmse = 10;
    else
        rmse = sqrt(sum(E.^2)/numel(E));
    end

    diff = cleanedPoints(:,3:4) - Y_(1:2,:)';  % [N x 2]
    E = sqrt(sum(diff.^2,2));                  % [N x 1]    
    
    
    t2 = clock();
    time = etime(t2,t1);

    timeres = double([time, rmse, sum(E<3), size(cleanedPoints,1)]);
    RES = [RES; timeres];

    fprintf('Image %d: RMSE = %.3f, correct matches = %d\n', i, rmse, size(cleanedPoints,1));

    if ~isempty(cleanedPoints)
        plotid = randperm(size(cleanedPoints,1),min(size(cleanedPoints,1)));
        out_path = fullfile(txt_path, [hou_path '-CMIM-' num2str(i) '-Mat.png']);
        cp_showMatch(im1, im2, cleanedPoints(plotid,1:2), cleanedPoints(plotid,3:4), E(plotid), out_path);
    end
    out_path = fullfile(txt_path, [hou_path '-CMIM-' num2str(i) '-Reg.png']);
    image_fusion(im2, im1, double(T), out_path);
end

save(fullfile(txt_path, ['RES_' hou_path '-CMIM.mat']), 'RES');
fprintf('All results saved to "%s"\n', fullfile(txt_path, ['RES_' hou_path '-CMIM.mat']));
