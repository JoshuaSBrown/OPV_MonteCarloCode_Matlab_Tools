%Generate avi movie
clear
close all
fclose all

dir = pwd;

list = ls;

[values, ~] = strsplit(list(1,:),'.xyz');
large = length(values);
r = large;
j=1;
k=1;
NumberList = [];

for i=1:large

    str = list(1,:);
    [str, str2] = strsplit(str,'.xyz');
    if isempty(str2)~=1
        [str, ~]=strsplit( str{i},'R1');
        if( exist('SaveStr','var')==0)
            SaveStr{k}=str{1};
            k=k+1;
        else
            flag=0;
            [~,cols]=size(SaveStr);
            for l=1:cols
                if (strcmp(SaveStr{l},str{1}))
                    flag=1;
                    break;
                end
            end

            if(flag==0)
                SaveStr{k}=str{1};
                k=k+1;
            end
        end
        
        if(length(str)<2)
           r = large-1;
           break; 
        end
        number = str2num(str{2});
        display(number)
        NumberList = [NumberList; number];
        j=j+1;
    end
end

NumberLarge = max(NumberList);
[~,cols2] = size(SaveStr);

Avg = 1;
%Now sorting through the different files we are going to create a movie
for i=1:cols2
    
    FileNameTentative = strcat(SaveStr{i},'R1');
    FileNameTentative2 = strcat(SaveStr{i},'R1Vel');
    flag2 = 0;
    mkdir(FileNameTentative2);
    
    ChargesReachElec = zeros(NumberLarge,1);
    MaxCharge2D = zeros(NumberLarge,1);
    MaxChargeHist = zeros(NumberLarge,1);
    
    MV_old = 0;
    NumCharges = 0;
    Vmin = 0;
    Vmax = 0;
    Vavg = zeros(NumberLarge-1,1);
    TimInc = zeros(NumberLarge-1,1);
    count = 1;
    count2 = 1;
    count3 = 1;
    Vel_5 = 0;
    Vedge = 0;
    Vmin_avg = zeros(10,1);
    Vmax_avg = zeros(10,1);
    maxID = 0;
    %cycle throught the numberlist
