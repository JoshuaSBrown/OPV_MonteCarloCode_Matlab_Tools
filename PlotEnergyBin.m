function PlotEnergyBin(filename)
%Plot the data put in an Energy bin file 

% Translate the DOS
    trans = 5;
    fid = fopen(filename);
    A = textscan(fid,'%f %f');
    
    figure(1)
    hold on;
    set(gcf, 'Position', [100, 100, 1000, 400])
    subplot(1,2,1);
    hold on
    plot(A{1}+trans,smooth(A{2}),'LineWidth',1.5);
    xlabel('Energy [eV]');
    ylabel('DOS');
    set(gcf,'Color','w');
    set(gca,'FontSize',16);
    
    subplot(1,2,2);
    set(gca,'yscale','log');
    hold on
    plot(A{1}+trans,smooth(A{2}),'LineWidth',1.5);
    set(gca,'FontSize',16);
    xlabel('Energy [eV]');
    ylabel('DOS');
    
end