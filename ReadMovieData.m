function [MV, Dimensions] = ReadMovieData( FileName )


fid = fopen(FileName);

c = textscan(fid,'%s %f %f %f %f','HeaderLines', 2 );
fclose(fid);

[r , ~] = size(c{1});

matrix = zeros(r,4);
matrix(:,1) = c{2};
matrix(:,2) = c{3};
matrix(:,3) = c{4};
matrix(:,4) = c{5};

Dimensions = zeros(3,1);
Dimensions(1,1) = max(matrix(:,1));
Dimensions(2,1) = max(matrix(:,2));
Dimensions(3,1) = max(matrix(:,3));

elem = find(matrix(:,4)~=-1);
MV = matrix(elem,:);

% figure();
% subplot(3,1,1);
% hist(matrix(:,1))
% subplot(3,1,2);
% hist(matrix(:,2))
% subplot(3,1,3);
% hist(matrix(:,3))
end