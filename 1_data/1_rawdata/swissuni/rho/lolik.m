function output = lolik(pm,dt)

% Construct the negative log-likelihood function which is used in the ML
% estimation of Tobit Model. 

% pm is a 3x1 vector of parameters, pm = (g,r,log(sigma))
% g = [alpha/(1-alpha)]^(1/(1-rho))
% r = -rho/(1-rho)
% pm(3) is the log of standard deviation in a normal distribution of error

% dt is the data used in NLLS (50x2 matrix), which consists of RE_self and PR. 

g = pm(1); r = pm(2); sig = exp(pm(3));

hr = dt(:,1); % RE_self

pr = dt(:,2); % PR

[n,m] = size(dt); lo_lik = 0; h = .00001; k = .00000001;

sigm = max([sig, h]);

for i = 1:n
    
    if hr(i) == 0
        % log-likelihood function when ith RE_self is 0
        x = - g/(sigm*(pr(i)^r + g));
        lo_lik = lo_lik + log(normcdf(x));
        
    elseif hr(i) == 1
        % log-likelihood function when ith RE_self is 1
        x = (pr(i)^r)/(sigm*(pr(i)^r + g));
        lo_lik = lo_lik + log(max([k,1-normcdf(x)]));
    else
        % log-likelihood function when 0< hr(i) <1
        x = ((hr(i)- g/(pr(i)^r + g))/sigm)^2;
        lo_lik = lo_lik - 0.5*(log(2*pi) + log(sigm^2) + x);
    end
    
end

% output is negative log-likelihood function with n observations
output = - lo_lik;
