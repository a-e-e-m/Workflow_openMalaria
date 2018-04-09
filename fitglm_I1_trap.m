Beta_lm=zeros(P1_dim,P2_dim,6);

clf
close

allmodelcoefficients = cell(P1_dim, P2_dim);

for n=1:1:P1_dim; %number of values for first scenario parameter
    for p=1:1:P2_dim; %number of values for second scenario parameter

        R_data=zeros(I1_dim,I2_dim,nseeds); %allocation to store data multidimensional
        Y=[]; % allocation to store data in vector
        for k=1:1:I1_dim; % over values of first intervention parameter
            for l=1:1:I2_dim; % over values of second intervention parameter
            R_data(k,l,:)=R{n,p,k,l,4}; % data
            Y =[Y; R{n,p,k,l,4}];
            end
        end

        no = I1_dim * I2_dim *nseeds; % number of data points

%       I1=trap
        trap=zeros(no,1);
        trap(1:200,1)=0;
        trap(201:400,1)=0.2;
        trap(401:600,1)=0.4;
        
        repellent=zeros(no,1);
        repellent(1:50,1)=0;
        repellent(51:100,1)=0.3;
        repellent(101:150,1)=0.5;
        repellent(151:200,1)=0.7;
        
        repellent(201:400,1)=repellent(1:200,1);
        repellent(401:600,1)=repellent(1:200,1);
        
        %log transform
        %Y = log(Y);
        
     tbl = table(trap,repellent,Y,'VariableNames',{'trap','repellent','Y'});  
     
     lm = fitglm(tbl,'Y ~ trap  + repellent + trap:repellent', 'Distribution', 'normal');
     
     allmodelcoefficients{n,p} = lm.Coefficients;
    
     Beta_lm(n,p,1:numel(lm.Coefficients.Estimate)) = lm.Coefficients.Estimate;
     
    %plotnr=(n-1)*P2_dim+p; %gives the number of the plot corresponding to n,p
    %subplot(P1_dim,P2_dim,plotnr);
    
    close gcf
  
    
%      p1=semilogy(repellent(1:200,1), exp(Y(1:200)),'og');
%      hold on
%      p2=semilogy(repellent(201:400,1), exp(Y(201:400)),'or');
%      hold on
%      p3=semilogy(repellent(401:600,1), exp(Y(401:600)),'om');
%     
%      hold on  
%          
%      repellent = [0 0.3 0.5 0.7];
%      p4 = semilogy(repellent, exp(Beta_lm(n,p,1) + 0   * Beta_lm(n,p,2) + Beta_lm(n,p,3)*repellent + Beta_lm(n,p,4) * 0   * repellent),'g');
%      hold on
%      p5 = semilogy(repellent, exp(Beta_lm(n,p,1) + 0.2 * Beta_lm(n,p,2) + Beta_lm(n,p,3)*repellent + Beta_lm(n,p,4) * 0.2 * repellent),'r');
%      hold on
%      p6 = semilogy(repellent, exp(Beta_lm(n,p,1) + 0.4 * Beta_lm(n,p,2) + Beta_lm(n,p,3)*repellent + Beta_lm(n,p,4) * 0.4 * repellent),'m');
    
     %Y=exp(Y);
    
     plot(repellent(1:200,1), Y(1:200),'og');
     hold on
     plot(repellent(201:400,1), Y(201:400),'or');
     hold on
     plot(repellent(401:600,1), Y(401:600),'om');

     
%      plot(trap(1:150,1), Y(1:150),'og');
%      hold on
%      plot(trap(151:300,1), Y(151:300),'or');
%      hold on
%      plot(trap(301:450,1), Y(301:450),'om');
%      hold on
%      plot(trap(451:600,1), Y(451:600),'ob');
    
     hold on  
         
