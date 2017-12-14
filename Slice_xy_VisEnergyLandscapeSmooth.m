function Slice_xy_VisEnergyLandscapeSmooth( FileName, z )
%This function takes the input of an .xyz file and grabs a plane at z
close all
if(z<0)
   error('The slize plane must have a z>0'); 
end
E0 = -5.2;
zdiff = 0.07;

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

F=find(D(:,4)==-5.2);
SeedX = D(F,1);
SeedY = D(F,2);
SeedZ = D(F,4);
for i=1:Col
    X(:,i) = X(:,i).*rangeX';
    Energy(:,i) = smooth((D((1+((i-1)*Row)):(i*Row),4))');

end
for i=1:Row
    Y(i,:) = Y(i,:).*rangeY;
    Energy(i,:) = smooth(Energy(i,:));
end



h = surf(X(2:Row-1,2:Col-1),Y(2:Row-1,2:Col-1),Energy(2:Row-1,2:Col-1));
hold on

set(h,'edgecolor','none');
xlabel('X-axis [nm]');
ylabel('Y-axis [nm]');
zlabel('Energy [eV]');
set(gca,'FontSize',18)
shading interp
view(0,90)
lightangle(45,-50)
h.FaceLighting = 'gouraud';
h.AmbientStrength = 0.5;
h.DiffuseStrength = 0.8;
h.SpecularStrength = 0.1;
h.SpecularExponent = 25;
h.BackFaceLighting = 'unlit';
zlim([(E0-(zdiff+0.04)) (E0+(zdiff+0.04))]);
set(gca, 'CLim', [(E0-zdiff) (E0+zdiff)]);
set(gca,'ZTick',linspace(-5.3,-5.1,2))
daspect([ 1 1 0.01]);
mymap = [ 0 0 1
0 1 1
0 1 0
1 1 0
1 0 0];
set(gcf,'Color','w');
colormap(mymap)

plot3(SeedY,SeedX,SeedZ+0.1,'ko','LineWidth',2,'MarkerFaceColor','r','MarkerSize',5);

h=colorbar;
ylabel(h, 'Energy [eV]');
%set(get(h,'title'),'string','Energy [eV]');
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

