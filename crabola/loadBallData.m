function md = loadBallData(path, varargin)

    %Factor de converción de unidades de mouse a cm
    %convK = 0.00661;
    % ver script de calibracion para correcciones
    convK = [0.006566 0.006696 0.005542 0.005551];

    %diametro = 20.5;
    diametro = 20.849;
    
    % keywords = {'crabola', 'data'};
    keyword_old = 'crabola';
    keyword_new = 'data';
    keyword_adjust = 'log_';
    keyword_t0 = 't0';
    keyword_tails = 'tails';
    multi = false;
    format = 0;
    filter = 0;
    for arg = 1:2:length(varargin)
        switch lower(varargin{arg})
            case 'factor'
                convK = varargin{arg+1};
            case 'diameter'
                diametro = varargin{arg+1};
            case 'keyword'
                keywords = varargin{arg+1};
            case 'multi'
                multi = varargin{arg+1};
            case 'filter'
                filter = varargin{arg+1};
        end
    end

    cd(path)
    files = dir;
    if multi
        nFiles = 0;
        for f = 1:length(files)
            name = string(files(f).name);
            if name.contains(keyword_old)
                nFiles = nFiles+1;
                file_multi(nFiles) = name;
                format = 0;
                %old_format = true;
            elseif name.contains(keyword_new)
                nFiles = nFiles+1;
                file_multi(nFiles) = name;
                format = 1;
                %old_format = false;
            end
            if f == length(files) && nFiles == 0
                error('I cannot find the crabola data file');
            end
        end
    else
        nFiles = 1;
    end

    % Exploro los nombres de los archivos extrayendo el nombre de los
    % correctos
    file = [];
    adjustFile = [];
    t0File = [];
    tailsFile = [];
    for f = 1:length(files)
        name = string(files(f).name);
        if name.contains(keyword_old) && isempty(file)
            file = name;
            format = 0;
            disp('asumo formato: old')
            %old_format = true;
        elseif name.contains(keyword_new) && isempty(file)
            file = name;
            format = 1;
            disp('asumo formato: new')
            %old_format = false;
        end
        if name.contains(keyword_adjust)
            adjustFile = name;
            disp('se encontro log')
        end
        if name.contains(keyword_t0)
            t0File = name;
            disp('se encontro t0')
        end
        if name.contains(keyword_tails)
            tailsFile = name;
            disp('se encontro tails')
        end
        if name.contains('timeStamps.txt')
            tsFile = fullfile(path, name);
            disp('se encontro timeStamps')
        end
        if f == length(files)>0 && isempty(file)
            error('I cannot find the crabola data file');
        end
    end

    %preparo un ID vacio
    crabID = '';
    for i = 1:nFiles
        if multi
            file = file_multi(i);
        end
        switch format
            case 0 %old
                %levanto los datos en el formato viejo
                rawData = csvread(fullfile(path, file));
                %genero el vector de tiempos
                time = rawData(:,5) + (rawData(:,6)/1000000);
                time = time - time(1,1);

                %busco los índices de inicio y final de cada estímulo.
                stimStartIND = find(rawData(:,1) == 130);
                stimFinishIND = find(rawData(:,1) == 131);
                nStims = length(stimStartIND);

                %me fijo los tiempos de inicio y final de cada estímulo
                stimStart = time(stimStartIND);
                stimFinish = time(stimFinishIND);

                %Genero el una matriz con los datos del mouse
                miceData(:,1:4) = rawData(:,1:4);
                %elimino las marcas de inicio y final los datos de mouse y de los tiempos:
                for n = nStims:-1:1
                    time(stimFinishIND(n)) = [];
                    time(stimStartIND(n)) = [];
                    miceData = removerows(miceData, 'ind', stimFinishIND(n));
                    miceData = removerows(miceData, 'ind', stimStartIND(n));
                end
            case 1 %new
                %levanto los datos en el formato nuevo
                dataTable = readtable(file);
                miceData = [dataTable.x1, dataTable.y1, dataTable.x2, dataTable.y2];
                %cargo el vector tiempos
                time = dataTable.time;

                %Cargo el ID en el caso de estar presente
                fileParts = file.split('-');
                for p = 1:length(fileParts)
                    part = char(fileParts(p));
                    if length(part) > 2 && contains(part,'ID') 
                        crabID = part(3:end);
                    end
                end

                %Ahora busco el archivo de los timeStamps
                tsTable = readtable(tsFile);
                stimStart = tsTable.t_start;
                stimFinish = tsTable.t_finish;

                nStims = length(stimStart);
                
                %correccion temporal
                if ~isempty(tailsFile) && ~isempty(t0File)
                    disp(['Se corregiran los tiempos usando tails'])
                    % Importo la tabla de tails
                    opts = delimitedTextImportOptions("NumVariables", 4);
                    opts.DataLines = [2, Inf];
                    opts.Delimiter = ",";
                    opts.VariableNames = ["code", "t_start", "code1", "t_finish"];
                    opts.VariableTypes = ["double", "duration", "double", "duration"];
                    opts = setvaropts(opts, "t_start", "InputFormat", "hh:mm:ss.SSSSSS");
                    opts = setvaropts(opts, "t_finish", "InputFormat", "hh:mm:ss.SSSSSS");
                    opts = setvaropts(opts, ["code", "code1"], "DecimalSeparator", ",");
                    correctionTable = readtable(tailsFile,opts);
                    % Elimino el codigo 0 que es el cierre
                    if correctionTable.code(end) == 0
                        correctionTable(end,:) = [];
                        disp('Tabla de tails completa')
                    else
                        error('La tabla de tails esta incompleta')
                    end
                    nCorrStim = height(correctionTable);
                    t0 = readtable(t0File);
                    t0 = t0.Var1 + seconds(t0.Var2/1e+6);
                    t0.Format = 'hh:mm:ss.SSSSSS';
                    if nCorrStim == nStims
                        startCorrected = seconds([correctionTable.t_start]-t0);
                        finishCorrected = seconds([correctionTable.t_finish]-t0);
                    else
                        error('tails y timestamps no contienen la misma cantidad de entradas')
                    end
                    if max(abs(stimStart - startCorrected))<0.3
                        stimStart = startCorrected;
                        stimFinish= finishCorrected;
                    else
                        fprintf('Hay un error mayor a 0.3s, verifique las correcciones \n');
                        fprintf('  | -------------   Start   --------- || ------------   Finish   --------- \n')
                        fprintf('N | Corrected | Registro  | Diferencia || Corrected | Registro  | Diferencia \n')
                        fprintf('--| --------- | --------- | ---------- || --------- | --------- | ----------\n')
                        for i = 1:max([nCorrStim nStims])
                            fprintf('%2d| %9.4f | %9.4f | %10.6f || %9.4f | %9.4f | %10.6f\n', i, startCorrected(i),stimStart(i),startCorrected(i)-stimStart(i),finishCorrected(i),stimFinish(i),finishCorrected(i)-stimFinish(i))
                        end
                        res = input('¿Relizar ajuste?(s/n)',"s");
                        if strcomp(res,'y') || strcomp(res,'s') || strcomp(res,'Y') || strcomp(res,'S')
                            stimStart = startCorrected;
                            stimFinish= finishCorrected;
                        else
                            disp('No se ajustaron los tiempos del registro')
                        end
                    end
                elseif ~isempty(adjustFile) && ~isempty(t0File)
                    disp(['Se corregiran los tiempos usando el archivo de log: ' convertStringsToChars(adjustFile)])
                    correctionTable = readtable(adjustFile);
                    % verifico que tengan la misma cantidad de estimulos
                    % hay que eliminar el 0, 99 y cualquiera por encima de
                    % 1000
                    validStims = find(  correctionTable.stim>0 & ...
                                        correctionTable.stim~=99 & ... 
                                        correctionTable.stim<1000);
                    t0 = readtable(t0File);
                    t0 = t0.Var1 + seconds(t0.Var2/1e+6);
                    t0.Format = 'hh:mm:ss.SSSSSS';
                    nCorrStim = length(validStims);
                    if nCorrStim ~= nStims
                        % En caso de que las listas de estimulos no sean
                        % iguales imprimo la tabla para que el usuario
                        % elija que hacer
                        fprintf('Hay distinta de cantidad de estimulos entre el log y el registro \n');
                        fprintf('N | Stim   | Duracion || Duracion \n')
                        fprintf('  | en log | en log   || en Registro\n')
                        fprintf('--|--------|----------||-------------\n')
                        durationLog=correctionTable.t_finish(validStims)-correctionTable.t_start(validStims);
                        for i = 1:max([nCorrStim nStims])
                            if i<=length(validStims)
                                fprintf('%2d| %6d | %8.2f ||', i, correctionTable.stim(validStims(i)), seconds(durationLog(i)))
                            else
                                fprintf('%2d|      - |        - ||', i)
                            end
                            if i<=length(stimFinish)
                                fprintf(' %9.2f\n',stimFinish(i)-stimStart(i))
                            else
                                fprintf('         -\n')
                            end
                        end
                        res = input('¿Relizar ajuste parcial?(s/n)',"s");
                        if ~(strcomp(res,'y') || strcomp(res,'s') || strcomp(res,'Y') || strcomp(res,'S'))
                            error('no se puede continuar')
                        end
                        
                    end
                    startCorrected = seconds(correctionTable.t_start(validStims))-seconds(t0);
                    finishCorrected = seconds(correctionTable.t_finish(validStims))-seconds(t0);
                    if max(abs(stimStart - startCorrected))<0.3
                        stimStart = startCorrected;
                        stimFinish= finishCorrected;
                    else
                        fprintf('Hay un error mayor a 0.3s, verifique las correcciones \n');
                        fprintf('  | -------------   Start   --------- || ------------   Finish   --------- \n')
                        fprintf('N | Corrected | Registro  | Diferencia || Corrected | Registro  | Diferencia \n')
                        fprintf('--| --------- | --------- | ---------- || --------- | --------- | ----------\n')
                        for i = 1:max([nCorrStim nStims])
                            fprintf('%2d| %9.4f | %9.4f | %10.6f || %9.4f | %9.4f | %10.6f\n', i, startCorrected(i),stimStart(i),startCorrected(i)-stimStart(i),finishCorrected(i),stimFinish(i),finishCorrected(i)-stimFinish(i))
                        end
                        res = input('¿Relizar ajuste?(s/n)',"s");
                        if strcomp(res,'y') || strcomp(res,'s') || strcomp(res,'Y') || strcomp(res,'S')
                            stimStart = startCorrected;
                            stimFinish= finishCorrected;
                        else
                            disp('No se ajustaron los tiempos del registro')
                        end
                    end
                    
                end
        end
        
        %calculo cuanto más lee un mouse que el otro
        relacionM2M1 = sum(abs(miceData(:,4)))/sum(abs(miceData(:,2)));

        %transformo los datos de desplazamiento en unidades de mouse a cm.
        miceData(:,1:2) =  miceData(:,1:2) * convK(1);
        miceData(:,3:4) = miceData(:,3:4) * convK(1)/relacionM2M1;
        %miceData(:,:) = miceData(:,:) .* repmat(convK, length(miceData),1);
%         assignin('base','miceData',[miceData time])
%         assignin('base','stimTimes',[stimStart stimFinish])
%         assignin('base','nStims',[nStims diametro])
%         assignin('base','diametro',diametro)
        
        %ahora que tengo los datos en centímietros genero mi set de datos.
        md(i) = MiceData(miceData, time, stimStart, stimFinish, nStims, diametro, crabID);
        if ~isempty(adjustFile)
            md(i).stimCode = correctionTable.stim(validStims);
            disp(correctionTable.stim(validStims))
        end
    end
end