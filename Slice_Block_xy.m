function Slice_Block_xy( FileName, z, thickness )
%This function takes the input of an .xyz file and grabs a plane at z

ext = FileName(end-3:end);
energyPositive = FileName(end-9:end-4);
core = FileName(1:end-4);
if(strcmp(ext,'.xyz')~=1)
    error('File is not of the .xyz file type');
end
    
if(z<0)
   error('The slize plane must have a z>0'); 
end

if strcmp(energyPositive,'Energy')
    fid = fopen(FileName);
    FileName2 = strcat(core,'SliceBlock_xy_z',num2str(z),'.xyz');
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
    
    F = D;
    
    for i=1:5
        for j=1:thickness
            F(:,i) = F(:,i)+(D(:,3)==(z+j-1)).*D(:,i);
        end
    end
    
    D = F;
    
    D1 = D(D(:,3)~=0,1);
    D2 = D(D(:,3)~=0,2);
    D3 = D(D(:,3)~=0,3);
    D4 = D(D(:,3)~=0,4);
    D5 = D(D(:,3)~=0,5);
    
    totalines = length(D1);
    fprintf(fid2,'C %f %f %f %f %f\n', [D1 D2 D3 D4 D5]');
    
    fclose(fid);
    
    frewind(fid2);
    fprintf(fid2,'%d',totalines);
    fclose(fid2);

else

    fid = fopen(FileName);
    FileName2 = strcat(core,'SliceBlock_xy_z',num2str(z),'.xyz');
    fid2 = fopen(FileName2,'w');
    fprintf(fid2,'              \n\n');
    TotalLines = str2double(fgetl(fid));
    fgetl(fid);
    C = textscan(fid,'%s %f %f %f %f %f %f\n');
    
    rows = length(C{1});
    cols = 6;
    
    D = zeros(rows,cols); 
    F = D;
    
    for i=1:cols
        D(:,i)=C{i+1};
    end
    
   
    
    for i=1:5
        for j=1:thickness
            F(:,i) = F(:,i)+(D(:,3)==(z+j-1)).*D(:,i);
        end
    end
    
    D = F;
    
    clear F;
    
    D1 = D(D(:,3)~=0,1);
    D2 = D(D(:,3)~=0,2);
    D3 = D(D(:,3)~=0,3);
    D4 = D(D(:,3)~=0,4);
    D5 = D(D(:,3)~=0,5);
    D6 = D(D(:,3)~=0,6);
    
    totalines = length(D1);
    A = [D1 D2 D3 D4 D5 D6]';
    fprintf(fid2,'C %f %f %f %f %f %g\n',A);
    
    fclose(fid);
    
    frewind(fid2);
    fprintf(fid2,'%d',totalines);
    fclose(fid2);
    
end

end

