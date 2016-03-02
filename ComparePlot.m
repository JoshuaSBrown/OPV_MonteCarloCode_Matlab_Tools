function ComparePlot( PATH1, PATH2 )
%This function plots and compares the Average current (fig 1) Average
%number of charges in the material (fig 2) Average number of charges to
%reach the electrode (fig 3) between PATH1 and PATH2 
%ComparePlot( PATH1, PATH2 ) 
%   Where PATH1 and PATH2 are paths to directories containing t-I.txt files
cd(PATH1);
CurrentPlot;
cd(PATH2);
CurrentPlot;

end

