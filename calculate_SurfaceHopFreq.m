function calculate_SurfaceHopFreq(Filename,freq)
% This function is designed to read in .xyz format file where the 4th
% column represents the hop frequencies of each of the sites it then
% proceeds to create an isosurface from the points defined by freq and
% makes a 3d plot
    close all
    
    ext = Filename(length(Filename)-3:length(Filename));
    if(strcmp(ext,'.xyz')~=1)
        error('File is not of the .xyz file type');
    end
    
    fid = fopen(Filename);
    fgetl(fid);
    fgetl(fid);
    C = textscan(fid,'%s %f %f %f %f %f %f');
    
    rows = length(C{1});
    cols = 3;

    % Read in xyz coordinates
    D = zeros(rows,cols);
    for i=1:cols
        D(:,i)=C{i+1};
    end
    
    % Read in Frequencies
    Frequencies = C{5};
    
    % Create volumes
    Row = max(D(:,1))+1;
    Col = max(D(:,2))+1;
    Shelf = max(D(:,3))+1;

    X = ones(Row,Col,Shelf);
    Y = ones(Row,Col,Shelf);
    Z = ones(Row,Col,Shelf);
    Visit = ones(Row,Col,Shelf);
    
    rangeX = linspace(1,Row,Row);
    rangeY = linspace(1,Col,Col);
    rangeZ = linspace(1,Shelf,Shelf);
    
    temp = ones(1,Col,Shelf);
    for i=1:Row
       X(i,:,:) = temp*rangeX(i); 
    end
    
    temp = ones(Row,1,Shelf);
    for i=1:Col
       Y(:,i,:) = temp*rangeY(i); 
    end
    
    temp = ones(Row,Col,1);
    for i=1:Shelf
       Z(:,:,i) = temp*rangeZ(i); 
    end
    
    for i=1:Row
        for j=1:Col
            var = Frequencies( (1+((i-1)*Row*Col)+(j-1)*Col):((i-1)*Row*Col)+j*Col);
            Visit(i,j,:) = reshape(var,[1,1,Shelf]);
        end
    end
    
    figure
    % isovalues = (0.01:0.01:0.2);
    p = patch(isosurface(X,Y,Z,Visit,freq));
    
    view([ -10 40]);
    
    p.FaceColor = 'blue';
    p.EdgeColor = 'none';
    daspect([1 1 1])
    view(3);
    axis tight
    camlight
    lighting gouraud
end