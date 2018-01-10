function  SiteDecayRate( filename,color )
%Plot the number of sites that have decayed at each position along the
%x-axis
%   Detailed explanation goes here

    fid = fopen(filename,'r');
    
    % Load time of decay x y and z position
    A = textscan(fid,'%f %d %d %d');
    
    fclose(fid);
    
%    figure(1)
%    hist(log(A{1}));
%    figure(2)
    
    figure(1)
    hold on
    colormap default
    %hist(double(A{2}),200)
    h = histogram(double(A{2}),200);
    set(h,'EdgeColor','none','FaceColor',color,'FaceAlpha',1)

%     plot(A{1},A{2},'LineWidth',2);
   
    set(gcf,'Color','w');
    set(gca,'FontSize',16);
    xlabel('x-axis [nm]');
    ylabel('# Decay Sites')

end

