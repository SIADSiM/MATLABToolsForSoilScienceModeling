% runAllTests.m
% This script discovers and runs all unit tests in the /tests directory.
% To run, simply execute this file in the MATLAB command window.

try
    fprintf('Starting test run...\n\n');

    % Define the project root and add it to the path, so the test runner can find the test files.
    projectRoot = fileparts(mfilename('fullpath'));
    addpath(projectRoot);

    % Create a test suite from the 'tests' folder.
    % This automatically discovers all files starting with 'test'.
    suite = matlab.unittest.TestSuite.fromFolder('tests');

    fprintf('Test suite created. Found %d tests.\n', numel(suite));

    % Create a test runner with text output to the command window.
    runner = matlab.unittest.TestRunner.withTextOutput;

    % Run the tests.
    result = runner.run(suite);

    % Display the results in a table format.
    fprintf('\n--- Test Results ---\n');
    disp(table(result));

    % Check for failures and provide a clear summary message.
    if runner.Failed
        fprintf('\nTESTS FAILED. See details above.\n');
        % In an automated CI/CD environment, you would use exit(1) here.
        % exit(1);
    else
        fprintf('\nALL TESTS PASSED SUCCESSFULLY!\n');
        % In an automated CI/CD environment, you would use exit(0) here.
        % exit(0);
    end

catch e
    fprintf('An error occurred during the test execution process:\n');
    fprintf('Error ID: %s\n', e.identifier);
    fprintf('Error Message: %s\n', e.message);
    % exit(1);
end
