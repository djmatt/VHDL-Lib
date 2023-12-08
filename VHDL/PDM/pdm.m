%Use allfun(@(x) pdm(x), your_vector) to use this function on a vector

function [y, e, cumerror] = pdm(x)
    persistent ce;  %cumulative error
    if(isempty(ce)) %for initializing ce
        ce = 0;
    end

    if(x>=ce)
        y = 1;
    else
        y = -1;
    end
    
    e = y-x;
    ce = e + ce;
    cumerror = ce;
%     assert(-1 <= ce && ce <= 1,'ce encountered invalid conditions\n ce = %g\n x = %g\n y = %g',ce,x,y)
end
