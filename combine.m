function combine(handles, list, group, varargin)
%default settings
PSHface = [0 0 0];
PSHedge = [0 0 0];
smoothPSH = false;
useLinePlot = false;
stimUnderPlot = false;
stimHeigth = 0.5;
if ~isempty(varargin)
    for arg = 1:2:length(varargin)
        switch lower(varargin{arg})
            case 'pshcolor'
                PSHface = varargin{arg+1};
            case 'pshedge'
                PSHedge = varargin{arg+1};
            case 'smooth'
                smoothPSH = varargin{arg+1};
            case 'uselineplot'
                useLinePlot = varargin{arg+1};
            case 'stimunderplot'
                stimUnderPlot = varargin{arg+1};
            case 'stimheigth'
                stimHeigth = varargin{arg+1};
        end
    end
end
%Combine grafica los PSH y el PSH promedio de la lista dada de neuronas
nNeurons = length(list);
%levanto la lista de estimulos
listStr = get(handles.stimCode_edit, 'string');
listCell = strsplit(listStr,' ');
stimCodes = zeros(1, length(listCell));
for neuron = 1:length(listCell)
    stimCodes(neuron) = str2double(listCell{neuron});
end

%levanto los monitores
mDerecho = get(handles.mDerecho_check, 'Value');
mIzquierdo = get(handles.mIzquierdo_check, 'Value');

%levanto los tiempos
tPre = str2double(get(handles.tPre_edit, 'string'));
tPost = str2double(get(handles.tPost_edit, 'string'));

%Tambien cargo el tamaño de bins calculo el número de bins que necesito
binSize = str2double(get(handles.binSize_edit, 'string'));
nBins = round((tPre + tPost)*(1000/binSize));

%ahora veo que neuronas voy a plotear
neuronList = get(handles.neuronList,'String');
%neuronIndex va a guardar los indices de handles.neuron donde estan las
%neuronas seleccioadas
neuronIndex = zeros(1,length(list));
found = 0;
for i = 1:length(neuronList)
    %recorro la neuronList y guardo los indices donde el nombre coincide
    %con el de grupo
    if sum(strcmp(neuronList{i}, list))
        found = found+1;
        neuronIndex(found) = i;
    end
end

%armo un cell array con los spikes
data = cell(1,nNeurons);
totalLength = 0;
allStims = [];
for neuron=1:nNeurons
    %cargo la lista de todos los estímulos de esta neurona
    Estimulos = handles.neurons{neuronIndex(neuron)}.Estimulos;
    %la lista de los monitores de cada estimulo
    Monitores = handles.neurons{neuronIndex(neuron)}.Monitores;
    %los spikes de la neurona
    spkTimes = handles.neurons{neuronIndex(neuron)}.data;
    %el nombre de la neurona
    data{neuron}.name = handles.neurons{neuronIndex(neuron)}.name;
    %elijo los estímulos a plotear
    data{neuron}.stims = checkStimAndMonitors(Estimulos,Monitores, stimCodes, ...
        mDerecho, mIzquierdo);

    %obtengo los spikes del cluster seleccionado (index indica a que
    %estimulo corresponden)
    [data{neuron}.raster,data{neuron}.index] = Sync(spkTimes,data{neuron}.stims(:,2),'durations',[-tPre; tPost]);
    data{neuron}.nData = length(data {neuron}.raster);
    totalLength = totalLength + data{neuron}.nData;
    allStims = [allStims; data{neuron}.stims];
end

%los ploteo por separado
figure(1);clf;
%maxRows determina el número maximo de filas. Si tengo más neuronas que ese
%número las divide en dos columnas (con suficientes neuronas las dos
%columnas tambien van a superar el numero maximo de columnas, habría que
%adaptar el script para que evalue que hacer en ese caso)
maxRows = 4;
if nNeurons > maxRows
    sPlotCols = 2;
    sPlotRows = ceil(nNeurons/2) + 1;
else
    sPlotCols = 1;
    sPlotRows = nNeurons+1;
end

for neuron = 1:nNeurons
    subplot(sPlotRows, sPlotCols, neuron)
    hold on
    titulo = ['Neurona: ', data{neuron}.name, '  Estimulos: ', num2str(unique(data{neuron}.stims(:,1))')];
    %armo el vector de frecuencias de disparo (Hz)
    [freq,~] = SyncHist(data{neuron}.raster, data{neuron}.index,'mode', 'mean'...
        ,'durations',[-tPre; tPost], 'nBins', nBins);
    if smoothPSH
        freq = smooth(freq, binSize/2);
    end
    %armo el vector de tiempos
    t = -tPre:(tPre+tPost)/(nBins-1):tPost;
    varg = {'PlotLines', useLinePlot, 'color', PSHface, 'StimUnderPlot', stimUnderPlot, 'StimHeigth', stimHeigth};
    hPlotInd = plotPSH(freq, t, data{neuron}.stims, tPre, tPost, titulo, varg{:});
    
    %si habia datos para graficar seteo la estetica de las barras
    if ~useLinePlot && ~isempty(hPlotInd)
        setAesthetics(hPlotInd, group);
    end
    %salvo por las dos ultimas neuronas elimino el eje x (es el mismo en
    %todos los graficos)
    xlabel({})
    if sPlotCols == 1
        set(gca,'xtick',[])
    elseif nNeurons - neuron > 1
        set(gca,'xtick',[])
    end
    hold off
end
%ahora genero un vector con todos los spikes juntos
combined.raster = zeros(totalLength,1);
combined.index = zeros(totalLength,1);
currentPoint = 1;
for neuron = 1:nNeurons
    combined.raster(currentPoint:(currentPoint+data{neuron}.nData-1),1) = data{neuron}.raster;
    combined.index(currentPoint:(currentPoint+data{neuron}.nData-1), 1) = data{neuron}.index;
    currentPoint = currentPoint+data{neuron}.nData;
end

%si hay dos columnas entonces el PSH promedio ocupa ambas columnas
if sPlotCols == 1
    combinedPos = nNeurons+1;
else
    combinedPos = [(sPlotRows*sPlotCols)-1,(sPlotRows*sPlotCols) ];
end

subplot(sPlotRows, sPlotCols, combinedPos)
hold on
titulo = 'Combined';
%armo el vector de frecuencias de disparo (Hz)
[freq,~] = SyncHist(combined.raster, combined.index,'mode', 'mean'...
    ,'durations',[-tPre; tPost], 'nBins', nBins);
freq = freq/nNeurons;
if smoothPSH
    freq = smooth(freq, binSize/2);
end
%armo el vector de tiempos
t = -tPre:(tPre+tPost)/(nBins-1):tPost;
varg = {'PlotLines', useLinePlot, 'color', getColor('M'), 'StimUnderPlot', stimUnderPlot, 'StimHeigth', stimHeigth};
hPlot = plotPSH(freq, t, allStims, tPre, tPost, titulo, varg{:});
if ~useLinePlot && ~isempty(hPlot)
    setAesthetics(hPlot, 'M');
end
hold off
