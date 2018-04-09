
%Interv1 corresponds to I1 and forms the groups i.e. different lines
%Interv2 corresponds to I2 and gives the indepenedent values inside each
%group

clf
close


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
     
        Link = 'log';
        scale = 'identity';
        lm = fitglm(tbl,'Y ~ Interv1^2  + Interv2^2 + Interv1:Interv2', ...
            'Distribution', 'normal', 'Link', Link);
     
     %store coefficients of model
     Beta(n,p,1:numel(lm.Coefficients.Estimate)) = lm.Coefficients.Estimate;
     
%     plotnr=(n-1)*P2_dim+p; %gives the number of the plot corresponding to n,p
%     subplot(P1_dim,P2_dim,plotnr);
   
    
  
if strcmp(scale,'log')==1;
    plotti=@semilogy;
else 
    plotti=@plot;
end

colours = {'m' 'c' 'r' 'g' 'b' 'y'};

%for loop over groups i.e. over values of Intervention 1
for i=1:I1_dim
    colour = colours{1, mod(i,6)};
    sign = ['o', colour];
    
    groupstart = 1+(i-1)*noI2; 
    groupend = i*noI2;
    
    %plot data points
    plotti( Interv2(groupstart:groupend), Y(groupstart:groupend), sign)
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
    
    curve = Beta(n,p,1) + ...
            Beta(n,p,2) * Interv1_values(i) + ...
            Beta(n,p,3) * Interv2_values + ...
            Beta(n,p,4) * Interv1_values(i) * Interv2_values + ...
            Beta(n,p,5) * Interv1_values(i) + ...
            Beta(n,p,6) * Interv2_values
    
    if strcmp(Link,'log')==1;
        curve = exp(curve);
    end
    
    plotti(Interv2_values, curve, colour);
    hold on
    
    %legendInfo{i} = [I{1,1}, ' ', I{1,4}{i}];
    
end
    
    %legend(legendInfo,'Location','best');
        

        %subplot parameters
            hx  = xlabel(I{2,1});
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
            Title=title(tit, 'Interpreter', 'none');

            set(Title, 'FontSize', titlefs);
            set(hx,'FontSize', plotfs);
            set(hy,'FontSize',plotfs);

            ha = gca;
            set(ha, 'FontSize', plotfs); 
            ha.XTickLabelRotation = 0;
                  
           
            hh=gcf;

          %  set(hh,'PaperOrientation','landscape');

          %  set(hh,'PaperPosition', [-1.5 -0.5 32 22]);
               
            plotname=[filename '__' P{1,2} P{1,4}{n} '_' P{2,2} P{2,4}{p} 'test_plot'];
            plotnamewithextension=[plotname '.tiff'];
            print(gcf, '-dtiff', plotnamewithextension);
            %print(gcf, '-dtiff', 'test_plot.tiff');
            
            close gcf
            
         
            
            
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

            
            plotname=[filename '__' P{1,2} P{1,4}{n} '_' P{2,2} P{2,4}{p} 'test_coeff'];
            plotnamewithextension=[plotname '.tiff'];
            print(gcf, '-dtiff', plotnamewithextension); 
            %print(gcf, '-dtiff', 'test_coeff.tiff');
            
            close gcf
    end 
end




     
     
     
     
