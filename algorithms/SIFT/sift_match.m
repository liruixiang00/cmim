% function [X, Y, scores, S1, S2, A1, A2] = sift_match(I1, I2, theta)
%     % Convert to single precision grayscale
%     if size(I1,3)==3, I1 = rgb2gray(I1); end
%     if size(I2,3)==3, I2 = rgb2gray(I2); end
% 
%     I1 = im2single(I1);
%     I2 = im2single(I2);
% 
%     % --- VLFeat SIFT extraction ---
% %     [f1, d1] = vl_sift(I1);
% %     [f2, d2] = vl_sift(I2);
%     [f1,d1] = vl_sift(im2single((I1)),'EdgeThresh',63) ;
%     [f2,d2] = vl_sift(im2single((I2)),'EdgeThresh',63) ;
%     % --- MATLAB built-in feature matcher (replace vl_ubcmatch) ---
%     [indexPairs, scores] = matchFeatures(d1', d2', ...
%         'MaxRatio', 1, ...          % 相当于 theta = 1
%         'MatchThreshold', 100);
% 
%     % Reconstruct match index matrix to keep compatibility
%     matches = indexPairs';
%     
%     % --- Construct output ---
%     x1 = f1(1, matches(1,:));
%     x2 = f2(1, matches(2,:)) + size(I1,2);
%     y1 = f1(2, matches(1,:));
%     y2 = f2(2, matches(2,:));
% 
%     X = [x1; y1]';
%     Y = [f2(1, matches(2,:)); y2]';
%     S1 = f1(3, matches(1,:));
%     S2 = f2(3, matches(2,:));
%     A1 = f1(4, matches(1,:));
%     A2 = f2(4, matches(2,:));
% end
function [X, Y,scores, S1, S2,A1,A2] = sift_match(I1, I2, theta)
%   [X, Y, S1, S2] = SIFT_MATCH(I1, I2, THETA) does sift match use
%   VL_Feat. 
%
% Input:
%   I1, I2: Tow input image.
%
%   theta: A descriptor D1 is matched to a descriptor D2 only if the
%       distance d(D1,D2) multiplied by THRESH is not greater than the
%       distance of D1 to all other descriptors. The default value of
%       THRESH used by VL_Feat is 1.5.
%
% Output:
%   X, Y: SIFT matches of interest points.
%   S1, S2: Scale of the matches point pairs
[f1,d1] = vl_sift(im2single((I1)),'EdgeThresh',63) ;
[f2,d2] = vl_sift(im2single((I2)),'EdgeThresh',63) ;

[matches, scores] = vl_ubcmatch(d1,d2, theta) ;

x1 = f1(1,matches(1,:)) ;
x2 = f2(1,matches(2,:)) + size(I1,2) ;
y1 = f1(2,matches(1,:)) ;
y2 = f2(2,matches(2,:)) ;
X = [x1; y1]';
Y = [f2(1,matches(2,:)); y2]';
S1 = f1(3, matches(1,:));
S2 = f2(3, matches(2,:));
A1= f1(4, matches(1,:));
A2 = f2(4, matches(2,:));
