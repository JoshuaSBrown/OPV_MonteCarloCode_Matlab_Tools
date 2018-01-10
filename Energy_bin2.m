function Energy_bin2( FileName )
%This function takes the input of an .xyz file plots the energies in a
%histogram

%Unlike previous version we will start using a fixed energy increment
%Resolution and min and max value

bins = 300;
EnergyMin = -5.7;
EnergyMax = -4.8;

close all
ext = FileName(end-3:end);
core = FileName(1:end-4);
if(strcmp(ext,'.xyz')~=1)
    error('File is not of the .xyz file type');
end
    
if(bins<=0)
   error('The number of bins must be greater than 0'); 
end

fid = fopen(FileName);
TotalLines = str2double(fgetl(fid));

Energies = zeros(TotalLines,1);
fgetl(fid);

C = textscan(fid,'%s %f %f %f %f %f');
Energies(:,1) = C{5};
clear C;

fclose(fid);

Energies = sort(Energies);

Ma = max(Energies);
Mi = min(Energies);
E0 = mean(Energies);

% if(abs(Ma-E0)>abs(Mi-E0))
%     inc = abs(Ma-E0)*2/(bins+1);
% else
%     inc = abs(Mi-E0)*2/(bins+1);
% end

Mi = EnergyMin;
Ma = EnergyMax;
inc = (EnergyMax-EnergyMin)/(bins+1);

%x_axis = linspace(Mi+inc/2,Ma-inc/2,bins);
x_axis = linspace(EnergyMin+inc/2,EnergyMax-inc/2,bins);
Count_Init = zeros(bins,1);

%Len = Mi;
Len = EnergyMin;
Cutoff = 1;
Bins_Stat_NON_Viable = 0;
Bins_Stat_NON_Viable2 = 0;
Init_Flag = 0;

Eval = zeros(bins,1);
En = Mi+inc/2;
num = 1;

Count_Init(1,1) = sum(Energies<(Mi+inc));
if(Count_Init(1,1)<Cutoff && Init_Flag ==0)
    Bins_Stat_NON_Viable = Bins_Stat_NON_Viable+1;
end

for i=2:bins
    
    Count_Init(i,1) = sum(Energies<(Mi+inc*i))-sum(Count_Init(1:i,1));

    if(Count_Init(i,1)<Cutoff && Init_Flag ==0 && En<-5.2)
        Bins_Stat_NON_Viable = Bins_Stat_NON_Viable+1;
    elseif(En>-5.2 && Count_Init(i,1)<Cutoff)
        Bins_Stat_NON_Viable2 = Bins_Stat_NON_Viable2+1;
    else
        Init_Flag = 1;
        Eval(num) = En;
        num = num+1;
    end
    
    En = En+inc;
    
end

Count = Count_Init(Bins_Stat_NON_Viable+1:length(Count_Init)-Bins_Stat_NON_Viable2);
fprintf('Number of Bins after trimming statistically small data %d\n',length(Count));

fid = fopen(strcat(FileName(1:length(FileName)-4),'Bin.txt'),'w');
for i=1:length(Count)
    
   fprintf(fid,'%g %g\n',Eval(i) ,Count(i)); 
    
end

fclose(fid);
