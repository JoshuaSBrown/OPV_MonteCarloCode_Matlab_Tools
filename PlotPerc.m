function  PlotPerc( Filename, Filename2 )
%Given a .perc file (Filename) plot the percolation pathways as lines
% NumCharges is the Number of charges that are in the file 
% Filename 2 should be the .xyz file with the energies

Xlen = 200;    
Ylen = 200;
Zlen = 200;

% Correlation Radius
CorRad = 5;

ext = Filename2(length(Filename2)-3:length(Filename2));
core = Filename2(1:end-4);

if(strcmp(ext,'.xyz')~=1)
    error('File is not of the .xyz file type');
end

% Determine if the Distance file exists
Filename3 = strcat(core,'Energy','.xyz');
Filename4 = strcat(core,'EnergyDistFile','.xyz');
if ~exist(Filename4,'file')==2
    % It does not exist so create it but first check if the Energy file
    % exists
    if exist(Filename3,'file')==2
        MakeDistanceXYZFileFromEnergyFile(Filename3,-5.2);
    else
        fprintf('Error Energy file does not exist and dist.xyz file not found');
        exit(1)
    end
end

% Open the distance .xyz file
fid2 = fopen(Filename4);

fgetl(fid2);
fgetl(fid2);

Row = Xlen;
Col = Ylen;
Shelf = Zlen;

C = textscan(fid2,'%s %f %f %f %f');
fclose(fid2);
rows = length(C{1});

Dist = zeros(rows,1);
Dist(:,1)=C{5};

X = ones(Row,Col,Shelf);
Y = ones(Row,Col,Shelf);
Z = ones(Row,Col,Shelf);
DistCube = ones(Row,Col,Shelf);

rangeX = linspace(1,Row,Row);
rangeY = linspace(1,Col,Col);
rangeZ = linspace(1,Shelf,Shelf);

temp = ones(1,Col,Shelf);
for i=1:Row
    X(i,:,:) = temp*rangeX(i);
end

temp = ones(Row,1,Shelf);
for i=1:Col
    Y(:,i,:) = temp*rangeY(i);
end

temp = ones(Row,Col,1);
for i=1:Shelf
    Z(:,:,i) = temp*rangeZ(i);
end

for i=1:Row
    for j=1:Col
        var2 = Dist( (1+((i-1)*Row*Col)+(j-1)*Col):((i-1)*Row*Col)+j*Col);
        DistCube(i,j,:) = reshape(var2,[1,1,Shelf]);
    end
end

hold on
% isovalues = (0.01:0.01:0.2);
p = patch(isosurface(X,Y,Z,DistCube,CorRad));

p.FaceColor = 'blue';
p.EdgeColor = 'none';
alpha('0.3')
daspect([1 1 1])
view(3);
axis tight
camlight
lighting gouraud


fid = fopen(Filename);
figure
hold on;

xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')
daspect([1 1 1])
set(gcf,'color','w');
while ~feof(fid)
    line = fgetl(fid);
    C = strsplit(line);
    NumCount = str2num(C{2});
    line = fgetl(fid);
    C = strsplit(line);
    i = 1;
    while(length(C)>2)
        

        x_pos = str2num(C{1});
        y_pos = str2num(C{2});
        z_pos = str2num(C{3});
        t     = str2num(C{4});
      
        while(y_pos<0)
           y_pos = y_pos + Ylen;
        end
        
        while(z_pos<0)
           z_pos = z_pos + Zlen;
        end
        
        if(y_pos>Ylen)
           y_pos = rem(y_pos,Ylen); 
        end
        if(z_pos>Zlen)
           z_pos = rem(z_pos,Zlen); 
        end
        
        if(i~=1)
            
            X = [x_pos old_x_pos];
            Y = [y_pos old_y_pos];
            Z = [z_pos old_z_pos];
            if(abs(x_pos-old_x_pos)<2 && abs(y_pos-old_y_pos)<2 && abs(z_pos-old_z_pos)<2)
                patchline(X,Y,Z,'edgealpha',0.1,'edgecolor','k')
            end
        end
        i = 2;
        old_x_pos = x_pos;
        old_y_pos = y_pos;
        old_z_pos = z_pos;
        line = fgetl(fid);
        if feof(fid)
           break;
        end
        C = strsplit(line);
    end
end
fclose(fid);
xlim([-1 200])
ylim([0 200])
zlim([0 200])
saveas(gcf,'3dImagePerc','jpg')
end

