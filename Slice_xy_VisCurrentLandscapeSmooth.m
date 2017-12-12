function Slice_xy_VisCurrentLandscapeSmooth( FileName, z )
%This function takes the input of an .xyz file and grabs a plane at z
close all
if(z<0)
   error('The slize plane must have a z>0'); 
end
%E0 = -5.2;
%zdiff = 0.07;

core = FileName(1:end-4);
FileName2 = strcat(core,'Slice_xy_z',num2str(z),'.xyz');

if(exist(FileName2,'file')==0)
    Slice_xyVisit( FileName, z);
end

fid = fopen(FileName2);

fgetl(fid);
fgetl(fid);

C = textscan(fid,'%s %f %f %f %f %f %f');

rows = length(C{1});
cols = 6;

D = zeros(rows,cols);
for i=1:6
   D(:,i)=C{i+1};
end

clear C

%Have to add 1 because starts at 0
Row = max(D(:,1))+1;
Col = max(D(:,2))+1;

X = ones(Row,Col);
Y = ones(Row,Col);
Visit = ones(Row,Col);

rangeX = linspace(1,Row,Row);
rangeY = linspace(1,Col,Col);

for i=1:Col
    X(:,i) = X(:,i).*rangeX';
    Visit(:,i) = ((D((1+((i-1)*Row)):(i*Row),5))');
end
for i=1:Row
    Y(i,:) = Y(i,:).*rangeY;
    Visit(i,:) = (Visit(i,:));
end
figure(1);

h = surf(X(2:Row-1,2:Col-1),Y(2:Row-1,2:Col-1),abs(max(max(Visit))-Visit(2:Row-1,2:Col-1)));
set(h,'edgecolor','none');
xlabel('X-axis [nm]');
ylabel('Y-axis [nm]');
zlabel('Visit Frequency');
set(gca,'FontSize',18)
shading interp
% view(50,40)
lightangle(60,30)
h.FaceLighting = 'gouraud';
h.AmbientStrength = 0.8;
h.DiffuseStrength = 0.8;
h.SpecularStrength = 0.1;
h.SpecularExponent = 25;
h.BackFaceLighting = 'unlit';
%zlim([(E0-zdiff) (E0+zdiff)]);
%set(gca, 'CLim', [(E0-zdiff) (E0+zdiff)]);
%set(gca,'ZTick',linspace(-5.3,-5.1,2))
daspect([ 1 1 0.001 ]);
mymap = [ 0 0 1
0 1 1
0 1 0
1 1 0
1 0 0];
set(gcf,'Color','w');
%colormap(flipud(mymap))
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

