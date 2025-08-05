function T_final = soilTemperatureProfile(T_initial, T_surface, T_bottom, K, dt, dz, n_steps)
% soilTemperatureProfile Simulates soil temperature distribution over time.
%
% Syntax:
%   T_final = soilTemperatureProfile(T_initial, T_surface, T_bottom, K, dt, dz, n_steps)
%
% Description:
%   This function simulates the one-dimensional vertical soil temperature
%   profile using the Fourier heat conduction equation, solved with an
%   explicit finite difference method. It allows for multi-layer
%   discretization.
%
%   The equation is: dT/dt = K * d^2T/dz^2
%
% Inputs:
%   T_initial - A vector representing the initial temperature profile
%               at different depths (degrees C). The number of elements
%               defines the number of soil layers.
%   T_surface - The temperature at the soil surface (z=0), which will be
%               held constant as a boundary condition (degrees C).
%   T_bottom  - The temperature at the bottom of the soil profile, held
%               constant as a boundary condition (degrees C).
%   K         - Thermal diffusivity of the soil (m^2/s).
%   dt        - Time step for the simulation (s).
%   dz        - Thickness of each soil layer (m).
%   n_steps   - The number of time steps to simulate.
%
% Outputs:
%   T_final   - A vector representing the final temperature profile after
%               n_steps of simulation (degrees C).
%
% Example:
%   % Setup a 2m profile with 10 layers (dz=0.2m)
%   dz = 0.2;
%   z = (dz:dz:2)';
%   T_initial = 15 * ones(size(z)); % Initial uniform temp
%   T_surface = 25; % Hot surface
%   T_bottom = 14;  % Cool bottom
%   K = 5e-7;       % Thermal diffusivity for a typical soil
%   dt = 3600;      % 1-hour time step
%   n_steps = 24;   % Simulate for 24 hours
%   T_final = soilTemperatureProfile(T_initial, T_surface, T_bottom, K, dt, dz, n_steps);
%   plot(T_final, -z);
%   xlabel('Temperature (C)');
%   ylabel('Depth (m)');
%   title('Soil Temperature Profile after 24h');
%
% Reference:
%   Hillel, D. (1998). Environmental Soil Physics. Academic Press.
%
% See also: soilWaterRetentionVG, bulkDensityCalc

    % --- Input Validation ---
    if nargin ~= 7
        error('soilTemperatureProfile:IncorrectInputCount', 'Seven input arguments are required.');
    end
    if ~isvector(T_initial) || ~isnumeric(T_initial)
        error('soilTemperatureProfile:InvalidT_initial', 'Initial temperature profile must be a numeric vector.');
    end
    if ~isscalar(T_surface) || ~isnumeric(T_surface)
        error('soilTemperatureProfile:InvalidT_surface', 'Surface temperature must be a numeric scalar.');
    end
    if ~isscalar(T_bottom) || ~isnumeric(T_bottom)
        error('soilTemperatureProfile:InvalidT_bottom', 'Bottom temperature must be a numeric scalar.');
    end
    if ~isscalar(K) || ~isnumeric(K) || K <= 0
        error('soilTemperatureProfile:InvalidK', 'Thermal diffusivity (K) must be a positive scalar.');
    end
    if ~isscalar(dt) || ~isnumeric(dt) || dt <= 0
        error('soilTemperatureProfile:InvalidDt', 'Time step (dt) must be a positive scalar.');
    end
    if ~isscalar(dz) || ~isnumeric(dz) || dz <= 0
        error('soilTemperatureProfile:InvalidDz', 'Layer thickness (dz) must be a positive scalar.');
    end
    if ~isscalar(n_steps) || ~isnumeric(n_steps) || n_steps < 1 || mod(n_steps,1) ~= 0
        error('soilTemperatureProfile:InvalidN_steps', 'Number of steps must be a positive integer.');
    end

    % --- Stability Check ---
    alpha = K * dt / dz^2;
    if alpha > 0.5
        warning('soilTemperatureProfile:StabilityWarning', ...
            ['Stability criterion (K*dt/dz^2 <= 0.5) is not met. Result may be unstable. ', ...
             'Current value is %f.'], alpha);
    end

    % --- Initialization ---
    T = T_initial(:); % Ensure T is a column vector
    num_layers = length(T);
    T_new = T;

    % --- Simulation Loop ---
    for j = 1:n_steps
        for i = 1:num_layers
            if i == 1 % Top layer, use surface boundary condition
                T_new(i) = T(i) + alpha * (T(i+1) - 2*T(i) + T_surface);
            elseif i == num_layers % Bottom layer, use bottom boundary condition
                T_new(i) = T(i) + alpha * (T_bottom - 2*T(i) + T(i-1));
            else % Internal layers
                T_new(i) = T(i) + alpha * (T(i+1) - 2*T(i) + T(i-1));
            end
        end
        T = T_new; % Update temperature profile for the next time step
    end

    T_final = T;

end