%repellent = [0 0.3 0.5 0.7];
%       plot(repellent, Beta_lm(n,p,1) + trap(1)   * Beta_lm(n,p,2) + Beta_lm(n,p,3)*repellent + ...
%          Beta_lm(n,p,4) * trap(1)   * repellent + trap(1)^2 *Beta_lm(n,p,5) + ...
%          repellent.^2 * Beta_lm(n,p,6),'g');
%      hold on
%      plot(repellent, Beta_lm(n,p,1) + trap(201) * Beta_lm(n,p,2) + Beta_lm(n,p,3)*repellent + ...
%          Beta_lm(n,p,4) * trap(201) * repellent + trap(201)^2 *Beta_lm(n,p,5) + ...
%          repellent.^2 * Beta_lm(n,p,6),'r');
%      hold on
%      plot(repellent, Beta_lm(n,p,1) + trap(401) * Beta_lm(n,p,2) + Beta_lm(n,p,3)*repellent + ...
%          Beta_lm(n,p,4) * trap(401) * repellent + trap(401)^2 *Beta_lm(n,p,5) + ...
%          repellent.^2 * Beta_lm(n,p,6),'m');
%      hold on
%      plot(repellent, Beta_lm(n,p,1) + trap(401) * Beta_lm(n,p,2) + Beta_lm(n,p,3)*repellent + ...
%          Beta_lm(n,p,4) * trap(401) * repellent + trap(401)^2 *Beta_lm(n,p,5) + ...
%          repellent.^2 * Beta_lm(n,p,6),'m'); 


     repellenti=[0 0.3 0.5 0.7];
     p1=plot(repellenti, Beta_lm(n,p,1) + trap(1)   * Beta_lm(n,p,2) + Beta_lm(n,p,3)*repellenti + ...
         Beta_lm(n,p,4) * trap(1)   * repellenti + trap(1)^2 *Beta_lm(n,p,5) + ...
         repellenti.^2 * Beta_lm(n,p,6),'g');
     hold on
     p2=plot(repellenti, Beta_lm(n,p,1) + trap(201) * Beta_lm(n,p,2) + Beta_lm(n,p,3)*repellenti + ...
         Beta_lm(n,p,4) * trap(201) * repellenti + trap(201)^2 *Beta_lm(n,p,5) + ...
         repellenti.^2 * Beta_lm(n,p,6),'r');
     hold on
     p3=plot(repellenti, Beta_lm(n,p,1) + trap(401) * Beta_lm(n,p,2) + Beta_lm(n,p,3)*repellenti + ...
         Beta_lm(n,p,4) * trap(401) * repellenti + trap(401)^2 *Beta_lm(n,p,5) + ...
         repellenti.^2 * Beta_lm(n,p,6),'m');

     
     
%      p1=plot(trapi, Beta_lm(n,p,1) + repellent(1)   * Beta_lm(n,p,2) + Beta_lm(n,p,3)*trapi + ...
%          Beta_lm(n,p,4) * repellent(1)   * trapi + repellent(1)^2 *Beta_lm(n,p,5) + ...
%          trapi.^2 * Beta_lm(n,p,6),'g');
%      hold on
%      p2=plot(trapi, Beta_lm(n,p,1) + repellent(151) * Beta_lm(n,p,2) + Beta_lm(n,p,3)*trapi + ...
%          Beta_lm(n,p,4) * repellent(151) * trapi + repellent(151)^2 *Beta_lm(n,p,5) + ...
%          trapi.^2 * Beta_lm(n,p,6),'r');
%      hold on
%      p3=plot(trapi, Beta_lm(n,p,1) + repellent(301) * Beta_lm(n,p,2) + Beta_lm(n,p,3)*trapi + ...
%          Beta_lm(n,p,4) * repellent(301) * trapi + repellent(301)^2 *Beta_lm(n,p,5) + ...
%          trapi.^2 * Beta_lm(n,p,6),'m');
%      hold on
%      p4=plot(trapi, Beta_lm(n,p,1) + repellent(451) * Beta_lm(n,p,2) + Beta_lm(n,p,3)*trapi + ...
%          Beta_lm(n,p,4) * repellent(451) * trapi + repellent(451)^2 *Beta_lm(n,p,5) + ...
%          trapi.^2 * Beta_lm(n,p,6),'b');  
     
         legend1=[I{1,1}, ' ', I{1,4}{1}];
         legend2=[I{1,1}, ' ', I{1,4}{2}];
         legend3=[I{1,1}, ' ', I{1,4}{3}];
         legend([p1,p2,p3], legend1, legend2, legend3,'Location','northeast');
        

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
               
            plotname=[filename '__' P{1,2} P{1,4}{n} '_' P{2,2} P{2,4}{p} 'glm_1stdegree_plot'];
            plotnamewithextension=[plotname '.tiff'];
            print(gcf, '-dtiff', plotnamewithextension); 
            
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

            
            plotname=[filename '__' P{1,2} P{1,4}{n} '_' P{2,2} P{2,4}{p} 'glm_1stdegree_coeff'];
            plotnamewithextension=[plotname '.tiff'];
            print(gcf, '-dtiff', plotnamewithextension); 
    end 
end




     
     
     
     

