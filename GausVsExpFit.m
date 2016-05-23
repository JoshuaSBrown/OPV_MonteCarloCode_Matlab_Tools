function GausVsExpFit( FileName )
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

fclose(fid);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Second fit to an exponential
ft = fittype( 'a*exp(b*abs(x+5.2))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Robust = 'Bisquare';
opts.StartPoint = [0.869084814693679 0.362032367426035];
opts.Upper = [max(Count)*10^4 Inf];

% Fit model to data.
[Exp_fitresult, Exp_gof] = fit( xData, yData, ft, opts );

plot(Energies,Count,'o');
hold on
plot(Energies,feval(Gaus_fitresult,Energies));
plot(Energies,feval(Exp_fitresult,Energies));

figure(2)
semilogy(Energies,Count,'o');
hold on
semilogy(Energies,feval(Gaus_fitresult,Energies));
semilogy(Energies,feval(Exp_fitresult,Energies));

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

    ft = fittype( 'a*exp(b*abs(x+5.2))', 'independent', 'x', 'dependent', 'y' );
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
    plot(Energies,Count,'o');
    hold on
    plot(Energies,feval(Gaus_fitresult_i,Energies));
    plot(Energies,feval(Exp_fitresult_i,Energies));
    
    figure
    semilogy(Energies,Count,'o');
    hold on
    semilogy(Energies,feval(Gaus_fitresult_i,Energies));
    semilogy(Energies,feval(Exp_fitresult_i,Energies));

    Gaus_Rval_i(i,1)=Gaus_gof_i.rsquare;
    Exp_Rval_i(i,1)=Exp_gof_i.rsquare;
    Rval(i,1) = Gaus_gof_i.rsquare+Exp_gof_i.rsquare;
end

[MaxRval, Elem] = max(Rval);

fprintf('Cross over point occurs at Energies %g and %g eV\n',Energies(3+Elem),Energies(length(Energies)-(3+Elem)));

Exp_perc = (length(Energies(3+Elem))+length(Energies(length(Energies)-(3+Elem))))/length(Energies)*100;
Gaus_perc = 100-Exp_perc;
fprintf('Percentage of points that fit Exp %f\n',Exp_perc);
fprintf('Percentage of points that fit Gaus %f\n',Gaus_perc);
fprintf('Mixed fit is optimal rsquare value of %g\n',MaxRval);
fprintf('Exponential fit rsquare value of %g\n',Exp_Rval_i(Elem));
fprintf('Gaussian fit rsquare value of %g\n',Gaus_Rval_i(Elem));

fprintf('Pure exponential fit is optimal rsquare value of %g\n',Exp_gof.rsquare);

fprintf('Pure gaussian fit is optimal rsquare value of %g\n',Gaus_gof.rsquare);
