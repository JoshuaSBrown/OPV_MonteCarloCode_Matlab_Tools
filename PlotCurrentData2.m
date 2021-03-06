function PlotCurrentData2( FileName )


%Determine the file type X, Y or Z type
placeholder = strfind(FileName,'.txt');
FileType = FileName(placeholder-1);
code = 0;

if(strcmp(FileType,'X')==1)
    code = 1;
    
    word1 = strfind(FileName,'Vx');
    word2 = strfind(FileName,'Vy');
    Voltage = str2num(FileName(word1+2:word2-1));
    
elseif(strcmp(FileType,'Y')==1)
    code = 2;
    
    word1 = strfind(FileName,'Vy');
    word2 = strfind(FileName,'Vz');
    Voltage = str2num(FileName(word1+2:word2-1));
    
elseif(strcmp(FileType,'Z')==1)
    code = 3;
    
    word1 = strfind(FileName,'Vz');
    word2 = strfind(FileName,'R');
    Voltage = str2num(FileName(word1+2:word2-1));
    
else
   error('Wrong file type needs to be X.txt Y.txt or Z.txt format');
   exit;
end

fid = fopen(FileName);

%How many points should be plotted. 
%If there are fewer than 40 datapoints
%Then all of them are plotted
FigNum = 1;
Resolution = 5000;
buffer = 1000;
count = 0;
count2 = 0;

A = textscan(fid,'%f %f %d %d %d %f %f');

Store = zeros(length(A{1}),length(A));
for i=1:length(A)
    Store(:,i)=A{i}; 
end

clear A

[count, col] = size(Store);

%Lets calculate the average drift velocity
v_sum = 0;
TotalNumberCharges=0;
Distance = 200*10^-7;   %Distance of system in cm

for i=1:length(Store)
    if(Store(i,1)~=0)
        v_sum = v_sum+Store(i,4)*Distance/(Store(i,1));  %Units of [cm/s]
        TotalNumberCharges = TotalNumberCharges+Store(i,4);
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
            count3/count
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
    ylabel('Current [Amps]');
    set(gcf,'color','w');
%     
%     subplot(3,1,2);
%     hold on
%     plot(PlotStore(:,1),PlotStore(:,3));
%     xlabel('Time [s]');
%     ylabel('Velocity [m/s]');
    
    subplot(2,1,2);
    hold on
    plot(PlotStore(:,1),log(PlotStore(:,3)));
    xlabel('Time [s]');
    ylabel('log Velocity [m/s]');
    
