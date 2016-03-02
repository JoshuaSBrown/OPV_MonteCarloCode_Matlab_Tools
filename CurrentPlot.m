%This script plots the Average current (fig 1) Average Num Charges in the 
%material (fig 2) and the Average num charges to reach the electrode (fig
%3) in the current directory. 


fid=fopen('t-I.txt','r');
rng('shuffle');
col=[rand rand rand];

fgetl(fid);
A=fgetl(fid);
sizeS=10000;
Store=zeros(sizeS,4);
count=0;
count2=0;

figure(1)
hold all
xlabel('Time [s]');
ylabel('Average Current');
set(groot,'defaultAxesColorOrder',col)

figure(2)
hold all
xlabel('Time [s]');
ylabel('Average Number of Charges in the material');


figure(3)
hold all
xlabel('Time [s]');
ylabel('Average Number of Charges to reach electrode');
hold off

figure(4);
if (ishandle(4))
    hold on
end
set(gca,'yscale','log')
xlabel('Time [s]');
ylabel('Average Current');

figure(5)
if (ishandle(5))    
    hold on
end
set(gca,'yscale','log')
xlabel('Time [s]');
ylabel('Average Number of Charges in the material');

figure(6)
if (ishandle(6))
    hold on
end
set(gca,'yscale','log')
xlabel('Time [s]');
ylabel('Average Number of Charges to reach electrode');

figure(7);
if (ishandle(7))
    hold on
end
set(gca,'yscale','log')
set(gca,'xscale','log')
xlabel('Time [s]');
ylabel('Average Current');

figure(8)
if (ishandle(8))    
    hold on
end
set(gca,'yscale','log')
set(gca,'xscale','log')
xlabel('Time [s]');
ylabel('Average Number of Charges in the material');

figure(9)
if (ishandle(9))
    hold on
end
set(gca,'yscale','log')
set(gca,'xscale','log')
xlabel('Time [s]');
ylabel('Average Number of Charges to reach electrode');

figure(10);
if (ishandle(10))
    hold on
end
set(gca,'xscale','log')
xlabel('Time [s]');
ylabel('Average Current');

figure(11)
if (ishandle(11))    
    hold on
end
set(gca,'xscale','log')
xlabel('Time [s]');
ylabel('Average Number of Charges in the material');

figure(12)
if (ishandle(12))
    hold on
end
set(gca,'xscale','log')
xlabel('Time [s]');
ylabel('Average Number of Charges to reach electrode');

while (  A~=-1 )
    
    B=str2num(A);
%     count=count+1;
    count2=count2+1;
    Store(count2,1:4)=B;
%     if ((count+1)>100)
%         Store=[Store; zeros(100,4)];
%         
%         count=0;
%     end
    A=fgetl(fid);
    if rem(count2,sizeS)==0 
       figure(1)
       hold on
       plot(Store(1:count2,1),Store(1:count2,2));
       
       figure(2)
       hold all
       plot(Store(1:count2,1),Store(1:count2,3));
       
       figure(3)
       hold all
       plot(Store(1:count2,1),Store(1:count2,4));
       
       figure(4);
       if (ishandle(4))
           hold on
       end
       plot(Store(1:count2,1),Store(1:count2,2));
       
       figure(5)
       if (ishandle(5))
           hold on
       end
       plot(Store(1:count2,1),Store(1:count2,3));
       
       figure(6)
       if (ishandle(6))
           hold on
       end
       plot(Store(1:count2,1),Store(1:count2,4));
       
       figure(7);
       if (ishandle(7))
           hold on
       end
       plot(Store(1:count2,1),Store(1:count2,2));
       
       figure(8)
       if (ishandle(8))
           hold on
       end
       plot(Store(1:count2,1),Store(1:count2,3));
       
       figure(9)
       if (ishandle(9))
           hold on
       end
       plot(Store(1:count2,1),Store(1:count2,4));
       
       figure(10);
       if (ishandle(10))
           hold on
       end
       plot(Store(1:count2,1),Store(1:count2,2));
       
       figure(11)
       if (ishandle(11))
           hold on
       end
       plot(Store(1:count2,1),Store(1:count2,3));
       
       figure(12)
       if (ishandle(12))
           hold on
       end
       plot(Store(1:count2,1),Store(1:count2,4));

       count2=0;
       clear Store
    end
end


fclose(fid);
