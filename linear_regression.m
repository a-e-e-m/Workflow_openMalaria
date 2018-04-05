Beta=zeros(P1_dim,P2_dim,3);

clf
close

for n=1:1:P1_dim; %number of values for first scenario parameter
    for p=1:1:P2_dim; %number of values for second scenario parameter

        R_data=zeros(I1_dim,I2_dim,nseeds);
        for k=1:1:I1_dim; % over values of first intervention parameter
            for l=1:1:I2_dim; % over values of second intervention parameter
            R_data(k,l,:)=R{n,p,k,l,4}; % data
            end
        end

        R_median=mean(R_data,3);
        %R_median=log(R_median./(1-R_median));

        Rr=[0 0.3 0.5 0.7];

        % linear regression
        k=1;
        X=ones(I2_dim,2);
        X(:,2)=Rr;
        Y=R_median(k,:)';
        beta=X\Y;
        beta_0=beta(1);
        beta_2=beta(2);

        k=2;
        X=ones(I2_dim,2);
        X(:,2)=Rr;
        Y=R_median(k,:)';
        beta=X\Y;
        beta_3=beta(2)-beta_2;
        beta_1=beta(1);

        Beta(n,p,1)=beta_1;
        Beta(n,p,2)=beta_2;
        Beta(n,p,3)=beta_3;
        
        plotnr=(n-1)*P2_dim+p; %gives the number of the plot corresponding to n,p
        subplot(P1_dim,P2_dim,plotnr)
%         p1=plot(Rr, exp(R_median(1,:))./(1+exp(R_median(1,:))),'*g');
%         hold on
%         p2=plot(Rr, exp(R_median(2,:))./(1+exp(R_median(2,:))),'+r');

        p1=plot(Rr, R_median(1,:),'*g');
        hold on
        p2=plot(Rr, R_median(2,:),'+r');        
        
        
         hold on  
         %Y1=exp(beta_0 + beta_2 * Rr)./(1+exp(beta_0 + beta_2 * Rr));
         %Y2=exp(beta_1 + (beta_2 + beta_3)*Rr)./(1+exp(beta_1 + (beta_2 + beta_3)*Rr));
         
         Y1=beta_0 + beta_2 * Rr;
         Y2=beta_1 + (beta_2 + beta_3)*Rr;
         p3=plot(Rr,Y1,'g');
         hold on
         p4=plot(Rr,Y2,'r');
         
         %set(gca, 'YScale', 'log');
        
         legend1=[I{1,1}, ' ', I{1,4}{1}];
         legend2=[I{1,1}, ' ', I{1,4}{2}];
         legend([p3,p4], legend1, legend2, 'Location','northeast');
        

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

print(gcf, '-dpdf', 'C:\Users\denzad\Desktop\test3_mean.pdf');

