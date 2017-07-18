function Slice_xy_VisEnergyLandscape( FileName, z )
%This function takes the input of an .xyz file and grabs a plane at z
close all
if(z<0)
   error('The slize plane must have a z>0'); 
end

core = FileName(1:end-4);
FileName2 = strcat(core,'Slice_xy_z',num2str(z),'.xyz');

if(exist(FileName2,'file')==0)
    Slice_xy( FileName, z);
end

fid = fopen(FileName2);

fgetl(fid);
fgetl(fid);

C = textscan(fid,'%s %f %f %f %f %f');

rows = length(C{1});
cols = 5;

D = zeros(rows,cols);
for i=1:5
   D(:,i)=C{i+1};
end

clear C

%Have to add 1 because starts at 0
Row = max(D(:,1))+1;
Col = max(D(:,2))+1;

X = ones(Row,Col);
Y = ones(Row,Col);
Energy = ones(Row,Col);

rangeX = linspace(1,Row,Row);
rangeY = linspace(1,Col,Col);

for i=1:Col
    X(:,i) = X(:,i).*rangeX';
    Energy(:,i) = (D((1+((i-1)*Row)):(i*Row),4))';
end
for i=1:Row
    Y(i,:) = Y(i,:).*rangeY;
end

h = surf(X,Y,Energy);
set(h,'edgecolor','none');
xlabel('X-axis [nm]');
ylabel('Y-axis [nm]');
zlabel('Energy [eV]');
set(gca,'FontSize',16)
shading interp
% view(50,40)
lightangle(45,-50)
h.FaceLighting = 'gouraud';
h.AmbientStrength = 0.5;
h.DiffuseStrength = 0.8;
h.SpecularStrength = 0.1;
h.SpecularExponent = 25;
h.BackFaceLighting = 'unlit';
zlim([-5.35 -5.05]);
set(gca, 'CLim', [-5.35, -5.05]);
set(gca,'ZTick',linspace(-5.35,-5.05,2))
daspect([ 1 1 0.01]);
mymap = [ 0 0 1
0 1 1
0 1 0
1 1 0
1 0 0];
set(gcf,'Color','w');
colormap(mymap)

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
fclose(fid);

end

