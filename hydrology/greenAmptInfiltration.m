function F = greenAmptInfiltration(Ks, psi, delta_theta, t_vector)
% greenAmptInfiltration Solves for cumulative infiltration using the Green-Ampt model.
%
% Syntax:
%   F = greenAmptInfiltration(Ks, psi, delta_theta, t_vector)
%
% Description:
%   This function calculates the cumulative infiltration (F) over time using
%   the Green-Ampt infiltration model. The implicit equation for F is solved
%   at each time step using the Newton-Raphson iterative method.
%
%   The implicit equation is: K_s*t = F - (psi*d_theta) * log(1 + F/(psi*d_theta))
%
% Inputs:
%   Ks          - Saturated hydraulic conductivity (m/s).
%   psi         - Wetting front soil suction head (m). This should be a
%                 positive value representing suction.
%   delta_theta - Change in volumetric water content from initial to saturated
%                 (theta_s - theta_i) (m^3/m^3).
%   t_vector    - A vector of time points (s) at which to calculate
%                 cumulative infiltration.
%
% Outputs:
%   F           - A vector of cumulative infiltration (m) corresponding to
%                 each time point in t_vector.
%
% Example:
%   Ks = 1.8e-5;    % Saturated hydraulic conductivity in m/s (silty clay loam)
%   psi = 0.16;     % Wetting front suction head in m
%   delta_theta = 0.2; % Change in moisture content (0.45 - 0.25)
%   t = 0:300:3600; % Time vector for 1 hour, every 5 mins
%   F = greenAmptInfiltration(Ks, psi, delta_theta, t);
%   plot(t/60, F*1000);
%   xlabel('Time (minutes)');
%   ylabel('Cumulative Infiltration (mm)');
%   title('Green-Ampt Infiltration');
%
% Reference:
%   Green, W.H., & Ampt, G.A. (1911). Studies on soil physics.
%   The Journal of Agricultural Science, 4(1), 1–24.
%
% See also: soilMoistureBalance, penmanMonteithET

    % --- Input Validation ---
    if nargin ~= 4
        error('greenAmptInfiltration:IncorrectInputCount', 'Four input arguments are required.');
    end
    if ~isnumeric(Ks) || ~isscalar(Ks) || Ks <= 0
        error('greenAmptInfiltration:InvalidInput', 'Ks must be a positive numeric scalar.');
    end
    if ~isnumeric(psi) || ~isscalar(psi) || psi <= 0
        error('greenAmptInfiltration:InvalidInput', 'psi must be a positive numeric scalar.');
    end
    if ~isnumeric(delta_theta) || ~isscalar(delta_theta) || delta_theta <= 0 || delta_theta >= 1
        error('greenAmptInfiltration:InvalidInput', 'delta_theta must be a numeric scalar between 0 and 1.');
    end
    if ~isnumeric(t_vector) || ~isvector(t_vector) || any(t_vector < 0)
        error('greenAmptInfiltration:InvalidInput', 't_vector must be a numeric vector with non-negative values.');
    end


    % --- Newton-Raphson Parameters ---
    max_iter = 100;
    tolerance = 1e-6;

    % --- Initialization ---
    F = zeros(size(t_vector));
    C = psi * delta_theta; % A constant group of parameters

    % --- Loop through each time point ---
    for i = 1:length(t_vector)
        t = t_vector(i);
        if t == 0
            F(i) = 0;
            continue;
        end

        % Initial guess for F using Philip's two-term approximation for better start
        F_n = Ks * t + sqrt(2*C*Ks*t);

        % Newton-Raphson Iteration
        for iter = 1:max_iter
            g_F = F_n - C * log(1 + F_n / C) - Ks * t;

            % Check for convergence
            if abs(g_F) < tolerance
                break;
            end

            g_prime_F = F_n / (F_n + C);

            % Avoid division by zero if F_n is 0
            if abs(g_prime_F) < 1e-9
                break; % Derivative is too small, solution is not changing
            end

            F_n = F_n - g_F / g_prime_F;

            % Ensure F_n doesn't become negative
            if F_n < 0
               F_n = tolerance;
            end
        end
        F(i) = F_n;
    end
end
