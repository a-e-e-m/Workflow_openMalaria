%BOXPLOT

%each combination of n and p correspond to one combination of scenario
%parameters
%The first for-loop over n,p is only for scaling of the y-axis in the
%second loop which gives the final plot

%translating to (historical) objects
P1_dim=numel(P{1,3});
P2_dim=numel(P{2,3});
I1_dim=numel(I{1,3});
I2_dim=numel(I{2,3});

%preparing the scaling of the Y-axes
Yax=zeros(P1_dim,P2_dim,2);
Yaxmax=zeros(P1_dim);
Yaxmin=zeros(P2_dim);

%preparing a cell array to store the scenario numbers per experiment
E_stored=cell(P1_dim, P2_dim, I1_dim*I2_dim, 3);

%prepare a cell array to store data behind the boxplot 
%for every situation (n,p) and every experiment (k, l) the 
%the following data is stored: colnr, str1, str2, datapoints
R=cell(P1_dim, P2_dim, I1_dim, I2_dim,4);


%Taking into account the parameters others than P1,P2,I1,I2
D0=ones(1,s); %preparing index vector
D0str=''; %prepared to construct label of experiment


%loop over the scenario parameters OTHERS than P1, P2 if there are some
if numel(P(:,1))>2;
    for i=3:1:numel(P(:,1));
        D0=D0.*P{i,5}; %herefore scenario parameters OTHERS than P1, P2 are really not allowed to have more than one value
        D0str=[D0str '  ' P{i,2}, ': ', cell2mat(P{i,4})];
    end
end
    
%for loop going over the intervention parameters OTHERS than I1, I2 if
%there are some
if numel(I(:,1))>2;
    for i=3:1:numel(I(:,1));
        D0=D0.*I{i,5}; %herefore intervention parameters OTHERS than I1, I2 are really not allowed to have more than one value
        D0str=[D0str '  ' I{i,2}, ': ', cell2mat(I{i,4})];
    end
end


            kstar=0; %prepare counter to check if for this situation (i.e. this n,p-iteration) base experiment has already passed
            lstar=0;


