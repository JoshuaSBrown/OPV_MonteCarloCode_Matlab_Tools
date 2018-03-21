%This function will look at the site Decay file and the distance of the
%decay site every nucleation center and determine the correlation function
%it is not the same as the other function which only considers the
%distance to the closest nucleation center. 

if exist('SiteDecay.txt','file')~=2 
    error('ERROR SiteDecay.txt file does not appear to exist');
end

% Now we are going to open and read the positions of all the nucleation
% centers
fid = fopen('SeedPos.txt');
C = textscan(fid,'%d %d %d');
fclose(fid);

Dx = C{1};
Dy = C{2};
Dz = C{3};

% Now we are going to read the SiteDecay.txt file
fid = fopen('SiteDecay.txt');
% Time xpos ypos zpos
C = textscan(fid,'%f %f %f %f');
fclose(fid);
Fx = C{2};
Fy = C{3};
Fz = C{4};

% Cycle through all the seeds in lattice
allValues = [];
MaxDist = 30;
for i=1:length(Dx)
    
    % Calculate the distance between the seeds and the sites that decayed
    x = double(Dx(i));
    y = double(Dy(i));
    z = double(Dz(i));
    
    R = sqrt((x-Fx).^2+(y-Fy).^2+(z-Fz).^2);
    
    values = R(R<MaxDist);
    allValues = [allValues; values];
end

Resolution = MaxDist+1;
X = linspace(0,MaxDist,Resolution);
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
                    count = count+8;
                end
            end
        end
    end
    counts(m-1) = count;
end

Y = discretize(allValues,X);
Y2 = histcounts(Y,X);
Y2vol = Y2./Volume;
Y2count = Y2./counts;
figure(1);
hold on
plot(Xcent(2:end-1),Y2vol(2:end-1),'LineWidth',2)
ylabel('Decay Event per Volume')
xlabel('Distance from Seed [nm]')
set(gca,'FontSize',16)
set(gcf,'Color','w');
figure(2);
hold on
histogram(Y);
set(gcf,'Color','w');
figure(3);
hold on
plot(Xcent(2:end-1),Y2count(2:end-1),'LineWidth',2);
set(gcf,'Color','w');
figure(4);
hold on
plot(Xcent(2:end-1),Y2(2:end-1).^(1/3),'LineWidth',2);
set(gcf,'Color','w');
ylabel('Decay Event per Site')
xlabel('Distance from Seed [nm]')
set(gca,'FontSize',16)
