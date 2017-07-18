function Slice_xy_VisEnergyLandscapeW1DAll( FileName, large_z, large_x )
%This function takes the input of an .xyz file and looks through the whole
%file defined from z=1 to z = large_z, as well as x=1 to x=large_x 
%looks for seeds. The difference in energy between the seed
%energies and the energies around the seeds are then taken and the absolute
%values of the differences added together.
close all
if(large_z<0)
    error('The slize plane must have a large_z>0');
end

SumAbsEnergyDiff = zeros(41,1);
NumSeeds = zeros(41,1);

for z=1:large_z
    
    
    %Start with a two dimensional slice
    core = FileName(1:end-4);
    FileName2 = strcat(core,'Slice_xy_z',num2str(z),'.xyz');
    
    if(exist(FileName2,'file')==0)
        Slice_xy( FileName, z);
    end
    
    fid = fopen(FileName2);
    
    fgetl(fid);
    fgetl(fid);
    C = textscan(fid,'%s %f %f %f %f %f');
    fclose(fid);
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
    
    Energy1D = ones(1,Col);
    
    rangeX = linspace(1,Row,Row);
    rangeY = linspace(1,Col,Col);
    
    for i=1:Col
        X(:,i) = X(:,i).*rangeX';
        Energy(:,i) = (D((1+((i-1)*Row)):(i*Row),4))';
    end
    for i=1:Row
        Y(i,:) = Y(i,:).*rangeY;
    end
    
    clear D;
    
    for Slice_x = 1:large_x
        Energy1D = Energy(Slice_x,:);
        
%         figure(1);
%         set(gcf, 'Position', [100, 100, 1000, 400]);
%         hold on;
%         subplot(1,2,1);
%         h = surf(X,Y,Energy);
%         set(h,'edgecolor','none');
%         xlabel('X-axis [nm]');
%         ylabel('Y-axis [nm]');
%         zlabel('Energy [eV]');
%         shading interp
%         % view(50,40)
%         lightangle(45,-50)
%         h.FaceLighting = 'gouraud';
%         h.AmbientStrength = 0.5;
%         h.DiffuseStrength = 0.8;
%         h.SpecularStrength = 0.1;
%         h.SpecularExponent = 25;
%         h.BackFaceLighting = 'unlit';
%         zlim([-5.35 -5.05]);
%         set(gca, 'CLim', [-5.35, -5.05]);
%         daspect([ 1 1 0.005]);
%         mymap = [ 0 0 1
%             0 1 1
%             0 1 0
%             1 1 0
%             1 0 0];
%         set(gcf,'Color','w');
%         colormap(mymap)
%         
%         hold on;
%         subplot(1,2,2);
%         plot(linspace(1,Col,Col),Energy1D,'LineWidth',2);
%         hold on
        
        Position = 0;
        for i=1:Col
            if Energy1D(1,i)==-5.2
                plot(i,-5.2,'or','MarkerSize',10,'LineWidth',2);
                
                %Add abs Energy Diff
                maxC = (i+20);
                minC = (i-20);
                Elem = 1;
                if((i-20)<1)
                    minC = 1;
                    Elem = 21-i;
                end
                if((i+20)>Col)
                    maxC = Col;
                end
                for j=minC:maxC
                    %fprintf('maxC %d minC %d i %d Elem %d\n',maxC,minC,i,Elem);
                    SumAbsEnergyDiff(Elem,1) = SumAbsEnergyDiff(Elem,1)+...
                                               abs(Energy1D(j)+5.2);
                    
                    NumSeeds(Elem) = NumSeeds(Elem)+1;
                    Elem = Elem+1;
                end
                
                
                if(Position==0)
                    Position = i;
                end
            end
        end
        
        xlabel('Y-axis');
        ylabel('Energy [eV]');
        set(gca,'XMinorTick','on');
        if(Position+20>Col)
            axisMax = Col;
        else
            axisMax = Position+20;
        end
        
        if(Position-20 < 1)
            axisMin = 1;
        else
            axisMin = Position-20;
        end
%         axis([axisMin axisMax min(Energy1D) max(Energy1D)]);
%         set(gca,'XTick',1:10:200);
%         set(gca,'FontSize',16);
%         subplot(1,2,1);
%         hold on
%         set(gca,'FontSize',16);
%         h2 = patch([Slice_x Slice_x Slice_x Slice_x],...
%             [axisMin axisMax axisMax axisMin],...
%             [min(Energy1D) min(Energy1D) max(Energy1D) max(Energy1D)],'k');
        
    end
    
end

figure(4);
plot(-20:20,SumAbsEnergyDiff./NumSeeds,'LineWidth',2);
set(gcf,'Color','w');
set(gca,'FontSize',16);
xlabel('Sites Neighboring Seed');
ylabel('|Energy Difference|')
end

