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
        
        function fig = makeMixedPlots(obj, stim, cluster, varargin)
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
            % 'spoffset'    elige desde que sublot comenzar a graficar

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
            stimPlot = 0;
            rasterPos = 'top';
            rasterPlot = 0;
            spoffset = 0;
            plusNSubPlots = 0;
            stimAlpha = 0.2;
            runLineWidth = 2;
            ephysLineWith = 1;
            ephysLineType = '-';
            runLineType = '-';
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
                    case 'stimplot'
                        stimPlot = varargin{arg+1};
                    case 'rasterplot'
                        rasterPlot = varargin{arg+1};
                    case 'rasterpos'
                        rasterPos = varargin{arg+1};
                    case 'spoffset'
                        spoffset = varargin{arg+1};
                    case 'addnsubplots'
                        plusNSubPlots = varargin{arg+1};
                    case 'stimalpha'
                        stimAlpha = varargin{arg+1};
                    case 'runlinewidth'
                        runLineWidth = varargin{arg+1};
                    case 'ephyslinetype'
                        ephysLineType = varargin{arg+1};
                    case 'ephyslinewith'
                        ephysLineWith = varargin{arg+1};
                    case 'runlinetype'
                        runLineType = varargin{arg+1};
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
            if isa(makeFig,'matlab.ui.Figure')
                fig = makeFig;
            elseif makeFig
                fig = figure('Renderer', 'painters', 'Position', [10 10 560 825]);
            else
                fig = findobj('Type','figure');
                fig = fig(end);
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
                ax{ns} = subplot(nSubPlots+plusNSubPlots, 1,ns+spoffset);
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
%                     if obj.stims(s).
                    plot(run.time-behavDelay, smooth(runPar, ballSpan, method), runLineType,'linewidth', runLineWidth)
                end
                if lTopLimit < max(ylim)
                    lTopLimit = max(ylim);
                    
                end
                if ns == round(length(stimIND)/2)
                    ylabel(behLabel);
                end
                if ~noephys
                    [raster, index, ~] = obj.neurons(cluster).getRasters(2, 'durations', [abs(xlimit(1)), abs(xlimit(2))], 'stimIndex', s);

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
                    plot(t, freq,ephysLineType,'linewidth',ephysLineWith)
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
                           ' Date: ' obj.date ...
                           ' ID: ' num2str(obj.crabID)]);
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
                    subplot(nSubPlots+1+plusNSubPlots, 1,ns+1+spoffset)
                    yyaxis right
                    plot(t, runningMean, '-b', t, airMean, '-r', 'linewidth', runLineWidth);
                end
            elseif plotMean == 2
                
            end
            
            for ns = 1:nSubPlots
                subplot(nSubPlots+plusNSubPlots, 1,ns+spoffset)
                if ns <= nSubPlots
                    s = stimIND(ns);
                end
                yyaxis left
                ylim([min(ylim) lTopLimit])
                
                line([obj.stims(s).finish - obj.stims(s).start, obj.stims(s).finish - obj.stims(s).start], [0, lTopLimit])
                %addPSHDecorations(stim, obj.stims(s).finish - obj.stims(s).start ,lTopLimit, 'StimUnderPlot', true)
                switch rasterPlot
                    case 1
                        PlotRasters_oneColor(raster(index == ns), index(index==ns),[-10, 15], max(ylim), 'RelativeSize', 0.1, 'position', rasterPos)
                end
                
                % Ploteo los estimulos
                yyaxis right
                if isfield(obj.stims,'reg')
                    %disp('reg es campo de stims')
                    if ~isempty(obj.stims(s).reg)
                        %disp('reg no esta vacio')
                        switch stimPlot
                            case 1
                                obj.plotShade(obj.stims(s).reg(:,1)',obj.stims(s).reg(:,2)','rigth',1,'stimmax',rTopLimit,'alpha',stimAlpha);
                            case 2
                                y = rTopLimit*obj.stims(s).reg(:,1)'/max(obj.stims(s).reg(:,1));
                                plot([-5 obj.stims(s).reg(:,2)' obj.stims(s).reg(end,2)'+5],[y(1) y y(end)],"--k");
                            case 3
                                obj.plotShade(obj.stims(s).reg(:,1)',obj.stims(s).reg(:,2)','rigth',1,'stimmax',rTopLimit*0.2,'alpha',stimAlpha,'yoffset',0.8*rTopLimit);
                        end
                    end
                end
                ylim([0 rTopLimit])
                
                %addPSHDecorations(stim, obj.ball.trial(s).duration, 40, 'stimUnderPlot', false, 'heigth', 0.2)
                xlim(xlimit)
                
            end
        end
        
        function [fig, corr] = plotCrossCorrBallEpys(obj,stimCode,cluster,varargin)
            binSize = 50;
            xlimi = [];
            bytrial = false;
            ballSpan = 10;
            ephysSpan = 10;
            method = 'loess';
            behavDelay = 10;
            titleTxt = [];
            behavior = 'tras';
            makeFig = true;
            nSP = 1;
            kSP = 1;
            runLineWidth = 2;
            ephysLineWith = 1;
            ephysLineType = '-';
            runLineType = '-';
            autotitle = false;
            diffCrossCorr = false;
            corr = [];
            rTopLimit= 0;
            fTopLimit= 0;
            windowCrosCorr = 6;
            plotData = false;
            mergeStims = 0;
            figPoss = [68     5   701   991];
            autoXLimit = false;
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'xlim'
                        xlimi = varargin{arg+1};
                    case 'binsize'
                        binSize = varargin{arg+1};
                    case 'title'
                        titleTxt = varargin{arg+1};
                    case 'behavior'
                        if sum(strcmp({'tras', 'rot', 'dir'}, varargin{arg+1}))==1
                            behavior = varargin{arg+1};
                        else
                            error('invalid "behavior", only "all", "ball" and "air" are permited')
                        end
                    case 'makefig'
                        makeFig = varargin{arg+1};
                    case 'smoothmethod'
                        method = varargin{arg+1};
                    case 'spanephys'
                        ephysSpan = varargin{arg+1};
                    case 'spanball'
                        ballSpan = varargin{arg+1};
                    case 'behavdelay'
                        behavDelay = varargin{arg+1};
                    case 'autotitle'
                        autotitle = varargin{arg+1};
                    case 'runlinewidth'
                        runLineWidth = varargin{arg+1};
                    case 'runlinetype'
                        runLineType = varargin{arg+1};
                    case 'ephyslinetype'
                        ephysLineType = varargin{arg+1};
                    case 'ephyslinewith'
                        ephysLineWith = varargin{arg+1};
                    case 'diffcrosscorr'
                        diffCrossCorr = varargin{arg+1};
                        nSP = 2;
                    case 'bytrial'
                        bytrial = varargin{arg+1};
                    case 'windowcroscorr'
                        windowCrosCorr = varargin{arg+1};
                    case 'plotdata'
                        plotData = varargin{arg+1};
                    case 'mergestims'
                        mergeStims = varargin{arg+1};
                    case 'figposs'
                        figPoss = varargin{arg+1};
                    case 'autoxlimit'
                        autoXLimit = varargin{arg+1};
                    otherwise
                        error(['invalid optional argument: ' varargin{arg}])
                end
            end
            
            kSP = kSP + plotData;
            
            if bytrial
                stimIND = stimCode;
            else
                stimIND = obj.getStimIndex(stimCode, 'condition', 'all');
            end
            
            if isempty(xlimi)
                maxStimLength = max([[obj.stims(stimIND).finish] - [obj.stims(stimIND).start]]);
                xlimit = [-10 maxStimLength+10];
            elseif ~autoXLimit
                xlimit = xlimi;
            end
            
            
            
            if isa(makeFig,'matlab.ui.Figure')
                fig = makeFig;
            elseif makeFig
                fig = figure('Renderer', 'painters', 'Position', [10 10 560 825]);
            else
                fig = findobj('Type','figure');
                fig = fig(end);
            end
            fig.Position = figPoss;
            
            if autotitle
                sgtitle([' Cluster: ' num2str(cluster) ...
                ' Date: ' obj.date ...
                ' ID: ' num2str(obj.crabID)]);
            elseif ~isempty(titleTxt)
                sgtitle(titleTxt)
            end
            
            nStims = length(stimIND);
            
            nXSP = (nSP*nStims)+(mergeStims*nSP);
            
            allData = [];
            
            for i = 1:nStims
                si = stimIND(i);
                % Datos de lectrofisiologia
                if autoXLimit
                    xlimit = [-10 obj.stims(stimIND).finish-obj.stims(stimIND).start+10];
                end
                nBins = round((xlimit(2)-xlimit(1))*(1000/binSize));
                [freq, tFrecs] = obj.neurons(cluster).getPSHbyIndex(xlimit, nBins,si, 'smoothspan', ephysSpan, 'smoothmethod', method);

                % Datos de crabola
                run = obj.ball.interpolateRuns(si, binSize/1000);
                
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
                               
                tRun = [run.time-behavDelay]';
                tRun(1) = [];
                runPar = smooth(runPar, ballSpan, method);
                runPar(1) = [];
             
                % acomodo el largo de los vectores
                if length(tRun)>length(tFrecs)
                    tRun(length(tFrecs)+1:end) = [];
                    runPar(length(freq)+1:end) = [];
                elseif length(tRun)<length(tFrecs)
                    tFrecs(length(tRun)+1:end) = [];
                    freq(length(runPar)+1:end) = [];
                end
                
                if diffCrossCorr
                    % Croscorelacion de las derivadas
                    % derivadas
                    diffRunPar = diff(runPar);
                    diffRunPar = smooth(diffRunPar, ballSpan, method);
                    diffRunPar = padarray(diffRunPar,[length(runPar)-length(diffRunPar) 0],0,"post");
                    diffFrecs = diff(freq);
                    diffFrecs = smooth(diffFrecs, ballSpan, method);
                    diffFrecs = padarray(diffFrecs,[length(freq)-length(diffFrecs) 0],0,"post");
                    
                    if isempty(allData)
                        allData = [tRun, runPar, freq, diffRunPar, diffFrecs];
                    else
                        allData = [allData; [tRun+allData(end,1), runPar, freq, diffRunPar, diffFrecs]];
                    end
                else
                    if isempty(allData)
                        allData = [tRun, runPar, freq];
                    else
                        allData = [allData; [tRun+allData(end,1), runPar, freq]];
                    end
                end
                
                % Figura de los datos a procesar
                figure(fig)
                
                if plotData
                    subplot(nXSP,kSP,1+(nSP*kSP*(i-1)))
                    yyaxis left
                    plot(tFrecs,freq,ephysLineType,'linewidth',ephysLineWith)
                    ylabel("Run [cm/s]")
                    ylim([0 max(freq)])
                    yyaxis right
                    plot(tRun,runPar,runLineType,'linewidth',runLineWidth)
                    ylabel("Ephys [Hz]")
                    ylim([0 max(runPar)])
                    if autotitle
                        title(['Filtered Data: Stm: ' num2str(obj.stims(si).code) ...
                            ' Tri: ' num2str(si) ...
                            ' Scr: ' num2str(obj.stims(si).screen)]);
                    end
                end
                
                % CrossCorrelacion
                [xcf, lags, bound] = obj.crosscorr(runPar,freq,'window',windowCrosCorr,'binsize',binSize);

                subplot(nXSP,kSP,kSP+(nSP*kSP*(i-1)))
                hold on
                stairs(lags*binSize/1000,xcf);
                yline(bound(1),'r',['s = ' num2str(bound(1),2)]);

                [maxXcf, maxXcfInd] = max(xcf);
                [minXcf, minXcfInd] = min(xcf);
                
                if abs(maxXcf) < abs(minXcf)
                   maxXcf = minXcf;
                   maxXcfInd = minXcfInd;
                end
                if maxXcf<0
                   ylim([maxXcf*1.5 -maxXcf*1.5])
                else
                    ylim([-maxXcf*1.5 maxXcf*1.5])
                end
                
                tMaxXcf = lags(maxXcfInd)*binSize/1000;
                
                xctlh = xline(tMaxXcf,'b',{'t = ', num2str(tMaxXcf,2)});
                yctlh = yline(maxXcf,'g',{'r = ', num2str(maxXcf,2)});

                fixHLineText(xctlh,8,[-windowCrosCorr windowCrosCorr],[0 1],tMaxXcf,maxXcf);
                fixHLineText(yctlh,8,[-windowCrosCorr windowCrosCorr],[0 1],tMaxXcf,maxXcf);
                
                ylim([-1 1])
                ylabel('p Value')
                xlabel('t [s]')
                corr = [corr;si maxXcf  tMaxXcf];
                disp(['Maxcorr=' num2str(maxXcf) ' t=' num2str(tMaxXcf)]);
                
                if autotitle
                    title(['Cross-Correlogram: Stm: ' num2str(obj.stims(si).code) ...
                            ' Tri: ' num2str(si) ...
                            ' Scr: ' num2str(obj.stims(si).screen)]);
                end

                if diffCrossCorr
                    % ploteo datos

                    if plotData
                        subplot(nXSP,kSP,3+(nSP*kSP*(i-1)))
                        yyaxis left
                        plot(tFrecs,diffFrecs,ephysLineType,'linewidth',ephysLineWith)
                        ylabel("Run [cm/s²]")
                        ylim([-max(diffFrecs)*1.5 max(diffFrecs)*1.5])
                        yyaxis right
                        plot(tRun,diffRunPar,runLineType,'linewidth',runLineWidth)
                        ylabel("Ephys [dHz]")
                        ylim([-max(diffRunPar)*1.5 max(diffRunPar)*1.5])
                        xlabel('t [s]')
                        if autotitle
                            title(['Filtered Data: Stm: ' num2str(obj.stims(si).code) ...
                            ' Tri: ' num2str(si) ...
                            ' Scr: ' num2str(obj.stims(si).screen)]);
                        end
                    end
                    
                    % croscorelacion
                    [diffXcf, diffLags, diffBound] = obj.crosscorr(runPar,freq,'window',windowCrosCorr,'binsize',binSize);
                    
                    subplot(nXSP,kSP,(2*kSP)+(nSP*kSP*(i-1)))
                    hold on
                    stairs(diffLags*binSize/1000,diffXcf);
                    yline(diffBound(1),'r',['-s = ' num2str(-bound(2),2)]);
                    [maxXcf, maxXcfInd] = max(diffXcf);
                    [minXcf, minXcfInd] = min(diffXcf);
                    
                    if abs(maxXcf) < abs(minXcf)
                       maxXcf = minXcf;
                       maxXcfInd = minXcfInd;
                    end
                    if maxXcf<0
                       ylim([maxXcf*1.5 -maxXcf*1.5])
                    else
                        ylim([-maxXcf*1.5 maxXcf*1.5])
                    end
                    tMaxXcf = lags(maxXcfInd)*binSize/1000;
                    
                    xctlh = xline(tMaxXcf,'b',{'t = ', num2str(tMaxXcf,2)});
                    yctlh = yline(maxXcf,'g',{'r = ', num2str(maxXcf,2)});
                    
                    fixHLineText(xctlh,8,[-windowCrosCorr windowCrosCorr],[-maxXcf*1.5 maxXcf*1.5],tMaxXcf,maxXcf);
                    fixHLineText(yctlh,8,[-windowCrosCorr windowCrosCorr],[-maxXcf*1.5 maxXcf*1.5],tMaxXcf,maxXcf);
                    
                    ylabel('p Value')
                    xlabel('t [s]')
                    

                    if autotitle
                        title(['Cross-Correlogram: Stm: ' num2str(obj.stims(si).code) ...
                            ' Tri: ' num2str(si) ...
                            ' Scr: ' num2str(obj.stims(si).screen)]);
                    end
                    
                    disp(['MaxDiffCorr=' num2str(maxXcf) ' t=' num2str(lags(maxXcfInd)*binSize/1000)]);
                    corr = [corr; si maxXcf lags(maxXcfInd)*binSize/1000];
                end
            end
            if mergeStims
                if plotData
                    subplot(nXSP,kSP,1+(nSP*kSP*(i)))
                    yyaxis left
                    plot(allData(:,1),allData(:,3),ephysLineType,'linewidth',ephysLineWith)
                    ylabel("Run [cm/s]")
                    ylim([0 max(allData(:,3))])
                    yyaxis right
                    plot(allData(:,1),allData(:,2),runLineType,'linewidth',runLineWidth)
                    ylabel("Ephys [Hz]")
                    ylim([0 max(allData(:,2))])
                    if autotitle
                        title('All stim filtered Data');
                    end
                end
                [xcf, lags, bound] = obj.crosscorr(allData(:,2),allData(:,3),'window',windowCrosCorr,'binsize',binSize);

                subplot(nXSP,kSP,kSP+(nSP*kSP*(i)))
                stairs(lags*binSize/1000,xcf);
                yline(bound(1),'r',['s = ' num2str(bound(1),2)]);
                hold on 
                
                [maxXcf, maxXcfInd] = max(xcf);
                [minXcf, minXcfInd] = min(xcf);
                
                if abs(maxXcf) < abs(minXcf)
                   maxXcf = minXcf;
                   maxXcfInd = minXcfInd;
                end
                if maxXcf<0
                   ylim([maxXcf*1.5 -maxXcf*1.5])
                else
                    ylim([-maxXcf*1.5 maxXcf*1.5])
                end
                tMaxXcf = lags(maxXcfInd)*binSize/1000;
