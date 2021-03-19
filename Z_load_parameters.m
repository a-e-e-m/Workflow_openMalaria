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

%Find 'pathscen', the path to the scenarios.csv file.
pathscen_found=find(strcmp(Para{1,1},'pathscen'),1);
pathscen=Para{1, 2}{pathscen_found};

%Find 'nseeds', the number of seeds used to run the simulation.
nseeds_found=find(strcmp(Para{1,1},'nseeds'),1);
nseeds=str2double(Para{1, 2}{nseeds_found});

%finds scen_columns by itself
filepath=strcat(pathscen, '/scenarios.csv');
fileID = fopen(filepath);
C_trash = textscan(fileID, '%s',1);
C_trash = char(C_trash{1,1});
fclose(fileID);
C_trash_commas_found=strfind(C_trash, ',');
scen_columns=numel(C_trash_commas_found)+1;

%Find name, values and labels for the scenario parameters.
P_found=find(strcmp(Para{1,1},'P')); %finds lines starting with "P"
P_unique=unique(Para{1,2}(P_found), 'stable'); %list all different scenario parameters
P_unique_dim=numel(P_unique); %number of different scenario parameters
P=cell(P_unique_dim,6); %prepare cell to store all info for scenario parameters
%"P{:,5}" is prepared for storing a matrix with the index vectors as rows
%"P{:,6}" is prepared for storing the number of different values of the
%parameters occuring in the scenarios 

for i=1:1:P_unique_dim
   P{i,1}=P_unique{i}; %ith scenario parameter
   
   %where info for ith scenario parameter are - within the lines beginning with P
   Para_1_2_P=Para{1,2}(P_found);
   P_i_found=find(strcmp(Para_1_2_P, P_unique{i})); 
   clear Para_1_2_P;
   
   %label of the ith scenario parameter
   Para_1_3_P=Para{1,3}(P_found);
   P{i,2}=Para_1_3_P{P_i_found(1)};
   clear Para_1_3_P;
   
   %values of the ith scenario parameter
   Para_1_4_P=Para{1,4}(P_found);
   P{i,3}=Para_1_4_P(P_i_found);
   clear Para_1_4_P;
   
   %labels of the values of the ith scenario parameter
   Para_1_5_P=Para{1,5}(P_found);
   P{i,4}=Para_1_5_P(P_i_found);
   clear Para_1_5_P;
end



%Find name, values and labels for the intervention parameters.
I_found=find(strcmp(Para{1,1},'I')); %finds lines starting with "I"
I_unique=unique(Para{1,2}(I_found), 'stable'); %lists all different intervention parameters
I_unique_dim=numel(I_unique); %number of different intervention parameters
I=cell(I_unique_dim,6); %prepare cell to store all info for scenario parameters
%"I{:,5}" is prepared for storing a matrix with the index vectors as rows
%"I{:,6}" is prepared for storing the number of different values of the
%parameters occuring in the scenarios 

for i=1:1:I_unique_dim
   I{i,1}=I_unique{i}; %ith intervention parameter
   
   %where info for ith scenario parameter are - within the lines beginning with I
   Para_1_2_I=Para{1,2}(I_found);
   I_i_found=find(strcmp(Para_1_2_I, I{i,1})); 
   clear Para_1_2_I
   
   %label of ith intervention parameter
   Para_1_3_I=Para{1,3}(I_found);
   I{i,2}=Para_1_3_I{I_i_found(1)};
   clear Para_1_3_I
   
   %values of ith intervention parameter
   Para_1_4_I=Para{1,4}(I_found);
   I{i,3}=Para_1_4_I(I_i_found);
   clear Para_1_4_I
   
   %labels of values of ith intervention parameter
   Para_1_5_I=Para{1,5}(I_found);
   I{i,4}=Para_1_5_I(I_i_found);
   clear Para_1_5_I
end

%Find 'compare' that tells whether to compare measures to a reference
%Experiment
compare_found=find(strcmp(Para{1,1},'compare'),1);
compare=str2double(Para{1, 2}{compare_found});

