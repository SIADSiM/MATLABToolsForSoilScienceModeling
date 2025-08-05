function A = soilErosionUSLE(R, K, LS, C, P)
% soilErosionUSLE Calculates soil loss using the Universal Soil Loss Equation (USLE).
%
% Syntax:
%   A = soilErosionUSLE(R, K, LS, C, P)
%
% Description:
%   This function computes the average annual soil loss (A) using the
%   empirical Universal Soil Loss Equation (USLE). The function can operate
%   on both scalar values (for a single site calculation) and matrices (for
%   spatial calculations), as long as all matrix inputs have the same dimensions.
%
%   The equation is: A = R * K * LS * C * P
%
% Inputs:
%   R  - Rainfall-runoff erosivity factor. Can be a scalar or a matrix.
%        The units depend on the region, but a common unit is
%        (MJ * mm) / (ha * h * yr).
%   K  - Soil erodibility factor. Can be a scalar or a matrix.
%        Units are typically (t * ha * h) / (ha * MJ * mm).
%   LS - Topographic factor (slope length and steepness). Dimensionless.
%        Can be a scalar or a matrix.
%   C  - Cover-management factor. Dimensionless (ranges from 0 to 1).
%        Can be a scalar or a matrix.
%   P  - Support practice factor. Dimensionless (ranges from 0 to 1).
%        Can be a scalar or a matrix.
%
% Outputs:
%   A  - Computed average annual soil loss per unit area (e.g., t / (ha * yr)).
%        The output will be a scalar or a matrix, matching the input dimensions.
%
% Example (Scalar):
%   R = 170;  % Erosivity for a sample location
%   K = 0.3;  % Erodibility for a silt loam
%   LS = 0.5; % Topography of a gentle, short slope
%   C = 0.1;  % Cover factor for conservation tillage
%   P = 1.0;  % No support practices
%   A = soilErosionUSLE(R, K, LS, C, P)
%   % Expected output: 2.55 t/ha/yr
%
% Example (Spatial/Matrix):
%   % User should load spatial data into matrices first.
%   % For example, using: R_grid = readgeoraster('R_factor.tif');
%   R_grid = [170, 180; 175, 185];
%   K_grid = [0.3, 0.32; 0.3, 0.32];
%   LS_grid = [0.5, 0.8; 0.6, 0.9];
%   C_grid = [0.1, 0.2; 0.1, 0.2];
%   P_factor = 1.0; % Can mix scalars and matrices
%   A_grid = soilErosionUSLE(R_grid, K_grid, LS_grid, C_grid, P_factor);
%   % A_grid will be a 2x2 matrix with soil loss values.
%
% Reference:
%   Wischmeier, W.H., & Smith, D.D. (1978). Predicting rainfall erosion
%   losses. USDA Agriculture Handbook 537.
%
% See also: (No direct dependencies in this repository)

    % --- Input Validation ---
    if nargin ~= 5
        error('soilErosionUSLE:IncorrectInputCount', 'Five input arguments are required.');
    end
    % A simple check to ensure inputs are numeric. More complex size
    % checking could be added, but MATLAB's element-wise operators will
    % error appropriately in most mismatch cases.
    if ~isnumeric(R) || ~isnumeric(K) || ~isnumeric(LS) || ~isnumeric(C) || ~isnumeric(P)
        error('soilErosionUSLE:InvalidInput', 'All inputs must be numeric.');
    end

    % --- USLE Calculation ---
    % Using element-wise multiplication (.*) to handle both scalar and matrix inputs.
    A = R .* K .* LS .* C .* P;

end
