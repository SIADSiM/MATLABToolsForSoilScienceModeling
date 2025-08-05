% plotTemperatureProfile.m
% This script demonstrates the use of the soilTemperatureProfile function to
% simulate the propagation of a temperature wave into the soil.

% --- Setup ---
clear; clc; close all;
addpath(fullfile(fileparts(pwd), 'physics'));

fprintf('Simulating daily soil temperature profile evolution...\n');

% --- Simulation Parameters ---
dz = 0.1;               % Layer thickness (m), 10 cm layers
max_depth = 2;          % Maximum depth of profile (m)
z = (dz:dz:max_depth)'; % Vector of depths for the layers' centers
num_layers = length(z);

T_initial = 15 * ones(size(z)); % Initial uniform temperature of 15 C
T_surface = 25;         % A hot surface temperature event (e.g., midday sun)
T_bottom = T_initial(end); % Bottom boundary held constant at the initial temperature

K = 4e-7;               % Thermal diffusivity for a moist loam (m^2/s)
dt = 1800;              % Time step (s), 30 minutes
sim_duration_hr = 24;   % Total simulation duration (hours)
n_steps = (sim_duration_hr * 3600) / dt;

% --- Check for Stability ---
% The explicit finite difference method is only stable if this condition is met.
alpha = K * dt / dz^2;
if alpha > 0.5
    error('Simulation is unstable. Decrease dt or increase dz. alpha = %.2f', alpha);
end
fprintf('Stability criterion alpha = %.3f (must be <= 0.5)\n', alpha);

% --- Run Simulation and Plot Intermediate Profiles ---
figure('Name', 'Soil Temperature Profile Evolution', 'Position', [100, 100, 700, 500]);
hold on;

% Plot initial profile as a dashed black line
plot(T_initial, -z, 'k--', 'LineWidth', 1.5);
legend_entries = {'Initial Profile'};

T_current = T_initial;
plot_times_hr = [6, 12, 24]; % Times at which to plot the profile (in hours)

% Loop through each time step of the simulation
for i = 1:n_steps
    % Run the simulation for a single time step. Note the last argument is 1.
    T_current = soilTemperatureProfile(T_current, T_surface, T_bottom, K, dt, dz, 1);

    current_hr = (i * dt) / 3600;
    % Check if the current simulation time is one of our designated plot times
    if any(abs(current_hr - plot_times_hr) < 1e-6)
        plot(T_current, -z, 'LineWidth', 2);
        legend_entries{end+1} = sprintf('%d hours', round(current_hr));
    end
end

hold off;

% --- Formatting ---
title('Soil Temperature Profile Evolution Over 24 Hours');
xlabel('Temperature (°C)');
ylabel('Depth (m)');
legend(legend_entries, 'Location', 'southeast');
grid on;
box on;
xlim([14, 26]);

fprintf('Plot generated successfully. Figure window shows the result.\n');
