function getISI(spks, binMS, histogramSizeMS, color)

nSpks = length(spks);
histogramSizeSec = histogramSizeMS /1000;
found = 0;
for s = 1:nSpks
    temp = spks(spks > spks(s) & spks < (spks(s)+ histogramSizeSec));
    if isempty(temp)
        continue
    else
        found = found+1;
        distanceSec(found) = temp(1) - spks(s);
    end
end
distanceMS = distanceSec * 1000;

binEdges = 0:binMS:histogramSizeMS;
binCenters = binEdges + binMS/2;
count = zeros(1,length(binEdges));
for bin = 1:length(binEdges)-1
    count(bin) = sum(distanceMS > binEdges(bin) & distanceMS < binEdges(bin + 1));
end


bar(binCenters, count, 'FaceColor', color, 'EdgeColor', color, 'BarWidth', 1)

xlim([0, binEdges(end)])