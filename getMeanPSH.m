function combined = getMeanPSH(handles, gList, params)
%Me devuelve un sctruct con los tiempos de spikes de todas las neuronas de
%la lista en un vector y con los indices de a que trial corresponden en
%otro
nNeurons = length(gList);

%ahora veo que neuronas voy a plotear
try 
    neuronList = get(handles.neuronList,'String');
catch ME
    try
        neuronList = handles.neuronList;
    catch
        rethrow(ME)
    end
end
%NLindex va a guardar los indices de handles.neuron donde estan las
%neuronas seleccioadas
[~, NLIndex,~] = intersect(neuronList, gList, 'stable');

%armo un cell array con los spikes
data = cell(1,nNeurons);
totalLength = 0;
allStims = [];
for neuron=1:nNeurons
    %cargo la lista de todos los estímulos de esta neurona
    Estimulos = handles.neurons{NLIndex(neuron)}.Estimulos;
    %la lista de los monitores de cada estimulo
    Monitores = handles.neurons{NLIndex(neuron)}.Monitores;
    %los spikes de la neurona
    spkTimes = handles.neurons{NLIndex(neuron)}.data;
    %el nombre de la neurona
    data{neuron}.name = handles.neurons{NLIndex(neuron)}.name;
    %elijo los estímulos a plotear
    data{neuron}.stims = checkStimAndMonitors(Estimulos,Monitores, params.stimCodes, ...
        params.mDerecho, params.mIzquierdo);
    %obtengo los spikes del cluster seleccionado (index indica a que
    %estimulo corresponden)
    [data{neuron}.raster,data{neuron}.index] = Sync(spkTimes,data{neuron}.stims(:,2),'durations',[-params.tPre; params.tPost]);
    data{neuron}.nData = length(data {neuron}.raster);
    totalLength = totalLength + data{neuron}.nData;
    allStims = [allStims; data{neuron}.stims];
end

%ahora genero un vector con todos los spikes juntos
combined.raster = zeros(totalLength,1);
combined.index = zeros(totalLength,1);
currentPoint = 1;
missingStims = 0;
for neuron = 1:nNeurons
    if neuron > 1
        if ~isempty(data{neuron-1}.index)
            data{neuron}.index = data{neuron}.index + max(data{neuron-1}.index);
        else
            for k = flip(2:neuron)
                if ~isempty(data{neuron-1}.index)
                    data{neuron}.index = data{neuron}.index + max(data{k-1}.index);
                    break
                end
            end
        end
    end
    combined.raster(currentPoint:(currentPoint+data{neuron}.nData-1),1) = data{neuron}.raster;
    combined.index(currentPoint:(currentPoint+data{neuron}.nData-1), 1) = data{neuron}.index;
    combined.neuronID(currentPoint:(currentPoint+data{neuron}.nData-1), 1) = neuron;
    if isempty(data{neuron}.stims)
        missingStims = missingStims+1;
    end
        
    currentPoint = currentPoint+data{neuron}.nData;
end
combined.stims = allStims;
combined.nEffectiveNeurons = nNeurons - missingStims; %contiene el numero de neuronas que a las que se le presentaron los estimulos requeridos