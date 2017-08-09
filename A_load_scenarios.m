%load_scenarios_Rusingathree

%create cell array to write scenario file in
C=cell(2,scen_columns);

%prepare textscan settings
header='%s';
for i=1:scen_columns-1;
header=strcat(header,' %s');
end
body=strcat(header(1:end-3),' %u');

%open, read and store scenario file
filepath=strcat(pathscen,'/scenarios.csv');
fileID = fopen(filepath);
C(1,:) = textscan(fileID, header, 1, 'Delimiter', ',');
C(2,:) = textscan(fileID, body, 'HeaderLines',1, 'Delimiter', ',');
fclose(fileID);

%s is the number of different scenarios in the scenario.csv file i.e.
%number of output files
s=numel(C{2,1});


%loop over the number of scenario parameters 
for i=1:1:numel(P(:,1));
    P_i_columninC_found=find(strcmp([C{1,:}], P{i,1})); %gives index of the column of C corresponding to parameter P{i,1}
    
    P_i_dim=numel(P{i,3});%number of different values for P_unique_i
    P{i,5}=zeros(P_i_dim, s); %matrix to store index vectors for the values of P_unique_i as rows
    
    for j=1:1:P_i_dim;
    P{i,5}(j,:)=strcmp(C{2,P_i_columninC_found},P{i,3}(j)); %logical index vector
    %vector of length s having an entry "1" at all places with an index
    %corresponding to an index (in C) of a scenario with value P{i,3}(j)
    %for parameter P{i,1}
    end
    
    P_i_inC_unique=unique(C{2,P_i_columninC_found}, 'stable'); %different values of parameter P{i,1} occuring in the scenarios 
    P{i,6}=numel(P_i_inC_unique); %number of different values of parameter P{i,1} occuring in the scenarios 
end


%loop over the number of intervention parameters 
for i=1:1:numel(I(:,1));
    I_i_columninC_found=find(strcmp([C{1,:}], I{i,1})); %gives index of the column of C corresponding to parameter I{i,1}
    
    I_i_dim=numel(I{i,3});%number of different values for I_unique_i
    I{i,5}=zeros(I_i_dim, s); %matrix to store index vectors for the values of I_unique_i as rows
    
    for j=1:1:I_i_dim;
    I{i,5}(j,:)=strcmp(C{2,I_i_columninC_found},I{i,3}(j)); %logical index vector
    %vector of length s having an entry "1" at all places with an index
    %corresponding to an index (in C) of a scenario with value I{i,3}(j)
    %for parameter I{i,1}
    end
    
    I_i_inC_unique=unique(C{2,I_i_columninC_found}, 'stable'); %different values of parameter I{i,1} occuring in the scenarios 
    I{i,6}=numel(I_i_inC_unique); %number of different values of parameter I{i,1} occuring in the scenarios 
end

%if compare==1 find index vector for base experiment
if compare==1
    B=ones(1,s); %prepare index vector of base experiment
    B_label=''; %prepare label of base experiment
    for i=1:1:numel(base(:,1));
        base_i_columninC_found=find(strcmp([C{1,:}], base{i,1})); %gives index of the column of C corresponding to parameter base{i,1}
        B_temp=strcmp(C{2,base_i_columninC_found}, base{i,3});
        B=B.*B_temp'; %index vector of base experiment
        B_label=[B_label, ' ', base{i,2}, base{i,4}] %label of base experiment
    end
end
