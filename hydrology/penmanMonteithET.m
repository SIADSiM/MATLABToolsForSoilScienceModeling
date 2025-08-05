function ETo = penmanMonteithET(T_mean, u2, R_n, G, RH_mean, elevation)
% penmanMonteithET Calculates reference evapotranspiration (ETo) using the FAO-56 Penman-Monteith equation.
%
% Syntax:
%   ETo = penmanMonteithET(T_mean, u2, R_n, G, RH_mean, elevation)
%
% Description:
%   This function computes the daily reference evapotranspiration (ETo) for a
%   hypothetical grass reference surface using the FAO-56 Penman-Monteith
%   method. This is the standard method recommended by the Food and
%   Agriculture Organization (FAO) for computing crop water requirements.
%
% Inputs:
%   T_mean    - Mean daily air temperature at 2m height (°C).
%   u2        - Mean daily wind speed at 2m height (m/s).
%   R_n       - Net radiation at the surface (MJ/m^2/day).
%   G         - Soil heat flux density (MJ/m^2/day). For daily calculations,
%               G is often assumed to be zero.
%   RH_mean   - Mean daily relative humidity (%).
%   elevation - Elevation above sea level (m).
%
% Outputs:
%   ETo       - Reference evapotranspiration (mm/day).
%
% Example:
%   % Example data for a location
%   T_mean = 20;    % °C
%   u2 = 2;         % m/s
%   R_n = 15;       % MJ/m^2/day
%   G = 0;          % MJ/m^2/day
%   RH_mean = 60;   % %
%   elevation = 100;% m
%   ETo = penmanMonteithET(T_mean, u2, R_n, G, RH_mean, elevation)
%   % Expected output: ~4.08 mm/day
%
% Reference:
%   Allen, R.G., Pereira, L.S., Raes, D., & Smith, M. (1998). Crop
%   Evapotranspiration — Guidelines for computing crop water requirements.
%   FAO Irrigation and Drainage Paper 56.
%
% See also: soilMoistureBalance, greenAmptInfiltration

    % --- Input Validation ---
    if nargin ~= 6
        error('penmanMonteithET:IncorrectInputCount', 'Six input arguments are required.');
    end
    if ~isnumeric(T_mean) || ~isscalar(T_mean)
        error('penmanMonteithET:InvalidInput', 'T_mean must be a numeric scalar.');
    end
    if ~isnumeric(u2) || ~isscalar(u2) || u2 < 0
        error('penmanMonteithET:InvalidInput', 'u2 must be a non-negative numeric scalar.');
    end
    if ~isnumeric(R_n) || ~isscalar(R_n)
        error('penmanMonteithET:InvalidInput', 'R_n must be a numeric scalar.');
    end
    if ~isnumeric(G) || ~isscalar(G)
        error('penmanMonteithET:InvalidInput', 'G must be a numeric scalar.');
    end
    if ~isnumeric(RH_mean) || ~isscalar(RH_mean) || RH_mean < 0 || RH_mean > 100
        error('penmanMonteithET:InvalidInput', 'RH_mean must be a numeric scalar between 0 and 100.');
    end
    if ~isnumeric(elevation) || ~isscalar(elevation)
        error('penmanMonteithET:InvalidInput', 'elevation must be a numeric scalar.');
    end


    % --- Constants ---
    LAMBDA = 2.45; % Latent heat of vaporization, MJ/kg

    % --- Calculations based on FAO-56 ---

    % 1. Atmospheric pressure (P) and psychrometric constant (gamma)
    P = 101.3 * ((293 - 0.0065 * elevation) / 293)^5.26; % Atmospheric pressure (kPa), Eq. 7
    gamma = 0.665e-3 * P; % Psychrometric constant (kPa/°C), Eq. 8

    % 2. Saturation vapor pressure (es) and slope of the curve (delta)
    es_T = 0.6108 * exp((17.27 * T_mean) / (T_mean + 273.3)); % Saturation vapor pressure at T_mean (kPa), Eq. 11
    delta = (4098 * es_T) / (T_mean + 273.3)^2; % Slope of vapor pressure curve (kPa/°C), Eq. 13

    % 3. Actual vapor pressure (ea)
    ea = (RH_mean / 100) * es_T; % Actual vapor pressure (kPa), Eq. 17

    % 4. Penman-Monteith Equation (ETo)
    numerator = 0.408 * delta * (R_n - G) + gamma * (900 / (T_mean + 273)) * u2 * (es_T - ea);
    denominator = delta + gamma * (1 + 0.34 * u2);
    ETo = numerator / denominator; % Eq. 6

end
