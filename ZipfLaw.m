function ZipfLaw(FileName)
%Script is designed to load xyz file of visitation frequency and then order
%the sites based on the frequency of visitation. Looking for Zipf's law

ext = FileName(end-3:end);
core = FileName(1:end-4);
if(strcmp(ext,'.xyz')~=1)
    error('File is not of the .xyz file type');
end
    
fid = fopen(FileName);
TotalLines = str2double(fgetl(fid));
fgetl(fid);
C = textscan(fid,'%s %f %f %f %f %f %f');
fclose(fid);

freq = C{5};
freq = sort(freq,'descend');
finish = sum(freq~=0);

h = figure(1);
set(h,'Position',[10 10 600 600]);
set(gcf,'Color','w');
subplot(3,1,1);
hold on
bar([1:finish],freq(1:finish),'edgecolor', 'none', 'BarWidth', 1);
ylabel('Frequency');
xlabel('Site');
subplot(3,1,2);
bar([1:finish],freq(1:finish),'edgecolor', 'none', 'BarWidth', 1);
set(gca, 'Yscale',  'log')
ylabel('Frequency');
xlabel('Site');
subplot(3,1,3);
bar([1:finish],freq(1:finish),'edgecolor', 'none', 'BarWidth', 1);
xlim([1 finish])
set(gca, 'Yscale',  'log')
set(gca, 'Xscale',  'log')
ylabel('Frequency');
xlabel('Site');

end
