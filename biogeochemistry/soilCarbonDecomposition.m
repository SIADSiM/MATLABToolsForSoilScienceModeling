function [C_decomposed, C_final] = soilCarbonDecomposition(C_initial, k_max, temp_scalar, moisture_scalar, dt)
% soilCarbonDecomposition Simulates first-order soil carbon decomposition.
%
% Syntax:
%   [C_decomposed, C_final] = soilCarbonDecomposition(C_initial, k_max, temp_scalar, moisture_scalar, dt)
%
% Description:
%   This function calculates the amount of soil organic carbon (SOC)
%   decomposed over a given time step using a first-order kinetic model.
%   The decomposition rate is modified by temperature and moisture scalars,
%   following the approach used in models like CENTURY.
%
%   The decomposition rate k is calculated as: k = k_max * temp_scalar * moisture_scalar
%   The decomposed C is then: C_initial * (1 - exp(-k * dt))
%
% Inputs:
%   C_initial       - Initial amount of soil organic carbon (e.g., in kg C/m^2).
%   k_max           - Maximum potential decomposition rate constant (e.g., per day).
%   temp_scalar     - Temperature limitation scalar (0-1).
%   moisture_scalar - Moisture limitation scalar (0-1).
%   dt              - Time step (in the same time units as k_max, e.g., days).
%
% Outputs:
%   C_decomposed    - The amount of carbon decomposed during the time step.
%   C_final         - The final amount of carbon remaining after decomposition.
%
% Example:
%   C_initial = 10;     % kg C/m^2
%   k_max = 0.0005;     % per day (for a slow pool)
%   temp_scalar = 0.8;  % Favorable temperature
%   moisture_scalar = 0.6; % Sub-optimal moisture
%   dt = 30;            % 30-day time step
%   [C_loss, C_end] = soilCarbonDecomposition(C_initial, k_max, temp_scalar, moisture_scalar, dt);
%   fprintf('Carbon lost: %.4f kg C/m^2\n', C_loss);
%   fprintf('Carbon remaining: %.4f kg C/m^2\n', C_end);
%
% Reference:
%   Parton, W.J., Schimel, D.S., Cole, C.V., & Ojima, D.S. (1987).
%   Analysis of factors controlling soil organic matter levels in Great
%   Plains grasslands. Soil Science Society of America Journal, 51(5),
%   1173–1179.
%
% See also: nitrogenMineralization, soilRespirationQ10

    % --- Input Validation ---
    if nargin ~= 5
        error('soilCarbonDecomposition:IncorrectInputCount', 'Five input arguments are required.');
    end
    if ~isnumeric(C_initial) || ~isscalar(C_initial) || C_initial < 0
        error('soilCarbonDecomposition:InvalidInput', 'C_initial must be a non-negative numeric scalar.');
    end
    if ~isnumeric(k_max) || ~isscalar(k_max) || k_max < 0
        error('soilCarbonDecomposition:InvalidInput', 'k_max must be a non-negative numeric scalar.');
    end
    if ~isscalar(temp_scalar) || temp_scalar < 0 || temp_scalar > 1
        error('soilCarbonDecomposition:InvalidScalar', 'Temperature scalar must be between 0 and 1.');
    end
    if ~isscalar(moisture_scalar) || moisture_scalar < 0 || moisture_scalar > 1
        error('soilCarbonDecomposition:InvalidScalar', 'Moisture scalar must be between 0 and 1.');
    end
    if ~isscalar(dt) || ~isnumeric(dt) || dt < 0
        error('soilCarbonDecomposition:InvalidInput', 'dt must be a non-negative numeric scalar.');
    end

    % --- Calculation ---
    % Effective decomposition rate
    k_eff = k_max * temp_scalar * moisture_scalar;

    % Calculate final carbon stock
    C_final = C_initial * exp(-k_eff * dt);

    % Calculate decomposed carbon
    C_decomposed = C_initial - C_final;

end
