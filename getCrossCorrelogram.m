function [trend, binCenters, timeDistance, count] = getCrossCorrelogram(spikesFirstCluster, spikesSecondCluster, binMS, histogramSizeMS, varargin)
% spikesFisrstCluster es un vector con todos los spikes de un cluster contenidos
% dentro de los tiempos que quiero analizar
% spikesSecondCluster es el equivalente del otro cluster
% binMS es el tama�o de los bines en ms
% histogramSizeMS es el tama�o del histograma en ms
probabilistic = false;
names = {};
type = 'auto';
makePlot = true;
smoothSpan = 3;
smoothCorrelogram = true;
barColor = [0.4, 0.4, 0.4];
lineColor = [0.8, 0, 0];
for arg = 1:2:length(varargin)
    switch lower(varargin{arg})
        case 'probabilistic'
            probabilistic = varargin{arg+1};
        case 'names'
            names = varargin{arg+1};
        case 'type'
            type = varargin{arg+1};
            if ~strcmp(type, 'auto') && ~strcmp(type, 'cross')
                error('correlogram type can only be "auto" or "cross"')
            end
        case 'makeplot'
            makePlot = varargin{arg+1};
        case 'smooth'
            smoothCorrelogram = varargin{arg+1};
        case 'smoothspan'
            smoothSpan = varargin{arg+1};
        case 'barcolor'
            barColor = varargin{arg+1};
        case 'linecolor'
            lineColor = varargin{arg+1};
    end
end

bin = binMS/1000;
histogramSize = histogramSizeMS/1000;
nBin = histogramSize*2/bin;
timeDistance = [];
spikes = 0;
for i = 1:length(spikesFirstCluster)
    second = spikesSecondCluster(spikesSecondCluster > spikesFirstCluster(i) - histogramSize);
    second = second(second < spikesFirstCluster(i) + histogramSize);

    for j = 1:length(second)
        distance = second(j) - spikesFirstCluster(i);
        if  distance ~= 0
            spikes = spikes+1;
            timeDistance(spikes) = distance;
        end
    end
end
%convierto a milisegundos
timeDistance = timeDistance*1000;

if probabilistic 
    yleg = 'probability';
else
    yleg = 'number of spikes';
end
%defino si es auto o cross correlograma
if strcmp(type, 'auto')
    figureTitle = 'Auto-Correlogram';
    if isempty(names)
        plotTitle = '';
    else
        plotTitle = names{1};
    end
else
    figureTitle = 'Cross-Correlogram';
    if isempty(names)
        plotTitle = '';
    else
        plotTitle = [names{1} ' vs ' names{2}];
        yleg = ['probability of a ' names{2} ' spike'];
    end
end



binCenters = -histogramSizeMS:binMS:histogramSizeMS;
binEdges = binCenters-(binMS/2);
binEdges = [binEdges, binEdges(end)+(binMS/2)];
for bin = 1:length(binEdges)-1
    count(bin) = sum(timeDistance >= binEdges(bin)) - sum(timeDistance > binEdges(bin+1));
end
prob = count / length(spikesFirstCluster);
if makePlot
    figure('NumberTitle', 'off', 'Name', figureTitle);
    if probabilistic
        bar(binCenters, prob, 'FaceColor', barColor, 'EdgeColor', barColor, 'BarWidth', 1)
    else
        bar(binCenters, count, 'FaceColor', barColor, 'EdgeColor', barColor, 'BarWidth', 1)
    end
end
if probabilistic
    if smoothCorrelogram
        %genero los valores negativos de la trendline
        trend = smooth(prob(binCenters < 0), smoothSpan);
        %y ahora los positivos
        trend = [ trend; smooth(prob(binCenters >= 0), smoothSpan)];
    else
        %genero los valores negativos de la trendline
        trend = prob(binCenters < 0)';
        %y ahora los positivos
        trend = [ trend; prob(binCenters >= 0)'];
    end
else
    if smoothCorrelogram
        %genero los valores negativos de la trendline
        trend = smooth(count(binCenters < 0), smoothSpan);
        %y ahora los positivos
        trend = [ trend; smooth(count(binCenters >= 0), smoothSpan);];
    else
        %genero los valores negativos de la trendline
        trend = count(binCenters < 0)';
        %y ahora los positivos
        trend = [ trend; count(binCenters >= 0)'];
    end
end

if makePlot
    hold on
    plot(binCenters, trend, 'Color', lineColor, 'LineWidth', 2, 'LineStyle', '-')
    xlim([-histogramSizeMS histogramSizeMS]);
    title(plotTitle)
    ylabel(yleg)
    xlabel('time (ms) ')
    hold off
end
