function theta = soilWaterRetentionVG(h, thetaR, thetaS, alpha, n)
% soilWaterRetentionVG Calculates soil water content using the van Genuchten model.
%
% Syntax:
%   theta = soilWaterRetentionVG(h, thetaR, thetaS, alpha, n)
%
% Description:
%   This function computes the volumetric soil water content (theta) as a
%   function of pressure head (h) using the closed-form equation developed
%   by van Genuchten (1980). This model is a widely used standard for
%   describing the soil water retention curve.
%
% Inputs:
%   h       - Pressure head (suction) (m). Must be a non-positive value.
%             Can be a scalar or a vector.
%   thetaR  - Residual water content (m^3/m^3).
%   thetaS  - Saturated water content (m^3/m^3).
%   alpha   - van Genuchten parameter related to the inverse of the air-entry
%             pressure (1/m).
%   n       - van Genuchten parameter related to the pore-size distribution
%             (dimensionless). Must be > 1.
%
% Outputs:
%   theta   - Volumetric water content (m^3/m^3). Will have the same
%             dimensions as h.
%
% Example:
%   % Parameters for a typical loam soil
%   h = -10;      % Pressure head in meters
%   thetaR = 0.078;
%   thetaS = 0.43;
%   alpha = 3.6;  % 1/m
%   n = 1.56;
%   theta_h = soilWaterRetentionVG(h, thetaR, thetaS, alpha, n)
%   % Expected output: ~0.108
%
% Reference:
%   van Genuchten, M.T. (1980). A closed-form equation for predicting the
%   hydraulic conductivity of unsaturated soils. Soil Science Society of
%   America Journal, 44(5), 892-898.
%
% See also: bulkDensityCalc

    % Input validation
    if nargin ~= 5
        error('soilWaterRetentionVG:IncorrectInputCount', 'This function requires five input arguments.');
    end
    if ~isnumeric(h) || any(h > 0)
        error('soilWaterRetentionVG:InvalidPressureHead', 'Pressure head (h) must be numeric and non-positive.');
    end
    if ~isnumeric(thetaR) || ~isscalar(thetaR) || thetaR < 0 || thetaR > 1
        error('soilWaterRetentionVG:InvalidThetaR', 'Residual water content (thetaR) must be a scalar between 0 and 1.');
    end
    if ~isnumeric(thetaS) || ~isscalar(thetaS) || thetaS < 0 || thetaS > 1
        error('soilWaterRetentionVG:InvalidThetaS', 'Saturated water content (thetaS) must be a scalar between 0 and 1.');
    end
    if thetaR >= thetaS
        error('soilWaterRetentionVG:InvalidThetaValues', 'Residual water content (thetaR) must be less than saturated water content (thetaS).');
    end
    if ~isnumeric(alpha) || ~isscalar(alpha) || alpha <= 0
        error('soilWaterRetentionVG:InvalidAlpha', 'Parameter alpha must be a positive scalar.');
    end
    if ~isnumeric(n) || ~isscalar(n) || n <= 1
        error('soilWaterRetentionVG:InvalidN', 'Parameter n must be a scalar greater than 1.');
    end

    % m parameter
    m = 1 - 1/n;

    % van Genuchten equation
    % Using abs(h) as h is expected to be negative (suction)
    theta = thetaR + (thetaS - thetaR) ./ (1 + (alpha * abs(h)).^n).^m;

end
