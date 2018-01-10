function AverageChargeEnergy(FileName,c)
% Translate the energy of the charges by 5 eV
trans = 5;
fid=fopen(FileName);
% Yellow [1 1 0]
% Red [1 0 0 ]
% Blue [0 0 1 ]
%c = [1 0 0];
A = textscan(fid,'%f %f %d');
figure(1)
yyaxis left
set(gca,'YColor','k')
hold on
h=plot(A{1},smoothdata(smoothdata(A{2}))+trans,'LineStyle','-','LineWidth',1.5,'Color',c);
ylabel('Average Energy Charges [eV]')
xlabel('Time [s]')
set(gcf,'Color','w')
set(gca,'FontSize',16)

figure(1)
yyaxis right
set(gca,'YColor','k')
hold on
plot(A{1},A{3},'LineWidth',1.5,'LineStyle','--','Color',c)
ylabel('Number of Charges in System')
xlabel('Time [s]')
set(gcf,'Color','w')
set(gca,'FontSize',16)

figure(2)
yyaxis left
set(gca,'YColor','k')
set(gca,'xscale','log')

hold on
h=semilogx(A{1},smoothdata(smoothdata(A{2}))+trans,'LineStyle','-','LineWidth',1.5,'Color',c);
ylabel('Average Energy Charges [eV]')
xlabel('Time [s]')
set(gcf,'Color','w')
set(gca,'FontSize',16)

figure(2)
yyaxis right
set(gca,'xscale','log')
set(gca,'YColor','k')
hold on
semilogx(A{1},A{3},'LineWidth',1.5,'LineStyle','--','Color',c)
ylabel('Number of Charges in System')
xlabel('Time [s]')
set(gcf,'Color','w')
set(gca,'FontSize',16)
fclose(fid)


end