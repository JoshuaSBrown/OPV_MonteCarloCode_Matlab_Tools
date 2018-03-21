function SeedDistDecayCorrelation( FileName, SeedEnergy )
%This function will look at the site Decay file and the distance of the
%decay site to the closest nucleation center and create a histogram, that
%way we can correlate the two. 

if exist('SiteDecay.txt','file')~=2 
    error('ERROR SiteDecay.txt file does not appear to exist');
end

endstr = length(FileName);
dist_ext = FileName(endstr-11:end);
ener_ext = FileName(endstr-9:end);
% Returns true (1) if same
if(strcmp(dist_ext,'DistFile.xyz')==1)
    DistFileName = FileName;
    % Check that the file exists
    if(exist(DistFileName,'file')~=2)
       % If it does not create it if the corresponding Energy.xyz file 
       % exists
       EnerFileName = strcat(FileName(1:end-12),'.xyz');
       if(exist(EnerFileName,'file')~=2)
           error('Energy file does not exist and neigther does distance file');
       end
       %If the energy file exists but the distance file does not create the
       %distance file
       MakeDistanceXYZFileFromEnergyFile( EnerFileName, SeedEnergy )
    end
elseif(strcmp(ener_ext,'Energy.xyz')==1)  
    DistFileName = strcat(FileName(1:end-4),'DistFile.xyz');
    % Check if the distance file already exists
    if(exist(DistFileName,'file')~=2)
        %If it does not create it 
        MakeDistanceXYZFileFromEnergyFile( FileName, SeedEnergy )
    end
else  
    error('Inappropriate file type for this function');
end

% Now we are going to open and read the distance file
fid = fopen(DistFileName);
TotalLines = str2double(fgetl(fid));
fgetl(fid);
C = textscan(fid,'%s %f %f %f %f');
fclose(fid);

%Turn data into a matrix
maxRow = max(C{2});
maxCol = max(C{3});
maxShe = max(C{4});

Dmatrix = zeros(maxRow+1,maxCol+1,maxShe+1);
%rowsD = length(C{1});
%colsD = 4;
%D = zeros(rowsD,colsD);
DistArray = C{5};
index = 1;
for i=1:maxRow
    for j=1:maxCol
        for k=1:maxShe
            Dmatrix(i,j,k) = DistArray(index);
            index=index+1;
        end
    end
end

% Now we are going to read the SiteDecay.txt file
fid = fopen('SiteDecay.txt');
% Time xpos ypos zpos
C = textscan(fid,'%f %d %d %d');
fclose(fid);
rowsF = length(C{1});
colsF = 3;
%Only want the position of the decay sites
F = zeros(rowsF,colsF);
for i=1:colsF
   F(:,i)=C{i+1};
end

NumberDecayedSites = length(F);
ArrayDecayDist = zeros(NumberDecayedSites,1);
for i=1:NumberDecayedSites
   x = F(i,1);
   y = F(i,2);
   z = F(i,3);
   ArrayDecayDist(i) = Dmatrix(x+1,y+1,z+1); 
end
% Now we want to create a bin system to bin the values 
Resolution = 60+1;
Distance = 60;
X = linspace(0,Distance,Resolution);
Xcent = (X(1:end-1)+X(2:end))./2;
% Determine the volume for each discretization
Volume = (X(2:end).^3-X(1:end-1).^3)*4/3*pi;
% Calculate the actual number of sites
counts = zeros(1,Resolution-1);
for m=2:Resolution
    count = 0;
    for i=1:Resolution
        for j=1:Resolution
            for k=1:Resolution
                DisLatPt = sqrt((i-1)^2+(j-1)^2+(k-1)^2);
                if(DisLatPt==0)
                    count = count+1;
                elseif(DisLatPt<X(m))
                    count = count +8;
                end
            end
        end
    end
    counts(m-1) = count;
end

for m=length(counts):-1:2
    counts(m) = counts(m)-counts(m-1);
end

% Returns the bin the data fits in
Y = discretize(ArrayDecayDist,X);
Y2 = histcounts(Y,X);
Y2vol = Y2./Volume;
Y2count = Y2./counts;
figure(1);
hold on
plot(Xcent(2:end),Y2vol(2:end))
ylabel('Decay Event per Volume')
xlabel('Distance from Seed [nm]')
set(gca,'FontSize',16)
figure(2);
hold on
histogram(Y);
figure(3);
hold on
plot(Xcent(2:end),Y2count(2:end));
ylabel('Decay Event per Site')
xlabel('Distance from Seed [nm]')
set(gca,'FontSize',16)
figure(4);
hold on
plot(Xcent(2:end),Y2(2:end).^(1/3));
end

