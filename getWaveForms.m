function [meanWaves, stdWaves] = getWaveForms(cluster, channel, nWaves)
%busco el archivo .res (contiene el cluster asignado a cada spike) en la
%carpeta del experimento
cluDataFile = uigetfile ({'*.clu.1'});
if isempty(cluDataFile)
    return
end
%genro un vector con el numero de cluster
clusterData = importdata(cluDataFile(1,:));
clusterID = clusterData(2:end);
spkDATFile = uigetfile ({'*.spkDAT.1.mat'});
if isempty(spkDATFile)
    warning('falta cargar las waveforms del registro:')
    warning(pwd)
    return
end

load(spkDATFile)

FullInd = find(clusterID == cluster);
%get random indexes to calculate the mean
ind = randi(length(FullInd), 1, nWaves);

waveforms = Segs(:,channel, ind);
waveforms = squeeze(waveforms);
meanWaves = mean(waveforms');
stdWaves = std(waveforms');