function output = bstrap(dt,nr)

% Compute the standard errors of (g, r) using the bootstrap method
% dt: the orginal data consisting of (RE_self, PR)
% nr: the number of replication

unif = 15*rand(nr,15);

G = []; R = []; h = .00001;

for i = 1:nr    

    % random sampling for each replication of bootstrap with replacement from the original data    
    
    rsam = unif(i,:);    
    subsp = [];
    
    for j = 1:15        
        for k = 1:15
            if (((k-1) <= rsam(j))& (rsam(j)<k)) 
                
                subsp = [subsp;dt(k,:)];
            end            
        end 
    end
    
    % Using a bootstap-sampled data, estimate NLLS to determine an initial value for MLE

    options = optimset('Display','off','MaxFunEvals',1e+6);
    
    x0 = [1,1];
    
    [x,res] = lsqnonlin(@nlregf,x0,[],[],[],subsp); sg2 = log(h+(res/13));
    
    pm0 = [x,sg2];
    
    % ML estimation with simplex method
    
    [pm,fval] = fminsearch(@lolik,pm0,options,subsp);
        
    G = [G;pm(1)]; R = [R;pm(2)]; 
    
end

output = [std(G),std(R)];


