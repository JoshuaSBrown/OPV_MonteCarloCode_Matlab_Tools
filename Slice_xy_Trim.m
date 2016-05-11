function Slice_xy_Trim( FileName, z, Einv, Limit )
%This function takes the input of an .xyz file and grabs a plane at z
%Einv is the energy we creating a log scale around. 
%Limit creates bounds out of which everything else is excluded. 
ext = FileName(end-3:end);
core = FileName(1:end-4);
if(strcmp(ext,'.xyz')~=1)
    error('File is not of the .xyz file type');
end
    
if(z<0)
   error('The slize plane must have a z>0'); 
end

fid = fopen(FileName);
FileName2 = strcat(core,'Slice_xy_z_Trim',num2str(z),'.xyz');
fid2 = fopen(FileName2,'w');
fprintf(fid2,'              \n\n');
TotalLines = str2double(fgetl(fid));
fgetl(fid);

C = textscan(fid,'%s %f %f %f %f %f');

rows = length(C{1});
cols = 5;

D = zeros(rows,cols);
for i=1:5
   D(:,i)=C{i+1};
end

for i=1:5
    D(:,i) = (D(:,3)==z).*D(:,i);
end

D1 = D(D(:,3)~=0,1);
D2 = D(D(:,3)~=0,2);
D3 = D(D(:,3)~=0,3);
D4 = D(D(:,3)~=0,4);
D5 = D(D(:,3)~=0,5);

Excess = (D4<=(Einv-Limit))+(D4>=(Einv+Limit));
Einv = Excess.*D4;

D1 = Excess.*D1;
D2 = Excess.*D2;
D3 = Excess.*D3;
D4 = Excess.*D4;
D5 = Excess.*D5;

D1 = D1(D1~=0);
D2 = D2(D2~=0);
D3 = D3(D3~=0);
D4 = D4(D4~=0);
D5 = D5(D5~=0);
Einv = Einv(Einv~=0);

totalines = length(D1);
fprintf(fid2,'C %f %f %f %f %f %f\n', [D1 D2 D3 D4 D5 Einv]');

fclose(fid);

frewind(fid2);
fprintf(fid2,'%d',totalines);
fclose(fid2);
end

