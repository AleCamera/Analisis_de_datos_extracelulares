function plotList_separated(handles, func, groupList, stimMat, groupColor, color, lineWidth)

nNeurons = length(groupList);
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

plotsPerFigure = length(stimMat);
%creo una figura por neurona. Cada figura va a tener los rasters y PSH de
%cada estimulo por separado
for neuron = 1:nNeurons
    figure(neuron);clf;
    %cargo la lista de todos los estímulos de esta neurona
    Estimulos = handles.neurons{neuronIndex(neuron)}.Estimulos;
    %la lista de los monitores de cada estimulo
    Monitores = handles.neurons{neuronIndex(neuron)}.Monitores;
    %los spikes de la neurona
    spkTimes = handles.neurons{neuronIndex(neuron)}.data;
    %el nombre de la neurona
    name = handles.neurons{neuronIndex(neuron)}.name;
    %empiezo un contador de estimulos
    nStim = 1;
    for nsPlot = 1:2:(plotsPerFigure*2)-1
        %elijo los estímulos a plotear
        stims = checkStimAndMonitors(Estimulos,Monitores, stimMat(nStim), ...
            mDerecho, mIzquierdo);
        if isempty(stims)
            continue;
        end
        %obtengo los spikes del cluster seleccionado (index indica a que
        %estimulo corresponden)
        [raster,index] = Sync(spkTimes,stims(:,2),'durations',[-tPre; tPost]);
        %creo el titulo de la figura
        if nsPlot == 1
            titulo = ['Neurona: ', name, '  Estimulos: ', string(stimMat(nStim))];
        else
            titulo = '';
        end
        %Ploteo los rasters
        subplot(plotsPerFigure, 2, nsPlot)
        hold on
        plotRasters(func, raster, index, tPre, tPost, stims, color, lineWidth)
        %si no es el último raster de la figura elimino el eje X
        if nsPlot ~= (plotsPerFigure*2)-1
            set(gca,'xtick',[])
            xlabel({})
            ylabel({})
        else
            xlabel('time (s)')

        end
        subplot(plotsPerFigure, 2, nsPlot+1)
        %armo el vector de frecuencias de disparo (Hz)
        [freq,~] = SyncHist(raster, index,'mode', 'mean' ,'durations',...
            [-tPre; tPost], 'nBins', nBins);
        %armo el vector de tiempos
        t = -tPre:(tPre+tPost)/(nBins-1):tPost;
        hBar = plotPSH(freq, t, stims,tPre, tPost, titulo);
        setAesthetics(hBar, groupColor);
        %si no es el último PSH de la figura elimino el eje X y los titulos
        %de los ejes X e Y
        if (nsPlot+1) ~= (plotsPerFigure*2)
            set(gca,'xtick',[])
            xlabel({})
            ylabel({})
        end
        hold off
        nStim = nStim+1;
    end
end