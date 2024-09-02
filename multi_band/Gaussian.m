% % Filename: Gaussian
% % Date: 2024.8.28
% % Author: Jiatong Guo
% % Description: To compute the distance-dependence scaling factor

% Parameters
sigma = 120;

% Normalized Gaussian function
f = @(x) (1 / (sigma * sqrt(2 * pi))) * exp(-x.^2 / (2 * sigma^2));

ceil = 200;
middle = 75;
floor = 0;

% Numerical integration from -inf to +inf
integral_result1 = integral(f, middle, ceil);
integral_result2 = integral(f, floor, middle);
scaling_factor = integral_result1 / integral_result2;

% Display the result
fprintf('The integral result1: %f\n', integral_result1);
fprintf('The integral result2: %f\n', integral_result2);
fprintf('The scaling factor : %f\n', scaling_factor);
