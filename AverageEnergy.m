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

fid = fopen('../DataT300Vx15Vy0Vz0R1Energy.xyz','r');
D = textscan(fid,'%s %d %d %d %f %f\n','HeaderLines',2);
fclose(fid);
EnergyVals = D{5};
EnergyArray = zeros(NumberLarge,1);
TimeArray = zeros(NumberLarge,1);
FileName = 'DataT300Vx15Vy0Vz0R1';
for i=1:NumberLarge
    FileNameTemp = strcat(FileName,num2str(i),'.xyz');
    fid = fopen(FileNameTemp,'r');
    C = textscan(fid,'%s %d %d %d %f %f\n','HeaderLines',2);
    fclose(fid);
    Array = C{5};
    NumCharges = sum(Array~=-1);
    EnergySum = 0;
    for j=1:length(Array)
        if Array(j)~=-1
            EnergySum = EnergySum+EnergyVals(j);
        end
    end
    MeanEnergy = EnergySum/NumCharges;
    figure(1);
    hold on
    plot(i,MeanEnergy,'bo');
    EnergyArray(i,1)=MeanEnergy;
    clear C;
    display('Stop');
    
    fid = fopen(FileNameTemp);
    line = fgetl(fid);
    fclose(fid);
    Digits = sscanf(line,'%d %f %d %d %d %f');
    TimeStamp = Digits(2);
    TimeArray(i,1)=TimeStamp;
end
 
figure(2)
plot(TimeArray,smooth(smooth(smooth(smooth(smooth(EnergyArray))))),'LineWidth',2)
hold on
plot(TimeArray,EnergyArray)
ylabel('Energy [eV]')
xlabel('Time [s]')
set(gcf,'Color','w')
set(gca,'FontSize',16)
save('TimeMeanEnergy','TimeArray', 'EnergyArray');
display(SaveStr)