elseif(col == 3)
    
    figure(FigNum);
    FigNum = FigNum+1;
    subplot(2,1,1);
    hold on
    plot(PlotStore(:,1),PlotStore(:,2));
    %plot(TStore(:,1),TStore(:,2),'r');
    xlabel('Time [s]');
    ylabel('Current [Amps]');
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
    ylabel('Mobility [cm2/(V s)]');
    
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
    ylabel('Current');
    
    subplot(2,2,2);
    plot(PlotStore(:,1),PlotStore(:,3),'.');
    hold on
    plot(PlotStore(:,1),smooth(PlotStore(:,3)),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Charges Reaching Source Electrode');
    
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
    ylabel('Current');
    
    subplot(2,2,2);
    hold on
    plot(PlotStore(:,1),smooth(PlotStore(:,3)),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Charges Reaching Source Electrode');
    
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
    
    yy1 = smooth(log(PlotStore(:,1)),log(temp),0.2,'loess');
    
    %Compare with Data Figure 3
    h = figure(FigNum);
    close(h);
    figure(FigNum);
    FigNum = FigNum+1;
    set(gcf,'position',[10 90 900 800])
    
    subplot(2,1,1);
    plot(PlotStore(:,1),log(PlotStore(:,6)),'.');
    hold on
    plot(PlotStore(:,1),yy1,'LineWidth',2);
    xlabel('Time[s]');
    ylabel('log Drift Velocity [m/s]');
    
    temp = smooth(PlotStore(:,7));
    co = 1;
    while( isempty(find(0==temp,1))~=1 && co<9)
        temp = smooth(temp);
        co = co+1;
    end
    yy3 = smooth(log(PlotStore(:,1)),log(temp),0.2,'rloess');
    
    subplot(2,1,2);
    plot(PlotStore(:,1),log(PlotStore(:,7)),'.');
    hold on
    plot(PlotStore(:,1),yy3,'LineWidth',2);
    xlabel('Time [s]');
    ylabel('log Mobility [cm2 / (V s)]');
    
    %Compare with other figure Figure 4
    figure(FigNum);
    FigNum = FigNum+1;
    set(gcf,'position',[10 90 900 800])
    
    subplot(2,1,1);
    hold on
    plot(PlotStore(:,1),yy1,'LineWidth',2);
    xlabel('Time[s]');
    ylabel('log Drift Velocity [m/s]');
    
    subplot(2,1,2);
    hold on
    plot(PlotStore(:,1),yy3,'LineWidth',2);
    xlabel('Time [s]');
    ylabel('log Mobility [cm2 / (V s)]');
    
    %Data vs smooth Figure 5
    h = figure(FigNum);
    close(h);
    figure(FigNum);
    FigNum = FigNum+1;
    set(gcf,'position',[10 90 900 800])
    
    subplot(2,1,1);
    plot(log(PlotStore(:,1)),log(PlotStore(:,6)),'.');
    hold on
    plot(log(PlotStore(:,1)),yy1,'LineWidth',2);
    xlabel('log Time[s]');
    ylabel('log Drift Velocity [m/s]');
    
    subplot(2,1,2);
    plot(log(PlotStore(:,1)),log(PlotStore(:,7)),'.');
    hold on
    plot(log(PlotStore(:,1)),yy3,'LineWidth',2);
    xlabel('log Time [s]');
    ylabel('log Mobility [cm2 / (V s)]'); 
    
    %Data vs other plot Figure 6
    figure(FigNum);
    FigNum = FigNum+1;
    set(gcf,'position',[10 90 900 800])
    
    subplot(2,1,1);
    hold on
    plot(log(PlotStore(:,1)),yy1,'LineWidth',2);
    xlabel('log Time[s]');
    ylabel('log Drift Velocity [m/s]');
    
    subplot(2,1,2);
    hold on
    plot(log(PlotStore(:,1)),yy3,'LineWidth',2);
    xlabel('log Time [s]');
    ylabel('log Mobility [cm2 / (V s)]'); 
    
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
    plot(log(PlotStore(:,1)),log(PlotStore(:,2)),'.');
    hold on
    plot(log(PlotStore(:,1)),(log(temp)),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Current');
    
    subplot(2,2,2);
    plot(log(PlotStore(:,1)),log(PlotStore(:,3)),'.');
    xlabel('Time [s]');
    ylabel('Charges Reaching Source Electrode');
    
    subplot(2,2,3);
    plot(log(PlotStore(:,1)),log(PlotStore(:,4)),'.');
    hold on
    plot(log(PlotStore(:,1)),log(smooth(PlotStore(:,4))),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Charges Reaching Drain');
    subplot(2,2,4);
    plot(log(PlotStore(:,1)),log(PlotStore(:,5)),'.');
    hold on
    plot(log(PlotStore(:,1)),log(smooth(PlotStore(:,5))),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Charges within System');
    
    %Smooth vs other plot
    figure(FigNum);
    FigNum = FigNum+1;
    set(gcf,'position',[ 10 90 900 800])
    
    subplot(2,2,1);
    hold on
    plot(log(PlotStore(:,1)),(log(temp)),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Current');
    
    subplot(2,2,2);
    hold on
    plot(log(PlotStore(:,1)),log(PlotStore(:,3)),'.');
    xlabel('Time [s]');
    ylabel('Charges Reaching Source Electrode');
    
    subplot(2,2,3);
    hold on
    plot(log(PlotStore(:,1)),log(smooth(PlotStore(:,4))),'LineWidth',2);
    xlabel('Time [s]');
    ylabel('Charges Reaching Drain');
    
    subplot(2,2,4);
    hold on
    plot(log(PlotStore(:,1)),log(smooth(PlotStore(:,5))),'LineWidth',2);
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
    ylabel('Current');
    subplot(2,2,2);
    hold on
    plot(PlotStore(:,1),PlotStore(:,3));
    xlabel('Time [s]');
    ylabel('Charges Reaching Source Electrode');
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
    hold on
    plot(log(PlotStore(:,1)),log(PlotStore(:,2)));
    xlabel('Time [s]');
    ylabel('Current');
    subplot(2,2,2);
    hold on
    plot(log(PlotStore(:,1)),log(PlotStore(:,3)));
    xlabel('Time [s]');
    ylabel('Charges Reaching Source Electrode');
    subplot(2,2,3);
    hold on
    plot(log(PlotStore(:,1)),log(PlotStore(:,4)));
    xlabel('Time [s]');
    ylabel('Charges Reaching Drain');
    subplot(2,2,4);
    hold on
    plot(log(PlotStore(:,1)),log(PlotStore(:,5)));
    xlabel('Time [s]');
    ylabel('Charges within System');
end

    figure(100);
    hold on
    avg = mean(PlotStore(:,7));
    
    v_avg = v_sum/TotalNumberCharges;
    if(code==1)
        Efield = Voltage/Distance;
        mobility = v_avg/Efield;
        fprintf('Mobility in X direction %g [cm^2/Vs] in Efield %g [V/cm]\n',mobility,Efield);
    elseif(code==2)
        Efield = Voltage/Distance;
        mobility = v_avg/Efield;
        fprintf('Mobility in Y direction %g [cm^2/Vs] in Efield %g [V/cm]\n',mobility,Efield);
    else
        Efield = Voltage/Distance;
        mobility = v_avg/Efield;
        fprintf('Mobility in Z direction %g [cm^2/Vs] in Efield %g [V/cm]\n',mobility,Efield);
        
    end
    
end
