%%% Compute the Euclidean distance between descriptors of two keypoints in reference image and target image %%%
%%% Guohua Lv %%%
%%% May 1, 2011 *** Monash University %%%
%
function ED=EuclideanDistance(point1,point2)

ED=sqrt(((point1(1)-point2(1))^2)+((point1(2)-point2(2))^2));

% % if n==144
%     s1=0;
% for i=1:128
%     s1=s1+((point1(i)-point2(i))^2);
% end
% ED1=sqrt(s1);
% 
%     s2=0;
% for i=129:144
%     s2=s2+((point1(i)-point2(i))^2);
% end
% ED2=sqrt(s2);
% 
% ED=ED1/8+ED2;
% 
% 
% % end % end of if n=144
end % end of func