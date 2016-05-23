function Trim( FileName, Einv, Limit )
%This function takes the input of an .xyz file and grabs a plane at z
%Einv is the energy we creating a log scale around. 
%Limit creates bounds out of which everything else is excluded. 
ext = FileName(end-3:end);
core = FileName(1:end-4);
if(strcmp(ext,'.xyz')~=1)
    error('File is not of the .xyz file type');
end
    
fid = fopen(FileName);
FileName2 = strcat(core,'Trim.xyz');
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

D1 = D(:,1);
D2 = D(:,2);
D3 = D(:,3);
D4 = D(:,4);
D5 = D(:,5);

Excess = (D4<=(Einv-Limit))+(D4>=(Einv+Limit));
Einv = Excess.*D4;

D1 = Excess.*(D1+1);
D2 = Excess.*(D2+1);
D3 = Excess.*(D3+1);
D4 = Excess.*D4;
D5 = Excess.*D5;

D1 = D1(D1~=0)-1;
D2 = D2(D2~=0)-1;
D3 = D3(D3~=0)-1;
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

