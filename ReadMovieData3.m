function [ChargePos ,SiteDist, TimeStamp] = ReadMovieData3( FileName )

%Just get the positions of the charges exclude the empty lattice. 

fid = fopen(FileName);

c = textscan(fid,'%s %f %f %f %f %f','HeaderLines', 2 );
fclose(fid);

[r , ~] = size(c{1});

matrix = zeros(r,4);
matrix(:,1) = c{2};
matrix(:,2) = c{3};
matrix(:,3) = c{4};
%Charge number
matrix(:,4) = c{5};


%Count number of charges in the lattice
NumCharges = sum(matrix(:,4)~=-1);
inc = 1;
ChargePos = zeros(NumCharges,3);
for i=1:length(matrix)

    if matrix(i,4)~=-1
        ChargePos(inc,1) = matrix(i,1);
        ChargePos(inc,2) = matrix(i,2);
        ChargePos(inc,3) = matrix(i,3);
        inc = inc+1;
    end
        
end

fid = fopen(FileName);
line = fgetl(fid);
fclose(fid);
Digits = sscanf(line,'%d %f %d %d %d %f');
SiteDist = Digits(6);
TimeStamp = Digits(2);

% figure();
% subplot(3,1,1);
% hist(matrix(:,1))
% subplot(3,1,2);
% hist(matrix(:,2))
% subplot(3,1,3);
% hist(matrix(:,3))
end