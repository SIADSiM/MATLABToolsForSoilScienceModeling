% plotRetentionCurve.m
% This script demonstrates the use of the soilWaterRetentionVG function to plot
% soil water retention curves for different soil types.

% --- Setup ---
% Clears variables, command window, and closes all figures to ensure a clean run.
clear; clc; close all;

% Add the path to the 'physics' directory where the function is located.
% This assumes the script is run from inside the 'examples' directory.
addpath(fullfile(fileparts(pwd), 'physics'));

fprintf('Generating soil water retention curves for different soil types...\n');

% --- Define Parameters for Different Soil Types ---
% van Genuchten parameters [thetaR, thetaS, alpha (1/m), n] are sourced from
% Carsel & Parrish (1988), a common reference for these values.
params.Sand = [0.045, 0.43, 14.5, 2.68];
params.Loam = [0.078, 0.43, 3.6, 1.56];
params.Clay = [0.090, 0.38, 0.8, 1.09];

soil_types = fieldnames(params);

% --- Generate Data and Plot ---
% Define a range of pressure heads (suction). A log-spaced vector is used
% because the relationship is highly non-linear. Goes from field capacity
% towards wilting point. pF scale from 0 to 4.2.
h = -logspace(-1, log10(1500), 200); % Suction from 0.1m to 1500m (~15 bar)

figure('Name', 'Soil Water Retention Curves', 'Position', [100, 100, 700, 500]);
hold on;

legend_entries = cell(1, length(soil_types));

for i = 1:length(soil_types)
    soil = soil_types{i};
    p = params.(soil);
    thetaR = p(1);
    thetaS = p(2);
    alpha = p(3);
    n = p(4);

    % Calculate the water content using the van Genuchten model
    theta = soilWaterRetentionVG(h, thetaR, thetaS, alpha, n);

    % Plot the curve for the current soil type
    plot(abs(h), theta, 'LineWidth', 2);
    legend_entries{i} = soil;
end

hold off;

% --- Formatting ---
set(gca, 'XScale', 'log'); % A log scale for suction is standard for these plots
title('Soil Water Retention Curves (van Genuchten Model)');
xlabel('Soil Water Suction (m) - (Log Scale)');
ylabel('Volumetric Water Content (\theta, m^3/m^3)');
legend(legend_entries, 'Location', 'northeast');
grid on;
box on;
% Set limits to typical range for better viewing
xlim([0.1, 10000]);

fprintf('Plot generated successfully. Figure window shows the result.\n');
