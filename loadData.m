function [data] = loadData(path)

cd (path)
%% Levanto los datos de los clusters
id = path(end-7:end);
%busco el archivo .res (contiene el cluster asignado a cada spike) en la
%carpeta del experimento
files = dir;
for f = 1:length(files)
    name = string(files(f).name);
    if name.contains([id '.clu'])
        cluDataFile = name;
        break
    end
    if f == length(files)
        error('I cannot find the .clu file');
    end
end
%cluDataFile = uigetfile ({'*.clu.1'});
%genro un vector con el numero de cluster
clusterData = importdata(cluDataFile(1,:));
nCluster = clusterData(2:end);
clear cluDataFile
clear clusterData

for f = 1:length(files)
    name = string(files(f).name);
    if name.contains([id '.res'])
        timeDataFile = name;
        break
    end
    if f == length(files)
        error('I cannot find the .res file');
    end
end
%busco el archivo con los tiempos de cada spike
%timeDataFile = uigetfile('*res.1');
%llevo los tiempos de los spikes de samples a segundos
tSpikes = importdata(timeDataFile) / 30000;
clear timeDataFile

%% Ahora separo los spikes por cluster. cada celda de data es un cluster

% allClusters = unique(nCluster);
% maxClusters = numel(allClusters);
% 
% countSpikesPerCluster = zeros(maxClusters,1);
% 
% for k = 1:maxClusters
%     countSpikesPerCluster(k) = sum(nCluster==allClusters(k));
% end
% 
% maxSpikesInCluster = max(countSpikesPerCluster);
% timeSpikesPerCluster = NaN([maxSpikesInCluster max(nCluster)],'double');
% 
% n = ones(1,max(nCluster)); %n es un vector donde cada columna es un contador para los disparos del cluster correspondiente
% for i = 1:length(tSpikes)
%     %coloco en la columna que corresponde al numero de cluster el tiempo de
%     %todos los spikes de ese cluster
%     for j = 1:max(nCluster)
%         if nCluster(i) == j
%             timeSpikesPerCluster(n(j), j) = tSpikes(i,1);
%             n(j) = n(j) + 1;
%         end
%     end
% end

data = cell(1,max(nCluster));
for cluster = 1:max(nCluster)
    data{cluster} = tSpikes(nCluster == cluster);
end
