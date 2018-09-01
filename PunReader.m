function [ MO_Coefs ] = PunReader( punfile )
%Returns the molecular orbital coefficients from fort.7 file format of a 
% Gaussian run. Each row is a molecular orbital and each value represents
% the coefficient in front of an individual atomic orbital. 

fid =  fopen(punfile,'r');
MO_Coefs = [];

MO_num = 1;
while ~feof(fid)
    line = fgetl(fid);
    
    while( contains(line,'Alpha'))
        MO_Coef_row = [];
        line = fgetl(fid);
        matches1 = strfind(line,'Alpha');
        matches2 = strfind(line,'Beta');
        
        Coef_num = 1;
       
        while isempty(matches1) && isempty(matches2)
            
            line = regexprep(line,'D','E');
            i=1;
            num = length(line)/15;
            for j=1:num
               value = line(i:(i+14));
               MO_Coef_row = [ MO_Coef_row str2num(value) ];
               i=i+15;
            end
           
            if(feof(fid))
                break;
            end
            line = fgetl(fid);
            matches1 = strfind(line,'Alpha');
            matches2 = strfind(line,'Beta');
            Coef_num = Coef_num+1;
        end
        MO_Coefs = [ MO_Coefs; MO_Coef_row ];
        clear MO_Coef_row;
        MO_num = MO_num+1;
    end
    
    if( contains(line,'Beta'))
       break; 
    end

    
end

fclose(fid);


end

