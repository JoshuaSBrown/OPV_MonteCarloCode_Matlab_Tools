function SmoothPlot(FileName)

close all;
openfig(FileName);

subplot(2,2,3);
f = gcf;
graphic = gca;
D=get(graphic,'Children'); %get the handle of the line object
XData=get(D,'XData'); %get the x data
YData=get(D,'YData'); %get the y data

[col, ~] = size(XData);

figure(200);
hold on
xlabel('Time [s]');
ylabel('Charges Reaching Drain');
set(gcf,'color','w')
index = col;
for i=1:col
   
    X1 = XData{i};
    Y1 = YData{i};
    
    ax = gca;
    ax.ColorOrderIndex = index;
    color = ax.ColorOrderIndex;
    h1 = plot(X1,Y1,'LineWidth',2);
    h1.Color(4)=0.2;
    
    temp = Y1;
    for j=1:100
       temp = smooth(temp); 
    end
    
    ax2 = gca;
    ax2.ColorOrderIndex = color;
    h(i) = plot(X1,temp,'LineWidth',2);
    
    index= index-1;
end

figure(f)
subplot(2,2,1);
D=get(gca,'Children'); %get the handle of the line object
XData=get(D,'XData'); %get the x data
YData=get(D,'YData'); %get the y data

[col, ~] = size(XData);

figure(201);
hold on
xlabel('Time [s]');
ylabel('Current [Arb Units]');
set(gcf,'color','w')
index = col;
for i=1:col
   
    X1 = XData{i};
    Y1 = YData{i};
    
    ax = gca;
    ax.ColorOrderIndex = index;
    color = ax.ColorOrderIndex;
    h1 = plot(X1,Y1,'LineWidth',2);
    h1.Color(4)=0.1;
    
    temp = Y1;
    for j=1:100
       temp = smooth(temp); 
    end
    
    ax2 = gca;
    ax2.ColorOrderIndex = color;
    h2(i) = plot(X1,temp,'LineWidth',2);
    
    index= index-1;
end



end