%                 scatter(lags(maxXcfInd)*binSize/1000,maxXcf*1.2,'v');
                xctlh = xline(tMaxXcf,'b',{'t = ', num2str(tMaxXcf,2)});
                yctlh = yline(maxXcf,'g',{'r = ', num2str(maxXcf,2)});

                fixHLineText(xctlh,8,[-windowCrosCorr windowCrosCorr],[0 1],tMaxXcf,maxXcf);
                fixHLineText(yctlh,8,[-windowCrosCorr windowCrosCorr],[0 1],tMaxXcf,maxXcf);
                    
                ylim([-1 1])
                
                if autotitle
                    title(['All stim Cross-Correlation'])
                end
                
                corr = [corr;0 maxXcf lags(maxXcfInd)*binSize/1000];
                disp(['Maxcorr=' num2str(maxXcf) ' t=' num2str(lags(maxXcfInd)*binSize/1000)]);
                
                
                
                if diffCrossCorr
                    if plotData
                        subplot(nXSP,kSP,3+(nSP*kSP*(i)))
                        yyaxis left
                        plot(allData(:,1),allData(:,5),ephysLineType,'linewidth',ephysLineWith)
                        ylabel("Run [cm/s²]")
                        ylim([-max(allData(:,5)) max(allData(:,5))])
                        yyaxis right
                        plot(allData(:,1),allData(:,4),runLineType,'linewidth',runLineWidth)
                        ylabel("Ephys [dHz]")
                        ylim([-max(allData(:,4)) max(allData(:,4))])
                        if autotitle
                            title('All stim filtered differential Data');
                        end
                    end
                    
                    % croscorelacion
                    [diffXcf, diffLags, diffBound] = obj.crosscorr(allData(:,4),allData(:,5),...
                                                                    'window',windowCrosCorr,'binsize',binSize);
                    subplot(nXSP,kSP,2*kSP+(nSP*kSP*(i)))
                    stairs(diffLags*binSize/1000,diffXcf);
                    yline(diffBound(1),'r',['s = ' num2str(diffBound(1),2)]);
                    [maxXcf, maxXcfInd] = max(diffXcf);
                    [minXcf, minXcfInd] = min(diffXcf);
                    hold on
                    if abs(maxXcf) < abs(minXcf)
                       maxXcf = minXcf;
                       maxXcfInd = minXcfInd;
                    end
                    tMaxXcf = lags(maxXcfInd)*binSize/1000;
                    xctlh = xline(tMaxXcf,'b',{'t = ', num2str(tMaxXcf,2)});
                    yctlh = yline(maxXcf,'g',{'r = ', num2str(maxXcf,2)});
                    
                    fixHLineText(xctlh,8,[-windowCrosCorr windowCrosCorr],[-maxXcf*1.5 maxXcf*1.5],tMaxXcf,maxXcf);
                    fixHLineText(yctlh,8,[-windowCrosCorr windowCrosCorr],[-maxXcf*1.5 maxXcf*1.5],tMaxXcf,maxXcf);
                    if maxXcf<0
                    	ylim([maxXcf*1.5 -maxXcf*1.5])
                    else
                        ylim([-maxXcf*1.5 maxXcf*1.5])
                    end
                    
                    if autotitle
                        title(['All stim differential Cross-Correlation'])
                    end
                    
                    disp(['MaxDiffCorr=' num2str(maxXcf) ' t=' num2str(lags(maxXcfInd)*binSize/1000)]);
                    corr = [corr; 0 maxXcf lags(maxXcfInd)*binSize/1000];
                end
            end
            
        end
        
        function [xcf, lags, bound] = crosscorr(obj,x1,x2,varargin)
            windowCrosCorr = 6;%s
            numStd = 3;
            binSize = 50;
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'window'
                        windowCrosCorr = varargin{arg+1};
                    case 'numstd'
                        numStd = varargin{arg+1};
                    case 'binsize'
                        binSize = varargin{arg+1};
                end
            end
            
            numLags = round(windowCrosCorr*1000/binSize);
            [xcf,lags,bound] = crosscorr(x1,x2,'NumLags',numLags,'NumSTD',numStd);
        end
        
        function means = getStimClusterMean(obj,stimCode,cluster,varargin)
            condition = 'all';
            screens = [];
            stimIND = [];
            useSmooth = false;
            ephysSpan = 5;
            ballSpan = 5;
            method = 'moving';
            binSize = 50;
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
                    case 'smooth'
                        useSmooth = varargin{arg+1};
                    case 'spanephys'
                        ephysSpan = varargin{arg+1};
                    case 'spanball'
                        ballSpan = varargin{arg+1};
                    case 'smoothmethod'
                        method = varargin{arg+1};
                    case 'binsize'
                        binSize = varargin{arg+1};
                    case 'trials'
                        stimIND = varargin{arg+1};
                end
            end
            
            if isempty(stimIND)
                stimIND = obj.getStimIndex(stimCode, 'condition', condition, 'screens', screens);
            end
            
            means = obj.ball.getStimsMean(stimIND,'smooth', useSmooth, 'span', ballSpan, 'smoothmethod', method, 'binsize',binSize);
            [meansFreq, tFreq] = obj.neurons(cluster).getStimsMean(stimIND,binSize,'smoothmethod',method,...
                'spanephys',ephysSpan,'usesmooth',useSmooth);
            means.meansFreq = meansFreq';
            
            if means.time(1) < tFreq(1)
                [~,minI] = nearestValue(means.time,tFreq(1));
                if minI > 1
                    means.time = means.time(minI:end);
                    means.vRot = means.vRot(minI:end);
                    means.vTras = means.vTras(minI:end);
                    means.vX1 = means.vX1(minI:end);
                    means.vX2 = means.vX2(minI:end);
                    means.dir = means.dir(minI:end);
                end
            elseif means.time(1) > tFreq(1)
                [~,minI] = nearestValue(tFreq,means.time(1));
                means.meansFreq = means.meansFreq(minI:end);
                tFreq = tFreq(minI:end);
            end
            if means.time(end) > tFreq(end)
                [~,maxI] = nearestValue(means.time,tFreq(end));
                if maxI < length(means.time)
                    means.time = means.time(1:maxI);
                    means.vRot = means.vRot(1:maxI);
                    means.vTras = means.vTras(1:maxI);
                    means.vX1 = means.vX1(1:maxI);
                    means.vX2 = means.vX2(1:maxI);
                    means.dir = means.dir(1:maxI);
                end
            elseif means.time(end) < tFreq(end)
                [~,maxI] = nearestValue(tFreq,means.time(end));
                if maxI < lenght(tFreq)
                    means.meansFreq = means.meansFreq(1:maxI);
                    tFreq = tFreq(1:maxI);
                end
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
            
            fileList = dir(path);
            %cargo los estimulos
            if any(contains({fileList.name},'Estimulos.mat'))
                load('Estimulos.mat');
            else
                disp('No existe Estimulos.mat en este directorio')
                [filename, pathname] = uigetfile('Estimulos.mat','/media/usuario/Disco/Usuario/Desktop/Matias/Datos');
                load(fullfile(pathname,filename))
            end
            %cargo los monitores
            if any(contains({fileList.name},'Monitores.mat'))
                load('Monitores.mat');
            else
                disp('No existe Monitores.mat en este directorio')
                [filename, pathname] = uigetfile('Monitores.mat','/media/usuario/Disco/Usuario/Desktop/Matias/Datos');
                load(fullfile(pathname,filename))
            end

            % Levanto los datos de los clusters
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
            
            %Cargo los registros de los estimulos si es que existen
            fileMask = contains({files.name},'RegStims.mat');
            if sum(fileMask)==1
                load(files(fileMask).name);
            elseif sum(fileMask)>1
                error('More than one RegStims.mat')
            else
                stimsRegs = cell(legnth(Estimulos),1);
            end
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
                neuron.EstReg = stimsRegs;
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
            %seleccionado bajo el campo de "fRates". El vector de tiempo en
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
        
        function est = plotShade(obj,var,t,varargin)
            YOffset = 0;
            stimMax = 1;
            tiempos = [-5 5];
            alpha = 0.5;
            rigth = 0;
            lColor = [];
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'stimmax'
                        stimMax = varargin{arg+1};
                    case 'lcolor'
                        lColor = varargin{arg+1};
                    case 'rigth'
                        rigth = varargin{arg+1};
                    case 'alpha'
                        alpha = varargin{arg+1};
                    case 'yoffset'
                        YOffset = varargin{arg+1};
                    otherwise
                        error(['invalid optional argument: ' varargin{arg}])
                end
            end

            var = reshape(var,1,[]);
            t = reshape(t,1,[]);
            
            if rigth
                yyaxis right
            else
                yyaxis left
            end

            xconf = [tiempos(1) t t(end)+tiempos(2) t(end)+tiempos(2) tiempos(1)];
            yconf = ((var/max(var))*stimMax)+YOffset;
            yconf = [yconf(1) yconf yconf(end) YOffset YOffset];
            
            if isempty(lColor)
                est = fill(xconf,yconf,[0 0 0]);
            else
                est = fill(xconf,yconf,lColor);
            end
            est.EdgeColor = 'none';
            est.FaceAlpha = alpha;
        end
        
    end
    
    
end
