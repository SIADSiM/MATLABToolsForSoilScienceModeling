classdef testBiogeochemistryFunctions < matlab.unittest.TestCase
% testBiogeochemistryFunctions contains unit tests for the biogeochemistry functions.

    properties (Constant)
        projectRoot = fileparts(fileparts(mfilename('fullpath')));
    end

    methods (TestClassSetup)
        function addFunctionPaths(testCase)
            addpath(fullfile(testCase.projectRoot, 'biogeochemistry'));
        end
    end

    methods (Test)
        % --- Tests for soilRespirationQ10 ---
        function testQ10Doubling(testCase)
            % With Q10=2 and a 10-degree increase, the rate should exactly double.
            R_ref = 1.5;
            T_ref = 10;
            Q10 = 2.0;
            T = 20;
            expectedR = 3.0;
            actualR = soilRespirationQ10(R_ref, Q10, T, T_ref);
            testCase.verifyEqual(actualR, expectedR, 'AbsTol', 1e-6, ...
                'Rate did not double for a 10-degree rise with Q10=2.');
        end

        function testQ10NoChange(testCase)
            % If the current temperature is the reference temperature, rate should be unchanged.
            R_ref = 1.5;
            T_ref = 10;
            Q10 = 2.0;
            T = 10;
            actualR = soilRespirationQ10(R_ref, Q10, T, T_ref);
            testCase.verifyEqual(actualR, R_ref, 'AbsTol', 1e-6, ...
                'Rate changed when T == T_ref.');
        end

        % --- Tests for soilCarbonDecomposition ---
        function testCarbonDecompositionNoLoss(testCase)
            % If either environmental scalar is zero, decomposition should be zero.
            C_initial = 10;
            k_max = 0.0005;
            dt = 30;

            [C_loss_temp, C_end_temp] = soilCarbonDecomposition(C_initial, k_max, 0, 0.6, dt);
            testCase.verifyEqual(C_loss_temp, 0, 'AbsTol', 1e-9, 'Decomposition should be zero if temp scalar is zero.');
            testCase.verifyEqual(C_end_temp, C_initial, 'AbsTol', 1e-9);

            [C_loss_moist, C_end_moist] = soilCarbonDecomposition(C_initial, k_max, 0.8, 0, dt);
            testCase.verifyEqual(C_loss_moist, 0, 'AbsTol', 1e-9, 'Decomposition should be zero if moisture scalar is zero.');
            testCase.verifyEqual(C_end_moist, C_initial, 'AbsTol', 1e-9);
        end

        function testCarbonDecompositionCalculation(testCase)
            % Test with known values from the function's example.
            C_initial = 10;
            k_max = 0.0005;
            temp_scalar = 0.8;
            moisture_scalar = 0.6;
            dt = 30;

            k_eff = k_max * temp_scalar * moisture_scalar; % 0.00024
            expected_C_final = C_initial * exp(-k_eff * dt); % 10 * exp(-0.00024 * 30) = 9.92825...
            expected_C_loss = C_initial - expected_C_final; % 0.07175...

            [C_loss, C_end] = soilCarbonDecomposition(C_initial, k_max, temp_scalar, moisture_scalar, dt);

            testCase.verifyEqual(C_end, expected_C_final, 'AbsTol', 1e-5, 'Final C calculation is incorrect.');
            testCase.verifyEqual(C_loss, expected_C_loss, 'AbsTol', 1e-5, 'Decomposed C calculation is incorrect.');
        end

        % --- Tests for nitrogenMineralization ---
        function testNitrogenMineralizationCoupling(testCase)
            % Test that N mineralization is correctly coupled to C decomposition.
            % The logic is duplicated, so this test ensures they stay in sync.
            C_initial = 10;
            k_max = 0.0005;
            temp_scalar = 0.8;
            moisture_scalar = 0.6;
            dt = 30;
            CN_ratio = 12;

            k_eff = k_max * temp_scalar * moisture_scalar;
            C_decomposed = C_initial * (1 - exp(-k_eff * dt));

            expected_N_min = C_decomposed / CN_ratio;
            actual_N_min = nitrogenMineralization(C_initial, k_max, temp_scalar, moisture_scalar, dt, CN_ratio);

            testCase.verifyEqual(actual_N_min, expected_N_min, 'AbsTol', 1e-9, ...
                'N mineralization calculation is not consistent with C decomposition logic.');
        end

        function testNitrogenMineralizationInvalidCN(testCase)
            % Test that the function errors for a zero or negative C:N ratio.
            C_initial = 10;
            k_max = 0.0005;
            temp_scalar = 0.8;
            moisture_scalar = 0.6;
            dt = 30;

            testCase.verifyError(@() nitrogenMineralization(C_initial, k_max, temp_scalar, moisture_scalar, dt, 0), ...
                'nitrogenMineralization:InvalidInput', 'Did not error for C:N = 0.');
            testCase.verifyError(@() nitrogenMineralization(C_initial, k_max, temp_scalar, moisture_scalar, dt, -10), ...
                'nitrogenMineralization:InvalidInput', 'Did not error for negative C:N.');
        end
    end
end
