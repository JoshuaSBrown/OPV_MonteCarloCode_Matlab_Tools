function Energy_bin( FileName, bins )
%This function takes the input of an .xyz file plots the energies in a
%histogram
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

% i=1;
% totalines=0;
% while(i<=TotalLines)
%    line = fgetl(fid); 
%    C = strsplit(line);
%    Val = str2double(C{5});
%    Energies(i,1) = Val;
%    totalines=totalines+1;
%    i=i+1
% end

fclose(fid);

Energies = sort(Energies);

Ma = max(Energies);
Mi = min(Energies);
E0 = mean(Energies);

if(abs(Ma-E0)>abs(Mi-E0))
    inc = abs(Ma-E0)*2/(bins+1);
else
    inc = abs(Mi-E0)*2/(bins+1);
end
x_axis = linspace(Mi+inc/2,Ma-inc/2,bins);
Count_Init = zeros(bins,1);

Len = Mi;

Count_Init(1,1) = sum(Energies<(Mi+inc));

Bins_Stat_NON_Viable = 0;
Init_Flag = 0;
for i=2:bins
    
    Count_Init(i,1) = sum(Energies<(Mi+inc*i))-sum(Count_Init(1:i,1));

    if(Count_Init(i,1)<10 && Init_Flag ==0)
        Bins_Stat_NON_Viable = Bins_Stat_NON_Viable+1;
    else
        Init_Flag = 1;
    end
    
end

Count = Count_Init(Bins_Stat_NON_Viable+1:length(Count_Init)-Bins_Stat_NON_Viable);
fprintf('Number of Bins after trimming statistically small data %d',length(Count));
bins = length(Count);
[Max_Count, Elem_Count] = max(Count);
%mid = round((bins-1)/2);
mid = Elem_Count;
x = x_axis(1:mid);
y = Count(1:mid);

TotalCount = sum(Count(1:mid));

x2 = linspace(min(x),max(x),100);

Rval = zeros(round((bins-1)/2)-6,1);
Flag = 0;

