function Slice_xy( FileName, z )
%This function takes the input of an .xyz file and grabs a plane at z

ext = FileName(end-3:end);
core = FileName(1:end-4);
if(strcmp(ext,'.xyz')~=1)
    error('File is not of the .xyz file type');
end
    
if(z<0)
   error('The slize plane must have a z>0'); 
end

fid = fopen(FileName);
FileName2 = strcat(core,'Slice_xy_z',num2str(z),'.xyz');
fid2 = fopen(FileName2,'w');
fprintf(fid2,'              \n\n');
TotalLines = str2double(fgetl(fid));
fgetl(fid);

i=1;
totalines=0;
while(i<=TotalLines)
   line = fgetl(fid); 
   C = strsplit(line);
   Val = str2double(C{4});
   if(Val==z)
      fprintf(fid2,strcat(line,'\n')); 
      totalines=totalines+1;
   end
   i=i+1;
end

fclose(fid);

frewind(fid2);
fprintf(fid2,'%d',totalines);
fclose(fid2);
end

