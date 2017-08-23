n=1;
p=3;

R_data=zeros(I1_dim,I2_dim,nseeds);
for k=1:1:2;
    for l=1:1:I2_dim;
    R_data(k,l,:)=R{n,p,k,l,4};
    end
end

R_median=median(R_data,3);

Rr=[0 0.3 0.5 0.7];

% linear regression
k=1;
X=ones(I2_dim,2);
X(:,2)=Rr;
Y=R_median(k,:)';
Beta=X\Y;
beta_2=Beta(2);

k=2;
X=ones(I2_dim,2);
X(:,2)=Rr;
Y=R_median(k,:)';
Beta=X\Y;
beta_3=Beta(2)-beta_2;
beta_1=Beta(1);



plot(Rr, R_median(1,:),'o', Rr, R_median(2,:),'+');
hold on  
Y1=beta_2 * Rr;
Y2=beta_1 + (beta_2 + beta_3)*Rr;
plot(Rr,Y1,'g', Rr,Y2,'r');