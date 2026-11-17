clc

% load the 2D giving data, which consists of (id, RE_self, RE_other, PR),
% where RE_self (other) is a relative expenditure for self (other) and RP represents the relative price of giving. 

Data_2D = readmatrix('3_input_matlab.csv')

save('Data_2D.mat', 'Data_2D')

load Data_2D.mat

dt = Data_2D;  n = length(dt)/15; % n is the number of subjects in the data

Results = []; h = .00001;

for i = 1:n

    m1 = 15*(i-1)+1; m2 = 15*i; id = i

    subdt = [dt(m1:m2,2),dt(m1:m2,4)]; % In the estimation, we use two variables (RE_self, PR).
    
    % In order to find an appropriate initial value for Tobit estimation,
    % we first use nonlinear least squares estimation.
    
    options = optimset('Display','off','MaxFunEvals',1e+6);
    
    x0 = [1,1];
    
    [x,res] = lsqnonlin(@nlregf,x0,[],[],[],subdt); sg2 = log(h+(res/13));
    
    % The NLLS estimated initial values for the parameters are served as a starting point 
    % in the search of ML estimation with Nelder-Meade Simplex Method. 
    
    pm0 = [x,sg2];
        
    [pm,fval] = fminsearch(@lolik,pm0,options,subdt);
    
    g = pm(1); r = pm(2); % r = -rho/(1-rho), g = [alpha/(1-alpha)]^(1/(1-rho))
    
    rho = real(r/(r-1)); alpha = real((g^(1-rho))/(1+(g^(1-rho)))); es = real(1/(rho-1)); % Elasticity of substitution
    
    % se = bstrap(subdt,200);
    
    Results = [Results; id, rho, alpha, es, g, r, exp(pm(3)), -fval];

    
end   

ResultsTable = array2table(Results);
ResultsTable.Properties.VariableNames = {'id', 'rho', 'alpha', 'es', 'g', 'r', 'expPM3', 'fval'};
Results=ResultsTable;

writetable(Results,'5_Results.csv')     
    
    
    



