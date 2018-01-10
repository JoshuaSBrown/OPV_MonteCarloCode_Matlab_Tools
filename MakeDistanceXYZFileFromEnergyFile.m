function MakeDistanceXYZFileFromEnergyFile( FileName, SeedEnergy )
%This function takes the input of an .xyz file finds all the energies that
%are equal to the seed energies it then proceeds to assign the distance of
%the closest energy to each point in the lattice. 

ext = FileName(end-3:end);
core = FileName(1:end-4);
if(strcmp(ext,'.xyz')~=1)
    error('File is not of the .xyz file type');
end
    

fid = fopen(FileName);
FileName2 = strcat(core,'DistFile','.xyz');
fid2 = fopen(FileName2,'w');
fprintf(fid2,'              \n\n');
TotalLines = str2double(fgetl(fid));
fgetl(fid);

C = textscan(fid,'%s %f %f %f %f %f %f');

rows = length(C{1});
cols = 6;

D = zeros(rows,cols);
for i=1:6
   D(:,i)=C{i+1};
end


Distances = ones(length(D),1)*-1;

Seedindices = find(D(:,4)==SeedEnergy);
Distances(Seedindices,1)=0;
SeedX = D(Seedindices,1);
SeedY = D(Seedindices,2);
SeedZ = D(Seedindices,3);

Lattice = ones(200,200,200)*200;
diff = 30;

for i=1:length(SeedX)
    
    x = SeedX(i);
    y = SeedY(i);
    z = SeedZ(i);
    
    x_low = x-diff;
    y_low = y-diff;
    z_low = z-diff;
    x_hig = x+diff;
    y_hig = y+diff;
    z_hig = z+diff;
    if(x_low<1)
        x_low=1;
    end
    if(y_low<1)
        y_low=1;
    end
    if(z_low<1)
        z_low=1;
    end
    if(x_hig>200)
        x_hig=200;
    end
    if(y_hig>200)
        y_hig=200;
    end
    if(z_hig>200)
        z_hig=200;
    end
    for xx=x_low:x_hig
        for yy=y_low:y_hig
            for zz=z_low:z_hig
                radius = sqrt((xx-x)^2+(yy-y)^2+(zz-z)^2);
                if(radius<Lattice(xx,yy,zz))
                    Lattice(xx,yy,zz) = radius;
                end
            end
        end
    end
    
end

% iterations = 20;
% Lattice = ones(200,200,200)*iterations;
% 
% for k=1:length(SeedX)
%     Lattice(SeedX(k)+1,SeedY(k)+1,SeedZ(k)+1)=0;
% end
% Lattice2 = Lattice;
% % Convert the system into a lattice
% for i=1:(iterations-1)
%     Lattice2(1:199,:,:) = Lattice2(1:199,:,:)-((Lattice(2:200,:,:)<(iterations))).*(Lattice2(1:199,:,:)>=(iterations));
%     Lattice2(2:200,:,:) = Lattice2(2:200,:,:)-((Lattice(1:199,:,:)<(iterations))).*(Lattice2(2:200,:,:)>=(iterations));
%     Lattice = Lattice2;
%     Lattice(:,1:199,:) = Lattice(:,1:199,:)-((Lattice2(:,2:200,:)<(iterations))).*(Lattice(:,1:199,:)>=(iterations));
%     Lattice(:,2:200,:) = Lattice(:,2:200,:)-((Lattice2(:,1:199,:)<(iterations))).*(Lattice(:,2:200,:)>=(iterations));
%     Lattice2 = Lattice;
%     Lattice2(:,:,1:199) = Lattice2(:,:,1:199)-((Lattice(:,:,2:200)<(iterations))).*(Lattice2(:,:,1:199)>=(iterations));
%     Lattice2(:,:,2:200) = Lattice2(:,:,2:200)-((Lattice(:,:,1:199)<(iterations))).*(Lattice2(:,:,2:200)>=(iterations));
%     
%     for k=1:length(SeedX)
%         Lattice2(SeedX(k)+1,SeedY(k)+1,SeedZ(k)+1)=0;
%     end
%     Lattice = Lattice2;
% end

% Convert lattice back into an Array
D4=zeros(200*200*200,1);
for i=1:200
    for j=1:200
       start = (i-1)*200*200+(j-1)*200+1;
       D4(start:(start-1+200))=Lattice(i,j,:);     
    end
end

D1 = D(:,1);
D2 = D(:,2);
D3 = D(:,3);
size(D1)
size(D4)
totalines = length(D1);
fprintf(fid2,'C %f %f %f %e\n', [D1 D2 D3 D4]');

fclose(fid);

frewind(fid2);
fprintf(fid2,'%d',totalines);
fclose(fid2);
end

