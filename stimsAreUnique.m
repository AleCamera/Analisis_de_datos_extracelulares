function areUnique = stimsAreUnique(stims, stims2plot)
if ~isempty(ismember(stims2plot, stims))
    arePresent = true;
else
    arePresent = false;
end
if length(stims2plot) == sum(ismember(stims2plot, stims))
    areAlone = true;
else
    areAlone = false;
end
if arePresent && areAlone
    areUnique = true;
else
    areUnique = false;
end

end
