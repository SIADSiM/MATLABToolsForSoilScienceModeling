classdef testPhysicsFunctions < matlab.unittest.TestCase
% testPhysicsFunctions contains unit tests for the functions in the /physics directory.

    properties (Constant)
        % Define project root relative to this file's location
        projectRoot = fileparts(fileparts(mfilename('fullpath')));
    end

    methods (TestClassSetup)
        % This runs once before all tests in this class
        function addFunctionPaths(testCase)
            % Add the 'physics' directory to the MATLAB path so the tests can find the functions
            addpath(fullfile(testCase.projectRoot, 'physics'));
        end
    end

    methods (Test)
        % --- Tests for bulkDensityCalc ---
        function testBulkDensityNormal(testCase)
            % Test with typical values
            pd = 2650; % kg/m^3
            p = 0.45;  % m^3/m^3
            expectedBD = 1457.5;
            actualBD = bulkDensityCalc(pd, p);
            testCase.verifyEqual(actualBD, expectedBD, 'AbsTol', 1e-6, ...
                'Calculation for typical values failed.');
        end

        function testBulkDensityPorosityZero(testCase)
            % Test with zero porosity (should equal particle density)
            pd = 2650;
            p = 0;
            expectedBD = 2650;
            actualBD = bulkDensityCalc(pd, p);
            testCase.verifyEqual(actualBD, expectedBD, 'AbsTol', 1e-6, ...
                'Zero porosity case failed.');
        end

        function testBulkDensityInvalidPorosity(testCase)
            % Test that the function errors for porosity > 1
            pd = 2650;
            p = 1.1;
            testCase.verifyError(@() bulkDensityCalc(pd, p), 'bulkDensityCalc:InvalidPorosity', ...
                'Did not error for porosity > 1.');
        end

        % --- Tests for soilWaterRetentionVG ---
        function testVGBasic(testCase)
            % Test with typical loam parameters from the function's example
            h = -10;
            thetaR = 0.078;
            thetaS = 0.43;
            alpha = 3.6;
            n = 1.56;
            expectedTheta = 0.10806; % A more precise value for verification
            actualTheta = soilWaterRetentionVG(h, thetaR, thetaS, alpha, n);
            testCase.verifyEqual(actualTheta, expectedTheta, 'AbsTol', 1e-5, ...
                'Calculation for typical VG parameters failed.');
        end

        function testVGSaturated(testCase)
            % Test at zero pressure head (should return saturated water content)
            h = 0;
            thetaR = 0.078;
            thetaS = 0.43;
            alpha = 3.6;
            n = 1.56;
            actualTheta = soilWaterRetentionVG(h, thetaR, thetaS, alpha, n);
            testCase.verifyEqual(actualTheta, thetaS, 'AbsTol', 1e-6, ...
                'Saturated (h=0) case failed.');
        end

        function testVGInvalidN(testCase)
            % Test that the function errors for n <= 1, which is a model constraint
            h = -10;
            thetaR = 0.078;
            thetaS = 0.43;
            alpha = 3.6;
            n = 1.0;
            testCase.verifyError(@() soilWaterRetentionVG(h, thetaR, thetaS, alpha, n), 'soilWaterRetentionVG:InvalidN', ...
                'Did not error for n <= 1.');
        end

        % --- Tests for soilTemperatureProfile ---
        function testTempProfileSteadyState(testCase)
            % If T_initial is a linear gradient between the boundaries, it is in
            % steady state and should not change over time.
            num_layers = 10;
            T_surface = 25;
            T_bottom = 15;
            % Create a linear gradient for the internal nodes
            T_initial = linspace(T_surface, T_bottom, num_layers + 2)';
            T_initial = T_initial(2:end-1); % Get the internal nodes

            K = 5e-7;
            dt = 3600;
            dz = 0.2;
            n_steps = 100;

            T_final = soilTemperatureProfile(T_initial, T_surface, T_bottom, K, dt, dz, n_steps);
            testCase.verifyEqual(T_final, T_initial, 'AbsTol', 1e-9, ...
                'Profile should be unchanged in steady-state conditions.');
        end

        function testTempProfileCooling(testCase)
            % A uniformly warm profile should cool down when exposed to cool boundaries
            dz = 0.2;
            z = (dz:dz:2)';
            T_initial = 20 * ones(size(z)); % Initial uniform temp
            T_surface = 10;
            T_bottom = 10;
            K = 5e-7;
            dt = 3600;
            n_steps = 24;

            % Check stability criterion to ensure the simulation is valid
            alpha = K * dt / dz^2;
            testCase.verifyLessThanOrEqual(alpha, 0.5, 'Stability criterion must be met for this test to be valid.');

            T_final = soilTemperatureProfile(T_initial, T_surface, T_bottom, K, dt, dz, n_steps);
            % Every layer should be cooler than the initial temperature
            testCase.verifyTrue(all(T_final < T_initial), ...
                'Entire profile should cool down.');
        end
    end
end
