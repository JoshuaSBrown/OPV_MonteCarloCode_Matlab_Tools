function PlotCurrentData3( FileName )

fid = fopen(FileName);

%How many points should be plotted. 
%If there are fewer than 40 datapoints
%Then all of them are plotted

FigNum = 1;
Resolution = 5000;
buffer = 1000;
count = 0;
count2 = 0;

A = fgetl(fid);
B = str2num(A);
[~, col] = size(B);

Store = zeros(buffer,col);

while( A~=-1)
    
    B = str2num(A);
    
    count2 = count2+1;
    count = count+1;
    Store(count,:) = B;
    
    A = fgetl(fid);
    
    if (rem(count2,buffer)==0)
        
        Store = [ Store; zeros(buffer,col) ];
        count2 = 0;
    end
    
end

count = count-1;
%Put data in separate matrix
TStore = Store(1:count,:);

count3 = 0;
count4 = 0;

Elem = zeros(1,col);

if(count>(Resolution-1))

    %How many points are used to average by
    inc = count/(Resolution-1);
    limit = inc;
    divisor = 0;
  
    PlotStore = zeros(Resolution-1,col);
    
    while( count3<count )
        
        count3 = count3+1;
        divisor = divisor+1;
        
        Elem = TStore(count3,:)+Elem;
        
        if(count3>=limit)
                
            count4 = count4+1;
            
            PlotStore(count4,:) = Elem./divisor;
            Elem = zeros(1,col);
            divisor = 0;
            limit = limit+inc;
        end
    end
    
else
    PlotStore = TStore(1:end-1,:);
end 

while (PlotStore(end,1)==0)
   PlotStore = PlotStore(1:end-1,:); 
end
%Clear store variable to save space
%clear Store

%Normal plots
if (col==3)
    figure(FigNum);
    FigNum = FigNum+1;
    subplot(2,1,1);
    hold on
    plot(PlotStore(:,1),PlotStore(:,2));
    %plot(TStore(:,1),TStore(:,2),'r');
    xlabel('Time [s]');
    ylabel('Current [A]');
    set(gcf,'color','w');
%     
%     subplot(3,1,2);
%     hold on
%     plot(PlotStore(:,1),PlotStore(:,3));
%     xlabel('Time [s]');
%     ylabel('Velocity [m/s]');
    
    subplot(2,1,2);
    set(gca,'yscale','log')
    hold on
    semilogy(PlotStore(:,1),(PlotStore(:,3)));
    xlabel('Time [s]');
    ylabel('Velocity [m/s]');
    
elseif(col == 3)
    
    figure(FigNum);
    FigNum = FigNum+1;
    subplot(2,1,1);
    hold on
    plot(PlotStore(:,1),PlotStore(:,2));
    %plot(TStore(:,1),TStore(:,2),'r');
    xlabel('Time [s]');
    ylabel('Current [A]');
    set(gcf,'color','w');
    
    subplot(2,2,2);
    hold on
    plot(PlotStore(:,1),PlotStore(:,3));
    xlabel('Time [s]');
    ylabel('Velocity [m/s]');   
        
    subplot(2,1,2);
    hold on
    plot(PlotStore(:,1),PlotStore(:,4));
    xlabel('Time [s]');
    ylabel('Mobility [cm^{2}/(V s)]');
    
