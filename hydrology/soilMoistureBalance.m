function [soilMoisture, percolation] = soilMoistureBalance(precip, ETo, FC, WP, rootZoneDepth, initialMoisture)
% soilMoistureBalance Implements a daily soil water balance.
%
% Syntax:
%   [soilMoisture, percolation] = soilMoistureBalance(precip, ETo, FC, WP, rootZoneDepth, initialMoisture)
%
% Description:
%   This function performs a daily soil water balance for the root zone
%   based on the methodology described in FAO-56. It tracks daily changes
%   in soil moisture storage based on precipitation, evapotranspiration,
%   and percolation losses. All units are in millimeters (mm).
%
% Inputs:
%   precip          - A vector of daily precipitation (mm).
%   ETo             - A vector of daily reference evapotranspiration (mm).
%                     Must be the same length as precip.
%   FC              - Field Capacity of the soil (m^3/m^3 or mm/mm).
%   WP              - Wilting Point of the soil (m^3/m^3 or mm/mm).
%   rootZoneDepth   - The depth of the root zone (mm).
%   initialMoisture - The initial soil moisture content in the root zone (mm).
%
% Outputs:
%   soilMoisture    - A vector of daily soil moisture storage in the root zone (mm).
%   percolation     - A vector of daily percolation losses (mm).
%
% Example:
%   % 30 days of data
%   days = 30;
%   precip = zeros(days, 1); precip([5, 15, 25]) = [20, 10, 30]; % Rain on days 5, 15, 25
%   ETo = 3.5 * ones(days, 1); % Constant ETo
%   FC = 0.34;      % Field capacity for a loam
%   WP = 0.18;      % Wilting point for a loam
%   rootZoneDepth = 600; % 600 mm root depth
%   initialMoisture = (FC - WP) * rootZoneDepth * 0.5 + WP * rootZoneDepth; % Start at 50% available water
%   [SM, Q] = soilMoistureBalance(precip, ETo, FC, WP, rootZoneDepth, initialMoisture);
%   figure;
%   subplot(2,1,1); plot(1:days, SM); ylabel('Soil Moisture (mm)'); title('Daily Soil Water Balance');
%   subplot(2,1,2); bar(1:days, Q); ylabel('Percolation (mm)'); xlabel('Day');
%
% Reference:
%   Allen, R.G., Pereira, L.S., Raes, D., & Smith, M. (1998). Crop
%   Evapotranspiration — Guidelines for computing crop water requirements.
%   FAO Irrigation and Drainage Paper 56.
%
% See also: penmanMonteithET, greenAmptInfiltration

    % --- Input Validation ---
    if length(precip) ~= length(ETo)
        error('soilMoistureBalance:InputSizeMismatch', 'Precipitation and ETo vectors must be the same length.');
    end
    if ~isnumeric(precip) || ~isvector(precip)
        error('soilMoistureBalance:InvalidInput', 'precip must be a numeric vector.');
    end
    if ~isnumeric(ETo) || ~isvector(ETo)
        error('soilMoistureBalance:InvalidInput', 'ETo must be a numeric vector.');
    end
    if ~isscalar(FC) || ~isnumeric(FC) || FC <= 0 || FC >= 1
        error('soilMoistureBalance:InvalidInput', 'FC must be a numeric scalar between 0 and 1.');
    end
    if ~isscalar(WP) || ~isnumeric(WP) || WP <= 0 || WP >= 1
        error('soilMoistureBalance:InvalidInput', 'WP must be a numeric scalar between 0 and 1.');
    end
    if WP >= FC
        error('soilMoistureBalance:InvalidInput', 'Wilting Point (WP) must be less than Field Capacity (FC).');
    end
    if ~isscalar(rootZoneDepth) || ~isnumeric(rootZoneDepth) || rootZoneDepth <= 0
        error('soilMoistureBalance:InvalidInput', 'rootZoneDepth must be a positive scalar.');
    end
    if ~isscalar(initialMoisture) || ~isnumeric(initialMoisture) || initialMoisture < 0
        error('soilMoistureBalance:InvalidInput', 'initialMoisture must be a non-negative scalar.');
    end

    % --- Soil Water Capacity Calculations ---
    % Water content at Field Capacity (mm)
    storageFC = FC * rootZoneDepth;
    % Water content at Wilting Point (mm)
    storageWP = WP * rootZoneDepth;

    % --- Initialization ---
    num_days = length(precip);
    soilMoisture = zeros(num_days, 1);
    percolation = zeros(num_days, 1);

    currentMoisture = initialMoisture;
    if currentMoisture > storageFC
        warning('soilMoistureBalance:InitialMoistureHigh', 'Initial moisture is above Field Capacity.');
    elseif currentMoisture < storageWP
        warning('soilMoistureBalance:InitialMoistureLow', 'Initial moisture is below Wilting Point.');
    end


    % --- Daily Loop ---
    for t = 1:num_days
        % 1. Add precipitation
        currentMoisture = currentMoisture + precip(t);

        % 2. Calculate percolation (if moisture exceeds field capacity)
        if currentMoisture > storageFC
            percolation(t) = currentMoisture - storageFC;
            currentMoisture = storageFC;
        else
            percolation(t) = 0;
        end

        % 3. Subtract evapotranspiration
        % Simplified approach: ET is at the reference rate until wilting point
        actualET = ETo(t);

        % Don't let soil moisture drop below wilting point due to ET
        if currentMoisture - actualET < storageWP
            actualET = currentMoisture - storageWP;
        end

        currentMoisture = currentMoisture - actualET;

        % Ensure moisture doesn't fall below WP (e.g., due to rounding)
        if currentMoisture < storageWP
            currentMoisture = storageWP;
        end

        soilMoisture(t) = currentMoisture;
    end
end
