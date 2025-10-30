clc;
clear all;
close all;

selpath = uigetdir(path,'RIFT Match Algorithm: Please Select Slice Images Dir');

PathA = strcat(selpath,'\'); 
PathB = strcat(selpath,'\');  

FileA = dir(fullfile(PathA,'*_src.tiff')); 
FileB = dir(fullfile(PathB,'*_dst.tiff'));

FileNamesA = {FileA.name}';
FileNamesB = {FileB.name}';

Length_Names = size(FileNamesA,1); % 获取所提取数据文件的个数
count=0;
for i=1:Length_Names
    
    disp(['......--->>>Current Perform :',num2str(i), '/ ',num2str(Length_Names)]);     
    
% 连接路径和文件名得到完整的文件路径
K_TraceA = strcat(PathA, FileNamesA(i));
K_TraceB = strcat(PathB, FileNamesB(i));
% K_TracePxy = strcat(PathPxy, FileNamesPxy(i));

mmc = char(FileNamesA(i));
mmc = strcat(mmc(1:end-9),'.pts');
K_TracePxy = strcat(PathA, mmc);

ref_file = (K_TraceA{1,1});
sen_file = (K_TraceB{1,1});
ptFile = char(K_TracePxy);

RIFT_demo_FUN(ref_file,sen_file,ptFile)
end