classdef testHydrologyFunctions < matlab.unittest.TestCase
% testHydrologyFunctions contains unit tests for the functions in the /hydrology directory.

    properties (Constant)
        projectRoot = fileparts(fileparts(mfilename('fullpath')));
    end

    methods (TestClassSetup)
        function addFunctionPaths(testCase)
            addpath(fullfile(testCase.projectRoot, 'hydrology'));
        end
    end

    methods (Test)
        % --- Tests for penmanMonteithET ---
        function testPenmanMonteithExample(testCase)
            % Test with the example values from the function's help block
            T_mean = 20;
            u2 = 2;
            R_n = 15;
            G = 0;
            RH_mean = 60;
            elevation = 100;
            expectedETo = 4.084; % A more precise value for verification
            actualETo = penmanMonteithET(T_mean, u2, R_n, G, RH_mean, elevation);
            testCase.verifyEqual(actualETo, expectedETo, 'AbsTol', 1e-3, ...
                'Calculation for the example case failed.');
        end

        function testPenmanMonteithNoWind(testCase)
            % Test with zero wind speed, which should reduce the aerodynamic term
            T_mean = 20;
            u2 = 0;
            R_n = 15;
            G = 0;
            RH_mean = 60;
            elevation = 100;
            % ETo should be lower than the case with wind
            actualETo = penmanMonteithET(T_mean, u2, R_n, G, RH_mean, elevation);
            testCase.verifyLessThan(actualETo, 4.0, ...
                'ETo with no wind should be less than ETo with wind.');
        end

        % --- Tests for greenAmptInfiltration ---
        function testGreenAmptAsymptoticBehavior(testCase)
            % For large t, the infiltration rate f should approach Ks.
            % This implies F(t) is approximately Ks*t + C, where C is a constant.
            Ks = 1e-5; % m/s
            psi = 0.1; % m
            delta_theta = 0.2;
            t = 86400; % 1 day (a long time for this process)

            F = greenAmptInfiltration(Ks, psi, delta_theta, t);

            % The infiltration rate f = Ks * (1 + (psi * delta_theta) / F)
            f_rate = Ks * (1 + (psi * delta_theta) / F);
            testCase.verifyEqual(f_rate, Ks, 'RelTol', 0.05, ...
                'Infiltration rate should be very close to Ks at long times.');
        end

        function testGreenAmptZeroTime(testCase)
            % Cumulative infiltration at t=0 must be 0.
            Ks = 1e-5;
            psi = 0.1;
            delta_theta = 0.2;
            t = 0;
            F = greenAmptInfiltration(Ks, psi, delta_theta, t);
            testCase.verifyEqual(F, 0, 'AbsTol', 1e-9, ...
                'Cumulative infiltration at t=0 should be zero.');
        end

        % --- Tests for soilMoistureBalance ---
        function testMoistureBalanceNoRain(testCase)
            % Test a simple dry-down scenario with no precipitation
            days = 10;
            precip = zeros(days, 1);
            ETo = 3 * ones(days, 1); % 3 mm/day
            FC = 0.30;
            WP = 0.15;
            rootZoneDepth = 500; % mm
            storageFC = FC * rootZoneDepth; % 150 mm
            storageWP = WP * rootZoneDepth; % 75 mm

            initialMoisture = storageFC; % Start at field capacity

            [SM, Q] = soilMoistureBalance(precip, ETo, FC, WP, rootZoneDepth, initialMoisture);

            % No rain means percolation should be zero throughout
            testCase.verifyEqual(Q, zeros(days,1), 'AbsTol', 1e-9, 'Percolation should be zero with no rain.');
            % Moisture should decrease by 3mm each day until it hits WP
            expected_day5_SM = initialMoisture - 5 * 3;
            testCase.verifyEqual(SM(5), expected_day5_SM, 'AbsTol', 1e-9, 'Moisture calculation incorrect at day 5.');
            % Final moisture should not be below the wilting point
            testCase.verifyGreaterThanOrEqual(SM(end), storageWP, 'AbsTol', 1e-9, ...
                'Soil moisture should not fall below wilting point.');
        end

        function testMoistureBalanceBigRain(testCase)
            % Test a large rainfall event that should cause percolation
            days = 1;
            precip = [100]; % 100 mm of rain
            ETo = [2];
            FC = 0.30;
            WP = 0.15;
            rootZoneDepth = 500; % mm
            storageFC = FC * rootZoneDepth; % 150 mm

            initialMoisture = 100; % Start with 100mm of water

            [SM, Q] = soilMoistureBalance(precip, ETo, FC, WP, rootZoneDepth, initialMoisture);

            % Water in = initial(100) + precip(100) = 200 mm.
            % Max storage (FC) is 150 mm. Percolation should be the excess.
            expectedPercolation = 200 - storageFC;
            testCase.verifyEqual(Q(1), expectedPercolation, 'AbsTol', 1e-9, 'Percolation calculation failed.');

            % After percolation, moisture is at FC (150). Then ET (2) is removed.
            expectedSM = storageFC - ETo(1);
            testCase.verifyEqual(SM(1), expectedSM, 'AbsTol', 1e-9, 'Final soil moisture calculation failed.');
        end
    end
end
