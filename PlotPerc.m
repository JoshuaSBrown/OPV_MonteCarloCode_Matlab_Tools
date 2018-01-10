function  PlotPerc( Filename )
%Given a .perc file plot the percolation pathways as lines
% NumCharges is the Number of charges that are in the file 

Ylen = 200;
Zlen = 200;

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
                patchline(X,Y,Z,'edgealpha',0.1)
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

