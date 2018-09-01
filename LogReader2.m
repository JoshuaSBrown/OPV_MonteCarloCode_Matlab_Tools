function [ S, Energies, AtomTypes, AtomOrbTypes,AtomPos,HOMO ] = LogReader2( logfile )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

fid = fopen(logfile,'r');

S = [];
Energies = [];

while ~feof(fid)
   
    line = fgetl(fid);
    index = 1;
    while( contains(line,'*** Overlap ***') )
        fgetl(fid);
        line = strtrim(fgetl(fid));
        line = regexprep(line,'D','E');
        C = strsplit(line);
        S_coef_row = str2double(C(1));
        
        S_start_cols = zeros(4,5);
        while(S_coef_row==index)
           
            if(length(C)<6)
                for j=2:length(C)
                    S_start_cols(index,j-1) = str2double(C(j));
                end
            else
                S_row = zeros(1,5);
                for j=2:length(C)
                    S_row(1,j-1) = str2double(C(j));
                end
                S_start_cols = [S_start_cols ; S_row ];
            end
            index = index+1;
            line = strtrim(fgetl(fid));
            line = regexprep(line,'D','E');
            C = strsplit(line);
            S_coef_row = str2double(C(1));
            
        end
        
        line = strtrim(fgetl(fid));
        totalMOs = index-1;
        
        S = zeros(totalMOs);
        [ r, c] = size(S_start_cols);
        for i=1:r
           for j=1:c
              if j<=i
                S(i,j) = S_start_cols(i,j);
                S(j,i) = S_start_cols(i,j);
              end   
           end
        end
        
        totalCount = ceil(totalMOs/5);
        index = 6;
        for count=2:totalCount
            for row_index=index:totalMOs
                line = regexprep(line,'D','E');
                C = strsplit(line);
                for j=2:length(C)
                    S(row_index,(count-1)*5+j-1) = str2double(C(j));
                    S((count-1)*5+j-1,row_index) = str2double(C(j));
                end
                line=strtrim(fgetl(fid));
            end
            
            index = index+5;
            line=strtrim(fgetl(fid));
        end
    end
    if( contains(line,'Population analysis using the SCF density') )
        fgetl(fid);
        fgetl(fid);
        fgetl(fid);
        index = 1;
        line = strtrim(fgetl(fid));
        Energies = zeros(totalMOs,1);
        HOMO = 0;
        while(contains(line,'Alpha'))
            C = strsplit(line);
            for i=5:length(C)
                Energies(index,1)=str2double(C(i));
                if(contains(line,'occ'))
                   HOMO = HOMO+1; 
                end
                index = index+1;
            end
            line = strtrim(fgetl(fid));
        end
    end
    if( contains(line,'Molecular Orbital Coefficients:'))
        fgetl(fid);
        fgetl(fid);
        fgetl(fid);
        index = 1;
        line = strtrim(fgetl(fid));
        C = strsplit(line);
        LineWAtom = length(C);
        %AtomTypes = containers.Map(int32(1),'var');
        %remove(AtomTypes,1) 
        
        %AtomOrbTypes = containers.Map(int32(1),'var');
        %remove(AtomOrbTypes,1)
        while(str2double(C(1))==index)
 
            if(length(C)==LineWAtom)
                AtomNum = str2double(C(2));
                AtomType = C(3);
                
                %AtomTypes(int32(AtomNum))=AtomType;
                OrbType = C(4);
                if(AtomNum==1)
                    AtomTypes = { string(AtomType) };
                    AtomOrbTypes = { string(OrbType) };
                else
                    AtomTypes{AtomNum} =  string(AtomType) ;
                   AtomOrbTypes{AtomNum} = string(OrbType); 
                end
                
                %AtomOrbTypes(int32(AtomNum))=OrbType;
            else
                OrbType = C(2);
                AtomOrbTypes{AtomNum} = string(strcat(AtomOrbTypes{AtomNum},' ',OrbType));
                
                %AtomOrbTypes(AtomNum)=strcat(AtomOrbTypes(int32(AtomNum)),' ',OrbType);
            end
            index=index+1;
            line = strtrim(fgetl(fid));
            C = strsplit(line);
        end
    end
    if( contains(line,'Coordinates (Angstroms)'))
        fgetl(fid);
        fgetl(fid);
        index = 1;
        line = strtrim(fgetl(fid));
        C = strsplit(line);
        
        AtomPos = [];
        while(str2double(C(1))==index)
            xyz = zeros(1,3);
            xyz(1,1) = str2double(C(4));
            xyz(1,2) = str2double(C(5));
            xyz(1,3) = str2double(C(6));
            if(index==1)
                AtomPos = xyz;
            else
                AtomPos = [ AtomPos; xyz ];
            end
            index = index+1;
            line = strtrim(fgetl(fid));
            C = strsplit(line);
        end
    end
    
end

fclose(fid);
end

