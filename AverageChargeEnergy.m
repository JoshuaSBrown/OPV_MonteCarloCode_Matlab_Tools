function AverageChargeEnergy(FileName)

fid=fopen(FileName);

A = textscan(fid,'%f %f %d');
c = [0 rand 1];
figure(1)
yyaxis left
hold on
h=plot(A{1},smoothdata(smoothdata(A{2})),'LineStyle','-','LineWidth',1.5,'Color',c);
ylabel('Average Energy Charges [eV]')
xlabel('Time [s]')
set(gcf,'Color','w')
set(gca,'FontSize',16)

figure(1)
yyaxis left
hold on
plot(A{1},A{3},'LineWidth',1.5,'LineStyle','--','Color',c)
ylabel('Number of Charges in System')
xlabel('Time [s]')
set(gcf,'Color','w')
set(gca,'FontSize',16)

figure(2)
yyaxis right
set(gca,'xscale','log')
hold on
h=semilogx(A{1},smoothdata(smoothdata(A{2})),'LineStyle','-','LineWidth',1.5,'Color',c);
ylabel('Average Energy Charges [eV]')
xlabel('Time [s]')
set(gcf,'Color','w')
set(gca,'FontSize',16)

figure(2)
yyaxis left
set(gca,'xscale','log')
hold on
semilogx(A{1},A{3},'LineWidth',1.5,'LineStyle','--','Color',c)
ylabel('Number of Charges in System')
xlabel('Time [s]')
set(gcf,'Color','w')
set(gca,'FontSize',16)
fclose(fid)


end