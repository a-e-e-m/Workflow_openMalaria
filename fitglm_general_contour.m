
%Interv1 corresponds to I1 and forms the groups i.e. different lines
%Interv2 corresponds to I2 and gives the indepenedent values inside each
%group

clf
close

modelname = 'glmfirstordersurf';

Beta=zeros(P1_dim,P2_dim,6); %allocation to store model coefficients

no = I1_dim * I2_dim *nseeds; %number of data points

for n=1:1:P1_dim; %number of values for first scenario parameter
    for p=1:1:P2_dim; %number of values for second scenario parameter

        Y=[]; % allocation to store data in vector
        
        %output vector i.e. dependent variable
        for k=1:1:I1_dim; % over values of first intervention parameter
            for l=1:1:I2_dim; % over values of second intervention parameter
            Y =[Y; R{n,p,k,l,4}]; % iteratively build up vector for output
            end
        end
        
        %independent variables
        Interv1 = [];
        Interv2 = [];
        
        noI2 = I2_dim*nseeds; %number of data points per value of Interv1
        for i=1:I1_dim;
            %iteratively build up vector for independent variable
            Interv1 = [Interv1; str2num(I{1,4}{i}) * ones(noI2,1)]; 
            %iteratively build up vector for independent variable
            for j=1:I2_dim;
            Interv2 = [Interv2; str2num(I{2,4}{j}) * ones(nseeds,1)];
            end
        end
        
        %store independent variables and output in table
        tbl = table(Interv1,Interv2,Y,'VariableNames',{'Interv1','Interv2','Y'});  
     
        Link = 'identity';
        scale = 'identity';
        lm = fitglm(tbl,'Y ~ Interv1 + Interv2 + Interv1:Interv2 ', ...
            'Distribution', 'normal', 'Link', Link);
     
     %store coefficients of model
     Beta(n,p,1:numel(lm.Coefficients.Estimate)) = lm.Coefficients.Estimate;
   

%creating figure for plot
figure(1)

%used later for ploting
if strcmp(scale,'log')==1;
    plotti=@semilogy;
else 
    plotti=@plot;
end

colours = {'r' 'g' 'b' 'm' 'c'};

plotnr=(n-1)*P2_dim+p; %gives the number of the plot corresponding to n,p
Dispersion(plotnr)=lm.Dispersion; %store dispersion

%for loop over groups i.e. over values of Intervention 1
for i=1:I1_dim
    
    %if subplotmode==1 subplot is given here
    if subplotmode==1
       subplot(P1_dim,P2_dim,plotnr);
    end
    
    colour = colours{1, mod(i-1,6)+1};
    sign = ['o', colour];
    legendName = [I{1,1}, ' ', I{1,4}{i}];
    
    groupstart = 1+(i-1)*noI2; 
    groupend = i*noI2;
    
    %plot data points
    plot3(Interv1(groupstart:groupend), Interv2(groupstart:groupend), Y(groupstart:groupend), sign)
    
    ha=gca;
    ha.ZLim=[0 1.5];
    hold on
    
    %plot regression lines
    Interv1_values = [];    
    for j=1:I1_dim
        Interv1_values = [Interv1_values, str2num(I{1,4}{j})];
    end
    
    Interv2_values = [];    
    for j=1:I2_dim
        Interv2_values = [Interv2_values, str2num(I{2,4}{j})];
    end
    
  Interv1cont=Interv1(1):0.05:Interv1(end);
  Interv2cont=Interv2(1):0.05:Interv2(end);

   [INTERV1CONT,INTERV2CONT]=meshgrid(Interv1cont,Interv2cont);
   z = Beta(n,p,1) + ...
            Beta(n,p,2) * INTERV1CONT + ...
            Beta(n,p,3) * INTERV2CONT + ...
            Beta(n,p,4) * INTERV1CONT .* INTERV2CONT ;
        
   s=surf(INTERV1CONT,INTERV2CONT, z, 'LineStyle', 'none'); 
%    hold on
%    
%       z2 = Beta(n,p,1) + ...
%             Beta(n,p,2) * INTERV1CONT + ...
%             Beta(n,p,3) * INTERV2CONT;
%         
% %    s=contour(INTERV1CONT,INTERV2CONT, z2, '--'); 
   
   
  % s=xlabel('trap-human ratio', 'FontSize', 16);
  % s=ylabel('repellent coverage', 'FontSize', 16); 
        

    
    ha=gca;

   
    
end
    hold off
    %legend('Location', 'best');
        



            ha = gca;
            set(ha, 'FontSize', plotfs); 
            ha.XTickLabelRotation = 0;
                  
%print plot file if subplotmode==0
if subplotmode==0
            hh=gcf;
            set(hh,'PaperOrientation','landscape');
            set(hh,'PaperPosition', [0 0 9 7]);        
    
            plotname=[filename '__' P{1,2} P{1,4}{n} '_' P{2,2} P{2,4}{p} '_' modelname '_' 'plot'];
            plotnamewithextension=[plotname '.tiff'];
            print(gcf, '-dtiff', plotnamewithextension);
            
            %close gcf
end            

            
         
%figure for model information 
figure(2)            
            % Get the table in string form.
            TString = evalc('disp(lm)');

            % Use TeX Markup for bold formatting and underscores.
            TString = strrep(TString,'<strong>','\bf');
            TString = strrep(TString,'</strong>','\rm');
            TString = strrep(TString,'_','\_');

            % Get a fixed-width font.
            FixedWidth = get(0,'FixedWidthFontName');

            % Output the table using the annotation command.
            annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
                'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);

%print figure with model information
            hh=gcf;
            set(hh,'PaperOrientation','portrait');
            set(hh,'PaperPosition', [0 0 20 15]);
    
            plotname=[filename '__' P{1,2} P{1,4}{n} '_' P{2,2} P{2,4}{p} '_' modelname '_' 'info'];
            plotnamewithextension=[plotname '.tiff'];
            print(gcf, '-dtiff', plotnamewithextension); 
            
            close gcf





    end 
end

if subplotmode==1
            figure(1)
            hh=gcf;

            set(hh,'PaperOrientation','landscape');

            set(hh,'PaperPosition', [-1.5 -0.5 32 22]);

            plotname=[filename '_' modelname '_' 'subplots'];
            plotnamewithextension=[plotname '.pdf'];
            print(gcf, '-dpdf', plotnamewithextension);

end


