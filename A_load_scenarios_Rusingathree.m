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

%identifying the column corresponding to P1, P2, I1, I2 respectively
p1 = find(strcmp([C{1,:}], P1));
p2 = find(strcmp([C{1,:}], P2));
i1 = find(strcmp([C{1,:}], I1{1}));
i2 = find(strcmp([C{1,:}], I2{1}));

%gives a logic vector indicating the different parameter values of 
%parameter P1
D1=zeros(P1_dim,s);
for j=1:P1_dim;
D1(j,:)=strcmp(C{2,p1},P1str{j,1});
end

%gives a logic vector indicating the different parameter values of
%parameter P2
D2=zeros(P2_dim,s);
for j=1:P2_dim;
D2(j,:)=strcmp(C{2,p2},P2str{j,1});
end

%finds how many different values for intervention parameter 1 are there in
%the scenario file
E1str=unique(C{2,i1}, 'stable');
E1str_dim=numel(E1str);


%gives a logic vector indicating the different intervention values of
%intervention I1
E1=zeros(I1_dim,s);
for j=1:I1_dim;
E1(j,:)=strcmp(C{2,i1},I1str{j,1});
end


%finds how many different values for intervention parameter 1 are there in
%the scenario file
E2str=unique(C{2,i2},'stable');
E2str_dim=numel(E2str);


%gives a logic vector indicating the different intervention values of
%intervention I2
E2=zeros(I2_dim,s);
for j=1:I2_dim;
E2(j,:)=strcmp(C{2,i2},I2str{j,1});
end
