function ScherMontrol( FileName )
%This function will calculate the mobility 
close all;
fclose all;

startfit = 150;
endfit = 1000;
Resolution = 5000;
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
            count3/count;
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
if(col~=7)
   error('Need 7 columned file\n');
   exit(1);
end

temp = smooth(PlotStore(:,6));
co = 1;
while( isempty(find(0==temp,1))~=1 && co<9)
    temp = smooth(temp);
    co = co+1;
end

%Compare with other figures Figure 2
figure(FigNum);
set(gcf,'position',[ 10 90 900 400])
subplot(1,2,1);
hold on
plot(PlotStore(:,1),smooth(PlotStore(:,2)),'LineWidth',2);
xlabel('Time [s]');
ylabel('Current [A]');
set(gca,'FontSize',16);

yy1 = smooth(log(PlotStore(:,1)),log(temp),0.2,'loess');

temp = smooth(PlotStore(:,7));
co = 1;
while( isempty(find(0==temp,1))~=1 && co<9)
    temp = smooth(temp);
    co = co+1;
end
yy3 = smooth(log(PlotStore(:,1)),log(temp),0.2,'rloess');

%log log plot
temp = smooth(PlotStore(:,2));
co = 1;
while( isempty(find(0==temp,1))~=1 && co< 9)
    temp = smooth(temp);
    co = co+1;
end

val = length(temp);
Low_mean = 0;
i = 0;
while i<endfit
    if temp(val)>0
        Low_mean = log(temp(val))+Low_mean;
        i = i+1;
    end
    val = val-1;
end

Low_mean = Low_mean/endfit;

finish = length(PlotStore(:,1));
for i=1:length(temp)
    if temp(i)<=0
        finish = i-1;
        break
    end
    if log(temp(i))<Low_mean
        finish = i-1;
        break
    end
end

rval = 0;

i = startfit;
index = 1;
while i<(finish-endfit)
    [xData, yData] = prepareCurveData(log(PlotStore(1:i,1)),log(temp(1:i,1)));
    ft = fittype('poly1');
    [fitresult,gof] = fit(xData,yData,ft);
    
    [xData, yData] = prepareCurveData(log(PlotStore(i:finish,1)),log(temp(i:finish,1)));
    ft2 = fittype('poly1');
    [fitresult2,gof2] = fit(xData,yData,ft2);
    
    if sqrt(gof.rsquare^2+gof2.rsquare^2)>rval
        rval = sqrt(gof.rsquare^2+gof2.rsquare^2);
        index = i;
        fprintf('rval %f index %d\n',rval,index);
        fitresult_final = fitresult;
        fitresult_final2 = fitresult2;
    end
    h = figure(10);
    hold on
    y = log(PlotStore(:,1))*fitresult.p1+fitresult.p2;
    y2 = log(PlotStore(:,1))*fitresult2.p1+fitresult2.p2;
    plot(log(PlotStore(:,1)),log(temp));
    plot(log(PlotStore(:,1)),y);
    plot(log(PlotStore(:,1)),y2);
    close(h);
    i = i + 20;
end


y = exp(log(PlotStore(1:finish,1))*fitresult_final.p1+fitresult_final.p2);
y2 = exp(log(PlotStore(1:finish,1))*fitresult_final2.p1+fitresult_final2.p2);
    
Efield = Voltage/Distance;
transitTime = exp((fitresult_final.p2-fitresult_final2.p2)/(fitresult_final2.p1-fitresult_final.p1));
vel_transit = Distance/transitTime;
mob_transit = vel_transit/Efield;

t = (PlotStore(1:finish,1));

h=figure(FigNum);
subplot(1,2,2);
hold on
set(gca,'xscale','log');
set(gca,'yscale','log');
plot((PlotStore(:,1)),((temp)),'LineWidth',1);
xlabel('Time [s]');
ylabel('Current [A]');
set(gca,'FontSize',16);
hold on
plot(t,y,'k');
plot(t,y2,'k');
axis([min((PlotStore(:,1))) (PlotStore(finish+40,1)) ...
    (temp(finish-1,1)) max((temp(1:finish-1,1)))*1.1]	);
set(gcf,'Color','w');
subplot(1,2,1);
axis([0 PlotStore(finish,1) 0 max(temp)]);
saveas(h,'ScherMontroll','fig');

fidScherMontroll = fopen('ScherMontroll.txt','w');
fprintf('Alpha High %f Alpha Low %f\n',1-abs(fitresult_final.p1),abs(fitresult_final2.p1)-1);
fprintf(fidScherMontroll,'Alpha High %f Alpha Low %f\n',1-abs(fitresult_final.p1),abs(fitresult_final2.p1)-1);

avg = mean(PlotStore(:,7));

v_avg = v_sum/TotalNumberCharges;


if(code==1)

    mobility = v_avg/Efield;
    fprintf('Mobility in X direction %g [cm^2/Vs] in Efield %g [V/cm]\n',mobility,Efield);
    fprintf('Transit Mobility in X direction %g [cm^2/Vs] in Efield %g [V/cm]\n',mob_transit,Efield);
    fprintf(fidScherMontroll,'\nMobility in X direction %g [cm^2/Vs] in Efield %g [V/cm]\n',mobility,Efield);
    fprintf(fidScherMontroll,'\nTransit Mobility in X direction %g [cm^2/Vs] in Efield %g [V/cm]\n',mob_transit,Efield);
elseif(code==2)
    
    mobility = v_avg/Efield;
    fprintf('Mobility in Y direction %g [cm^2/Vs] in Efield %g [V/cm]\n',mobility,Efield);
    fprintf('Transit Mobility in Y direction %g [cm^2/Vs] in Efield %g [V/cm]\n',mob_transit,Efield);
    fprintf(fidScherMontroll,'\nMobility in Y direction %g [cm^2/Vs] in Efield %g [V/cm]\n',mobility,Efield);
    fprintf(fidScherMontroll,'\nTransit Mobility in Y direction %g [cm^2/Vs] in Efield %g [V/cm]\n',mob_transit,Efield);
else
    
    mobility = v_avg/Efield;
    fprintf('Mobility in Z direction %g [cm^2/Vs] in Efield %g [V/cm]\n',mobility,Efield);
    fprintf('Transit Mobility in Z direction %g [cm^2/Vs] in Efield %g [V/cm]\n',mob_transit,Efield);
    fprintf(fidScherMontroll,'\nMobility in Z direction %g [cm^2/Vs] in Efield %g [V/cm]\n',mobility,Efield);
    fprintf(fidScherMontroll,'\nTransit Mobility in Z direction %g [cm^2/Vs] in Efield %g [V/cm]\n',mob_transit,Efield);
end

fclose(fidScherMontroll);
end