for i=4:(mid-4)
  [xData, yData] = prepareCurveData( x(mid-i:mid), log(y(mid-i:mid))' );
  % Set up fit for gaussian curve
  ft = fittype( 'gauss1' );
  opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
  opts.Display = 'Off';
  opts.Lower = [-Inf x_axis(Elem_Count)-inc 0];
  opts.StartPoint = [Max_Count x_axis(Elem_Count) 0.0416952789965878];
  opts.Upper = [Inf x_axis(Elem_Count)+inc Inf];
  % Fit model to data.
  [fitresult, gof] = fit( xData, exp(yData), ft, opts );
  
  ft = fittype( 'log(a1*exp(-((x-b)/c)^2))', 'independent', 'x', 'dependent', 'y' );
  opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
  opts.Display = 'Off';
  opts.Lower = [fitresult.a1*0.8 fitresult.b1*1.2 fitresult.c1*0.8];
  opts.StartPoint = [fitresult.a1 fitresult.b1 fitresult.c1];
  opts.Upper = [fitresult.a1*1.2 fitresult.b1*0.8 fitresult.c1*1.2];
  opts.DiffMaxChange = 1E-5;
  % Fit model to data.
  [f1, gof] = fit( xData, yData, ft, opts );
  Rval(i-3,1) = gof.rsquare;
  
  if(gof.rsquare<0)
     Flag = 1;
  end
  
  [xData, yData] = prepareCurveData( x(1:mid-i), log(y(1:mid-i))' );
  % Set up fit for exponential
  ft = fittype( 'log(a*exp(b*x-c))', 'independent', 'x', 'dependent', 'y' );
  opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
  opts.Display = 'Off';
  opts.Lower = [0 0 -Inf];
  opts.StartPoint = [0.0823604224879257 0.815510036601453 0.416622452917132];
  % Fit model to data.
  if(size(yData)<3)
      Rval(i-3,1)= 0;
      Flag = 0;
  else
    [f2, gof] = fit( xData, yData, ft, opts );
    Rval(i-3,1) = (Rval(i-3,1)+gof.rsquare);
    if(gof.rsquare<0 || Flag == 1)
        Rval(i-3,1) = 0;
        display('Stop')
        Flag = 0;
    end
  end
  
  
end

%Test pure Gaussian 
[xData, yData] = prepareCurveData( x, log(y)' );
% Set up fit for gaussian curve
ft = fittype( 'gauss1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf x_axis(Elem_Count)-inc 0];
opts.StartPoint = [Max_Count x_axis(Elem_Count) 0.0416952789965878];
opts.Upper = [Inf x_axis(Elem_Count)+inc Inf];
% Fit model to data.
[fitresult, gof] = fit( xData, exp(yData), ft, opts );
ft = fittype( 'log(a1*exp(-((x-b)/c)^2))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [fitresult.a1*0.8 fitresult.b1*1.2 fitresult.c1*0.8];
opts.StartPoint = [fitresult.a1 fitresult.b1 fitresult.c1];
opts.Upper = [fitresult.a1*1.2 fitresult.b1*0.8 fitresult.c1*1.2];
opts.DiffMaxChange = 1E-5;
% Fit model to data.
[Gaus_fitresult, Gaus_gof] = fit( xData, yData, ft, opts );
Gaus_rval = Gaus_gof.rsquare*2;

%Test pure Exponential
[xDataS, yDataS] = prepareCurveData( x, log(y));
% Set up fit for exponential
ft = fittype( 'log(a*exp(b*x-c))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 0 -Inf];
opts.StartPoint = [0.0823604224879257 0.815510036601453 0.416622452917132];
% Fit model to data.
[Exp_fitresult, Exp_gof] = fit( xData, yData, ft, opts );
Exp_rval = Exp_gof.rsquare*2;

[Mix_rval, Elem] = max(Rval);

if(Mix_rval>Gaus_rval && Mix_rval>Exp_rval)
    i = Elem+3;
    %Parameters for Chosen Fit
    [xData, yData] = prepareCurveData( x(mid-i:mid)', log(y(mid-i:mid))' );
    % Set up fit for gaussian curve
    ft = fittype( 'gauss1' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Lower = [-Inf x_axis(Elem_Count)-inc 0];
    opts.StartPoint = [Max_Count x_axis(Elem_Count) 0.0416952789965878];
    opts.Upper = [Inf x_axis(Elem_Count)+inc Inf];
    % Fit model to data.
    [fitresult, ~] = fit( xData, exp(yData), ft, opts );
    ft = fittype( 'log(a1*exp(-((x-b)/c)^2))', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Lower = [fitresult.a1*0.8 fitresult.b1*1.2 fitresult.c1*0.8];
    opts.StartPoint = [fitresult.a1 fitresult.b1 fitresult.c1];
    opts.Upper = [fitresult.a1*1.2 fitresult.b1*0.8 fitresult.c1*1.2];
    opts.DiffMaxChange = 1E-5;
    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );
    
    fprintf('R value Gaussian fit %g\n',gof.adjrsquare);
    fprintf('Percent fits Gaussian %g\n',((i/mid))*100);
    fprintf('Percent of sites in Gaussian %g\n',(sum(Count(i:mid))/TotalCount*100));
    % Plot fit with data.
    fig = figure(1);
    plot( x, y ,'b.');
    hold on
    plot( x2, exp(feval(fitresult,x2)),'r' );
    
    fig2 = figure(2);
    semilogy( x, y,'b.' );
    hold on
    semilogy( x2, exp(feval(fitresult,x2)),'r');
    
    [xData, yData] = prepareCurveData( x(1:mid-i)', log(y(1:mid-i))' );
    % Set up fit for exponential
    ft = fittype( 'log(a*exp(b*x-c))', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Lower = [0 0 -Inf];
    opts.StartPoint = [0.0823604224879257 0.815510036601453 0.416622452917132];
    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );
    fprintf('R value Exponential fit %g\n',gof.adjrsquare);
    fprintf('Percent fits Exponential %g\n',(1-(i/mid))*100);
    fprintf('Percent of sites in Exponential %g\n',100-(sum(Count(i:mid))/TotalCount*100));
    
    % Plot fit with data.led fit
    figure(fig);
    hold on
    plot( x2, exp(feval(fitresult,x2)),'--r');
    legend('Data', 'Gaussian','Exponential', 'Location', 'NorthWest' );
    legend boxoff
    xlabel('Energies');
    ylabel('DOS');
    set(gcf,'Color','w');
    ylim([ 0 max(Count)*1.1]);
    
    figure(fig2);
    hold on
    semilogy( x2, exp(feval(fitresult,x2)),'--r');
    legend('Data', 'Gaussian','Exponential', 'Location', 'NorthWest' );
    legend boxoff
    xlabel('Energies');
    ylabel('ln(DOS)');
    set(gcf,'Color','w');
    ylim([ (min(exp(yDataS)))*0.9 (max(exp(yDataS)))*1.1]);
elseif (Gaus_rval>Exp_rval)
    
    fprintf('R value Gaussian fit %g\n',Gaus_gof.adjrsquare);
    fprintf('Percent fits Gaussian %g\n',100);
    % Plot fit with data.
    figure(1);
    plot( x, y ,'b.');
    hold on
    plot( x2, exp(feval(Gaus_fitresult,x2)),'r' );
    legend('Data', 'Gaussian','Location', 'NorthWest' );
    legend boxoff
    xlabel('Energies');
    ylabel('DOS');
    set(gcf,'Color','w');
    ylim([ 0 max(Count)*1.1]);
    
    figure(2);
    semilogy( x, y,'b.' );
    hold on
    semilogy( x2, exp(feval(Gaus_fitresult,x2)),'r');
    legend('Data', 'Gaussian', 'Location', 'NorthWest' );
    legend boxoff
    xlabel('Energies');
    ylabel('ln(DOS)');
    set(gcf,'Color','w');
    ylim([ (min(exp(yDataS)))*0.9 (max(exp(yDataS)))*1.1]);
else
    fprintf('R value Exponential fit %g\n',Exp_gof.adjrsquare);
    fprintf('Percent fits Exponential %g\n',100);
    % Plot fit with data.
    figure(1);
    plot( x, y ,'b.');
    hold on
    plot( x2, exp(feval(Exp_fitresult,x2)),'r' );
    legend('Data', 'Exponential','Location', 'NorthWest' );
    legend boxoff
    xlabel('Energies');
    ylabel('DOS');
    set(gcf,'Color','w');
    ylim([ 0 max(Count)*1.1]);
    
    figure(2);
    semilogy( x, y,'b.' );
    hold on
    semilogy( x2, exp(feval(Exp_fitresult,x2)),'r');
    legend('Data', 'Exponential', 'Location', 'NorthWest' );
    legend boxoff
    xlabel('Energies');
    ylabel('ln(DOS)');
    set(gcf,'Color','w'); 
    ylim([ (min(exp(yDataS)))*0.9 (max(exp(yDataS)))*1.1]);
end

