function PlotCurrentData( FileName )

fid = fopen(FileName);

%How many points should be plotted. 
%If there are fewer than 40 datapoints
%Then all of them are plotted
Resolution = 40;
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

%Put data in separate matrix
TStore = Store(1:count,:);

count3 = 0;
count4 = 0;

Elem = zeros(1,col);

if(count>Resolution)

    %How many points are used to average by
    inc = count/Resolution;
    limit = inc;
    divisor = 0;
  
    PlotStore = zeros(Resolution,col);
    
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
    PlotStore = TStore;
end 
%Clear store variable to save space
clear Store

%Normal plots
if (col==2)
    figure(1);
    hold on
    plot(PlotStore(:,1),PlotStore(:,2));
    xlabel('Time [s]');
    ylabel('Current');
    set(gcf,'color','w');
else
    figure(1);
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
    
    %log log plot
    figure(2);
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

end
