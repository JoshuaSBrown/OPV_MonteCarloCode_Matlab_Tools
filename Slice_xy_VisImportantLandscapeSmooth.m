function Slice_xy_VisImportantLandscapeSmooth( FileName, z )
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
    F=(D(:,6)./D(:,4));
clear C

%Have to add 1 because starts at 0
Row = max(D(:,1))+1;
Col = max(D(:,2))+1;

X = ones(Row,Col);
Y = ones(Row,Col);
Time = ones(Row,Col);
Freq = ones(Row,Col);

rangeX = linspace(1,Row,Row);
rangeY = linspace(1,Col,Col);

for i=1:Col
    X(:,i) = X(:,i).*rangeX';
    Time(:,i) = ((D((1+((i-1)*Row)):(i*Row),6))');
    Freq(:,i) = ((D((1+((i-1)*Row)):(i*Row),4))');
end

TimePerHop = Time./Freq;

max(max(TimePerHop))
min(min(TimePerHop))

% FreqCutoff = 100;
% lowerCutoff = 10^-33;
% upperCutoff = 10^-28;
% FreqNew = Freq.*(TimePerHop>lowerCutoff).*(TimePerHop<upperCutoff).*(Freq<FreqCutoff);
for i=1:Row
     Y(i,:) = Y(i,:).*rangeY;
%     Time(i,:) = (Time(i,:));
%     Freq(i,:) = ((D((1+((i-1)*Row)):(i*Row),4))');
end

figure(1)
hold on
largest = max(max(Freq));
for i=1:length(Freq)
    for j=1:length(Freq)
        if Freq(i,j)>0
            plotcube([1 1 1],[i j 0],abs(1/log(Freq(i,j)/largest)));
            set(gco,'EdgeColor','none');
        end
    end 
end
view(0,90)
% 
% %Smooth again
% for i=1:Col
%     FreqNew(:,i) = smooth(FreqNew(:,i));
% end
% for i=1:Row
%     FreqNew(i,:) = smooth(FreqNew(i,:));
% end
% figure(1);
% 
% 
% F(isnan(F))=[];
% j=1;
% total = sum(F>0);
% G=zeros(1,total);
% for i=1:length(F)
%    if F(i)>0
%       G(1,j)=F(i);
%       j=j+1;
%    end
% end
% 
% hist((G),100);
% set(gca,'xscale','log');
% figure(2);

% h = surf(X(2:Row-1,2:Col-1),Y(2:Row-1,2:Col-1),(FreqNew(2:Row-1,2:Col-1)));
% set(h,'edgecolor','none');
% xlabel('X-axis [nm]');
% ylabel('Y-axis [nm]');
% zlabel('Freq');
% set(gca,'FontSize',18)
% shading interp
% view(0,90)
% lightangle(60,60)
% h.FaceLighting = 'gouraud';
% h.AmbientStrength = 0.8;
% h.DiffuseStrength = 0.8;
% h.SpecularStrength = 0.1;
% h.SpecularExponent = 25;
% h.BackFaceLighting = 'unlit';
% %zlim([(E0-zdiff) (E0+zdiff)]);
% %min(min(abs(log(Time(2:Row-1,2:Col-1)))))
% %max(max(abs(log(Time(2:Row-1,2:Col-1)))))
% %set(gca, 'CLim', [18 42]);
% %set(gca,'ZTick',linspace(-5.3,-5.1,2))
% %daspect([ 1 1 1 ]);
% mymap = [ 0 0 1
% 0 1 1
% 0 1 0
% 1 1 0
% 1 0 0];
% set(gcf,'Color','w');


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
daspect([ 1 1 0.003]);
% colormap(mymap)
log(max(max(Time)))
fclose(fid);

end

