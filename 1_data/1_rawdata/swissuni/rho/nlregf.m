function output = nlregf(x,dt)

% Construct the residuals in each observed sample, which is used to compute
% the sum of squared residuals in the Nonlinear Least Squares Estimation.

% x(1) = g = [alpha/(1-alpha)]^(1/(1-rho))
% x(2) = r = -rho/(1-rho)

% dt is the data used in NLLS (50x2 matrix), which consists of RE_self and PR. 

out = zeros(15,1);

for i = 1:15
    
    out(i) = dt(i,1) - x(1)/(dt(i,2)^x(2) + x(1));
end

output = out;
