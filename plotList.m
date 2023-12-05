function plotList(handles, func, groupList, groupColor, color, lineWidth)
nNeurons = length(groupList);
%levanto la lista de estimulos
listStr = get(handles.stimCode_edit, 'string');
listCell = strsplit(listStr,' ');
for i = 1:length(listCell)
    stimCodes(i) = str2double(listCell{i});
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
neuronIndex = zeros(1,length(groupList));
found = 0;

for i = 1:length(neuronList)
    %recorro la neuronList y guardo los indices donde el nombre coincide
    %con el de groupA
    if sum(strcmp(neuronList{i}, groupList))
        found = found+1;
        neuronIndex(found) = i;
    end
end

%ahora genero una figura y la voy cargando con los rasters y PSH
neuron = 1;
maxPlotsPerFigure = 3;
if length(groupList) < maxPlotsPerFigure
    plotsPerFigure = length(groupList);
else
    plotsPerFigure = maxPlotsPerFigure;
end
nFigure = 1;
%doy vueltas en el loop mientas que haya neuronas sin plotear
while neuron <= nNeurons
    figure(nFigure);clf;
    if nNeurons - (neuron-1) > plotsPerFigure
        plotsToDo = plotsPerFigure;
    else
        plotsToDo = nNeurons - (neuron-1);
    end
    %recorro el subplot. Con dos columnas tiene:
    %filas:1,3,5,...,n para la primer columna y
    %filas:2,4,6,...,n+1 para la segunda columna
    for nPlot = 1:2:(plotsToDo*2)-1
        %cargo la lista de todos los estímulos de esta neurona
        Estimulos = handles.neurons{neuronIndex(neuron)}.Estimulos;
        %la lista de los monitores de cada estimulo
        Monitores = handles.neurons{neuronIndex(neuron)}.Monitores;
        %los spikes de la neurona
        spkTimes = handles.neurons{neuronIndex(neuron)}.data;
        %el nombre de la neurona
        name = handles.neurons{neuronIndex(neuron)}.name;
        %elijo los estímulos a plotear
        stims = checkStimAndMonitors(Estimulos,Monitores, stimCodes, ...
            mDerecho, mIzquierdo);
        %obtengo los spikes del cluster seleccionado (index indica a que 
        %estimulo corresponden)
        [raster,index] = Sync(spkTimes,stims(:,2),'durations',[-tPre; tPost]);
        %creo el titulo de la figura
        titulo = ['Neurona: ', name, '  Estimulos: ', num2str(unique(stims(:,1))')];
        %Ploteo los rasters
        subplot(plotsPerFigure, 2, nPlot)
        hold on
        plotRasters(func, raster, index, tPre, tPost, stims, color, lineWidth)
        if nPlot ~= (plotsToDo*2)-1
            set(gca,'xtick',[])
            xlabel({})
        else
            xlabel('tiempo (s)')
        end
        subplot(plotsPerFigure, 2, nPlot+1)
        %armo el vector de frecuencias de disparo (Hz)
        [freq,~] = SyncHist(raster, index,'mode', 'mean' ,'durations',...
            [-tPre; tPost], 'nBins', nBins);
        %armo el vector de tiempos
        t = -tPre:(tPre+tPost)/(nBins-1):tPost;
        hBar = plotPSH(freq, t, stims,tPre, tPost, titulo);
        setAesthetics(hBar, groupColor);
        if (nPlot+1) ~= (plotsToDo*2)
            set(gca,'xtick',[])
            xlabel({})
            ylabel ('')
        else
            xlabel('tiempo (s)')
            ylabel ('freq (Hz)')
        end
        hold off
        neuron = neuron+1;
    end
    nFigure = nFigure+1;
end