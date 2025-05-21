classdef CrabolaEphysRec
    properties
        stims;
        neurons Neuron;
        ball MiceData;
        date;
        folder;
        crabID;
        protocol;
    end
    methods
        function obj = CrabolaEphysRec(type, inpt, varargin)
            % CrabolaEphysRec es el constructor de la clase. 
            % Tengo que decirle que tipo de input le doy:
            % 'file' si el input es el path a la carpeta con la salida del
            % spike sorting
            % 'data' si input es un cell array con:
            % 1- un objeto de la clase MiceData con los datos de la crabola
            % del registro
            % 2- un vector de objetos de la clase Neurons con las neuronas
            % del registro
            % 3- los estimulos
            % el argumento optativo "samplefreq" me permite setear la
            % frecuencia de sampleo a la que cargar las neuronas
            sf = 30000;
            saveFile = false;
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'samplefreq'
                        sf = varargin{arg+1};
                    otherwise
                        error([varargin{arg} 'is not a valid argument'])
                end
            end
            if strcmp(type, 'file')
                if strcmp(inpt, '')
                    path = uigetdir(pwd);
                else
                    path = inpt;
                end
                cd(path)
                list = dir;
                for f = 3:length(list)
                    fileList{f-2} = list(f).name;
                end
                %Busco si hay un recording
                for f = 1:length(fileList)
                    if contains(fileList{f}, 'recording')
                        rec = load(replace(fileList{f}, '', ''));
                        obj = rec.obj;
                        if isempty(obj.date)
                            obj.date = obj.getDate();
                            save('recording.mat', 'obj');
                        end
                        if isempty(obj.protocol)
                            obj.protocol = generarProtocoloCrabola(length(obj.stims), {'pelota', 'aire'});
                            for s = 1:length(obj.stims)
                                if strcmp(obj.protocol{s}, 'pelota')
                                    obj.stims(s).running = true;
                                end
                            end
                            protocolo = obj.protocol;
                            save('protocolo.mat', 'protocolo');
                            save('recording.mat', 'obj');
                        end
                        return
                    elseif f == length(fileList)
                        %si no existe lo genero
                        disp('I cannot find the recording.mat file, we need to generate it')
                        disp('creating recording.mat file...')
                        neurons = obj.loadClusters(path, 'samplefreq', sf);
                        ballData = loadBallData(path);
                        obj.stims = neurons(1).stims;
                        for j = 1:length(fileList)
                            if contains(fileList{j}, 'protocolo')
                                prot = load(replace(fileList{j}, '', ''));
                                try
                                    protocol = prot.protocolo;
                                catch ME
                                    try 
                                        protocol = prot.protocol;
                                    catch ME
                                        retrhow(ME)
                                    end
                                end
                                obj.protocol = protocol;
                                for s = 1:length(obj.stims)
                                    if strcmp(obj.protocol{s},'pelota')
                                        obj.stims(s).running = true;
                                    end
                                end
                            elseif j == length(fileList)
                                %generar protocolo
                                if isempty(obj.protocol)
                                    obj.protocol = generarProtocoloCrabola(length(obj.stims), {'pelota', 'aire'});
                                    for s = 1:length(obj.stims)
                                        if strcmp(obj.protocol{s},'pelota')
                                            obj.stims(s).running = true;
                                        end
                                    end
                                end
                            end
                        end
                        saveFile = true;
                    end
                end
               
            elseif strcmp(type, 'data')
                ballData = inpt{1};
                neurons = inpt{2};
                stims = inpt{3};
                for s = 1:length(stims)
                stimList(s) = struct('code', stims(s,1), ...
                    'start', stims(s,2), ...
                    'finish', stims(s,3), ...
                    'running', false);
                end
                obj.stims = stimList;
            end
            obj.ball = ballData;
            obj.neurons = neurons;
            obj.crabID = ballData.crabID;
            obj.folder = obj.neurons(1).folder;
            obj.date = obj.getDate();
            if saveFile
                save('recording.mat', 'obj');
                disp('recoding.mat file saved')
            end
            if length(obj.ball.trial) < length(obj.stims)
                disp('There are missing trials on the crabola')
                disp(['i have ' num2str(length(obj.stims)) ' on the ephys'])
                disp(['but only ' num2str(length(obj.ball.trial)), ' on the crabola']);
            elseif length(obj.ball.trial) > length(obj.stims)
                disp('There are missing trials on the ephys')
                disp(['i have ' num2str(length(obj.ball.trial)), ' on the crabola']);
                disp(['but only ' num2str(length(obj.stims)) ' on the ephys'])
            end            
        end
        
        function stimIND = getStimIndex(obj, stimCodes, varargin)
            condition = 'all';
            screens = [];
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'condition'
                        if sum(strcmp({'all', 'ball', 'air'}, varargin{arg+1}))
                             condition = varargin{arg+1};
                        elseif varargin{arg+1} == 0
                            condition = 'air';
                        elseif varargin{arg+1} == 1
                            condition = 'ball';
                        else
                            error('invalid "condition", only "0-1", "all", "ball" and "air" are permited')
                        end
                    case 'screens'
                        screens = varargin{arg+1};
                end
            end
            %find selected stims
            % This code filters of stims by all the posible criteria and
            % makes boolean vectors as result.
            % The result stimIND is the result of the AND operation over
            % all the lists.
            % The code makes a ones filed list for each codition as defualt
            % until the filter is selected.
            
            % Filter by code
            whereCodes = ones(1,length(obj.stims));
            if ~isempty(stimCodes)
                whereCodes = ismember([obj.stims.code], stimCodes);
            end
            
            % Filter by runing codition
            whereRuning = ones(1,length(obj.stims));
            if strcmp(condition, 'ball')
                whereRuning = ismember([obj.stims.running], 1);
            elseif strcmp(condition, 'air')
                whereRuning = ismember([obj.stims.running], 0);
            end
            
            %Filter by screen
            whereScreen = ones(1,length(obj.stims));
            if ~isempty(screens)
                whereScreen = ismember([obj.stims.screen], screens);
            end
            stimIND = find(whereCodes&whereRuning&whereScreen);
            
        end
        
        
        function makeMixedPlots(obj, stim, cluster, varargin)
            %makeMixedPlots toma un estimulo y un cluster y devuelve una
            %figura con los graficos apilados de cada trial de ese
            %estimulo. En los graficos se grafica la actividad del cluster
            %selecionado y la actividad del animal. Ademas una linea azul
            %marca el final del movimiento del estimulo. Todos los
            %estimulos empiezan en cero.
            %
            % 'condition'   me permite seleccionar si uso todos los trials,
            %               solo los que el bicho estaba sobre la pelota o solo los que
            %               solo los que estaba en el aire.
            %
            % 'xlim'        me permite seleccionar los limites horizontales.
            %
            % 'binsize'     es el tamaño del bineado en ms.
            %
            % 'title'       pone un titulo en la figura.
            %
            % 'behavior'    me permite elegir si quiero graficar la velocidad
            %               traslacional, rotacional o la direccion.
            %
            % 'plotmean'    1 agrega una fila mas a la figura con la media de
            %               la respuesta de las neuronas en las distitntas
            %               condiciones
            %               2 genera una nueva figura con la media de la
            %               respuesta
            %
            % 'makefig'     si es verdadero genera una nueva figura, si es
            %               falso trata de plotear sobre la anterior
            %
            % 'smoothmethod' define el metodo que voy a usar con la funcion 
            %                'smooth'
            % 'spanephys'   define el numero de bines que uso para la
            %               ventana del suavizado de la frecuencia de disparo
            %
            % 'spanball'    define el numero de bines que uso para la
            %               ventana del suavizado de la velocidad traslacional
            % 'addtitle'    agrega un titulo general a la figura
            % 'behavdelay'  ofset negativo sobre el comportamiento
            % 'autotitle'   agrega un titulo a cada subfigura con los datos
            %               Cluster:  Stim:  Trial:  Screen:  Runing:  Nº Spikes:  Date: 
            % 'noephys'     no plotea la respuesta fisiologica

            condition = 'all';
            xlimit = [-10, 15];
            binSize = 50;
            titleTxt = '';
            behavior = 'tras';
            plotMean = 0;
            makeFig = true;
            ephysSpan = 5;
            ballSpan = 5;
            method = 'moving';
            addTitle = false;
            behavDelay = 10;
            autotitle = 0;
            noephys = 0;
            bytrial = 0;
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'condition'
                        if sum(strcmp({'all', 'ball', 'air'}, varargin{arg+1}))
                            condition = varargin{arg+1};
                        else
                            error('invalid "condition", only "all", "ball" and "air" are permited')
                        end
                    case 'xlim'
                        xlimit = varargin{arg+1};
                    case 'binsize'
                        binSize = varargin{arg+1};
                    case 'title'
                        titleTxt = varargin{arg+1};
                    case 'behavior'
                        if sum(strcmp({'tras', 'rot', 'dir'}, varargin{arg+1}))
                            behavior = varargin{arg+1};
                        else
                            error('invalid "behavior", only "all", "ball" and "air" are permited')
                        end
                    case 'plotmean'
                        plotMean = varargin{arg+1};
                    case 'makefig'
                        makeFig = varargin{arg+1};
                    case 'smoothmethod'
                        method = varargin{arg+1};
                    case 'spanephys'
                        ephysSpan = varargin{arg+1};
                    case 'spanball'
                        ballSpan = varargin{arg+1};
                    case 'addtitle'
                        addTitle = varargin{arg+1};
                    case 'behavdelay'
                        behavDelay = varargin{arg+1};
                    case 'autotitle'
                        autotitle = varargin{arg+1};
                    case 'noephys'
                        noephys = varargin{arg+1};
                    case 'bytrial'
                        bytrial = varargin{arg+1};
                    otherwise
                        error(['invalid optional argument: ' varargin{arg}])
                end
            end
            nBins = round((xlimit(2)-xlimit(1))*(1000/binSize));
            
            if bytrial
                stimIND = stim;
            else
                stimIND = obj.getStimIndex(stim, 'condition', condition);
            end
            [~, index, ~] = obj.neurons(cluster).getRasters(stim, 'durations', [-xlimit(1), xlimit(2)], 'stimIndex', stimIND);

            for i = unique(index)'
                disp([' trial ' num2str(i) ' has ' num2str(sum(index == i)) ' spikes'])
            end
                
            lTopLimit = 0;
            rTopLimit = 0;
            if makeFig
                figure('Renderer', 'painters', 'Position', [10 10 560 825]);
            end
            
            if addTitle
                sgtitle(titleTxt)
            end
            hold on
            
            if plotMean == 1
                nSubPlots = length(stimIND)+1;
            else
                nSubPlots = length(stimIND);
            end
            freqs = [];
            for ns = 1:length(stimIND)
                s = stimIND(ns);
                ax{ns} = subplot(nSubPlots, 1,ns);
                axes(ax{ns})
                hold on
                run = obj.ball.interpolateRuns(s, binSize/1000);
                if strcmp(behavior, 'tras')
                    runPar = run.vTras;
                    behLabel = 'traslational speed (cm/s)';
                elseif strcmp(behavior, 'rot')
                    runPar = run.vRot;
                    behLabel = 'rotational speed (deg/s)';
                else
                    runPar = run.Dir;
                    behLabel = 'direction (deg)';
                end
                
                if ~isempty(runPar)
                    yyaxis left
                    plot(run.time-behavDelay, smooth(runPar, ballSpan, method), 'linewidth', 2)

                end
                if lTopLimit < max(ylim)
                    lTopLimit = max(ylim);
                    
                end
                if ns == round(length(stimIND)/2)
                    ylabel(behLabel);
                end
                if ~noephys
                    [raster, index, ~] = obj.neurons(cluster).getRasters(2, 'durations', [abs(xlimit(1)), abs(xlimit(2))], 'stimIndex', s);
    %                 [freq,~] = SyncHist(raster(index == ns), index(index==ns),'mode', 'mean' ,'durations',...
    %                                     [xlimit(1); xlimit(2)], 'nBins', nBins);
                    assignin('base','raster',raster)
                    [freq, t] = obj.neurons(cluster).getPSH(raster, index, xlimit, nBins);

                    freq = smooth(freq, ephysSpan, method);
    %                 t = (xlimit(1):(xlimit(2) - xlimit(1))/(nBins-1):xlimit(2))';
                    if isempty(freq)
                        freq = zeros(size(t));
                    end
                    if plotMean
                        freqs(:,ns) = freq;
                    end
                    yyaxis right
                    plot(t, freq)
                    if ns == round(length(stimIND)/2)
                        ylabel('firing freq (Hz)');
                    end
                else
                    raster = [];
                end
                if rTopLimit < max(ylim)
                    rTopLimit = max(ylim);
                end
                if ns == length(stimIND)
                    xlabel('time (s)')
                end
                pool = {'FALSE', 'TRUE'};
                if autotitle
                    title(['Cluster: ' num2str(cluster) ...
                           ' Stim: ' num2str(obj.stims(stimIND(ns)).code) ...
                           ' Trial: ' num2str(stimIND(ns)) ...
                           ' Screen: ' num2str(obj.stims(stimIND(ns)).screen) ...
                           ' Runing: ' pool{obj.stims(stimIND(ns)).running+1} ...
                           ' Nº Spikes: ' num2str(length(raster)) ...
                           ' Date: ' obj.date]);
                end
            end
            
            if plotMean == 1
                runningTrials = false(1, length(stimIND));
                airTrials = false(1, length(stimIND));
                for nt = 1:length(stimIND)
                    if obj.stims(stimIND(nt)).running
                        runningTrials(nt) = true;
                    else
                        airTrials(nt) = true;
                    end
                end
                if ~isempty(freqs)
                    runningMean = mean(freqs(:,runningTrials), 2);
                    airMean = mean(freqs(:,airTrials), 2);
                    hold on
                    subplot(nSubPlots, 1,ns+1)
                    yyaxis right
                    plot(t, runningMean, '-b', t, airMean, '-r', 'linewidth', 2);
                end
            elseif plotMean == 2
                
            end
            
            
            for ns = 1:nSubPlots
                subplot(nSubPlots, 1,ns)
                if ns < nSubPlots
                    s = stimIND(ns);
                end
                yyaxis left
                ylim([min(ylim) lTopLimit])
                line([obj.stims(s).finish - obj.stims(s).start, obj.stims(s).finish - obj.stims(s).start], [0, lTopLimit])
                %addPSHDecorations(stim, obj.stims(s).finish - obj.stims(s).start ,lTopLimit, 'StimUnderPlot', true)
                %PlotRasters_oneColor(raster(index == ns), index(index==ns),[-10, 15], max(ylim), 'RelativeSize', 0.1, 'position', 'botom')
                yyaxis right
                ylim([0 rTopLimit])
                
                %addPSHDecorations(stim, obj.ball.trial(s).duration, 40, 'stimUnderPlot', false, 'heigth', 0.2)
                xlim(xlimit)
            end
            
        end
        
        
        function neurons = loadClusters(obj, path, varargin)
            % loadClusters toma el path de la carpeta donde estan los
            % archivos ya sorteados y levanta los clusters (ignorando el 0
            % que corresponde a artefatos). Devuelve un vector de neuronas
            % de la clase "Neurons"
            
            %con el argunmento optativo "samplefreq" puedo setear la frecuencia de
            %sampleo del registro
            sf = 30000;
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'samplefreq'
                        if varargin{arg+1} > 0
                            sf = varargin{arg+1};
                        else
                            error('sample frequency must be > 0')
                        end
                end
            end
            cd (path)
            
            %cargo los estimulos
            load('Estimulos.mat');
            %cargo los monitores
            load('Monitores.mat');
            %% Levanto los datos de los clusters
            id = path(end-7:end);
            %busco el archivo .clu (contiene el cluster asignado a cada spike) en la
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
            %genro un vector con el numero de cluster
            clusterData = importdata(cluDataFile(1,:));
            nCluster = clusterData(2:end);
            
            clear cluDataFile
            clear clusterData
            
            
            %busco el archivo con los tiempos de cada spike            
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

            %llevo los tiempos de los spikes de samples a segundos
            tSpikes = importdata(timeDataFile) / sf;
            clear timeDataFile
            for cluster = 1:max(nCluster)
                neuron.data = tSpikes(nCluster == cluster);
                neuron.file = path;
                neuron.cluster = cluster;
                neuron.Estimulos = Estimulos;
                neuron.Monitores = Monitores;
                neuron.name = [id '-C' num2str(cluster)];
                neurons(cluster) = Neuron(neuron);
            end
        end
        
        function date = getDate(obj)
            folder = char(obj.folder);
            dateStr = folder(end-7:end);
            date = [dateStr(1:4) '-' dateStr(5:6) '-' dateStr(7:8)];
        end
        
        function plotConditionComparisons(obj, stim, neuronIND, varargin)
            
            rasterArgs = {};
            ballColor = [0.8 0.2 0.2];
            airColor = [0.2 0.2 0.8];
            combinedColor = [0.8 0.2 0.8];
            addRasters = false;
            rasterSize = 0.4;
            stimHeigth = 0.05;
            topFreq = 60;
            for arg = 1:2:length(varargin)
                switch varargin{arg}
                    case 'rasterargs'
                        rasterArgs = varargin{arg+1};
                    case 'ballcolor'
                        ballColor = varargin{arg+1};
                    case 'aircolor'
                        airColor = varargin{arg+1};
                    case 'combinedColor'
                        combinedColor = varargin{arg+1};
                    case 'rasters'
                        addRasters = varargin{arg+1};
                    case 'rasterSize'
                        rasterSize = varargin{arg+1};
                    case 'stimheigth'
                        stimHeigth = varargin{arg+1};
                    case 'topfreq'
                        topFreq = varargin{arg+1};
                    otherwise
                        error([varargin{arg} ' is an invalid argument'])
                end
            end
            for n = neuronIND
                figure(n);
                subplot(2,1,1);  hold on; title('ball');
                stimIND = obj.getStimIndex(stim, 'condition', 'ball');
                obj.neurons(n).plotPSH(stimIND, [2, 5], 100, 'rasters', addRasters, 'pshColor', ballColor, 'relativesize', rasterSize, 'smoothspan', 10, 'smoothmethod', 'lowess')
                ylim([0 topFreq])
                topLimit = max(ylim);
                addPSHDecorations(stim, 3.4, topLimit, 'stimunderplot', addRasters, 'heigth', stimHeigth)
                subplot(2,1,2);  hold on; title('air');
                stim = 2;
                stimIND = obj.getStimIndex(stim, 'condition', 'air');
                obj.neurons(n).plotPSH(stimIND, [2, 5], 100, 'rasters', addRasters, 'pshColor', airColor, 'relativesize', rasterSize, 'smoothspan', 10, 'smoothmethod', 'lowess')
                addPSHDecorations(stim, 3.4, topLimit, 'stimunderplot', addRasters, 'heigth', stimHeigth)
            end
        end
        
        function compareNeurons(obj, neuronList, stim, varargin)
            xlimit = [-10, 15];
            binSize = 50;
            plotMean = false;
            colorList = [];
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'xlim'
                        xlimit = varargin{arg+1};
                    case 'binsize'
                        binSize = varargin{arg+1};
                    case 'plotmean'
                        plotMean = varargin{arg+1};
                    case 'colorlist'
                        colorList = varargin{arg+1};
                end
            end
            
            %si no especifiqué los colores genero un patrón al azar
            if isempty(colorList)
                colorList{1} = getDifferentRGB([0.5, 0.5, 0.5]);
                for i = 2:length(neuronList)
                    colorList{i} = getDifferentRGB(colorList{i-1});
                    
                end
            end
            nBins = round((xlimit(2)-xlimit(1))*(1000/binSize));
            stimIND = obj.getStimIndex(stim);
            if plotMean
                nSubPlots = length(stimIND)+1;
            else
                nSubPlots = length(stimIND);
            end
            %checkeo que la lista este organizada en columnas y la corrijo
            %en el caso contrario.
            [nRows, nCols] = size(neuronList);
            if nRows > nCols
                neuronList = neuronList';
            end
            for ns = 1:length(stimIND)
                nNeu = 0;
                raster = [];
                index = [];
                s = stimIND(ns);
                ax{ns} = subplot(nSubPlots, 1,ns);
                hold on
                for n = neuronList
                    nNeu = nNeu + 1;
                    [rasters{nNeu}, indexes{nNeu}] = obj.neurons(n).getRasters(2, 'durations', [abs(xlimit(1)), abs(xlimit(2))], 'stimIndex', s);
                    [freqs{nNeu}, times{nNeu}] = obj.neurons(n).getPSH(rasters{nNeu}, indexes{nNeu}, xlimit, nBins);
                    plot(times{nNeu},freqs{nNeu}, 'linewidth', 2, 'color', colorList{nNeu})
                    raster = [raster; rasters{nNeu}];
                    index = [index; (ones(size(indexes{nNeu}))*nNeu)];
                end
                maxfreq = max(ylim);
                PlotRasters_oneColor(raster, index, xlimit,maxfreq, ...
                                     'position', 'top', ...
                                     'relativesize', 0.3, ...
                                     'colorlist', colorList);
                line([obj.stims(s).finish - obj.stims(s).start, obj.stims(s).finish - obj.stims(s).start], [0, max(ylim)])
                if ns == 1
                    legend(string(neuronList))
                end
            end
            
            
        end
        
        function mixData = getRunAndFireRate(obj, clu, stim, varargin)
            
            %devuelve un struct con los las frecuencias de disparo del
            %cluster seleccionado para todos los trials del estimulos
            %seleccionado bajo el capo de "fRates". El vector de tiempo en
            %el cmapo "t_ephys" y las corridas de la crabola en el campo 
            %"runs".
            %
            % 'condition'    --> puede ser 'ball', 'air' o 'all'
            %
            % 'binSize'      --> el bineo en ms
            %
            % 'durations'    --> el intervalo de tiempo con respecto al 
            %                    inicio [segsAntes y secsDespues]
            %
            % 'spanephys'    --> el span de la ventan movil que suaviza la
            %                    curva de respuesta de las neuronas
            %
            % 'spanball'     --> el span de la ventan movil que suaviza la
            %                    curva de la velocidad del animal
            %
            % 'smoothmethod' --> metodo usado para el suavizado
            %
            % 'smoothball'    --> opcion de suavizar las corridas
            %
            % 'stimind'       --> reemplaza  a stim. Fuerza los indices a
            %                       exportar
            
            condition = 'ball';
            binSize = 50;%ms
            durations = [2 6];
            ephysSpan = 5;
            ballSpan = 5;
            smoothMethod = 'moving';
            smoothBallMethod = 'moving';
            smoothBall = false;
            stimIND = [];
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'condition'
                        condition = varargin{arg+1};
                    case 'binsize'
                        binSize = varargin{arg+1};
                    case 'durations'
                        durations = varargin{arg+1};
                    case 'spanephys'
                        ephysSpan = varargin{arg+1};
                    case 'smoothmethod'
                        smoothMethod = varargin{arg+1};
                    case 'spanball'
                        ballSpan = varargin{arg+1};
                    case 'smoothball'
                        smoothBall = varargin{arg+1};
                    case 'stimind'
                        stimIND = varargin{arg+1};
                    otherwise
                        error(['invalid optional argument: ' varargin{arg}])
                end
            end
            nBins = round((durations(2)+durations(1))*(1000/binSize));
            neu =  obj.neurons(clu);
            if isempty(stimIND)
                stimIND = obj.getStimIndex(stim, 'condition', condition);
            end
            for i = 1:length(stimIND)
                [raster, index, stimList] = neu.getRasters(stim, 'stimindex', stimIND(i), 'durations', durations);
                [freq, t] = neu.getPSH(raster, index, [-durations(1) durations(2)], nBins, 'smoothspan', ephysSpan, 'smoothmethod', smoothMethod);
                if ~isempty(freq)
                    fRates(:,i)  = freq;
                else
                    error('No hay spikes en este registro');
                end
                currRun = obj.ball.interpolateRuns(stimIND(i), binSize/1000, 'smooth', smoothBall, 'span', ballSpan, 'smoothmethod', smoothBallMethod);
                currRun.time = currRun.time-10;
                runs(i) = currRun;
            end
            
            if isempty(stimIND)
                mixData.fRates = [];
                mixData.t_ephys = [];
                mixData.runs = [];
                mixData.spontFreq = [];
                mixData.spontFreq.general = [];
                mixData.airIND = [];
                mixData.ballIND = [];
                mixData.ID = []
                mixData.clu = [];
            else
                mixData.fRates = fRates;
                mixData.t_ephys = t;
                mixData.runs = runs;
                mixData.spontFreq = obj.neurons(clu).getSpontaneousFreqs(20, stim, 'StimIndex', stimIND);
                mixData.spontFreq.general = obj.neurons(clu).getSpontaneousFreqs(20, stim, 'StimIndex', 1:length(obj.stims));
                mixData.airIND = obj.getStimIndex(unique([obj.stims.code]), 'condition', 'air');
                mixData.ballIND = obj.getStimIndex(unique([obj.stims.code]), 'condition', 'ball');
                mixData.ID = str2double(obj.crabID);
                mixData.clu = clu;
            end
        end
        
    end
end
