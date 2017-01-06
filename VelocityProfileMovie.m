%Generate avi movie
%This script useses the .xyz files to create a velocity profile 
clear
close all
fclose all

dir = pwd;

list = ls;

[r, c]=size(list);


j=1;
k=1;
for i=1:r

    str = list(i,:);
    [str, str2] = strsplit(str,'.xyz');
    if isempty(str2)~=1
        [str, ~]=strsplit( str{1},'R1');
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
        number = str2num(str{2});
        display(number)
        NumberList(j,1) = number;
        j=j+1;
    end
end

NumberLarge = max(NumberList);
[~,cols2] = size(SaveStr);

Avg = 30;
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
    %cycle throught the numberlist
    for j=1:NumberLarge
        
        FileName = strcat(dir,'\',FileNameTentative,num2str(j),'.xyz');
        
        if exist(FileName,'file')
            [MV, Dimensions, SiteDist, TimeStamp]=ReadMovieData2(FileName);
            
            if (flag2==0);
                flag2 = 1;
                X = ones(Dimensions(1,1)+1,Dimensions(3,1)+1);
                Z = ones(Dimensions(1,1)+1,Dimensions(3,1)+1);
               
                xarray = 0:Dimensions(1,1);
                zarray = 0:Dimensions(3,1);
                
                for k=1:(Dimensions(3,1)+1)
                    X(:,k) = X(:,k).*xarray';
                end
                
                for l=1:(Dimensions(1,1)+1)
                    Z(l,:) = Z(l,:).*zarray;
                end
            end
            
            [~,Order] = sort(MV(:,4));
            
            if(length(MV)>NumCharges)
                NumCharges=length(MV);
            end
            %Reorder the Movie frame so that they are in order of
            %chages id
            MV = MV((Order(:)),:);
            
            if length(MV_old)~=1
                
                %Make sure that the lengths are the same
                if(length(MV_old)==length(MV))
                   Vel = (MV(:,1)-MV_old(:,1))*SiteDist/(TimeStamp-TimeStamp_old);
                else
                   %Find out how many differences exist
                   diff = abs(length(MV_old)-length(MV));
                   
                   %MV_old can have smaller size if a charge hops to an
                   %electrode and then re-enters the system again. 
                   if length(MV_old)<length(MV)
                       small=length(MV_old);
                   else
                       small=length(MV);
                   end
                   
                   MV2 = MV;
                   
                   for m=1:diff
                        %Find first difference
                        firstOccurance = find(MV2(1:small,4)~=MV_old(1:small,4)==1,1);
                        if firstOccurance == 0
                            if length(MV_old)>length(MV2)
                                MV_old = [MV_old(1:firstOccurance-1,:) ; MV_old(firstOccurance+1:end,:)];
                            else
                                MV2 = [MV2(1:firstOccurance-1,:) ; MV2(firstOccurance+1:end,:)];
                            end
                        else
                            if length(MV_old)>length(MV2)
                                MV_old = MV_old(1:length(MV_old)-1,:);
                            else
                                MV2 = MV2(1:length(MV2)-1,:);
                            end
                        end
                   end
                   Vel = (MV2(:,1)-MV_old(:,1))*SiteDist/(TimeStamp-TimeStamp_old);
                   
                end
                
                h=figure(1)
                
                if min(Vel)*0.9<Vmin
                    Vmin = min(Vel)*0.9;
                end
                if max(Vel)*0.9>Vmax
                    Vmax = max(Vel)*0.9;
                end
                
                Res = 30;
                if rem(Res,2)==1
                   error('Must use a resolution that is even other wise charges with 0 velocity will be placed as positive or negative value when binned!'); 
                end
                
                bin = zeros(Res,1);
                
                if abs(Vmin)>abs(Vmax)
                   Vedge = abs(Vmin); 
                else
                   Vedge = abs(Vmax);
                end
                
                Vel_5 = Vel+Vel_5;
                
                if count ==5
                    
                    %Average
                    Vel_5 = Vel_5/5;
                    
                    range = linspace(-Vedge,Vedge,Res);
                    Vinc = range(2)-range(1);
                    Lend = sum(Vel_5<Vmin);
                    Hend = sum(Vel_5>Vmax);
                    for n=1:Res
                        bin(n,1) = sum(Vel_5<(Vmin+Vinc*n))-Lend;
                        Lend = Lend+bin(n,1);
                    end
                    
                    count = 1;
                    hh = bar((range+Vinc/2),bin/NumCharges,'EdgeColor','none');
                    hold on
                    plot((range+Vinc/2),bin/NumCharges,'LineWidth',2);
                    set(gcf,'Color','w');
                    ylim([0 1])
                    xlabel('Velocity [m/s]')
                    ylabel('Percentage of Charges')
                    saveas(h,strcat(FileNameTentative2,'\',FileNameTentative2,'Frame',num2str(j-1),'.jpg'))
                    close gcf;
                end
                
                count = count+1;
                Vavg(j-1,1) = mean(Vel);
                TimeInc(j-1,1) = (TimeStamp+TimeStamp_old)/2;
                
            end
            MV_old = MV;
            TimeStamp_old = TimeStamp;
        end
    end
    make_video(strcat(FileNameTentative2,'\'),'jpg',strcat(FileNameTentative2,'.avi'),5)
end

figure(2);
h=plot(TimeInc,Vavg,'LineWidth',2);
set(gcf,'Color','w')
xlabel('Time [s]');
ylabel('Avg Vel [m/s]')
saveas(h,strcat(FileNameTentative2,'AvgVel','.jpg'))
                
display(SaveStr)

