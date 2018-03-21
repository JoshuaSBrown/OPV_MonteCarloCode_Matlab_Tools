function MakeSeedLocatoinFile( FileName, SeedEnergy )
%This function takes the input of an .xyz file finds all the energies that
%are equal to the seed energies it then proceeds to assign the distance of
%the closest energy to each point in the lattice. 

ext = FileName(end-3:end);
core = FileName(1:end-4);
if(strcmp(ext,'.xyz')~=1)
    error('File is not of the .xyz file type');
end
    

fid = fopen(FileName);
TotalLines = str2double(fgetl(fid));
fgetl(fid);

C = textscan(fid,'%s %f %f %f %f %f %f');
fclose(fid);

rows = length(C{1});
cols = 6;

D = zeros(rows,cols);
for i=1:6
   D(:,i)=C{i+1};
end

Seedindices = find(D(:,4)==SeedEnergy);

fid2 = fopen('SeedPos.txt','w');
fprintf(fid2,'%d %d %d\n', [D(Seedindices,1) D(Seedindices,2) D(Seedindices,3)]');
fclose(fid2);

end

