%%P_plot_over_time
%plots the dynamics of the below specified scenario
%at maximum 10 different parameter settings are possible

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%subplot not yet working!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clf
close

%clear some variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except E_stored C path_output pathscen name id id_name person population ylabbel;

%loading things
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%loads the parameters from matlab_OM_plot_parameters.txt
filepath='./matlab_OM_plot_followup_parameters.txt';
fileID = fopen(filepath);
Para_followup_plot = textscan(fileID, '%s %s %s', 'Delimiter', '=');
fclose(fileID);
dim=numel(Para_followup_plot{1,1});

%Find 'start', the survey time step matlab shall start the analysis 
start_found=find(strcmp(Para_followup_plot{1,1},'start'),1);
start=str2double(Para_followup_plot{1, 2}{start_found});

%Find 'finito', the survey time step matlab shall end the analysis 
finito_found=find(strcmp(Para_followup_plot{1,1},'finito'),1);
finito=str2double(Para_followup_plot{1, 2}{finito_found});

%finds out how many lines there are in the output file 
  
    %getting the name of any outputfile
    filepath=strcat(pathscen,'/scenarios.csv');
    fileID = fopen(filepath);
    temp = textscan(fileID, '%s', 1, 'HeaderLines', 1, 'Delimiter', ',');
    temp = char(temp{1,1});
    temp = temp(1:end-4);
    fclose(fileID);
    clear filepath
    
Atrash=load(strcat(path_output,'/',temp, '.txt'));
clear temp
[L, trash]=size(Atrash);
%sets finito to this value if finito was 0 i.e. if analysis shall be
%conducted until the end of the data
endefeuer=Atrash(L,1);
if finito==0;
    finito=endefeuer;
end

%gives the number of the first line of the survey timestep start
startline=find(Atrash(:,1)==start, 1);

%gives the number of the last line of the survey timestep finito
finitoline=find(Atrash(:,1)==finito, 1, 'last');

%Find 'SurveyTimestepCorrection', which gives the survey time step whos 
%values have to be corrected and the respective correction factor
SurveyTimestepCorrection_found=find(strcmp(Para_followup_plot{1,1},'SurveyTimestepCorrection'));
SurveyTimestepCorrection=zeros(numel(SurveyTimestepCorrection_found),2);
for i=1:1:numel(SurveyTimestepCorrection_found);
    SurveyTimestepCorrection(i,1)=str2double(Para_followup_plot{1, 2}{SurveyTimestepCorrection_found(i)});
    SurveyTimestepCorrection(i,2)=str2double(Para_followup_plot{1, 3}{SurveyTimestepCorrection_found(i)});
end

%finds the experiment indices of the experiment matlab shall plot
U_found=find(strcmp(Para_followup_plot{1,1},'timeplot'));
U_dim=numel(U_found);

%finds out if matlab shall plot into one subplot
plotmode_found=find(strcmp(Para_followup_plot{1,1},'plotmode'));
plotmode=Para_followup_plot{1,2}{plotmode_found};

%finds the agegroup matlab shall look at
age_found=find(strcmp(Para_followup_plot{1,1},'age'));
age=str2double(Para_followup_plot{1,2}{age_found});

%finds the path and name matlab shall save the output to
saveas_found=find(strcmp(Para_followup_plot{1,1},'saveas'));
if numel(saveas_found)~=0;
saveas=Para_followup_plot{1,2}{saveas_found};
end

%finds a manually inserted label for the y-axis if there is one
yaxis_found=find(strcmp(Para_followup_plot{1,1},'yaxis'));
yaxis=Para_followup_plot{1,2}{yaxis_found};

%finds a manually inserted scaling factor
scaling_found=find(strcmp(Para_followup_plot{1,1},'scaling'));
scaling=str2double(Para_followup_plot{1,2}{scaling_found});

%finds whether scaling of y-axis is manually set
yaxmanual_found=find(strcmp(Para_followup_plot{1,1},'yaxmanual'));
yaxmanual=str2double(Para_followup_plot{1,2}{yaxmanual_found});

%finds the minimal value for manually set scaling of y-axis
yaxmin_found=find(strcmp(Para_followup_plot{1,1},'yaxmin'));
yaxmin=str2double(Para_followup_plot{1,2}{yaxmin_found});

%finds the minimal value for manually set scaling of y-axis
yaxmax_found=find(strcmp(Para_followup_plot{1,1},'yaxmax'));
yaxmax=str2double(Para_followup_plot{1,2}{yaxmax_found});


%plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for u=1:1:U_dim;
    
    %gives the index vector of the uth experiment 
    Experiment_index=str2num(Para_followup_plot{1,2}{U_found(u)});
    indexa=Experiment_index(1);
    indexb=Experiment_index(2);
    indexc=Experiment_index(3);
    Eind=E_stored{indexa, indexb, indexc, 3};
    Eind_dim=numel(Eind);
    
    %prepare loading the data
    A=zeros(Eind_dim,finitoline-startline+1,4);
    AA=zeros(finitoline-startline+1,4);
    
    %loop over the scenarios belonging to the uth experiment in order to load the data 
    for i=1:1:Eind_dim
        datanr=Eind(i)-1; %Eind is with respect to indices in C starting with 1 while datanr is with respect to the output-nr starting with 0
        temp = char(C{2,1}(Eind(i)));
        temp = temp(1:end-4);
        output_path=strrep(strcat(path_output,'/',temp,'.txt'), '\', '/');
        fileID = fopen(output_path);
        AA=cell2mat(textscan(fileID, '%f %f %f %f', 'HeaderLines', startline-1, 'Delimiter', ','));
        fclose(fileID);
        AA=AA(1:finitoline-startline+1,:);
        A(i,:,:)=AA;
        clear AA
        clear temp
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
        %A_id_agesum is a threedimensional array 
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
                A_measure_agesum(:,:,2)=A_measure_agesum(:,:,2) + A_measure(:,Age_i_found, 4);
            end 
        end
    end
    
    %take the median (over the scenarios) of the data
    A_measure_agesum_median=median(A_measure_agesum,1);
    A_measure_agesum_median=squeeze(A_measure_agesum_median); % remove singleton dimension
    
    %divides by the population size if demanded
    if person==1
        A_measure_agesum_median(:,2)=A_measure_agesum_median(:,2)/population;
    end
    
    %Correction of the values of one survey timestep that is longer or short than
    %the others
    for j=1:1:(numel(SurveyTimestepCorrection)/2);
    for i=1:1:(numel(A_measure_agesum_median)/2)
        if mod(A_measure_agesum_median(i,1),12)==mod(SurveyTimestepCorrection(j,1),12)+1;
            A_measure_agesum_median(i,2)=A_measure_agesum_median(i,2)*SurveyTimestepCorrection(j,2);
        end
    end
    end
    
    X=1905+A_measure_agesum_median(:,1)/12;
    Y=scaling*A_measure_agesum_median(:,2);
    
    %checks what plot to use
    if strcmp(plotmode,'subplot')==1
    %subplot
    side=ceil(sqrt(U_dim));
    subplot(side,side,u);
    plot(X,Y);
    
    else
    %separate plots each saved to a separate file
    close;
    clf;
    plot(X,Y);
    
    end
    
    %gives the name of the uth experiment 
    Experiment_name=[E_stored{indexa, indexb, indexc, 1}, sprintf('\n'), E_stored{indexa, indexb, indexc, 2}, ' ', '(median over ',num2str(Eind_dim),' scenarios)'];
    
    plotfs = 6.5;
    Title=title(Experiment_name, 'Interpreter', 'none');
    set(Title, 'FontSize', plotfs);
    
    %set scaling of the y-axis if yaxis is scaled manually
    if yaxmanual==1;
        haha=gca;
         haha.YLim=[yaxmin yaxmax];
    end
    
    %label of x-axis
    hx  = xlabel('years');
    
    %label of y-axis
    %overwrite ylabbel if yaxis is not 0
    if strcmp(yaxis,'0')~=1;
       ylabbel=yaxis;
    end
    
    hy = ylabel(ylabbel); %ylabbel is from D_boxplot.m
    
    set(hx,'FontSize', plotfs);
    set(hy,'FontSize',plotfs);
    
    hh=gcf;
   

   

    %checks what plot to use
    if strcmp(plotmode,'subplot')~=1
    %separate plots each saved to a separate file
    file_name=strrep(Experiment_name,'.','_');
    file_name=strrep(file_name,':','_');
    file_name=strrep(file_name,' ','_'); 
    file_name=strcat(file_name, '.', plotmode);
    file_name=strcat(saveas, file_name);
   % file_name=file_name{1,1};
    printmode=strcat('-d', plotmode);
    print(gcf, printmode, file_name);
    end
    

    %checks what plot to use
    if strcmp(plotmode,'subplot')==1
    set(hh,'PaperOrientation','landscape');
    set(hh,'PaperPosition', [-1.5 -0.5 32 22]);    
        %subplot
        print(gcf, '-dpdf', saveas);
    end
    
end