%Find 'proportion' that tells whether to compare measures to a reference
%Experiment
proportion_found=find(strcmp(Para{1,1},'proportion'),1);
proportion=str2double(Para{1, 2}{proportion_found});

%load base experiment if compare==1 or proportion==1
if compare==1 || proportion==1;
    base_found=find(strcmp(Para{1,1},'base'));
    %test whether base experiment is properly defined
    if numel(base_found)~=I_unique_dim
        'base experiment not properly defined'
        return 
    end
    
    base=cell(I_unique_dim,4);
    base(:,1)=Para{1,2}(base_found); %parameters for base experiment
    base(:,2)=Para{1,3}(base_found); %labels of parameters for base experiment
    base(:,3)=Para{1,4}(base_found); %values of parameters for base experiment
    base(:,4)=Para{1,5}(base_found); %labels of values of parameters for base experiment
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
Atrash=load(strcat(path_output,'/wu',name,'_7_out.txt'));
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

%finds a manually inserted label for the y-axis if there is one
yaxis_found=find(strcmp(Para{1,1},'yaxis'));
yaxis=Para{1,2}{yaxis_found};

%finds whether scaling of y-axis is manually set
alignrow_found=find(strcmp(Para{1,1},'alignrow'));
alignrow=str2double(Para{1,2}{alignrow_found});

%finds whether scaling of y-axis is manually set
yaxmanual_found=find(strcmp(Para{1,1},'yaxmanual'));
yaxmanual=str2double(Para{1,2}{yaxmanual_found});

%finds the minimal value for manually set scaling of y-axis
yaxmin_found=find(strcmp(Para{1,1},'yaxmin'));
yaxmin=str2double(Para{1,2}{yaxmin_found});

%finds the minimal value for manually set scaling of y-axis
yaxmax_found=find(strcmp(Para{1,1},'yaxmax'));
yaxmax=str2double(Para{1,2}{yaxmax_found});

%finds a manually inserted scaling factor
scaling_found=find(strcmp(Para{1,1},'scaling'));
scaling=str2double(Para{1,2}{scaling_found});

%Find 'subplotmode' that tell whether to use subplotmode or not
subplotmode_found=find(strcmp(Para{1,1},'subplotmode'),1);
subplotmode=str2double(Para{1, 2}{subplotmode_found});

%Find 'showtitle' that tell whether to print titles or not
showtitle_found=find(strcmp(Para{1,1},'showtitle'),1);
showtitle=str2double(Para{1, 2}{showtitle_found});

%Find 'shorttitle' that tell whether to print titles or not
shorttitle_found=find(strcmp(Para{1,1},'shorttitle'),1);
shorttitle=str2double(Para{1, 2}{shorttitle_found});

%Find 'plotfs', the font size of the labels in the plots
plotfs_found=find(strcmp(Para{1,1},'plotfs'),1);
plotfs=str2double(Para{1, 2}{plotfs_found});

%Find 'titlefs', the font size of the titles in the plots
titlefs_found=find(strcmp(Para{1,1},'titlefs'),1);
titlefs=str2double(Para{1, 2}{titlefs_found});

%Find 'labelrotation', the angle about which the labels in the plot shall be
%rotated 
labelrotation_found=find(strcmp(Para{1,1},'labelrotation'),1);
labelrotation=str2double(Para{1, 2}{labelrotation_found});

%Find 'fileformat', the format the figure shall be saved as
paperorientation_found=find(strcmp(Para{1,1},'paperorientation'),1);
paperorientation=Para{1, 2}{paperorientation_found};

%Find 'fileformat', the format the figure shall be saved as
fileformat_found=find(strcmp(Para{1,1},'fileformat'),1);
fileformat=Para{1, 2}{fileformat_found};

%Find 'filename', the path and name of the pdf matlab shall print
filename_found=find(strcmp(Para{1,1},'filename'),1);
filename=Para{1, 2}{filename_found};