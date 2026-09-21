clear all; close all; clc;


%Load variable with sensor parameters and number of targets
%The columns are as follows: f_number, pixel pitch (m),focal length (m),aperture diameter (m),half-angle FOV (degrees), 
% overall SNR count (total number of instances where SNR>threshold),target SNR count (total number of targets where SNR>threshold) 

load("IntegrationTimeSNRInfo.mat");
Integration_time=repmat([0.1:0.1:10],3,1);
f1=figure();
%plot(Integration_time(1:10), targetSNRCount(:,1:10),'--o')
plot(Integration_time(:,1:60)' ,count_matching_approaches(:,1:60)')%,'--o'
xlabel("Integration Time (Second)")
ylabel("Number of Detected Close Approaches")
legend(["FAI","PCO","IDS"],'Location','northeast')
title("Impact of integration time on number of detected Close RSO approaches")
%subtitle("Comparison of FAI, PCO, IDS")
            ylim([min(min(count_matching_approaches))-1 max(max(count_matching_approaches))+10])
            saveas(f1,"sensorIntegrationTimeComparison_approaches.jpg"); %Save the jpg figure

f2=figure();
%plot(Integration_time(1:10), targetSNRCount(:,1:10),'--o')
plot(Integration_time(:,1:60)' ,count_matching_targets(:,1:60)','--o')
xlabel("Integration Time (Second)")
ylabel("Number of Close Approaches")
legend(["FAI","PCO","IDS"],'Location','northeast')
title("Impact of integration time on number of observed RSOs")
subtitle("Comparison of FAI, PCO, IDS")
 ylim([min(min(count_matching_targets))-1 max(max(count_matching_targets))+1])
            saveas(f2,"sensorIntegrationTimeComparison_targets.jpg"); %Save the jpg figure

% %% Creating separate figures for each parameter
% %Note: the code does not seem very intuitive so I will explain how it
% %works. It first starts by going through the list in params (I want to plot
% %F_number, pixel pitch, and focal length). In the first iteration, the goal is 
% % to generate a plot for focal length vs target count for each unique
% % combination of F_number and pixel pitch, and so on. The code starts by
% % finding the unique values for F_number and pixel pitch and then finds the
% % instances where they are both equal and plots the focal length vs target
% % count. 
% params = {'Fnumber','Pixel Pitch','Focal Length','Fnumber','Pixel Pitch'}; %Names of the parameters to loop through (variable names are repeated to allow for plotting each variables while freezing the others)
% adjustedParameters=[OverallParameters(:,1:3),OverallParameters(:,1:2)]; %Values of the sensor parameters to plot
% for i = 1:length(unique(params)) %For each of the 3 parameters to plot
%     unique_params_1 = unique(adjustedParameters(:,i)); % Finding unique parameter values 
%     for j = 1:numel(unique_params_1) %Loop through each unique parameter
%         index = adjustedParameters(:,i) == unique_params_1(j); % Filtering data based on unique parameter values
%         unique_params_2 = unique(adjustedParameters(index,i+1)); %Finding the unique values of the next parameter
%         for k = 1:numel(unique_params_2) %Loop through the unique parameters of the next parameter
%             f1=figure("Visible","off");
%             index2 = adjustedParameters(:,i+1) == unique_params_2(k); % Filtering data based on unique parameter values
%             index3= index&index2; %Find the values where the two parameters are unique
%             plot(adjustedParameters(index3,i+2), OverallParameters(index3, end),'o--'); %Plot the values
%             xlabel(params{i+2});
%             ylabel('Number of Objects');
%             titleVal=sprintf('%s vs Number of Objects', params{i+2});
%             subtitle(sprintf("with %s = %s and %s = %s", params{i},string(unique_params_1(j)),params{i+1},num2str(unique_params_2(k))));
%             title(titleVal); 
%             grid on;
%             fileName=strrep(sprintf("%s_const%s_%s_const%s_%s",params{i+2},params{i},string(unique_params_1(j)),params{i+1},num2str(unique_params_2(k))), '.', '');
%             saveas(f1,sprintf("C:\\Users\\randaq\\MATLAB Drive\\REDWING Sensitivity CGP\\Results\\Figures\\individualParameter_1day30sec\\%s.jpg",fileName)); %Save the jpg figure
%         end
%     end
% end
% 
% %% Manual Plot
% 
% params = {'Fnumber','Pixel Pitch','Focal Length','Fnumber','Pixel Pitch'}; %Names of the parameters to loop through (variable names are repeated to allow for plotting each variables while freezing the others)
% anomaly = find (OverallParameters(:,2)==2e-5);
% OverallParameters(anomaly,:)=[];
% adjustedParameters=[OverallParameters(:,1:3),OverallParameters(:,1:2)]; %Values of the sensor parameters to plot
% for i = 1:length(unique(params)) %For each of the 3 parameters to plot
%     unique_params_1 = unique(adjustedParameters(:,i)); % Finding unique parameter values 
%     for j = 1:numel(unique_params_1) %Loop through each unique parameter
%         index = adjustedParameters(:,i) == unique_params_1(j); % Filtering data based on unique parameter values
%         unique_params_2 = unique(adjustedParameters(index,i+1)); %Finding the unique values of the next parameter
%         for k = 1:numel(unique_params_2) %Loop through the unique parameters of the next parameter
%             f1=figure("Visible","off");
%             index2 = adjustedParameters(:,i+1) == unique_params_2(k); % Filtering data based on unique parameter values
%             index3= index&index2; %Find the values where the two parameters are unique
%             yyaxis left
%             plot(adjustedParameters(index3,i+2), OverallParameters(index3, end),'o--'); %Plot the values
%             xlabel(params{i+2});
%             ylabel('Number of Objects');
%             yyaxis right
%             plot(adjustedParameters(index3,i+2), OverallParameters(index3, 5)*2,'o--'); %Plot the values
%             ylabel("FOV (degrees)")
%             titleVal=sprintf('%s vs Number of Objects', params{i+2});
%             subtitle(sprintf("with %s = %s and %s = %s", params{i},string(unique_params_1(j)),params{i+1},num2str(unique_params_2(k))));
%             title(titleVal); 
%             grid on;
%             fileName=strrep(sprintf("%s_const%s_%s_const%s_%s",params{i+2},params{i},string(unique_params_1(j)),params{i+1},num2str(unique_params_2(k))), '.', '');
%             saveas(f1,sprintf("C:\\Users\\randa\\MATLAB Drive\\REDWING Sensitivity CGP\\Results\\Figures\\individualParameter_1day30sec\\Extra Plots\\FOV_%s_v2.jpg",fileName)); %Save the jpg figure
%         end
%     end
% end