Beta=zeros(P1_dim,P2_dim,3);

clf
close

for n=1:1:P1_dim; %number of values for first scenario parameter
    for p=1:1:P2_dim; %number of values for first scenario parameter

        R_data=zeros(I1_dim,I2_dim,nseeds); %allocation to store data multidimensional
        Y=[]; % allocation to store data in vector
        for k=1:1:I1_dim; % over values of first intervention parameter
            for l=1:1:I2_dim; % over values of first intervention parameter
            R_data(k,l,:)=R{n,p,k,l,4}; % data
            Y =[Y; R{n,p,k,l,4}];
            end
        end

        no = I1_dim * I2_dim *nseeds; % number of data points
        
        X=ones(no,4);
        
        X(1:no/2,2)=0;
        X(no/2+1:end,2)=0.2;
        
        X(1:50,3)=0;
        X(51:100,3)=0.3;
        X(101:150,3)=0.5;
        X(151:200,3)=0.7;
        X(201:250,3)=0;
        X(251:300,3)=0.3;
        X(301:350,3)=0.5;
        X(351:400,3)=0.7;
        
        X(:,4)=X(:,2).*X(:,3);
        
        
        B = X\Y;

        Beta(n,p,1)=B(1);     %intercept    
        Beta(n,p,2)=B(2);     %trap    
        Beta(n,p,3)=B(3);     %repellent
        Beta(n,p,4)=B(4);     %synergy i.e. trap*repellent
        
        
        plotnr=(n-1)*P2_dim+p; %gives the number of the plot corresponding to n,p
        subplot(P1_dim,P2_dim,plotnr)

        p1=plot(X(1:200,3), Y(1:200),'og');
        hold on
        p2=plot(X(201:400,3), Y(201:400),'or');        
        
        
        hold on  
         
        repellent = [0 0.3 0.5 0.7];
        p3 = plot(repellent, B(1) + B(3)*repellent,'g');
        
        hold on
        p4 = plot(repellent, B(1) + 0.2 * B(2) + B(3)*repellent + B(4) * 0.2 * repellent,'r');
         
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

print(gcf, '-dpdf', 'C:\Users\denzad\Desktop\test2.pdf');

