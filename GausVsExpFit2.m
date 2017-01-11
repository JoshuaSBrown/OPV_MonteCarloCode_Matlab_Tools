function GausVsExpFit2( FileName )
%This function takes the input of an .xyz file plots the energies in a
%histogram
close all
ext = FileName(end-3:end);
core = FileName(1:end-4);
if(strcmp(ext,'.txt')~=1)
    error('File is not of the .txt file type');
end
    
fid = fopen(FileName);

C = textscan(fid,'%f %f');
Energies = C{1};
Count = C{2};

display(sum(Count))
display(sum(Count)*(Energies(2)-Energies(1)))
[ ~, ELEM] = max(Count);
MidE = -1*Energies(ELEM);

func = strcat('a*exp(b*abs(x+',num2str(MidE),'))');

fclose(fid);

Volume = (200*10^-7)^3; %[cm2]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%First fit to a guassian curve
[xData, yData] = prepareCurveData( Energies, Count );

% Set up fittype and options.
ft = fittype( 'gauss1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Robust = 'Bisquare';
opts.Lower = [-Inf -Inf 0];
opts.StartPoint = [899367 -5.20036 0.00588307310389407];

% Fit model to data.
[Gaus_fitresult, Gaus_gof] = fit( xData, yData, ft, opts );

%Calculate the RMSE on a log scale
Gaus_sum = 0;
for j=1:length(Energies)
    a1 = Gaus_fitresult.a1;
    b1 = Gaus_fitresult.b1;
    c1 = Gaus_fitresult.c1;
    Gaus_sum = (log( a1*exp(-((Energies(j)-b1)/c1)^2) )-log(Count(j)))^2;
end
%Gaus_RMSE = sqrt( Gaus_sum/length(Energies) );
Gaus_RMSE = sqrt( Gaus_sum );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Second fit to an exponential
ft = fittype( func, 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Robust = 'Bisquare';
opts.StartPoint = [0.869084814693679 0.362032367426035];
opts.Upper = [max(Count)*10^4 Inf];

% Fit model to data.
[Exp_fitresult, Exp_gof] = fit( xData, yData, ft, opts );

%Calculate the RMSE on a log scale
Exp_sum = 0;
for j=1:length(Energies)
    a = Exp_fitresult.a;
    b = Exp_fitresult.b;
    Exp_sum = (log( a*exp(b*abs(Energies(j)+5.2)))-log(Count(j)))^2;
end
%Exp_RMSE = sqrt( Exp_sum/length(Energies) );
Exp_RMSE = sqrt( Exp_sum );

%Now we are going to try to combine the two curves so that we can find the
%optimal fit. We will do this by fitting the exponential to the outside and
%the gaussian to the middle data points

%Total iterations
Iter = floor((length(Count)-12)/2);

Rval = zeros(Iter,1);
Gaus_Rval_i = zeros(Iter,1);
Exp_Rval_i = zeros(Iter,1);
for i=1:Iter

    %Create Data set for Exponential
    Exp_X = Energies(1:(3+i));
    Exp_X = [Exp_X; Energies((length(Energies)-(3+i)):length(Energies))];
    Exp_Y = Count(1:(3+i));
    Exp_Y = [Exp_Y; Count((length(Count)-(3+i)):length(Count))];
    
    [Exp_xData_i, Exp_yData_i] = prepareCurveData( Exp_X, Exp_Y );

    ft = fittype( func, 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Robust = 'Bisquare';
    opts.StartPoint = [0.869084814693679 0.362032367426035];
    opts.Upper = [max(Count)*10^4 Inf];
    
    % Fit model to data.
    [Exp_fitresult_i, Exp_gof_i] = fit( Exp_xData_i, Exp_yData_i, ft, opts );
    
    %Calculate the RMSE on a log scale
    Exp_sum = 0;
    for j=1:length(Exp_X)
       a = Exp_fitresult_i.a;
       b = Exp_fitresult_i.b;
       Exp_sum = (log( a*exp(b*abs(Exp_X(j)+5.2)))-log(Exp_Y(j)))^2; 
    end
    %Exp_RMSE_i = sqrt( Exp_sum/length(Exp_X) );
    Exp_RMSE_i = sqrt( Exp_sum );
    
    Gaus_X = Energies((3+i):(length(Energies)-(3+i)));
    Gaus_Y = Count((3+i):(length(Count)-(3+i)));
    [Gaus_xData_i, Gaus_yData_i] = prepareCurveData( Gaus_X, Gaus_Y );
    
    % Set up fittype and options.
    ft = fittype( 'gauss1' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Robust = 'Bisquare';
    opts.Lower = [-Inf -Inf 1];
    opts.StartPoint = [899367 -5.20036 10000];
    opts.Upper = [ 10^6 0 Inf];
    i
    % Fit model to data.
    [Gaus_fitresult_i, Gaus_gof_i] = fit( Gaus_xData_i, Gaus_yData_i, ft, opts );
    
    %Calculate the RMSE on a log scale
    Gaus_sum = 0;
    for j=1:length(Gaus_X)
       a1 = Gaus_fitresult_i.a1;
       b1 = Gaus_fitresult_i.b1;
       c1 = Gaus_fitresult_i.c1;
       Gaus_sum = (log( a1*exp(-((Gaus_X(j)-b1)/c1)^2) )-log(Gaus_Y(j)))^2; 
    end
    %Gaus_RMSE_i = sqrt( Gaus_sum/length(Gaus_X) );
    Gaus_RMSE_i = sqrt( Gaus_sum );
    
    Gaus_Rval_i(i,1)=Gaus_RMSE_i;
    Exp_Rval_i(i,1)=Exp_RMSE_i;
    Rval(i,1) = sqrt(Gaus_RMSE_i^2+Exp_RMSE_i^2);
    
end

[MinRval, Elem] = min(Rval);

fprintf('Cross over point occurs at Energies %g and %g eV\n',Energies(3+Elem),Energies(length(Energies)-(3+Elem)));

Exp_perc = (length(1:Energies(3+Elem))+length(Energies(length(Energies)-(3+Elem):length(Energies))))/length(Energies)*100;
Gaus_perc = 100-Exp_perc;
fprintf('Percentage of points that fit Exp %f\n',Exp_perc);
fprintf('Percentage of points that fit Gaus %f\n',Gaus_perc);
fprintf('Mixed fit is optimal root mean square error value of %g\n',MinRval/length(Energies));
fprintf('Exponential fit root square error value of %g\n',Exp_Rval_i(Elem));
fprintf('Gaussian fit root square error value of %g\n',Gaus_Rval_i(Elem));
fprintf('Pure exponential fit is optimal root mean square error value of %g\n',Exp_RMSE/length(Energies));
fprintf('Pure gaussian fit is optimal root mean square error value of %g\n',Gaus_RMSE/length(Energies));

if (MinRval<Exp_RMSE && MinRval<Gaus_RMSE)
        %Create Data set for Exponential
        
    i = Elem;
    Exp_X = Energies(1:(3+i));
    Exp_X = [Exp_X; Energies((length(Energies)-(3+i)):length(Energies))];
    Exp_Y = Count(1:(3+i));
    Exp_Y = [Exp_Y; Count((length(Count)-(3+i)):length(Count))];
    
    [Exp_xData_i, Exp_yData_i] = prepareCurveData( Exp_X, Exp_Y );

    ft = fittype( func, 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Robust = 'Bisquare';
    opts.StartPoint = [0.869084814693679 0.362032367426035];
    opts.Upper = [max(Count)*10^4 Inf];
    
    % Fit model to data.
    [Exp_fitresult_i, Exp_gof_i] = fit( Exp_xData_i, Exp_yData_i, ft, opts );
    
    Gaus_X = Energies((3+i):(length(Energies)-(3+i)));
    Gaus_Y = Count((3+i):(length(Count)-(3+i)));
    [Gaus_xData_i, Gaus_yData_i] = prepareCurveData( Gaus_X, Gaus_Y );
    
    % Set up fittype and options.
    ft = fittype( 'gauss1' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Robust = 'Bisquare';
    opts.Lower = [-Inf -Inf 0];
    opts.StartPoint = [899367 -5.20036 0.00588307310389407];
    
    % Fit model to data.
    [Gaus_fitresult_i, Gaus_gof_i] = fit( Gaus_xData_i, Gaus_yData_i, ft, opts );
    
    figure
    plot(Energies,Count/Volume,'o');
    hold on
    plot(Energies,feval(Gaus_fitresult_i,Energies)/Volume,'LineWidth',2);
    plot(Energies,feval(Exp_fitresult_i,Energies)/Volume,'LineWidth',2);
    set(gcf,'Color','w');
    set(gca,'FontSize',18);
    xlabel('Energy [eV]');
    ylabel('DOS [cm^-^3]');
    axis([-5.6 -4.8 0 13E19]);
    legend('Data','Gausian','Exponential')
    legend boxoff
    figure
    semilogy(Energies,Count/Volume,'o');
    hold on
    semilogy(Energies,feval(Gaus_fitresult_i,Energies)/Volume,'LineWidth',2);
    semilogy(Energies,feval(Exp_fitresult_i,Energies)/Volume,'LineWidth',2);
    set(gcf,'Color','w');
    set(gca,'FontSize',18);
    xlabel('Energy [eV]');
    ylabel('DOS [cm^-^3]');
    legend('Data','Gausian','Exponential')
    legend boxoff
elseif( Exp_RMSE<Gaus_RMSE)
    figure(3)
    plot(Energies,Count/Volume,'o');
    hold on
    plot(Energies,feval(Exp_fitresult,Energies)/Volume,'LineWidth',2);
    set(gcf,'Color','w');
    set(gca,'FontSize',18);
    xlabel('Energy [eV]');
    ylabel('DOS [cm^-^3]');
    legend('Data','Exponential')
    legend boxoff
    axis([-5.6 -4.8 0 13E19]);
    figure(4)
    semilogy(Energies,Count/Volume,'o');
    hold on
    semilogy(Energies,feval(Exp_fitresult,Energies)/Volume,'LineWidth',2);
    set(gcf,'Color','w');
    set(gca,'FontSize',18);
    xlabel('Energy [eV]');
    ylabel('DOS [cm^-^3]');
    legend('Data','Exponential')
    legend boxoff
else
    figure(5)
    plot(Energies,Count/Volume,'o');
    hold on
    plot(Energies,feval(Gaus_fitresult,Energies)/Volume,'LineWidth',2);
    set(gcf,'Color','w');
    set(gca,'FontSize',18);
    xlabel('Energy [eV]');
    ylabel('DOS [cm^-^3]');
    legend('Data','Gausian')
    axis([-5.6 -4.8 0 13E19]);
    legend boxoff
    figure(6)
    semilogy(Energies,Count/Volume,'o');
    hold on
    semilogy(Energies,feval(Gaus_fitresult,Energies)/Volume,'LineWidth',2);
    set(gcf,'Color','w');
    set(gca,'FontSize',18);
    xlabel('Energy [eV]');
    ylabel('DOS [cm^-^3]');
    legend('Data','Gausian')
    legend boxoff
end
    
