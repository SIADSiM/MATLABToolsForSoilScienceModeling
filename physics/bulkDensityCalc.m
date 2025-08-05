function bulkDensity = bulkDensityCalc(particleDensity, porosity)
% bulkDensityCalc Calculates bulk density from particle density and porosity.
%
% Syntax:
%   bulkDensity = bulkDensityCalc(particleDensity, porosity)
%
% Description:
%   This function calculates the soil bulk density based on the particle
%   density and porosity, following the relationship described in Hillel (1998).
%
% Inputs:
%   particleDensity - Particle density of the soil solids (kg/m^3).
%                     A common value for mineral soils is 2650 kg/m^3.
%   porosity        - The fraction of the total soil volume occupied by pores (m^3/m^3).
%                     Value should be between 0 and 1.
%
% Outputs:
%   bulkDensity     - The dry bulk density of the soil (kg/m^3).
%
% Example:
%   pd = 2650; % Particle density in kg/m^3
%   p = 0.45;  % Porosity as a fraction
%   bd = bulkDensityCalc(pd, p)
%   % Expected output: 1457.5
%
% Reference:
%   Hillel, D. (1998). Environmental Soil Physics. Academic Press.
%
% See also: soilWaterRetentionVG

    % Input validation
    if nargin ~= 2
        error('bulkDensityCalc:IncorrectInputCount', 'This function requires exactly two input arguments: particleDensity and porosity.');
    end
    if ~isnumeric(particleDensity) || ~isscalar(particleDensity) || particleDensity <= 0
        error('bulkDensityCalc:InvalidParticleDensity', 'Particle density must be a positive scalar number.');
    end
    if ~isnumeric(porosity) || ~isscalar(porosity) || porosity < 0 || porosity > 1
        error('bulkDensityCalc:InvalidPorosity', 'Porosity must be a scalar number between 0 and 1.');
    end

    % Calculation
    bulkDensity = particleDensity * (1 - porosity);

end
