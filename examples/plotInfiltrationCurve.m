% plotInfiltrationCurve.m
% This script demonstrates the use of the greenAmptInfiltration function to
% plot cumulative infiltration curves for different soil types.

% --- Setup ---
clear; clc; close all;
addpath(fullfile(fileparts(pwd), 'hydrology'));

fprintf('Generating Green-Ampt infiltration curves...\n');

% --- Define Parameters for Different Soil Types ---
% Green-Ampt parameters [Ks (m/s), psi (m), delta_theta (m^3/m^3)]
% Values are representative for these soil textures.
params.sandy_loam = [2.9e-5, 0.11, 0.21]; % Sandy Loam: high conductivity
params.silty_clay = [5.0e-7, 0.29, 0.18]; % Silty Clay: low conductivity

soil_types = fieldnames(params);
legend_entries = {'Sandy Loam', 'Silty Clay'};

% --- Generate Data and Plot ---
% Time vector for 2 hours (7200 seconds), with 1-minute intervals
t = 0:60:7200;

figure('Name', 'Green-Ampt Infiltration Curves', 'Position', [100, 100, 700, 500]);
hold on;

for i = 1:length(soil_types)
    soil = soil_types{i};
    p = params.(soil);
    Ks = p(1);
    psi = p(2);
    delta_theta = p(3);

    % Calculate cumulative infiltration using the Green-Ampt model
    F = greenAmptInfiltration(Ks, psi, delta_theta, t);

    % Plot in more intuitive units: cumulative mm vs. time in minutes
    plot(t/60, F*1000, 'LineWidth', 2);
end

hold off;

% --- Formatting ---
title('Green-Ampt Cumulative Infiltration');
xlabel('Time (minutes)');
ylabel('Cumulative Infiltration (mm)');
legend(legend_entries, 'Location', 'southeast');
grid on;
box on;

fprintf('Plot generated successfully. Figure window shows the result.\n');
