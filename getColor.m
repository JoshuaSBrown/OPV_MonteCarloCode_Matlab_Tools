function [ col ] = getColor( value, colors )
%Will get a color, if you pass in a number between 0 and 1, colors is a
%list of different colors... e.g.
% [ 0 1 0;
%   1 0 0];
% Here is two colors, If I pass in a value will output will find it
% somewhere between the two and return it. If I passed in value=0.5 col
% would be = [ 0.5 0.5 0 ]; which is halfway between the two colors passed
% in

[ numColors, ~ ] = size(colors);

if(value>1 || value<0)
   error('value must be between 0 and 1'); 
end

frac = 0;
fracOld = 0;
colorInd = 0;
for i = 1:numColors 
    if value<=frac
        fracOld = frac-1/(numColors-1);
        break;
    end
    colorInd = colorInd+1;
    frac = frac + 1/(numColors-1);
end
if(colorInd==0)
   colorInd =1; 
end
if(colorInd==numColors)
   error('This should not happen'); 
end
baseColor = colors(colorInd,:);
nextColor = colors(colorInd+1,:);

diffColor = nextColor - baseColor;

diff = (value-fracOld)*(numColors-1);

col = [baseColor(1)+diffColor(1)*diff,...
    baseColor(2)+diffColor(2)*diff,...
    baseColor(3)+diffColor(3)*diff];
    

end

