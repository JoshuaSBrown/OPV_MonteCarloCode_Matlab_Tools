%Generate avi movie
clear
close all
fclose all

list = ls;

[r, c]=size(list);


j=1;
k=1;
for i=1:r

    str = list(i,:);
    [str, str2] = strsplit(str,'.xyz');
    if isempty(str2)~=1
        [str, ~]=strsplit( str{1},'R1');
        if( exist('SaveStr','var')==0)
            SaveStr{k}=str{1};
            k=k+1;
        else
            flag=0;
            [~,cols]=size(SaveStr);
            for l=1:cols
                if (strcmp(SaveStr{l},str{1}))
                    flag=1;
                    break;
                end
            end

            if(flag==0)
                SaveStr{k}=str{1};
                k=k+1;
            end
        end
        number = str2num(str{2});
        display(number)
        NumberList(j,1) = number;
        j=j+1;
    end
end

NumberLarge = max(NumberList);
[~,cols2] = size(SaveStr);

Avg = 30;
%Now sorting through the different files we are going to create a movie
for i=1:cols2
    
    FileNameTentative = strcat(SaveStr{i},'R1');
    flag2 = 0;
    mkdir(FileNameTentative);
    
    ChargesReachElec = zeros(NumberLarge,1);
    MaxCharge2D = zeros(NumberLarge,1);
    MaxChargeHist = zeros(NumberLarge,1);
    %cycle throught the numberlist
    for j=1:NumberLarge
        
        FileName = strcat(FileNameTentative,num2str(j),'.xyz');
        
        if exist(FileName,'file')
            [MV, Dimensions]=ReadMovieData(FileName);
            
            if (flag2==0);
                flag2 = 1;
                X = ones(Dimensions(1,1)+1,Dimensions(3,1)+1);
                Z = ones(Dimensions(1,1)+1,Dimensions(3,1)+1);
               
                xarray = 0:Dimensions(1,1);
                zarray = 0:Dimensions(3,1);
                
                for k=1:(Dimensions(3,1)+1)
                    X(:,k) = X(:,k).*xarray';
                end
                
                for l=1:(Dimensions(1,1)+1)
                    Z(l,:) = Z(l,:).*zarray;
                end
            end

            C = sparse(Dimensions(1,1)+1,Dimensions(3,1)+1);
            H = sparse(Dimensions(1,1)+1,1);
            [rows, cols] = size(MV);
                
            for k=1:rows
                
                xM = MV(k,1)+1;
                yM = MV(k,2)+1;
                C(xM,yM)=C(xM,yM)+1;
                H(xM,1)=H(xM,1)+1;
            end
            
            ValM2 = floor(full(max(H))/10)*10+10;
            MaxCharge2D(j,1) = max(max(C));
            MaxChargeHist(j,1) = max(H);
            if (j<=Avg)
                ValM3 = floor(mean(MaxChargeHist(1:j,1))/10)*10+10;
                ValM4 = floor(mean(MaxCharge2D(1:j,1))/10)*10+10;
            else
                ValM3 = floor(mean(MaxChargeHist((j-Avg):j,1))/10)*10+10;
                ValM4 = floor(mean(MaxCharge2D((j-Avg):j,1))/10)*10+10;
            end
            if (flag2==1)
               flag2=2;
               ValM = full(max(max(C)));
               TotalCharges = full(sum(sum(C)));
            end
            
            ChargesReachElec(j,1) = TotalCharges-full(sum(sum(C)));
            TotalCharges = TotalCharges-ChargesReachElec(j,1);
            figure('Position', [100, 100, 800, 800]);
            subplot(2,2,2);
            bar(xarray,H,'EdgeColor','none');
            if( ValM3 < (floor(max(ChargesReachElec)/10)*10+10))
                ValM3 = floor(max(ChargesReachElec)/10)*10+10;
            end
            ylim([0 ValM3])
            xlabel('x');
            ylabel('Number of Charges');
            subplot(2,2,1);
            h = surf(X,Z,full(C));
            xlabel('x');
            ylabel('y');
            caxis(gca,[0 ValM4])
            set(h,'edgecolor','none');
            view(0,90);
            daspect([1 1 1]);
            subplot(2,2,3);
            h = surf(X,Z,full(C));
            xlabel('x');
            ylabel('y');
            zlim(gca,[0 ValM]);
            caxis(gca,[0 ValM4])
            set(gcf,'Color','w');
            set(h,'edgecolor','none');
            subplot(2,2,4);
            hold on
            h=plot(1:j,ChargesReachElec(1:j,1),'b');
            
            ylim([0 ValM3])
            xlabel('Time Steps');
            ylabel('Number of Charges');
            axis([ 1 NumberLarge 0 ValM3]);
            saveas(h,strcat(FileNameTentative,'\',FileNameTentative,'Frame',num2str(j),'.jpg'))
            close gcf;
        end
    end
    make_video(strcat(FileNameTentative,'\'),'jpg',strcat(FileNameTentative,'.avi'),5)
end
display(SaveStr)

