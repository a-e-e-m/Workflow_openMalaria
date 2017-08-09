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

%fontsizes
plotfs = 4.5;
titlefs = 10;


%Taking into account the parameters others than P1,P2,I1,I2
D0=ones(1,s); %preparing index vector

%loop over the scenario parameters OTHERS than P1, P2 if there are some
if numel(P(:,1))>2;
    for i=3:1:numel(P(:,1));
        D0=D0.*P{i,5}; %herefore scenario parameters OTHERS than P1, P2 are really not allowed to have more than one value
    end
end
    
%for loop going over the intervention parameters OTHERS than I1, I2 if
%there are some
if numel(I(:,1))>2;
    for i=3:1:numel(I(:,1));
        D0=D0.*I{i,5}; %herefore intervention parameters OTHERS than I1, I2 are really not allowed to have more than one value
    end
end


%two runs to align the y-axis in the second one
for run=1:1:2;
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
            X=zeros(nseeds,(I1_dim*I2_dim)); %matrix that will take the data for the boxplot
            Label=cell.empty(I1_dim*I2_dim,0); %vector for the names of the boxes

            for k=1:I1_dim; %loop over number of values for I1
                for l=1:I2_dim; %loop over number of values for I2
                    colnr=(k-1)*I2_dim+l; %gives the column corresponding to k,l

                    if run==1;
                        %label for experiment
                        str1=strcat(I{1,2},I{1,4}{k});
                        str2=strcat(I{2,2},I{2,4}{l});
                        strcurrent=[str1, ' ', str2];

                        %index vector for experiment
                        E=D.*I{1,5}(k,:).*I{2,5}(l,:);
                        Eind=find(E);       

                        %store those
                        E_stored{n,p,colnr,1}=strcat(P{1,2}, ': ', P{1,4}(n), '__', P{2,2}, ': ', P{2,4}(p)); %label of situation
                        E_stored{n,p,colnr,2}=strcurrent; %label of experiment "without situation"
                        E_stored{n,p,colnr,3}=Eind; %index vector of experiment
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
                        datanr=Eind(i)-1; %Eind is with respect to indices in C starting with 1while datanr is with respect to the output-nr starting with 0
                        output_path=strrep(strcat(path_output,'/wu',name,'_',num2str(datanr),'_out.txt'), '\', '/');
                        fileID = fopen(output_path);
                        AA=cell2mat(textscan(fileID, '%f %f %f %f', 'HeaderLines', startline-1, 'Delimiter', ','));
                        fclose(fileID);
                        A(i,:,:)=AA;
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

                    %divides by the population size if demanded
                    if person==1
                        A_measure_agesum_sum=A_measure_agesum_sum/population;
                    end

                    %divides by the number of years if demanded
                    if year==1
                        years=(finito-start)/12;
                        A_measure_agesum_sum=A_measure_agesum_sum/years;
                    end

                    X(:,colnr)=A_measure_agesum_sum;
                    Label{colnr}=strcurrent;
                end
            end 
            plotnr=(n-1)*P2_dim+p; %gives the number of the plot corresponding to n,p
            %note that P2_dim is the length of the rows of the subplot
            subplot(P1_dim,P2_dim,plotnr);
            boxplot(X, 'labels', Label');

            %subplot parameters
            hx  = xlabel('Intervention');
            ylabbel=id_name;
            if person==1
                ylabbel=strcat(ylabbel, 'per person');
            end
            if year==1
                ylabbel=strcat(ylabbel, 'per year');
            end
            hy = ylabel(ylabbel);

            tit=E_stored{n,p,colnr,1};
            Title=title(tit, 'Interpreter', 'none');

            set(Title, 'FontSize', titlefs);
            set(hx,'FontSize', plotfs);
            set(hy,'FontSize',plotfs);

            ha = gca;
            set(ha, 'FontSize', plotfs); 
            ha.XTickLabelRotation = 0;

            if run==1;
                %stores the scaling of the Y-axis for this subplot
                Yax(n,p,:)=ha.YLim;    
            else    
                %aligns the scaling of the Y-axis 
                ha.YLim=[Yaxmin(n) Yaxmax(n)];						  							  
            end


            clear D
            clear E
            clear X

        end 
    end
    if run==1;
        %finds the max of the YLim in each row of subplots
        Yaxmax=max(Yax(:,:,2),[],2);
        Yaxmin=min(Yax(:,:,1),[],2);
    end
end
hh=gcf;

set(hh,'PaperOrientation','landscape');

set(hh,'PaperPosition', [-1.5 -0.5 32 22]);

print(gcf, '-dpdf', pdfname);

