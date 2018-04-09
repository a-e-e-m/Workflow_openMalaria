clear all
x=[0:0.01:1];
%y =  2 ./ (1 + exp(-7*x))-1;
y=0.5*x.^(0.25);
plot(x,y)


LastName = {'Smith';'Johnson';'Williams';'Jones';'Brown'};
Age = [38;43;38;40;49];
Height = [71;69;64;67;64];
Weight = [176;163;131;133;119];
T = table(Age,Height,Weight,'RowNames',LastName);

uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,...
    'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);


x = linspace(0,pi);
y1 = cos(x);
plot(x,y1)
legend('cos(x)')

hold on 
y2 = cos(2*x);
plot(x,y2)
legend('cos(2x)')