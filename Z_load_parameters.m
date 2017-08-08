%load_parameters loads parameters for the matlab scripts from the txt-file
%matlab_OM_boxplot_parameters.txt which has to be in the same folder as the
%.m-files

clear;

%load matlab_OM_boxplot_parameters.txt
filepath='./matlab_OM_boxplot_parameters.txt';
fileID = fopen(filepath);
Para = textscan(fileID, '%s %s %s %s %s', 'Delimiter', '=');
fclose(fileID);

%for A_load_scenarios

%Find 'pathscen', the path to the scenarios.txt file.
pathscen_found=find(strcmp(Para{1,1},'pathscen'),1);
pathscen=Para{1, 2}{pathscen_found};

%Find 'scen_columns', the number of columns in the fiel scenarios.csv.
scen_columns_found=find(strcmp(Para{1,1},'scen_columns'),1);
scen_columns=str2double(Para{1, 2}{scen_columns_found});


%Find name, values and labels for the scenario parameters.
P_found=find(strcmp(Para{1,1},'P'));
P_unique=unique(Para{1,2}(P_found), 'stable');
P_unique_dim=numel(P_unique);
P=cell(P_unique_dim,6); %prepare cell to store all info for scenario parameters
%"P{:,5}" is prepared for storing a matrix with the index vectors as rows
%"P{:,6}" is prepared for storing the number of different values of the
%parameters occuring in the scenarios 

for i=1:1:P_unique_dim
   P{i,1}=P_unique{i}; %ith scenario parameter
   P_unique_i_found=find(strcmp(Para{1,2}, P_unique{i})); %where info for ith scenario parameter are
   P{i,2}=Para{1,3}{P_unique_i_found(1)};
   P{i,3}=Para{1,4}(P_unique_i_found);
   P{i,4}=Para{1,5}(P_unique_i_found);
end



%Find name, values and labels for the intervention parameters.
I_found=find(strcmp(Para{1,1},'I'));
I_unique=unique(Para{1,2}(I_found), 'stable');
I_unique_dim=numel(I_unique);
I=cell(I_unique_dim,6); %prepare cell to store all info for scenario parameters
%"I{:,5}" is prepared for storing a matrix with the index vectors as rows
%"I{:,6}" is prepared for storing the number of different values of the
%parameters occuring in the scenarios 

for i=1:1:I_unique_dim
   I{i,1}=I_unique{i}; %ith scenario parameter
   I_unique_i_found=find(strcmp(Para{1,2}, I_unique{i})); %where info for ith scenario parameter are
   I{i,2}=Para{1,3}{I_unique_i_found(1)};
   I{i,3}=Para{1,4}(I_unique_i_found);
   I{i,4}=Para{1,5}(I_unique_i_found);
end



%for B_load_output

%Find 'path_output', the path of the output files
path_output_found=find(strcmp(Para{1,1},'path_output'),1);
path_output=Para{1, 2}{path_output_found};

%Find 'name', the name of the experiment
name_found=find(strcmp(Para{1,1},'name'),1);
name=Para{1, 2}{name_found};

%for C_extract_Aid_agesum

%finds the agegroup matlab shall look at
age_found=find(strcmp(Para{1,1},'age'));
age=str2double(Para{1,2}{age_found});

%Find 'start', the survey time step matlab shall start the analysis 
start_found=find(strcmp(Para{1,1},'start'),1);
start=str2double(Para{1, 2}{start_found});

%Find 'finito', the survey time step matlab shall end the analysis 
finito_found=find(strcmp(Para{1,1},'finito'),1);
finito=str2double(Para{1, 2}{finito_found});

%finds out how many lines there are in the output file 
Atrash=load(strcat(path_output,'/wu',name,'_0_out.txt'));
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

%Find 'id', the measure matlab shall analyse
id_found=find(strcmp(Para{1,1},'id'),1);
id=str2double(Para{1, 2}{id_found});
id_name=Para{1, 3}{id_found};

%Find 'person', a value of either 0 or 1 that indicates whether matlab
%shall measure per person,
%and find 'population', the population size of the simulation.
person_found=find(strcmp(Para{1,1},'person'),1);
person=str2double(Para{1, 2}{person_found});

population_found=find(strcmp(Para{1,1},'population'),1);
population=str2double(Para{1, 2}{population_found});

%Find 'year', a value of either 0 or 1 that indicates whether matlab
%shall measure per year i.e whether it shall take 
%the average over the time between start and finito
year_found=find(strcmp(Para{1,1},'year'),1);
year=str2double(Para{1, 2}{year_found});

%Find 'pdfname', the path and name of the pdf matlab shall print
pdfname_found=find(strcmp(Para{1,1},'pdfname'),1);
pdfname=Para{1, 2}{pdfname_found};