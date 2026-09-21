clear all; close all; clc;


%Load variable with sensor parameters and number of targets
%The columns are as follows: f_number, pixel pitch (m),focal length (m),aperture diameter (m),half-angle FOV (degrees), 
% overall SNR count (total number of instances where SNR>threshold),target SNR count (total number of targets where SNR>threshold) 
rE = 6.378e+3;
load("num_seq_200_all_xsec_RSO_0.mat");
disp(num_of_seq);
%%disp(length_of_seq);
f1 = figure();
num = num_of_seq(4, 99, :);
RSO = repmat([1:1:length(num)], 3,1);
bar(RSO(1,:)', num(:)');
% sum(num(:))/100
xlabel("RSO")
ylabel(" Number of Detected Close Approaches")
% ylim([-1 17]);
%legend(["FAI","PCO","IDS", "Sagitta", "Auricam"],'Location','northeast')
title("(200 km) Number of Approaches for Each RSO- SAGITTA")
% %subtitle("Comparison of FAI, PCO, IDS")
%             %ylim([min(num)-1 max(num)+1])
%             saveas(f1,"200 host decay SAGITTA new.png"); %Save the jpg figure
% 
% f1.close()

 load("OrbitOutputs0.mat");

%%load('Min_magnitudes_400.mat')
%f2 = figure();
%i = 5;
%Integration_time=[0.1:0.1:10]';
%min_mVs(i,:)
%min_mV = min_mVs(i,:);
%plot(Integration_time, min_mV)
%xlabel("Integration time")
%ylabel(" Minimum magnitude")
%ylim([-1 17]);
 %legend(["FAI","PCO","IDS", "Sagitta", "Auricam"],'Location','northeast')
%title("(400 km) Number of Approaches for Each RSO- SAGITTA")





%  f2 = figure();
%  times = repmat([0:timeStep:max(t)], length(TargetSMAs(1,:)), 1);
% TargetSMAs(:,1)
%  TargetSMAs = TargetSMAs-rE;
%  RW_SMAs= RW_SMA_200 - rE;
%  length(TargetSMAs(1,:));
%  plot(times(:,:)'/timeStep,TargetSMAs(:,:));
%  for i = 1: 5
%     hold on
%     s = (i-1)*100;
%     s
%     e = i*100;
%     e
%  plot(times(1,:)'/timeStep,RW_SMAs(:))
%  hold on
%  RW_SMAs= RW_SMA_300 - rE;
%  plot(times(1,:)'/timeStep,RW_SMAs(:))
%  hold on
%  RW_SMAs= RW_SMA_400 - rE;
%  plot(times(1,:)'/timeStep,RW_SMAs(:))
%  hold on
%  RW_SMAs= RW_SMA_500 - rE;
%  plot(times(1,:)'/timeStep,RW_SMAs(:))
%  hold on
%  RW_SMAs= RW_SMA_600 - rE;
%  plot(times(1,:)'/timeStep,RW_SMAs(:))
%  end
%  ylim([0, 620])
%  xlabel("Minutes")
%  ylabel("Altitude (km)")
% legend(["FAI","PCO","IDS"],'Location','northeast')
%  title("Progression of Orbits of Re-entering Objects")
% xlim([0, 45000]);

% saveas(f2,"Radii of Objects - 14 days.jpg");

%load("SNR_2.mat");
%SNR(6)
%avg = sum(SNR(:))/length(SNR(:))


% load("Params.mat")
% num = num_of_seq(2, 99, :);
% var = zeros(1, 50);
% for v=1:length(num(:))
%     %params_cos(v).a
%     %var(v) = params_cos(v).a-rE;
%     var(v) = params_cos(v).mm;
% end
% p = polyfit(var, num(:), 1);
% px = [min(var) max(var)];
% py = polyval(p, px);
% 
% f3 = figure();
% scatter(var, num(:), 10, 'filled');
% hold on
% plot(px, py, 'LineWidth', 1);
% ylabel("Number of Approaches")
% xlabel("Starting Mean Motion")
% caption = sprintf('y = %f x + %f', p(1), p(2));
% text(0.0665, 8, caption, 'FontSize', 10, 'Color', 'r', 'FontWeight', 'bold');
% title("Number of Approaches vs Mean Motion at Start (400 km)")



% load("num_seq.mat");
% RSOs=repmat([1:1:100],1,1);
% %length(length_of_seq(:,1)')
% f2=figure();
% % %plot(Integration_time(1:10), targetSNRCount(:,1:10),'--o')
% % %length_of_seq(:,:,4)
% max(max(max(max(length_of_seq(:,99,:,:)))))
% sum(sum(sum(sum(length_of_seq(:,99,:,:)))))/(length(length_of_seq(1,1,1,:))* length(length_of_seq(1,1,:,1))* length(length_of_seq(:,1,1,1)))

% 
% = length_of_seq(1,1,:,:);
% sequence = repmat([1:1:length(one_k1)],1,1);
% heatmap(RSOs(:)', sequence(:)', one_k1(:,:));
% % %plot(Integration_time(:,1:60)' ,count_matching_approaches(:,1:60)')%,'--o'
% xlabel("RSO")
% ylabel("Approach Number")
% 
% % %legend(["FAI","PCO","IDS"],'Location','northeast')
% title("Length of Approaches for each RSO")
% % %subtitle("Comparison of FAI, PCO, IDS")
%              %ylim([min(min(length_of_seq))-1 max(max(length_of_seq))+10])
%              saveas(f2,"length_of_seqs.jpg"); %Save the jpg figure