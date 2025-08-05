function N_mineralized = nitrogenMineralization(C_initial, k_max, temp_scalar, moisture_scalar, dt, CN_ratio)
% nitrogenMineralization Simulates net N mineralization based on C decomposition.
%
% Syntax:
%   N_mineralized = nitrogenMineralization(C_initial, k_max, temp_scalar, moisture_scalar, dt, CN_ratio)
%
% Description:
%   This function calculates the net nitrogen (N) mineralized during the
%   decomposition of soil organic matter. It does this by first calculating
%   the amount of carbon decomposed (using the same logic as the
%   soilCarbonDecomposition function) and then dividing by the carbon-to-
%   nitrogen (C:N) ratio of the organic matter. This approach tightly
%   couples the C and N cycles, following the principles of models like
%   CENTURY.
%
% Inputs:
%   C_initial       - Initial amount of soil organic carbon (e.g., in kg C/m^2).
%   k_max           - Maximum potential decomposition rate constant (e.g., per day).
%   temp_scalar     - Temperature limitation scalar (0-1).
%   moisture_scalar - Moisture limitation scalar (0-1).
%   dt              - Time step (in the same time units as k_max, e.g., days).
%   CN_ratio        - The Carbon:Nitrogen ratio of the decomposing soil
%                     organic matter (dimensionless, e.g., 12 for 12:1).
%
% Outputs:
%   N_mineralized   - The amount of nitrogen mineralized during the time step
%                     (in the same mass units as C_initial, e.g., kg N/m^2).
%
% Example:
%   C_initial = 10;     % kg C/m^2
%   k_max = 0.0005;     % per day
%   temp_scalar = 0.8;
%   moisture_scalar = 0.6;
%   dt = 30;            % days
%   CN_ratio = 12;      % C:N ratio of 12:1
%   N_min = nitrogenMineralization(C_initial, k_max, temp_scalar, moisture_scalar, dt, CN_ratio);
%   fprintf('Nitrogen mineralized: %.6f kg N/m^2\n', N_min);
%
% Reference:
%   Parton, W.J., Schimel, D.S., Cole, C.V., & Ojima, D.S. (1987).
%   Analysis of factors controlling soil organic matter levels in Great
%   Plains grasslands. Soil Science Society of America Journal, 51(5),
%   1173–1179.
%
% See also: soilCarbonDecomposition, soilRespirationQ10

    % --- Input Validation ---
    if nargin ~= 6
        error('nitrogenMineralization:IncorrectInputCount', 'Six input arguments are required.');
    end
    if ~isnumeric(C_initial) || ~isscalar(C_initial) || C_initial < 0
        error('nitrogenMineralization:InvalidInput', 'C_initial must be a non-negative numeric scalar.');
    end
    if ~isnumeric(k_max) || ~isscalar(k_max) || k_max < 0
        error('nitrogenMineralization:InvalidInput', 'k_max must be a non-negative numeric scalar.');
    end
    if ~isscalar(temp_scalar) || temp_scalar < 0 || temp_scalar > 1
        error('nitrogenMineralization:InvalidScalar', 'Temperature scalar must be between 0 and 1.');
    end
    if ~isscalar(moisture_scalar) || moisture_scalar < 0 || moisture_scalar > 1
        error('nitrogenMineralization:InvalidScalar', 'Moisture scalar must be between 0 and 1.');
    end
    if ~isscalar(dt) || ~isnumeric(dt) || dt < 0
        error('nitrogenMineralization:InvalidInput', 'dt must be a non-negative numeric scalar.');
    end
    if ~isscalar(CN_ratio) || CN_ratio <= 0
        error('nitrogenMineralization:InvalidInput', 'CN_ratio must be a positive scalar.');
    end

    % --- Calculation ---

    % 1. Calculate the amount of carbon decomposed.
    k_eff = k_max * temp_scalar * moisture_scalar;
    C_decomposed = C_initial * (1 - exp(-k_eff * dt));

    % 2. Calculate mineralized nitrogen based on C:N ratio.
    N_mineralized = C_decomposed / CN_ratio;

end