elseif (col==7)
    
    %Figure 1
    h = figure(FigNum);
    close(h);
    figure(FigNum);
    FigNum = FigNum+1;
    set(gcf,'position',[ 10 90 900 800])
    subplot(2,2,1);
    plot(PlotStore(:,1),PlotStore(:,2),'.');
    hold on
    plot(PlotStore(:,1),smooth(PlotStore(:,2)),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Current [A]');
    
    subplot(2,2,2);
    plot(PlotStore(:,1),PlotStore(:,3),'.');
    hold on
    plot(PlotStore(:,1),smooth(PlotStore(:,3)),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Charges Reaching Source');
    
    subplot(2,2,3);
    plot(PlotStore(:,1),PlotStore(:,4),'.');
    hold on;
    plot(PlotStore(:,1),smooth(smooth(smooth(PlotStore(:,4)))),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Charges Reaching Drain');
    
    subplot(2,2,4);
    plot(PlotStore(:,1),PlotStore(:,5),'.');
    hold on
    plot(PlotStore(:,1),smooth(PlotStore(:,5)),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Charges within System');
    
    temp = smooth(PlotStore(:,6));
    co = 1;
    while( isempty(find(0==temp,1))~=1 && co<9)
        temp = smooth(temp);
        co = co+1;
    end
    
    %Compare with other figures Figure 2
    figure(FigNum);
    FigNum = FigNum+1;
    set(gcf,'position',[ 10 90 900 800])
    subplot(2,2,1);
    hold on
    plot(PlotStore(:,1),smooth(PlotStore(:,2)),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Current [A]');
    
    subplot(2,2,2);
    hold on
    plot(PlotStore(:,1),smooth(PlotStore(:,3)),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Charges Reaching Source');
    
    subplot(2,2,3);
    hold on;
    plot(PlotStore(:,1),smooth(smooth(smooth(PlotStore(:,4)))),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Charges Reaching Drain');
    
    subplot(2,2,4);
    hold on
    plot(PlotStore(:,1),smooth(PlotStore(:,5)),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Charges within System');
    
    yy1 = (smooth(log(PlotStore(:,1)),(temp),0.2,'loess'));
    
    %Compare with Data Figure 3
    h = figure(FigNum);
    close(h);
    figure(FigNum);
    FigNum = FigNum+1;
    set(gcf,'position',[10 90 900 800])
    
    subplot(2,1,1);
    semilogy(PlotStore(:,1),(PlotStore(:,6)),'.');
    hold on
    semilogy(PlotStore(:,1),yy1,'LineWidth',2);
    xlabel('Time[s]');
    ylabel('Drift Velocity [m/s]');
    
    temp = smooth(PlotStore(:,7));
    co = 1;
    while( isempty(find(0==temp,1))~=1 && co<9)
        temp = smooth(temp);
        co = co+1;
    end
    yy3 = (smooth(log(PlotStore(:,1)),(temp),0.2,'rloess'));
    
    subplot(2,1,2);
    set(gca,'yscale','log')
    semilogy(PlotStore(:,1),(PlotStore(:,7)),'.');
    hold on
    semilogy(PlotStore(:,1),yy3,'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Mobility [cm^{2}/(Vs)]');
    
    %Compare with other figure Figure 4
    figure(FigNum);
    FigNum = FigNum+1;
    set(gcf,'position',[10 90 900 800])
    
    subplot(2,1,1);
    set(gca,'yscale','log')
    hold on
    semilogy(PlotStore(:,1),yy1,'LineWidth',2);
    xlabel('Time[s]');
    ylabel('Drift Velocity [m/s]');
    
    subplot(2,1,2);
    set(gca,'yscale','log')
    hold on
    semilogy(PlotStore(:,1),yy3,'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Mobility [cm^{2}/(Vs)]');
    
    %Data vs smooth Figure 5
    h = figure(FigNum);
    close(h);
    figure(FigNum);
    FigNum = FigNum+1;
    set(gcf,'position',[10 90 900 800])
    
    subplot(2,1,1);
    loglog(PlotStore(:,1),(PlotStore(:,6)),'.');
    hold on
    loglog(PlotStore(:,1),yy1,'LineWidth',2);
    xlabel('Time[s]');
    ylabel('Drift Velocity [m/s]');
    
    subplot(2,1,2);
    semilogx(PlotStore(:,1),PlotStore(:,7),'.');
    hold on
    semilogx(PlotStore(:,1),yy3,'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Mobility [cm^{2}/(Vs)]'); 
    
    %Data vs other plot Figure 6
    figure(FigNum);
    FigNum = FigNum+1;
    set(gcf,'position',[10 90 900 800])
    
    subplot(2,1,1);
    set(gca,'xscale','log')
    hold on
    semilogx(PlotStore(:,1),yy1,'LineWidth',2);
    xlabel('Time[s]');
    ylabel('Drift Velocity [m/s]');
    
    subplot(2,1,2);
    set(gca,'xscale','log')
    hold on
    semilogx(PlotStore(:,1),yy3,'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Mobility [cm^{2}/(Vs)]'); 
    
    %log log plot
    %data vs smooth Figure 7
    h = figure(FigNum);
    close(h);
    figure(FigNum);
    FigNum = FigNum+1;
    set(gcf,'position',[ 10 90 900 800])
    
    subplot(2,2,1);
    temp = smooth(PlotStore(:,2));
    co = 1;
    while( isempty(find(0==temp,1))~=1 && co< 9)
        temp = smooth(temp);
        co = co+1;
    end
    loglog(PlotStore(:,1),PlotStore(:,2),'.');
    hold on
    loglog(PlotStore(:,1),(temp),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Current [A]');
    
    subplot(2,2,2);
    loglog(PlotStore(:,1),PlotStore(:,3),'.');
    xlabel('Time [s]');
    ylabel('Charges Reaching Source');
    
    subplot(2,2,3);
    loglog(PlotStore(:,1),PlotStore(:,4),'.');
    hold on
    loglog(PlotStore(:,1),smooth(PlotStore(:,4)),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Charges Reaching Drain');
    subplot(2,2,4);
    set(gca,'xscale','log','yscale','log')
    loglog(PlotStore(:,1),PlotStore(:,5),'.');
    set(gca,'xscale','log','yscale','log')
    hold on
    loglog(PlotStore(:,1),smooth(PlotStore(:,5)),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Charges within System');
    
    %Smooth vs other plot
    figure(FigNum);
    FigNum = FigNum+1;
    set(gcf,'position',[ 10 90 900 800])
    
    subplot(2,2,1);
    set(gca,'xscale','log','yscale','log')
    hold on
    loglog(PlotStore(:,1),(temp),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Current [A]');
    
    subplot(2,2,2);
    set(gca,'xscale','log','yscale','log')
    hold on
    loglog(PlotStore(:,1),PlotStore(:,3),'.');
    xlabel('Time [s]');
    ylabel('Charges Reaching Source');
    
    subplot(2,2,3);
    set(gca,'xscale','log','yscale','log')
    hold on
    loglog(PlotStore(:,1),smooth(PlotStore(:,4)),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Charges Reaching Drain');
    
    subplot(2,2,4);
    hold on
    set(gca,'xscale','log','yscale','log')
    loglog(PlotStore(:,1),smooth(PlotStore(:,5)),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Charges within System');
    
elseif (col==6)

    figure(FigNum);
    FigNum = FigNum+1;
    set(gcf,'position',[ 10 90 900 800])
    subplot(2,2,1);
    hold on
    plot(PlotStore(:,1),PlotStore(:,2));
    xlabel('Time [s]');
    ylabel('Current [A]');
    subplot(2,2,2);
    hold on
    plot(PlotStore(:,1),PlotStore(:,3));
    xlabel('Time [s]');
    ylabel('Charges Reaching Source');
    subplot(2,2,3);
    hold on
    plot(PlotStore(:,1),PlotStore(:,4));
    xlabel('Time [s]');
    ylabel('Charges Reaching Drain');
    subplot(2,2,4);
    hold on
    plot(PlotStore(:,1),PlotStore(:,5));
    xlabel('Time [s]');
    ylabel('Charges within System');
    
    figure(FigNum);
    FigNum = FigNum+1;
    set(gcf,'position',[10 90 900 800])
    hold on
    plot(PlotStore(:,1),PlotStore(:,6));
    xlabel('Time[s]');
    ylabel('Drift Velocity [m/s]');
    
    %log log plot
    figure(FigNum);
    FigNum = FigNum+1;
    set(gcf,'position',[ 10 90 900 800])
    subplot(2,2,1);
    set(gca,'xscale','log','yscale','log')
    hold on
    loglog(PlotStore(:,1),PlotStore(:,2));
    xlabel('Time [s]');
    ylabel('Current');
    subplot(2,2,2);
    set(gca,'xscale','log','yscale','log')
    hold on
    loglog(PlotStore(:,1),PlotStore(:,3));
    xlabel('Time [s]');
    ylabel('Charges Reaching Source');
    subplot(2,2,3);
    set(gca,'xscale','log','yscale','log')
    hold on
    loglog(PlotStore(:,1),PlotStore(:,4));
    xlabel('Time [s]');
    ylabel('Charges Reaching Drain');
    subplot(2,2,4);
    hold on
    plot(log(PlotStore(:,1)),log(PlotStore(:,5)));
    xlabel('Time [s]');
    ylabel('Charges within System');
end

    %figure(100);
    %hold on
    %avg = mean(PlotStore(:,7));
    
    for i=1:8
        figure(i)
        set(gcf,'Color','w');
        if (i<=2 || i>=7)
            subplot(2,2,1);
            set(gca,'FontSize',16);
            subplot(2,2,2);
            set(gca,'FontSize',16);
            subplot(2,2,3);
            set(gca,'FontSize',16);
            subplot(2,2,4);
            set(gca,'FontSize',16);
        else
            subplot(2,1,1);
            set(gca,'FontSize',16);
            subplot(2,1,2);
            set(gca,'FontSize',16);
        end
    end
end
