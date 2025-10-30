function Wenvifile1(PTs,Path)
	fp = fopen(Path, 'w');
	fprintf(fp,'%s\n','; ENVI Image to Image GCP File');
	fprintf(fp,'%s\n','; base file: C:\Documents\test1ref.bmp');
	fprintf(fp,'%s\n','; warp file: C:\Documents\test1sen.bmp');
	fprintf(fp,'%s\n','; Base Image (x,y), Warp Image (x,y)');
	fprintf(fp,'%s\n',';');

%     cc1 = PTs(:,1:end-1);
%     cc2 = PTs(:,end);
%     fprintf(fp,'%10.2f%10.2f%10.2f%10.2f\n',PTs);
    fprintf(fp,'%10.2f%10.2f%10.2f%10.2f\n',PTs(:,1:end-1));
    fprintf(fp,'%10.2f%10.2f%10.2f%10.2f',PTs(:,end));
    fclose(fp);