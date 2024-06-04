clear; clc; close all; 

data=readmatrix('frame_ratings.csv');
% range=400:670;
range=1:length(data);
k=data(range, 1);
susp=data(range, 2);
susp_filtered = replaceZeroWithNeighbor(susp, 1);
plot(k, susp, 'LineWidth', 2);
hold on;
plot(k, susp_filtered, 'LineWidth', 2);
legend('original', 'filtered');

xlabel('k, frame');
ylabel('Suspiciousness');
grid on;

data(:, 2)=susp_filtered;
writematrix(data, 'vids/cropped1m.csv');