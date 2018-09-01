function Slice_xy_VisDistTimeConvLandscapeSmooth( FileName, z )
%This function takes the input of an .xyz file and grabs a plane at z
% fileName - Energy file
% FileName3 - Frequency file

FileName3 = FileName;
close all
if(z<0)
   error('The slize plane must have a z>0'); 
end
E0 = -5.2;
zdiff = 0.07;

core = FileName(1:end-4);

FileName2 = strcat(core,'EnergyDistFileSlice_xy_z',num2str(z),'.xyz');
core2 = FileName3(1:end-4);
FileName4 = strcat(core2,'Slice_xy_z',num2str(z),'.xyz');

if(exist(FileName2,'file')==0)
    Slice_xyDist( strcat(core,'EnergyDistFile.xyz'), z);
end
if(exist(FileName4,'file')==0)
    Slice_xyVisit( FileName3, z);
end
fid = fopen(FileName2);

fgetl(fid);
fgetl(fid);

C = textscan(fid,'%s %f %f %f %f');

rows = length(C{1});
cols = 4;

D = zeros(rows,cols);
for i=1:cols
   D(:,i)=C{i+1};
end
fclose(fid);
clear C

fid = fopen(FileName4);
fgetl(fid);
fgetl(fid);
C = textscan(fid,'%s %f %f %f %f %f %f');

rows = length(C{1});
cols = 6;

D2 = zeros(rows,cols);
for i=1:6
   D2(:,i)=C{i+1};
end
fclose(fid);
clear C

%Have to add 1 because starts at 0
Row = max(D(:,1))+1;
Col = max(D(:,2))+1;

X = ones(Row,Col);
Y = ones(Row,Col);
Dist = ones(Row,Col);
Time = ones(Row,Col);

rangeX = linspace(1,Row,Row);
rangeY = linspace(1,Col,Col);

for i=1:Col
    X(:,i) = X(:,i).*rangeX';
    Dist(:,i) = ((D((1+((i-1)*Row)):(i*Row),4))');
    Time(:,i) = ((D2((1+((i-1)*Row)):(i*Row),6))');
end

Conv = Dist(2:Row-1,2:Col-1).*(log(Time(2:Row-1,2:Col-1)));
%Conv(isnan(Conv)) = 0; 
Conv(isinf(Conv)) = 0; 
for i=1:Col-2
    Conv(:,i) = smooth(Conv(:,i));
end

for i=1:Row-2
    Y(i,:) = Y(i,:).*rangeY;
    Conv(i,:) = smooth(Conv(i,:));
end


%Smooth again
for i=1:Col-2
    Conv(:,i) = smooth(Conv(:,i));
end
for i=1:Row-2
    Conv(i,:) = smooth(Conv(i,:));
end

Conv = (Conv);

Conv(isinf(Conv)) = 0; 
Conv(2:Row-3,2:Col-3)=Conv(2:Row-3,2:Col-3)/500;
h = surf(X(3:Row-2,3:Col-2),Y(3:Row-2,3:Col-2),(Conv(2:Row-3,2:Col-3)));
hold on

set(h,'edgecolor','none');
xlabel('X-axis [nm]');
ylabel('Y-axis [nm]');
zlabel('Energy [eV]');
set(gca,'FontSize',18)
shading interp
view(0,90)
lightangle(200,40)
h.FaceLighting = 'gouraud';
h.AmbientStrength = 0.7;
h.DiffuseStrength = 0.8;
h.SpecularStrength = 0.1;
h.SpecularExponent = 25;
h.BackFaceLighting = 'unlit';
%zlim([(E0-zdiff) (E0+zdiff)]);
%set(gca, 'CLim', [(E0-zdiff) (E0+zdiff)]);
%set(gca,'ZTick',linspace(-5.3,-5.1,2))
daspect([ 1 1 0.01]);

set(gcf,'Color','w');
% mymap = [ 0 0 1
% 0 1 1
% 0 1 0
% 1 1 0
% 1 0 0];
%hbc = colorbar(mymap)
%ylabel(hbc,'Distance from Seed Site [nm]')
%plot3(SeedX,SeedY,SeedZ+0.1,'ko','LineWidth',2,'MarkerFaceColor','r','MarkerSize',5);
% [Xq,Yq] = meshgrid(rangeX,rangeY);
% Zq = interp2(rangeX,rangeY,Energy,Xq,Yq,'spline');
% Xq = 1:.5:200; Yq = Xq;
% [Xq,Yq] = meshgrid(Xq,Yq);
% Zq = interp2(rangeX,rangeY,Energy,Xq,Yq,'spline');
% figure
% h = surf(Xq,Yq,Zq);
% set(h,'edgecolor','none');
% shading interp
% %view(50,40)
% lightangle(-45,-45)
% h.FaceLighting = 'gouraud';
% h.AmbientStrength = 0.3;
% h.DiffuseStrength = 0.8;
% h.SpecularStrength = 0.9;
% h.SpecularExponent = 25;
% h.BackFaceLighting = 'unlit';
% daspect([ 1 1 0.003]);
% colormap(mymap)
colormap jet
caxis([-1 0])
cb=colorbar;
end

