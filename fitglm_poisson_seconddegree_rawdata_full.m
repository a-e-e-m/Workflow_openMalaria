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
       % Y = log(Y);
        
     tbl = table(trap,repellent,Y,'VariableNames',{'trap','repellent','Y'});  
     
     lm = fitglm(tbl,'Y ~ trap + repellent + trap:repellent + trap^2 + repellent^2', 'Distribution', 'poisson');
     
     allmodelcoefficients{n,p} = lm.Coefficients;
    
     Beta_lm(n,p,1:numel(lm.Coefficients.Estimate)) = lm.Coefficients.Estimate;
     
    plotnr=(n-1)*P2_dim+p; %gives the number of the plot corresponding to n,p
    

    subplot(P1_dim,P2_dim,plotnr);
    %plot(lm);
    
     p1=semilogy(repellent(1:200,1), Y(1:200),'og');
     hold on
     p2=semilogy(repellent(201:400,1), Y(201:400),'or');
     hold on
     p3=semilogy(repellent(401:600,1), Y(401:600),'om');
    
     hold on  
         
     repellent = [0 0.3 0.5 0.7];
     p4 = semilogy(repellent, exp(Beta_lm(n,p,1) + trap(1)   * Beta_lm(n,p,2) + Beta_lm(n,p,3)*repellent + Beta_lm(n,p,4) * trap(1)   * repellent + trap(1)^2 *Beta_lm(n,p,5) + repellent.^2 * Beta_lm(n,p,6)),'g');
     hold on
     p5 = semilogy(repellent, exp(Beta_lm(n,p,1) + trap(201) * Beta_lm(n,p,2) + Beta_lm(n,p,3)*repellent + Beta_lm(n,p,4) * trap(201) * repellent + trap(201)^2 *Beta_lm(n,p,5) + repellent.^2 * Beta_lm(n,p,6)),'r');
     hold on
     p6 = semilogy(repellent, exp(Beta_lm(n,p,1) + trap(401) * Beta_lm(n,p,2) + Beta_lm(n,p,3)*repellent + Beta_lm(n,p,4) * trap(401) * repellent + trap(401)^2 *Beta_lm(n,p,5) + repellent.^2 * Beta_lm(n,p,6)),'m');
      
    
%      p1=plot(repellent(1:200,1), Y(1:200),'og');
%      hold on
%      p2=plot(repellent(201:400,1), Y(201:400),'or');
%      hold on
%      p3=plot(repellent(401:600,1), Y(401:600),'om');
%     
%      hold on  
%          
%      repellent = [0 0.3 0.5 0.7];
%      p4 = plot(repellent, Beta_lm(n,p,1) + 0   * Beta_lm(n,p,2) + Beta_lm(n,p,3)*repellent + Beta_lm(n,p,4) * 0   * repellent,'g');
%      hold on
%      p5 = plot(repellent, Beta_lm(n,p,1) + 0.2 * Beta_lm(n,p,2) + Beta_lm(n,p,3)*repellent + Beta_lm(n,p,4) * 0.2 * repellent,'r');
%      hold on
%      p6 = plot(repellent, Beta_lm(n,p,1) + 0.4 * Beta_lm(n,p,2) + Beta_lm(n,p,3)*repellent + Beta_lm(n,p,4) * 0.4 * repellent,'m');
     
         
     
         legend1=[I{1,1}, ' ', I{1,4}{1}];
         legend2=[I{1,1}, ' ', I{1,4}{2}];
         legend3=[I{1,1}, ' ', I{1,4}{3}];
         legend([p4,p5,p6], legend1, legend2, legend3, 'Location','northeast');
        

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

            
    end 
end

hh=gcf;

set(hh,'PaperOrientation','landscape');

set(hh,'PaperPosition', [-1.5 -0.5 32 22]);

print(figure(1), '-dpdf', 'C:\Users\denzad\Documents\3640_LSTM Push Pull_Saddler_serversync\3.b Modelling\Preliminary OpenMalaria\Preliminary_Analysis\plots\Rusinga_15\Rusinga15_simEIR_logtransform_logscale_preintervEIR100and200_2019_2020_allages_glmpoisson_seconddegree.pdf');
     
     
     
     

