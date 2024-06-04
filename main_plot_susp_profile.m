%% Defunct
clear; clc; close all; 

data=readmatrix('frame_ratings.csv');
% range=400:670;
range=1:length(data);
k=data(range, 1);
susp=data(range, 2);
plot(k, susp, 'LineWidth', 2);
hold on;

xlabel('k, frame');
ylabel('Suspiciousness');
grid on;
