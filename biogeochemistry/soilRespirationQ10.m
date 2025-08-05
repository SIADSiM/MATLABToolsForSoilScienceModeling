function R = soilRespirationQ10(R_ref, Q10, T, T_ref)
% soilRespirationQ10 Computes soil respiration rates with the Q10 formulation.
%
% Syntax:
%   R = soilRespirationQ10(R_ref, Q10, T, T_ref)
%
% Description:
%   This function calculates the soil respiration rate (R) at a given
%   temperature (T) based on a reference respiration rate (R_ref) at a
%   reference temperature (T_ref), using the Q10 temperature coefficient.
%   The Q10 model is a widely used empirical model to describe the
%   temperature sensitivity of biological rates.
%
% Inputs:
%   R_ref - The reference respiration rate, measured at T_ref. Units can be
%           anything (e.g., umol CO2/m^2/s), as the output will be in the
%           same units.
%   Q10   - The Q10 temperature coefficient (dimensionless). A value of 2.0
%           is common.
%   T     - The current temperature (°C). Can be a scalar or a vector.
%   T_ref - The reference temperature at which R_ref was measured (°C).
%
% Outputs:
%   R     - The calculated respiration rate at temperature T, in the same
%           units as R_ref.
%
% Example:
%   R_ref = 1.5;  % umol CO2/m^2/s at 10°C
%   T_ref = 10;   % °C
%   Q10 = 2.0;
%   T = 20;       % Calculate rate at 20°C
%   R = soilRespirationQ10(R_ref, Q10, T, T_ref)
%   % Expected output: 3.0
%
%   T_vector = 0:5:30; % Calculate for a range of temperatures
%   R_vector = soilRespirationQ10(R_ref, Q10, T_vector, T_ref);
%   plot(T_vector, R_vector);
%   xlabel('Temperature (°C)');
%   ylabel('Respiration Rate (umol CO2/m^2/s)');
%   title('Q10 Temperature Dependence of Soil Respiration');
%
% Reference:
%   Based on the general principles of Q10 temperature coefficients as
%   discussed in ecological modeling literature, e.g., Lloyd, J., & Taylor,
%   J.A. (1994). On the temperature dependence of soil respiration.
%   Functional Ecology, 8(3), 315–323.
%
% See also: nitrogenMineralization, soilCarbonDecomposition

    % --- Input Validation ---
    if nargin ~= 4
        error('soilRespirationQ10:IncorrectInputCount', 'Four input arguments are required.');
    end
    if ~isnumeric(R_ref) || ~isscalar(R_ref) || R_ref < 0
        error('soilRespirationQ10:InvalidInput', 'R_ref must be a non-negative numeric scalar.');
    end
    if ~isnumeric(Q10) || ~isscalar(Q10) || Q10 <= 0
        error('soilRespirationQ10:InvalidInput', 'Q10 must be a positive numeric scalar.');
    end
    if ~isnumeric(T)
        error('soilRespirationQ10:InvalidInput', 'T must be numeric.');
    end
    if ~isnumeric(T_ref) || ~isscalar(T_ref)
        error('soilRespirationQ10:InvalidInput', 'T_ref must be a numeric scalar.');
    end

    % --- Q10 Calculation ---
    R = R_ref .* Q10.^((T - T_ref) / 10);

end
