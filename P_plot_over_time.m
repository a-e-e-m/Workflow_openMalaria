%%P_plot_over_time
%plots the dynamics of the below specified scenario
%at maximum 10 different parameter settings are possible

clf
close

%loads the parameters from matlab_OM_plot_parameters.txt
filepath='./matlab_OM_plot_parameters.txt';
fileID = fopen(filepath);
Para_plot = textscan(fileID, '%s %s %s', 'Delimiter', '=');
fclose(fileID);
dim=prod(size(Para_plot{1,1}));

%finds the measure matlab shall look at
IDDI=find(strcmp(Para_plot{1,1},'id'),1);
ID=str2double(Para_plot{1,2}{IDDI});

%finds the name of the measure 
IDDINAME=find(strcmp(Para_plot{1,1},'idname'),1);
IDNAME=Para_plot{1,2}{IDDINAME};

%Find 'start', the survey time step matlab shall start the analysis 
start_found=find(strcmp(Para_plot{1,1},'start'),1);
start=str2double(Para_plot{1, 2}{start_found});

%Find 'finito', the survey time step matlab shall end the analysis 
finito_found=find(strcmp(Para_plot{1,1},'finito'),1);
finito=str2double(Para_plot{1, 2}{finito_found});



%finds out how many lines there are in the output file 
Atrash=load(strcat(path_output,'/wu',name,'_0_out.txt'));
[L trash]=size(Atrash);

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






%prepare matrix for identifying scenario
Scen=ones(s,1);
Tittel='';

u=find(strcmp(Para_plot{1,1},'1'),1);
[num, status]=str2num(Para_plot{1,1}{u});

while status==1
    idi=find(strcmp(Para_plot{1,2}{u},[C{1,:}]));
    Scen=strcmp(C{2,idi},Para_plot{1,3}{u}).*Scen;
    Tittel=strvcat(Tittel, strcat(Para_plot{1,2}{u}, ':', Para_plot{1,3}{u}));
    if u==dim
        break
    end
    u=u+1;
    [num, status]=str2num(Para_plot{1,1}{u});
end

%part of A we are looking at
A_agessum=A;

% % %indices of lines of age group 1
%  Ages1=A_Lines(1,:,2)==1;
%  F_Ages1=find(Ages1);
% % %indices of lines of age group 2
%  Ages2=A_Lines(1,:,2)==2;
%  F_Ages2=find(Ages2);
% % %summing up over age groups
% A_agessum=A_Lines(:,F_Ages1,:);
% A_agessum(:,:,4)=A_Lines(:,F_Ages1,4)+A_Lines(:,F_Ages2,4);

IDInd=A_agessum(1,:,3)==ID;
FIDInd=find(IDInd);
Scenind=find(Scen);
A_agessum_IDScen=median(A_agessum(Scenind,FIDInd,4),1);

X=[start:finito];
Y=A_agessum_IDScen;
plot(X,Y);

%plot parameters
plotfs = 10;
hx  = xlabel('months');
hy = ylabel(IDNAME);

Title=title(Tittel, 'Interpreter', 'none');

set(Title, 'FontSize', plotfs);
set(hx,'FontSize', plotfs);
set(hy,'FontSize',plotfs);