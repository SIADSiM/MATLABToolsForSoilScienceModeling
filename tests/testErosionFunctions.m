classdef testErosionFunctions < matlab.unittest.TestCase
% testErosionFunctions contains unit tests for the functions in the /erosion directory.

    properties (Constant)
        projectRoot = fileparts(fileparts(mfilename('fullpath')));
    end

    methods (TestClassSetup)
        function addFunctionPaths(testCase)
            addpath(fullfile(testCase.projectRoot, 'erosion'));
        end
    end

    methods (Test)
        % --- Tests for soilErosionUSLE ---
        function testUSLEScalar(testCase)
            % Test with the scalar example from the function's help block.
            R = 170;
            K = 0.3;
            LS = 0.5;
            C = 0.1;
            P = 1.0;
            expectedA = 2.55;
            actualA = soilErosionUSLE(R, K, LS, C, P);
            testCase.verifyEqual(actualA, expectedA, 'AbsTol', 1e-6, ...
                'Scalar calculation for the example case failed.');
        end

        function testUSLEMatrix(testCase)
            % Test with the matrix example from the function's help block.
            R_grid = [170, 180; 175, 185];
            K_grid = [0.3, 0.32; 0.3, 0.32];
            LS_grid = [0.5, 0.8; 0.6, 0.9];
            C_grid = [0.1, 0.2; 0.1, 0.2];
            P_factor = 1.0;

            % Manually perform the element-wise calculation for the expected result.
            expectedA = (R_grid .* K_grid .* LS_grid .* C_grid .* P_factor);
            actualA = soilErosionUSLE(R_grid, K_grid, LS_grid, C_grid, P_factor);

            testCase.verifyEqual(actualA, expectedA, 'AbsTol', 1e-6, ...
                'Matrix calculation failed.');
        end

        function testUSLEZeroFactor(testCase)
            % If any of the USLE factors is zero, the resulting soil loss must be zero.
            R = 170;
            K = 0.3;
            LS = 0.5;
            C = 0; % Zero cover factor implies no erosion
            P = 1.0;
            expectedA = 0;
            actualA = soilErosionUSLE(R, K, LS, C, P);
            testCase.verifyEqual(actualA, expectedA, 'AbsTol', 1e-9, ...
                'A non-zero factor should result in zero soil loss.');
        end

        function testUSLEMatrixMismatch(testCase)
            % Test that MATLAB's own error handling for matrix dimension
            % mismatch is correctly propagated.
            R_grid = [170, 180; 175, 185]; % This is a 2x2 matrix
            K_grid = [0.3, 0.32, 0.3];     % This is a 1x3 matrix
            LS = 1; C = 1; P = 1;

            % The expected error ID for dimension mismatch is 'MATLAB:dimagree'
            testCase.verifyError(@() soilErosionUSLE(R_grid, K_grid, LS, C, P), 'MATLAB:dimagree', ...
                'Did not error correctly for mismatched matrix dimensions.');
        end
    end
end
