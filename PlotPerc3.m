function  PlotPerc3( Filename, Filename2 )
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
Filename3 = strcat(core,'.xyz');
Filename4 = strcat(core,'DistFile','.xyz');
if ~(exist(Filename4,'file')==2)
    % It does not exist so create it but first check if the Energy file
    % exists
    if exist(Filename3,'file')==2
        MakeDistanceXYZFileFromEnergyFile(Filename3,-5.2);
    else
        error('Error Energy file does not exist and dist.xyz file not found');
    end
end

% Open the distance .xyz file
fid2 = fopen(Filename4);

fgetl(fid2);
fgetl(fid2);

Row = Xlen;
Col = Ylen;
Shelf = Zlen;

function id = getId(ylen,zlen, xp, yp, zp)
% gets the id of the element in a 3d matrix
    id = ylen*zlen*xp+yp*zlen+zp+1;
end

function xyz = getPos(ylen,zlen,id)
    id = id-1;
    x = floor(id/(ylen*zlen));
    id = rem(id,ylen*zlen);
    y = floor(id/(zlen));
    z = rem(id,zlen);
    xyz = [ x, y, z];
end

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

figure(1)
hold on
% isovalues = (0.01:0.01:0.2);
% p = patch(isosurface(X,Y,Z,DistCube,CorRad));
% 
% p.FaceColor = 'blue';
% p.EdgeColor = 'none';
% p.FaceAlpha = 0.1;
% daspect([1 1 1])
% 
% axis tight
% camlight
% lighting gouraud

set(gcf, 'Position', [200, 200, 900, 900])
fid = fopen(Filename);
figure(1)
hold on;

xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')
daspect([1 1 1])
set(gcf,'color','w');

% Each element 
%pairs = sparse(Row*Col*Shelf,Row*Col*Shelf);
data_pairs = [];
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
            
            if(x_pos>=0 && old_x_pos>=0)
                X = [x_pos old_x_pos];
                Y = [y_pos old_y_pos];
                Z = [z_pos old_z_pos];
                
                id_new = getId(Col,Shelf,x_pos,y_pos,z_pos);
                id_old = getId(Col,Shelf,old_x_pos,old_y_pos,old_z_pos);
                
                if(id_new<0 || id_old<0)
                    error('id incorrect');
                end
                
                % This can occur if we are dealing with an electrod at
                % x_pos=-1
                if(id_new ~= id_old)
                %pairs(id_old,id_new)= pairs(id_old,id_new)+1;
                data_pairs = [ data_pairs; id_new, id_old, 1, t];
                %             if(abs(x_pos-old_x_pos)<2 && abs(y_pos-old_y_pos)<2 && abs(z_pos-old_z_pos)<2)
                %                 if(x_pos>0 && y_pos>0 && z_pos > 0 && old_x_pos>0 && old_y_pos>0 && old_z_pos>0)
                %                     if (DistCube(x_pos,y_pos,z_pos)<=CorRad || DistCube(old_x_pos,old_y_pos,old_z_pos)<=CorRad)
                %                         patchline(X,Y,Z,'edgecolor','r','edgealpha',0.08)
                %                     else
                %
                %                         patchline(X,Y,Z,'edgecolor','k','edgealpha',0.08)
                %                     end
                %                 else
                %                     patchline(X,Y,Z,'edgecolor','k','edgealpha',0.08)
                %                 end
                %             end
                end
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

data_pairs = sortrows(data_pairs);

freq_data_pairs = [ data_pairs(1,:) ];
index = 1;
for i=2:length(data_pairs)
    if data_pairs(i,1) == freq_data_pairs(index,1) && data_pairs(i,2)==freq_data_pairs(index,2)
       freq_data_pairs(index,3) = freq_data_pairs(index,3)+1; 
       freq_data_pairs(index,4) = freq_data_pairs(index,4)+data_pairs(i,4);
    else 
       freq_data_pairs = [freq_data_pairs; data_pairs(i,:) ];
       index = index + 1;
    end
end

MaxFreq = max(freq_data_pairs(:,3));
freq_data_pairs(:,4) = log(freq_data_pairs(:,4));
maxTimeLogNum = max(freq_data_pairs(:,4));
minTimeLogNum = min(freq_data_pairs(:,4));
maxTimeLogNum = maxTimeLogNum-minTimeLogNum;

colors = [1,0,0; % red
          1,1,0; % yellow
          0,1,0; % green
          0,0,1; % blue
          0,0,0];% black

for i=1:length(freq_data_pairs)
   id_old = freq_data_pairs(i,1);
   id_new = freq_data_pairs(i,2);
   
   xyz_new = getPos(Col,Shelf,id_new);
   xyz_old = getPos(Col,Shelf,id_old);
   X = [xyz_new(1), xyz_old(1)];
   Y = [xyz_new(2), xyz_old(2)];
   Z = [xyz_new(3), xyz_old(3)];
   r = abs(X(2)-X(1))+abs(Y(2)-Y(1))+abs(Z(2)-Z(1));
   %Make sure we are not connecting across periodic boundaries. 
   if (r<2)
        c = getColor((freq_data_pairs(i,4)-minTimeLogNum)/maxTimeLogNum,colors);
        patchline(X,Y,Z,'edgecolor',c,'edgealpha',freq_data_pairs(i,3)/MaxFreq);
   end
   
end

xlim([-1 200])
ylim([0 200])
zlim([0 200])

view([30 30]);
for i=1:360
    view([29+i 30])
    picName = strcat('Angle',num2str(i));
    saveas(gcf,picName,'jpg')
end
%make_video2('.','jpg','AngleVid.avi',5,'Angle')
end
