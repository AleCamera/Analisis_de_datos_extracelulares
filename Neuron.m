classdef Neuron
    properties 
        name string;
        folder string;
        cluster;
        data;
        waveform;
        t_waveform;
        AC struct;
        stims struct;
        group struct;
    end
    methods
        %constructor from old data set
        function obj = Neuron(neu)
            if nargin == 0
                obj.name = '';
                obj.folder = '';
                obj.cluster = [];
                obj.data = [];
                obj.waveform = [];
                obj.t_waveform = [];
                obj.AC = struct('bins', [],...
                    'count', [],...
                    'trend', []);
                obj.stims = struct('code', [], ...
                    'start', [], ...
                    'finish', [], ...
                    'screen', []);
                obj.group = struct('name', '', ...
                    'file', '');
                
            else
                obj.name = neu.name;
                obj.folder = neu.file;
                obj.cluster = neu.cluster;
                obj.data = neu.data;
                if isfield(neu, 'waveform')
                    obj.waveform = neu.waveform;
                    obj.t_waveform = [];
                elseif obj.cluster > 1
                    [obj.t_waveform, obj.waveform] = obj.getWaveforms();
                else
                    obj.waveform =  [];
                    obj.t_waveform = [];
                end
                if isfield(neu, 'ACbins') && isfield(neu, 'ACcount') && isfield(neu, 'ACtrend')
                    obj.AC = struct('bins', neu.ACbins,...
                        'count', neu.ACcount,...
                        'trend', neu.ACtrend);
                else
                    obj.AC = struct('bins', [],...
                        'count', [],...
                        'trend', []);
                end
                if isfield(neu, 'Estimulos')
                    for s = 1:length(neu.Estimulos)
                        stimList(s) = struct('code', neu.Estimulos(s,1), ...
                            'start', neu.Estimulos(s,2), ...
                            'finish', neu.Estimulos(s,3), ...
                            'screen', neu.Monitores(s),...
                            'running', false);
                    end
                    obj.stims = stimList;
                else
                    obj.stims = struct('code', [], ...
                        'start', [], ...
                        'finish', [], ...
                        'screen', []);
                end
                if isfield(neu, 'group')
                    obj.group = struct('name', neu.group.name, ...
                        'file', neu.group.file);
                else
                    obj.group = struct('name', '', ...
                        'file', '');
                end
            end
        end
        
        function stimIND = getStimIndex(obj, stimCodes, varargin)
            rigthScreen = true;
            leftScreen = true;
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'rigthscreen'
                        rigthScreen = varargin{arg+1};
                    case 'leftscreen'
                        leftScreen = varargin{arg+1};
                end
            end
            %find selected stims
            stimIND = find(ismember([obj.stims.code], stimCodes));
            %if there are no screens selected o no stims match the codes
            if (~leftScreen && ~rigthScreen) || isempty(stimIND) 
                stimIND = [];
                return
            %ignore the stims of the unselected screens
            elseif rigthScreen && ~leftScreen
                for s = flip(1:length(stimIND))
                    if obj.stim(stimIND(s)).screen ~= 'D'
                        stimIND(s) = [];
                    end
                end
            elseif ~rigthScreen && leftScreen
                for s = flip(1:length(stimIND))
                    if obj.stims(stimIND(s)).screen ~= 'I'
                        stimIND(s) = [];
                    end
                end
            end
           
        end
        
        function dur = getMeanStimDuration(obj, stimCode, varargin)
            stimIndex = [];
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'stimindex'
                        stimIndex = varargin{arg+1};
                end
            end
            if isempty(stimIndex)
                stimIND = obj.getStimIndex(stimCodes);
            else
                stimIND = stimIndex;
            end
            startTimes = [obj.stims(stimIND).start];
            finishTimes = [obj.stims(stimIND).finish];
            dur = mean(finishTimes - startTimes);
        end
        
        function [raster, index, stimList] = getRasters(obj, stimCodes, varargin)
            %me devuelve un vector 'rasters' con los tiempos de cada spike
            % un vector 'index' con el numero de trial de cada spike y una
            % struct 'stimList' con los datos de cada trial
            
            % 'durations' es un vector de dos celdas de largo que tiene el
            % numero de segundos a tener en cuenta antes del inicio del
            % estimulo y el numero de segundos despues
            
            % 'screens' es un vector de dos booleanos que define si quiero
            % la pantalla izquierda (T-F), la derecha(F-T) o las dos(T-T)
            
            % 'StimIndex' reeemplaza a el codigo del estimulo por el trial
            % (ejemplo, tal vez solo me interesan los trials 2 y 7)
            % entonces 'stimindex' seria [2 7].
            durations = [1 4];
            selectedScreens = [true true];
            stimIndex = [];
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'durations'
                        durations = varargin{arg+1};
                    case 'screens'
                        if length(varargin{arg+1}) ~= 2
                            error('screens must have 2 values')
                        else
                            selectedScreens =  varargin{arg+1};
                        end
                    case 'stimindex'
                        stimIndex = varargin{arg+1};
                end
            end
            if isempty(stimIndex)
                stimIND = obj.getStimIndex(stimCodes, 'RigthScreen', selectedScreens(1), 'LeftScreen', selectedScreens(2));
            else
                stimIND = stimIndex;
            end
            stimList = obj.stims(stimIND);
            
            nTrials = length(stimIND); %total amount of trials
            if nTrials == 0
                warning(strcat('No trials for those stimuli in the neuron ', obj.name))
                raster=[];
                index=[];
                return
            end
            
            startTimes = [obj.stims(stimIND).start];
            finishTimes = [obj.stims(stimIND).finish];
            
            %now we need to find the longest trial and set that duration
            %for all trials
            longestTrial = max(finishTimes - startTimes);
            %we add the post stimulus time to the max duration.
            maxDuration = longestTrial + durations(2);
            raster = [];
            index = [];
            for t = 1:nTrials
                start = startTimes(t);
                trialRaster = Sync(obj.data, start,'durations',[-durations(1); maxDuration]);
                raster = [raster ; trialRaster];
                index = [index; (zeros(length(trialRaster), 1)+ t)];
            end
        end
        
        function [freq, t] = getPSH(obj, raster, index, bounds, nBins, varargin)
            span = 5;
            method = 'moving';
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'smoothspan'
                        span = varargin{arg+1};
                    case 'smoothmethod'
                        method = varargin{arg+1};
                end
            end
            [freq,~] = SyncHist(raster, index,'mode', 'mean' ,'durations',...
                                bounds, 'nBins', nBins);
            if strcmp('gaussian',method)
                w = gausswin(span, 2.5);
                w = w/sum(w);
                freq = filtfilt(w, 1, freq);
            else
                freq = smooth(freq, span, method);
            end
            t = (bounds(1):(bounds(2) - bounds(1))/(nBins):bounds(2))';
            t = t(2:end);
        end
        
        function screens = getScreens(obj, stimCode)
            stimIND = obj.getStimIndex(stimCode);
            for ind = 1:length(stimIND)
                screens(ind) = obj.stims(stimIND(ind)).screen;
            end
        end
        
        function has = hasScreens(obj, stimCode, screen)
            screens = obj.getScreens(stimCode);
            has = sum(strcmp(screens, screen));
        end
        
        
        function [t_waves, waves] = getWaveforms(obj)
            %getWaveforms carga la waveform promedio del cluster.
            
            %assignin('base', 'obj', obj);
            
            %[FileName,~,~] = uigetfile('*.spkDAT.mat','Seleccione archivo *spkDAT.mat para usar');
            fullSegLen = 7; %ms
            finalSegLen = 4.5; %ms
            minPeakInd = 1.5; %ms
            maxPeakInd = minPeakInd + (fullSegLen - finalSegLen);
            fileList = dir;
            assignin('base', 'fileList',fileList);
            for f = 1:length(fileList)
                if contains(fileList(f).name, '_SPK_')
                    FileName = char(fileList(f).name);
                    break
                elseif f == length(fileList)
                    disp('I can find the _SPK_ file, we need to generate it')
                    disp('creating _SPK_ file...')
                    GetSPKWF('type', 'fil', 'length', fullSegLen)
                    [FileName,~,~] = uigetfile('*.mat','Seleccione archivo *_SPK_fil.mat para usar');
                end
            end
            load(FileName);
            
            [nWavePoints, nElectrodes, nSpikes] = size(Spk.Segs);
            %nWavePoints
            if length(Spk.CluID) > nSpikes
                Spk.CluID = Spk.CluID(1:nSpikes);
            end
            for clu = min(Spk.CluID):max(Spk.CluID)
                spkIndx = find(Spk.CluID == clu);
                for elec = 1:nElectrodes
                    for spk = 1:length(spkIndx)
                        try
                            cluster{clu}(elec).voltage(:,spk) = Spk.Segs(:, elec, spkIndx(spk));
                        catch ME
                            clu
                            elec
                            spk
                            assignin('base', 'spkIndx', spkIndx)
                            rethrow(ME)
                        end
                    end
                    %aplico un detrend para remover el offset que hay por los LFPs
                    cluster{clu}(elec).voltage = detrend(cluster{clu}(elec).voltage);
                end
            end
            
            %Busco el electrodo donde la señal sea mas grande
            bestCh = zeros(max(Spk.CluID),1);
            maxSpike = zeros(max(Spk.CluID),1);
            for clu = min(Spk.CluID):max(Spk.CluID)
                for elec = 1:nElectrodes
                    if max(abs(mean(cluster{clu}(elec).voltage'))) > maxSpike(clu)
                        maxSpike(clu) = max(abs(mean(cluster{clu}(elec).voltage')));
                        bestCh(clu) = elec;
                    end
                end
            end
            
            %Ahora corrijo señales corridas
            spks = [];
            discarted = 0;
            binSize = 1000 / Spk.sampleRate;
            t = 0:binSize:(fullSegLen - binSize);
            clu = obj.cluster;
            elec = bestCh(clu);
            [~, totalSpks] = size(cluster{clu}(elec).voltage);
            for spkInd = 1:totalSpks 
                %spkInd
                %clu
                spk = cluster{clu}(elec).voltage(:,spkInd);
                peakInd = find(spk == min(spk));
                t_peak = t(peakInd);
                if length(t_peak > 1)
                    t_peak = t_peak(1);
                end
                if t_peak > minPeakInd && t_peak < maxPeakInd
                    sampleDiffs = round((t_peak - minPeakInd)/binSize);
                    %sampleDiffs
                    %sampleDiffs + (round(finalSegLen/binSize))
                    %size(spk)
                    newSpk = spk(sampleDiffs : sampleDiffs + (round(finalSegLen/binSize)));
                    %size(newSpk)
                    spks(:,end+1) = newSpk;
                else
                    discarted = discarted+1;
                    continue;
                end
            end
            disp(['From cluster ' num2str(clu) ' I have discarted ' num2str(discarted) ' of a total of' num2str(totalSpks) ' spikes'])
            waves = mean(spks, 2);
            waves = waves(1:end-1);
            t_waves = (0:binSize:(finalSegLen - binSize))';
            %figure
            %plot(cluster{nCluster}(bestCh(nCluster)).voltage(:,randi(length(cluster{nCluster}(bestCh(nCluster)).voltage), 1, 20)))
            %waves = mean(cluster{obj.cluster}(bestCh(obj.cluster)).voltage');
        end
        
        function plotPSH(obj, stimIndex, bounds, nBins, varargin)
            % plotPSH toma un array de indices de estimulos a plotear y los
            % grafica.
            
            %   stimIndex    --> vector de indices de estimulos a plotear
            
            %   bounds       --> vector con el numero de segundos antes y
            %                    numero de segundos despues de inicio del
            %                    estimulo
             
            %   nBins        --> numero de bines a usar para el PSH
            
            % Argumentos optativos:
            
            %   rasters      --> agrega los rasters
            
            %   pshcolor     --> setea el color del trazo del PSH
            
            %   rasterColor  --> setea el colo del raster
            
            %   smoothSpan   --> cuantos bines se usan para la ventana movil
            %                   que suaviza la curva del PSH
            
            %   relativeSize --> sete el tamaño relativo que va a ocupar el
            %                    raster
            
            %   rasterArgs   --> cell array con los argumentos optativos 
            %                    para pasarle a la funcion 
            %                    "PlotRasters_oneColor" (ver su
            %                    documentacion)
            
            addRasters = false;
            pshColor = [0 0 0];
            rasterColor = [0 0 0];
            relativeSize = 0.2;
            span = 5;
            rasterArgs = {};
            pshArgs = {};
            method = 'moving';
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'rasters'
                        addRasters = varargin{arg+1};
                    case 'pshcolor'
                        pshColor = varargin{arg+1};
                    case 'rastercolor'
                        rasterColor = varargin{arg+1};
                    case 'smoothspan'
                        span = varargin{arg+1};
                    case 'relativesize'
                        relativeSize = varargin{arg+1};
                    case 'rasterargs'
                        rasterArgs = varargin{arg+1};
                    case 'smoothmethod'
                        method = varargin{arg+1};
                    case 'pshargs'
                        pshArgs = varargin{arg+1};
                    otherwise
                        error(['there is no propertie called' varargin{arg}])
                end
            end
 
            [raster, index, ~] = obj.getRasters([], 'durations',...
                                        bounds, 'stimIndex', stimIndex);
                                    
            [freq, time] = obj.getPSH(raster, index, [-bounds(1) bounds(2)], nBins, 'smoothSpan', span, 'smoothmethod', method);
            
            plot(time, freq, 'linewidth', 1.5, 'color', pshColor);
            
            yLimits = ylim;
            maxFreq = yLimits(2);

            if addRasters
                hold on
                if ~isempty(rasterArgs)
                    PlotRasters_oneColor(raster, index, [-bounds(1) bounds(2)],maxFreq, rasterArgs{:});
                else
                    PlotRasters_oneColor(raster, index, [-bounds(1) bounds(2)],...
                                         maxFreq, 'Color',  rasterColor,...
                                         'position', 'top', ...
                                         'relativeSize', relativeSize);
                end
            end
        end
        
        function [sFreq] = getSpontaneousFreqs(obj, t_prev, stim, varargin)
            % devuelve un struct con las frecuencias de disparo para cada
            % estimulo en el campo "freqs", la media de esas frecuencias en
            % el campo "means", el desvio en el campo "std" y el error
            % estandar en el campo "err".                                  
            % "t_prev" es el tiempo previo al inicio del estímulo en
            % segundos
            % "stim" es la lista de estimulo deseados
            % argumentos optativos:
            %
            % stimindex --> vector de indices. La función ignora a "stim" y 
            %               pasa a devolver a los estimulos cuyos indices 
            %               sean los del vector.
            
            stimIND = [];
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'stimindex'
                        stimIND = varargin{arg+1};
                end
            end
            
            
            t_before_start = 5; %secs
            nBins = 200;
            if isempty(stimIND)
                stimIND = obj.getStimIndex(stim);
            end
            ns = 0;
            sFreq.freqs = [];
            for ind = stimIND
                ns = ns+1;
                [raster, index, ~] = obj.getRasters([], 'durations',...
                    [t_prev, 1], 'stimIndex', ind);
                [freq, t] = getPSH(obj, raster, index, [-t_prev, 1], nBins);
                if isempty(freq)
                    ns = ns-1;
                else
                    sFreq.freqs(ns) = mean(freq(t < -(t_before_start+0.5)));
                end
            end
            sFreq.mean = mean(sFreq.freqs);
            sFreq.std = std(sFreq.freqs);
            sFreq.err = sFreq.std / sqrt(length(stimIND));
            
            
            
        end
        
    end
end
