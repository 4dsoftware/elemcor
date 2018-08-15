function [M, I] = permlist(V, N)
nV = numel(V) ;
if nV==0 || N == 0
        M = zeros(nV,N) ;
        I = zeros(nV,N) ;
        
elseif N == 1
        % return column vectors
        M = V(:) ;
        I = (1:nV).' ;
else
        % this is faster than the math trick used for the call with three
        % arguments.
        [Y{N:-1:1}] = ndgrid(1:nV) ;
        I = reshape(cat(N+1,Y{:}),[],N) ;
        M = V(I) ;
end

