
fid=fopen('RandomEnergyi.txt','r');
rows=str2double(fgetl(fid));
fgetl(fid);
mtx=zeros(1,rows);

for i=1:rows
   a=str2num(fgetl(fid));
   mtx(1,i)=a(2);
end

figure(1)
hist(mtx);

fid=fopen('RandomEnergyj.txt','r');
rows=str2double(fgetl(fid));
fgetl(fid);
mtx2=zeros(1,rows);

for i=1:rows
   a=str2num(fgetl(fid));
   mtx2(1,i)=a(2);
end

figure(2)
hist(mtx2);

fid=fopen('RandomEnergyk.txt','r');
rows=str2double(fgetl(fid));
fgetl(fid);
mtx3=zeros(1,rows);

for i=1:rows
   a=str2num(fgetl(fid));
   mtx3(1,i)=a(2);
end

figure(3)
hist(mtx3);