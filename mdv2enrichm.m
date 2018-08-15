function f = mdv2enrichm(x,nt)
%x is mdv, nt is extra mass (nt), f is enrichment
if (length(x) < nt + 1)
    x = [x;zeros(nt+1-length(x),1)];
end
f = (0:nt) * x(1:(nt+1))/nt;
end