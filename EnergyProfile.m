function EnergyProfile(FileEnergy)

%Generate avi movie of the Energy of the sites that the charges are
%utilizing
close all

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

%Read Energy file 
fid = fopen(FileEnergy);
C = textscan(fid,'%s %d %d %d %f %f\n','HeaderLines',2);
fclose(fid);
xsize = max(C{2});
ysize = max(C{3});
zsize = max(C{4});

Energies = zeros(xsize+1,ysize+1,zsize+1);

Eng = C{5};

Emin = min(Eng);
Emax = max(Eng);
Erange = max(Eng)-min(Eng);
bins = 100;
E_inc = Erange/bins;
Evalues = min(Eng)+E_inc/2+linspace(0,99,100)*E_inc;

Bins = zeros(bins,1);
BinsT = zeros(bins,1);
inc = 1;
for i=1:(xsize+1)
    for j=1:(ysize+1)
       for k=1:(zsize+1)
          Energies(i,j,k) = Eng(inc);
          inc = inc+1;
       end
    end
end

AvgE = 0;
AverageEng = 0;
TimeS = 0;0

%Data from how many files are combined 
Resolution = 5;
Res_inc = 1;
imageNum = 1;

%Now sorting through the different files we are going to create a movie
for i=1:cols2
    
    FileNameTentative = strcat(SaveStr{i},'R1');
    FileNameTentative2 = strcat(SaveStr{i},'R1energy');

    if ~exist(FileNameTentative2,'dir')
        mkdir(FileNameTentative2);
    end
    for j=1:NumberLarge
        
        FileName = strcat(dir,'/',FileNameTentative,num2str(j-1),'.xyz');
        
        if exist(FileName,'file')
            [ChargePos, SiteDist, TimeStamp]=ReadMovieData3(FileName);
            
            
            for k=1:length(ChargePos)
                AvgE = AvgE+Energies(ChargePos(k,1)+1,ChargePos(k,2)+1,ChargePos(k,3)+1);
                for l=1:bins
                    if Energies(ChargePos(k,1)+1,ChargePos(k,2)+1,ChargePos(k,3)+1)<=(Emin+l*E_inc)
                        Bins(l,1) = Bins(l,1)+1;
                    end
                end
            end
            
        end
        
        if j==1
           AverageEng = AvgE/length(ChargePos); 
           TimeS = TimeStamp;
        else
           AverageEng = [AverageEng ; AvgE/length(ChargePos)];
           TimeS = [TimeS; TimeStamp];
        end
        
        BinsT = BinsT+[Bins(1,1); Bins(2:end,1)-Bins(1:(end-1),1)];
        Bins = zeros(bins,1);
         if(Res_inc==Resolution)
            
            %plot and save figure
            h = figure('Position',[100,100,600,600]);
            barh(Evalues,BinsT/Resolution,'r','EdgeColor','none');
            hold on
            titleStr = sprintf('Time: %g [s]',TimeStamp);
            title(titleStr);
            Res_inc = 0;
            ylabel('Energy [eV]');
            xlabel('Number of Charges');
            axis([ 0 10 min(Eng) max(Eng)])
            set(gcf,'Color','w');
            saveas(h,strcat(dir,'/',FileNameTentative2,'/',FileNameTentative2,num2str(imageNum),'.jpg'))
            imageNum = imageNum+1;
            close all;
            BinsT = zeros(bins,1);
         end
        Res_inc = Res_inc+1;
    end
end

figure(2);
h=plot(TimeS,AverageEng,'LineWidth',2);
set(gcf,'Color','w')
xlabel('Time [s]');
ylabel('Energy [eV]')
saveas(h,strcat(FileNameTentative2,'AvgEnergy','.jpg'))
save('DataEnergyAvg',TimeS,AverageEng);            
display(SaveStr)

