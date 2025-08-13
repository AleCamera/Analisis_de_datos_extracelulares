function [minVal,idx] = nearestValue(a,n)
    [~,idx]=min(abs(a-n));
    minVal = a(idx);
end