%two runs to align the y-axis in the second one
for run=1:1:2;

    %suppresses second run if scaling of y axis is set manually
    if yaxmanual==1 && run==2
        continue 
    end
    
    clf
    close
    
    for n=1:P1_dim; %loop over the number of values for P1
        %note that for fix n, P1 is fix
        for p=1:P2_dim; %loop over the number of values for P1
        %note that for fix p, P2 is fix
    
            D=D0.*P{1,5}(n,:).*P{2,5}(p,:); %gives vector of length s having an entry "1" at all places with an index
            %corresponding to an index (in C) of a scenario corresponding to the choosen situation
            D_ind=find(D); %gives a vector with the indices (in C) of those scenarios
            D_dim=numel(D_ind);  %gives the number of those scenarios


            nseeds=D_dim/(I{1,6}*I{2,6}); %gives the number of seeds per experiment
            X=zeros(nseeds,(I1_dim*I2_dim-compare)); %matrix that will take the data for the boxplot, if compare==1 then there is one column less
            Label=cell.empty(I1_dim*I2_dim,0); %vector for the names of the boxes

            %if matlab shall compare to a base experiment, the index vectors
            %for this experiment are generated here and the data is loaded
            %and the values for measure==id is extracted
            %output for this part is: B_measure
            if compare==1 || proportion==1;
               E=D.*Bind;
               Eind=find(E);
               
               %loads the data
               %output is A_measure_agesum which is a threedimensional array 
               %with as many pages as scenarios the experiment has and
               %where each page is a matrix with the first column giving the timestep 
               %and the second one the value of the measure
               %with values eventually summed up over age groups
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

               %prepare loading the data
               Eind_dim=numel(Eind);
               B=zeros(Eind_dim,finitoline-startline+1,4);
               BB=zeros(finitoline-startline+1,4);

               %loop over the scenarios belonging to the uth experiment in order to load the data 
               for i=1:1:Eind_dim
                   datanr=Eind(i)-1; %Eind is with respect to indices in C starting with 1 while datanr is with respect to the output-nr starting with 0
                   output_path=strrep(strcat(path_output,'/wu',name,'_',num2str(datanr),'_out.txt'), '\', '/');
                   fileID = fopen(output_path);
                   BB=cell2mat(textscan(fileID, '%f %f %f %f', 'HeaderLines', startline-1, 'Delimiter', ','));
                   fclose(fileID);
                   BB=BB(1:finitoline-startline+1,:);
                   B(i,:,:)=BB;
                   clear BB
               end
               clear Eind;
               
               %finds the lines corresponding to the measure given by id
               measure=B(1,:,3)==id;
               measure_found=find(measure);

               %extracts the lines of A corresponding to measure id
               B_measure=B(:,measure_found,:);
               
                    %searches for the age group "age" if specified and else sums up over 
                    %all age groups available (may be still only one) 
                    if age~=0;
                        Age_1=B_measure(1,:,2)==age;
                        Age_1_found=find(Age_1);
                        B_measure_agesum=B_measure(:,Age_1_found,[1 4]);
                    else
                        %finds agegroups
                        Agegroups=unique(B(1,measure_found,2));
                        Agegroups_dim=numel(Agegroups);

                        %summing up over agegroups if there are multiple, else only rename
                        %A_measure_agesum

                        %initialising A_id_agesum with agegroup 1
                        %A_measure_agesum is a threedimensional array 
                        %where each page is a matrix with the first column giving the timestep 
                        %and the second one the value of the measure
                        Age_1=B_measure(1,:,2)==Agegroups(1);
                        Age_1_found=find(Age_1);
                        B_measure_agesum=B_measure(:,Age_1_found,[1 4]);

                        if Agegroups_dim > 1;
                            for i=2:1:Agegroups_dim;
                                %indices of lines of agegroup i
                                Age_i=B_measure(1,:,2)==Agegroups(i);
                                Age_i_found=find(Age_i);

                                %recursively summing up over age groups
                                B_measure_agesum(:,:,2)=B_measure_agesum(:,:,2) + B_measure(:,Age_i_found,4);
                            end 
                        end
                    end

                    %summing up values over survey timesteps
                    B_measure_agesum_sum=sum(squeeze(B_measure_agesum(:,:,2)),2);

                    %divides by the population size if demanded
                    if person==1
                        B_measure_agesum_sum=B_measure_agesum_sum/population;
                    end

                    %divides by the number of years if demanded
                    if year==1
                        years=(finito-start)/12;
                        B_measure_agesum_sum=B_measure_agesum_sum/years;
                    end
                    
                    %scaling by the manually inserted factor
                    B_measure_agesum_sum=scaling*B_measure_agesum_sum;
                    
               
            end
            
            
            base_contr=0;   %prepared counter to check if for this situation (i.e. this n,p-iteration) base experiment has already passed (base_contr=1) or not (base_contr=0)
                            %will stay 0 if compare==0.
                                    
                                    
            for k=1:I1_dim; %loop over number of values for I1
                for l=1:I2_dim; %loop over number of values for I2
                       
                    if run==1;
                        %label for experiment
                        str1=strcat(I{1,2},I{1,4}{k});
                        str2=strcat(I{2,2},I{2,4}{l});
                        strcurrent=[str1, ' ', str2];
                        

                        %index vector for experiment
                        E=D.*I{1,5}(k,:).*I{2,5}(l,:);
                        
                        %exits this iteration of the loop if it is the base
                        %experiment
                        if compare==1
                           DBind=D.*Bind;
                           if E==DBind
                               base_contr=1; %to recognise in the first run that base experiment has passed
                               kstar=k; %to recognise in the second run that base experiment has passed
                               lstar=l; %to recognise in the second run that base experiment has passed
                              continue
                           end
                           clear DBind
                        end
                        
                        colnr=(k-1)*I2_dim+l-base_contr;     %gives the column corresponding to k,l
                                                             %if compare==1 and base experiment has already passed (and hence this l-iteration skipped), then colnr is adjusted 
                                                             %if compare==0 then base_contr is anyway always 0
                        Eind=find(E);       

                        %store those
                        if shorttitle==0;
                            E_stored{n,p,colnr,1}=[P{1,2}, ': ', cell2mat(P{1,4}(n)), '   ', P{2,2}, ': ', cell2mat(P{2,4}(p)), sprintf('\n'), D0str]; %label of situation
                        else
                            E_stored{n,p,colnr,1}=[P{1,2}, ': ', cell2mat(P{1,4}(n)), '   ', P{2,2}, ': ', cell2mat(P{2,4}(p))]; %label of situation
                        end
                        E_stored{n,p,colnr,2}=strcurrent; %label of experiment "without situation"
                        E_stored{n,p,colnr,3}=Eind; %index vector of experiment
                    
                    elseif run==2;
                    if k==kstar && l==lstar; %recgonises if base experiment is passing 
                       base_contr=1;
                       continue
                    end
                    colnr=(k-1)*I2_dim+l-base_contr;     %gives the column corresponding to k,l
                                                             %if compare==1 and base experiment has already passed (and hence this l-iteration skipped), then colnr is adjusted 
                                                             %if compare==0 then base_contr is anyway always 0
                    end
                    
                    Eind=E_stored{n,p,colnr,3}; %retrieve index vector
                    strcurrent=E_stored{n,p,colnr,2}; %retrieve label of experiment "without situation"


                    %loads the data
                    %output is A_measure_agesum which is a threedimensional array 
                    %with as many pages as scenarios the experiment has and
                    %where each page is a matrix with the first column giving the timestep 
                    %and the second one the value of the measure
                    %with values eventually summed up over age groups
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    %prepare loading the data
                    Eind_dim=numel(Eind);
                    A=zeros(Eind_dim,finitoline-startline+1,4);
                    AA=zeros(finitoline-startline+1,4);

                    %loop over the scenarios belonging to the uth experiment in order to load the data 
                    for i=1:1:Eind_dim
                        datanr=Eind(i)-1; %Eind is with respect to indices in C starting with 1 while datanr is with respect to the output-nr starting with 0
                        output_path=strrep(strcat(path_output,'/wu',name,'_',num2str(datanr),'_out.txt'), '\', '/');
                        fileID = fopen(output_path);
                        AA=cell2mat(textscan(fileID, '%f %f %f %f', 'HeaderLines', startline-1, 'Delimiter', ','));
                        fclose(fileID);
                        AA=AA(1:finitoline-startline+1,:);
                        A(i,:,:)=AA;
                        clear AA
                    end

                    %finds the lines corresponding to the measure given by id
                    measure=A(1,:,3)==id;
                    measure_found=find(measure);

                    %extracts the lines of A corresponding to measure id
                    A_measure=A(:,measure_found,:);
                    

                    %searches for the age group "age" if specified and else sums up over 
                    %all age groups available (may be still only one) 
                    if age~=0;
                        Age_1=A_measure(1,:,2)==age;
                        Age_1_found=find(Age_1);
                        A_measure_agesum=A_measure(:,Age_1_found,[1 4]);
                    else
                        %finds agegroups
                        Agegroups=unique(A(1,measure_found,2));
                        Agegroups_dim=numel(Agegroups);

                        %summing up over agegroups if there are multiple, else only rename
                        %A_measure_agesum

                        %initialising A_id_agesum with agegroup 1
                        %A_measure_agesum is a threedimensional array 
                        %where each page is a matrix with the first column giving the timestep 
                        %and the second one the value of the measure
                        Age_1=A_measure(1,:,2)==Agegroups(1);
                        Age_1_found=find(Age_1);
                        A_measure_agesum=A_measure(:,Age_1_found,[1 4]);

                        if Agegroups_dim > 1;
                            for i=2:1:Agegroups_dim;
                                %indices of lines of agegroup i
                                Age_i=A_measure(1,:,2)==Agegroups(i);
                                Age_i_found=find(Age_i);

                                %recursively summing up over age groups
                                A_measure_agesum(:,:,2)=A_measure_agesum(:,:,2) + A_measure(:,Age_i_found,4);
                            end 
                        end
                    end

                    %summing up values over survey timesteps
                    A_measure_agesum_sum=sum(squeeze(A_measure_agesum(:,:,2)),2);
                    
                    %scaling with the manually inserted factor (which is 1
                    %if not inserted)
                    A_measure_agesum_sum=scaling*A_measure_agesum_sum;

                    %divides by the population size if demanded
                    if person==1
                        A_measure_agesum_sum=A_measure_agesum_sum/population;
                    end

                    %divides by the number of years if demanded
                    if year==1
                        years=(finito-start)/12;
                        A_measure_agesum_sum=A_measure_agesum_sum/years;
                    end

                    %if matlab shall compare to a base experiment, the values
                    %of A_measure_agesum_sum are here changed to
                    %differences to B_measure_agesum_sum
                    if compare==1
                        A_measure_agesum_sum=B_measure_agesum_sum-A_measure_agesum_sum;
                    end
                    
                    %if matlab shall show measures as proportions to a base experiment, 
                    %the values of A_measure_agesum_sum are here changed to proportions 
                    %with respect to B_measure_agesum_sum
                    if proportion==1
                        A_measure_agesum_sum=A_measure_agesum_sum./B_measure_agesum_sum;
                    end
                    
                    X(:,colnr)=A_measure_agesum_sum;
                    Label{colnr}=strcurrent;
                    
                    %store raw data in R if run=1
                    if run==1
                    R{n,p,k,l,1}=colnr;
                    R{n,p,k,l,2}=str1;
                    R{n,p,k,l,3}=str2;
                    R{n,p,k,l,4}=A_measure_agesum_sum;
                    
                        %store data for base experiment if there is one
                        if compare==1 || proportion==1;
                           R{n,p,kstar,lstar,4}=zeros(nseeds,1);
                        end
                    end
                    
                end
            end 
            plotnr=(n-1)*P2_dim+p; %gives the number of the plot corresponding to n,p
            %note that P2_dim is the length of the rows of the subplot
            
            if subplotmode==1
                subplot(P1_dim,P2_dim,plotnr);
            end
            
            boxplot(X, 'labels', Label');


            %plot parameters
            ha = gca;
            set(ha, 'FontSize', plotfs); 
            ha.XTickLabelRotation = labelrotation;
            
            hx  = xlabel('Intervention');
            ylabbel=id_name;
            if person==1
                ylabbel=[ylabbel, ' per person '];
            end
            if year==1
                ylabbel=[ylabbel, 'per year '];
            end
            
            if compare==1
                ylabbel=[ylabbel, 'as difference to '];
            end
            
            if compare==1 && proportion==1
                ylabbel=[ylabbel, 'and '];
            end
            
            if proportion==1
                ylabbel=[ylabbel, 'proportional to '];
            end
            
            if compare==1 || proportion==1
                ylabbel=[ylabbel, 'base experiment'];
            end
            
            if strcmp(yaxis,'0')~=1;
                ylabbel=yaxis;
            end
            
            hy = ylabel(ylabbel);

            tit=E_stored{n,p,colnr,1};
            
            %if showtitle=1, then set title of plot
            if showtitle==1
            Title=title(tit, 'Interpreter', 'none');
            Title.FontSize = titlefs;
            end 
            

            if run==1;
                
                %if yaxmanual==1, then scaling of y axis is set manually 
                %and also print in separate prints desired
                if yaxmanual==1
                    ha.YLim=[yaxmin yaxmax];

                    %print to separate files
                    if subplotmode==0;
                        printto=['-d' fileformat];
                        plotname=[filename '__' P{1,2} P{1,4}{n} '_' P{2,2} P{2,4}{p}];
                        plotnamewithextension=[plotname '.' fileformat];
                        print(gcf, printto, plotnamewithextension);
                    end
                
                else
                %stores the scaling of the Y-axis for this subplot
                Yax(n,p,:)=ha.YLim; 
                end
                
            else    
                %aligns the scaling of the Y-axis if alignros==1
                if alignrow==1
                ha.YLim=[Yaxmin(n) Yaxmax(n)];
                end
                
                %print to separate files
                if subplotmode==0;
                printto=['-d' fileformat];
                plotname=[filename '__' P{1,2} P{1,4}{n} '_' P{2,2} P{2,4}{p}];
                plotnamewithextension=[plotname '.' fileformat];
                print(gcf, printto, plotnamewithextension);
                end
            end
            

            clear D
            clear E
            clear X
            clear A

        end 
    end
    if run==1;
        %finds the max of the YLim in each row of subplots
        Yaxmax=max(Yax(:,:,2),[],2);
        Yaxmin=min(Yax(:,:,1),[],2);
    end
end
hh=gcf;


%paper settings if saved to pdf
if strcmp(fileformat, 'pdf')==1
    set(hh,'PaperOrientation',paperorientation);
    
    if strcmp(paperorientation, 'landscape')==1
        paperposition=[-1.5 -0.5 32 22];
    else
        paperposition=[-0.5 -1.5 22 32];  
    end
    set(hh,'PaperPosition', paperposition);
end


printto=['-d' fileformat];
filenamewithextension=[filename '.' fileformat];
print(gcf, printto, filenamewithextension);



