# Workflow_openMalaria
plot boxplots and dynamics for openMalaria output to compare different interventions and different scenarios
Matlab scripts 

This 'workflow' is designed to quickly get an overview of the effect of different interventions on different scenarios 
in openMalaria. 
You need to set parameters in text files and then run a matlab script.
The idea is to first print an overview consisting of subplots for different scenarios containing boxplots for the different 
interventions. 
Therefore set your parameters in matlab_OM_boxplot_parameters.txt and run callZAD.m.
Then you can pick individual scenarios with individual interventions and produce plots showing the dynamics over time.
Therefore set your parameters in matlab_OM_plot_followup_parameters.txt and run P_followup_timeplot.m.

These workflows are quite general.

There are other scripts, especially for regression analysis. But these scripts are rather hard coded, not at all general and 
not well documented.