%     for j=1:NumberLarge
%         
%         FileName = strcat(dir,'/',FileNameTentative,num2str(j-1),'.xyz');
%         
%         if exist(FileName,'file')
%             [MV, Dimensions, SiteDist, TimeStamp]=ReadMovieData2(FileName);
%             
%             if (flag2==0)
%                 flag2 = 1;
%                 X = ones(Dimensions(1,1)+1,Dimensions(3,1)+1);
%                 Z = ones(Dimensions(1,1)+1,Dimensions(3,1)+1);
%                
%                 xarray = 0:Dimensions(1,1);
%                 zarray = 0:Dimensions(3,1);
%                 
%                 for k=1:(Dimensions(3,1)+1)
%                     X(:,k) = X(:,k).*xarray';
%                 end
%                 
%                 for l=1:(Dimensions(1,1)+1)
%                     Z(l,:) = Z(l,:).*zarray;
%                 end
%             end
%             
%             [~,Order] = sort(MV(:,4));
%             
%             if(length(MV)>NumCharges)
%                 NumCharges=length(MV);
%             end
%             %Reorder the Movie frame so that they are in order of
%             %chages id
%             MV = MV((Order(:)),:);
%             
%             if length(MV_old)~=1
%                 
%                 %Make sure that the lengths are the same
%                 if(length(MV_old)==length(MV))
%                    Vel = (MV(:,1)-MV_old(:,1))*SiteDist/(TimeStamp-TimeStamp_old);
%                    ID = MV(:,4);
%                 else
%                     
%                    %Find out how many differences exist based on the size
%                    %of the matrix
%                    if abs(length(MV_old))>abs(length(MV))
%                       MaxLen = length(MV_old);
%                    else
%                       MaxLen = length(MV);
%                    end
%                    
%                    lendiff = abs(length(MV_old)-length(MV));
%                    
%                    addtodiff = 0;
%                    inc_old = 0;
%                    inc_new = 0;
%                    m=1;
%                    while m<=(MaxLen-lendiff) && (m+inc_old)<(MaxLen-lendiff) && (m+inc_new)<(MaxLen-lendiff)
%                       
%                        if((m+inc_old)>length(MV_old) || (m+inc_new)>length(MV))
%                           display('Stop') 
%                        end
%                        
%                        while MV_old(m+inc_old,4)~=MV(m+inc_new,4)
%                            
%                            addtodiff = addtodiff+1;
%                            if MV_old(m+inc_old,4)<MV(m+inc_new,4)
%                                inc_old = inc_old+1;
%                            elseif MV(m+inc_new,4)<MV_old(m+inc_old,4)
%                                inc_new = inc_new+1;
%                            end
%                            
%                        end
%                        m=m+1;
%                    end
%                    
%                    diff = lendiff+addtodiff;
%                    
%                    %MV_old can have smaller size if a charge hops to an
%                    %electrode and then re-enters the system again. 
%                    if length(MV_old)<length(MV)
%                        small=length(MV_old);
%                    else
%                        small=length(MV);
%                    end
%                    
%                    MV2 = MV;
%                    
%                    m = 1;
%                    while m<=diff
%                         %Find first difference
%                         firstOccurance = find(MV2(1:small,4)~=MV_old(1:small,4)==1,1);
%                         if isempty(firstOccurance)~=1
%                             if firstOccurance == 0
%                                 if length(MV_old)>length(MV2)
%                                     MV_old = [MV_old(1:firstOccurance-1,:) ; MV_old(firstOccurance+1:end,:)];
%                                 else
%                                     MV2 = [MV2(1:firstOccurance-1,:) ; MV2(firstOccurance+1:end,:)];
%                                 end
%                             else
%                                 
%                                 if(MV2(firstOccurance,4)>MV_old(firstOccurance,4))
%                                     MV_old = [MV_old(1:firstOccurance-1,:); MV_old(firstOccurance+1:end,:)];
%                                 else
%                                     MV2 = [MV2(1:firstOccurance-1,:); MV2(firstOccurance+1:end,:)];
%                                 end
%                                 if lendiff>abs(length(MV_old)-length(MV2))
%                                     lendiff = lendiff-1;
%                                     diff = diff-1;
%                                 end
%                                 
%                             end
%                             if length(MV_old)<length(MV2)
%                                 small=length(MV_old);
%                             else
%                                 small=length(MV2);
%                             end
%                         end
%                         m=m+1;
%                    end
%                    if length(MV2)~=length(MV_old)
%                       display('stop') 
%                    end
%                    Vel = (MV2(:,1)-MV_old(:,1))*SiteDist/(TimeStamp-TimeStamp_old);
%                    ID = MV2(:,4);
%                 end
%                 
%                 CurrentNumCharges = length(MV_old)
%                 
%                 if j==2
%                     Vmin = min(Vel);
%                     Vmax = max(Vel);
%                     
%                     Vmin_avg(:,1) = Vmin;
%                     Vmax_avg(:,1) = Vmax;
%                 else
%                     Vmin_avg(count3,1) = Vmin;
%                     Vmax_avg(count3,1) = Vmax;
%                 end
%                 
%                 if count3==10
%                    count3 = 1;
%                 else
%                     count3=count3+1;
%                 end
%                    
%                 
%                 if mean(Vmin_avg)>Vmin*0.9
%                     Vmin = Vmin+abs(Vmin)*0.1;
%                 elseif mean(Vmin_avg)<Vmin*1.1
%                     Vmin = Vmin-abs(Vmin)*0.1;
%                 end
%                 
%                 if mean(Vmax_avg)>Vmax*1.1
%                     Vmax = Vmax+Vmax*0.1;
%                 elseif mean(Vmax_avg)<Vmax*0.9
%                     Vmax = Vmax-Vmad*0.1;
%                 end
%                 
%                 
%                 h=figure(1);
%                 
% %                 if min(Vel)*0.9<Vmin
% %                     Vmin = min(Vel)*0.9;
% %                 end
% %                 if max(Vel)*0.9>Vmax
% %                     Vmax = max(Vel)*0.9;
% %                 end
%                 
%                 Res = 30;
%                 if rem(Res,2)==1
%                    error('Must use a resolution that is even other wise charges with 0 velocity will be placed as positive or negative value when binned!'); 
%                 end
%                 
%                 bin = zeros(Res,1);
%                 
%                 if abs(Vmin)>abs(Vmax)
%                    if abs(Vmin)*0.2>Vedge
%                        if abs(Vmin)*0.2>600
%                            Vedge = abs(Vmin)*0.2;
%                        else
%                            Vedge = 600;
%                        end
%                    end
%                 else
%                     if Vmax*0.2>Vedge
%                         if abs(Vmax)*0.2>600
%                             Vedge = abs(Vmax)*0.2;
%                         else
%                             Vedge = 600; 
%                         end
%                     end
%                 end
%                 
%                 if maxID<max(ID)
%                     diff = max(ID) - maxID;
%                     for n=1:diff
%                         Vel_5 = [Vel_5; 0 ];
%                     end
%                     maxID = max(ID);
%                     ID_Vel_5 = ones(maxID+1,1).*linspace(0,maxID,maxID+1)';
%                 end
%                 
%                 for n=1:length(Vel)
%                     Vel_5(ID(n)+1,1)=Vel_5(ID(n)+1,1)+Vel(n);
%                 end
%                 
%                 Resolution2 = 15;
%                 if count == Resolution2
%                     
%                     %Average
%                     Vel_5 = Vel_5/Resolution2;
%                     
%                     range = linspace(-Vedge,Vedge,Res);
%                     Vinc = range(2)-range(1);
%                     Lend = sum(Vel_5<-Vedge);
%                     Hend = sum(Vel_5>Vedge);
%                     for n=1:Res
%                         bin(n,1) = sum(Vel_5<(-Vedge+Vinc*n))-Lend;
%                         Lend = Lend+bin(n,1);
%                     end
%                     
%                     count = 1;
%                     hh = bar((range+Vinc/2),bin/CurrentNumCharges,'EdgeColor','none','BarWidth', 1);
%                     hold on
%                     
%                     plot((range+Vinc/2),smooth(bin/CurrentNumCharges),'r','LineWidth',2);
%                     set(gcf,'Color','w');
%                     ylim([0 0.70])
%                     xlim([-0.5*10^4 1*10^4])
%                     xlabel('Velocity [m/s]')
%                     ylabel('Percentage of Charges')
%                     if(TimeStamp>3.555*10^-9)
%                        display('Stop'); 
%                     end
%                     titleStr = sprintf('Time: %g [s]',TimeStamp);
%                     title(titleStr);
%                     saveas(h,strcat(FileNameTentative2,'\',FileNameTentative2,'Frame',num2str(count2),'.jpg'))
%                     count2=count2+1;
%                     close gcf;
%                     
%                     Vel_5(:) = 0;
%                     
%                 end
%                 
%                 count = count+1;
%                 Vavg(j-1,1) = mean(Vel);
%                 TimeInc(j-1,1) = (TimeStamp+TimeStamp_old)/2;
%                 
%             end
%             
%             maxID = max(MV(:,4));
%             Vel_5 = zeros(maxID+1,1);
%             MV_old = MV;
%             TimeStamp_old = TimeStamp;
%         end
%     end
    make_video(strcat(FileNameTentative2,'\'),'jpg',strcat(FileNameTentative2,'.avi'),5)
end

figure(2);
h=plot(TimeInc,Vavg,'LineWidth',2);
set(gcf,'Color','w')
xlabel('Time [s]');
ylabel('Avg Vel [m/s]')
saveas(h,strcat(FileNameTentative2,'AvgVel','.jpg'))
                
display(SaveStr)

