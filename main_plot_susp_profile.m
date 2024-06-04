%% Defunct
clear; clc; close all; 

data=readmatrix('frame_ratings.csv');
k=data(:, 1);
susp=data(:, 2);
plot(k, susp, 'LineWidth', 2);

xlabel('k, frame');
ylabel('Suspiciousness');
grid on;
