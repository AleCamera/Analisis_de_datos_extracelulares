classdef VideoData < handle
    properties
        RutaCarpeta         char      % Ruta base del experimento
        TablaMarcas         table     % Contenido de registro_marcas_sincronizado.csv
        StructComp          struct    % Struct array de comportamiento (limpio)
        TablaSincronizada   table     % Tabla final con datos cruzados
        crabData            CrabolaEphysRec
        
        preStimTime         double = 5.0 % Tiempo en segundos antes del estímulo (ej: 5.0s)
        clusterDefecto      double = 1   % Cluster por defecto si no se especifica
        offsetRun           double = 0
        
        % Gestión de fragmentos de video
        VideosInfo          table     % Tabla con Nombres de archivo, Duraciones y Offsets globales
    end
    
    properties (Access = private)
        % Memoria temporal para la GUI de curaduría
        MemoriaCeldasVideo  cell
        DuracionesComp      double
        ToleranciaAlgoritmo double
        
        % Handles de componentes UI clásicos
        hFigGUI
        hListVideo
        hListStruct
        hLblStatus
    end
    
    methods
        %% --- CONSTRUCTOR ---
        function obj = VideoData(rutaCarpeta)
            if nargin > 0
                obj.RutaCarpeta = rutaCarpeta;
                obj.cargarYReconstruirLineatiempo();
            end
        end
        
        %% 1) CARGA Y RECONSTRUCCIÓN DE LÍNEA DE TIEMPO
        function cargarYReconstruirLineatiempo(obj)
            rutaCSV = fullfile(obj.RutaCarpeta, 'registro_marcas_sincronizado.csv');
            if ~exist(rutaCSV, 'file')
                error('No se encontró el archivo csv en la ruta especificada.');
            end
            obj.TablaMarcas = readtable(rutaCSV, 'TextType', 'char');
            
            archivosUnicos = unique(obj.TablaMarcas.Archivo);
            nVideos = length(archivosUnicos);
            
            nombres = cell(nVideos, 1);
            duraciones = zeros(nVideos, 1);
            offsets = zeros(nVideos, 1);
            
            fprintf('📹 Analizando estructura de videos en disco...\n');
            progresoOffset = 0.0;
            for i = 1:nVideos
                rutaAbsolutaVideo = fullfile(obj.RutaCarpeta, archivosUnicos{i});
                if ~exist(rutaAbsolutaVideo, 'file')
                    error('Falta el archivo de video: %s en la carpeta.', archivosUnicos{i});
                end
                
                vr = VideoReader(rutaAbsolutaVideo);
                nombres{i} = archivosUnicos{i};
                duraciones(i) = vr.Duration;
                offsets(i) = progresoOffset;
                
                progresoOffset = progresoOffset + vr.Duration;
            end
            
            obj.VideosInfo = table(nombres, duraciones, offsets, ...
                'VariableNames', {'Archivo', 'DuracionExacta', 'OffsetGlobal'});
            fprintf('✅ Línea de tiempo unificada reconstruida con éxito (%d videos).\n', nVideos);
        end
        
        %% 2) SINCRONIZACIÓN BASADA EN TIEMPOS DE HARDWARE
        function sincronizarConComportamiento(obj, structComportamiento)
            if nargin < 2
                obj.StructComp = obj.crabData.stims;
            else
                obj.StructComp = structComportamiento;
            end
            
            
            nMarcasVideo = height(obj.TablaMarcas);
            if nMarcasVideo == 0
                error('No hay marcas cargadas en el archivo CSV.');
            end
            
            obj.DuracionesComp = [obj.StructComp.finish] - [obj.StructComp.start];
            obj.ToleranciaAlgoritmo = 1.5; 
            
            obj.MemoriaCeldasVideo = cell(nMarcasVideo, 10); 
            for vIdx = 1:nMarcasVideo
                obj.MemoriaCeldasVideo{vIdx, 1}  = obj.TablaMarcas.Archivo{vIdx};
                obj.MemoriaCeldasVideo{vIdx, 2}  = obj.TablaMarcas.ID_Hardware_Trial(vIdx);
                obj.MemoriaCeldasVideo{vIdx, 3}  = obj.TablaMarcas.Hardware_Duration(vIdx);
                obj.MemoriaCeldasVideo{vIdx, 4}  = obj.TablaMarcas.Hardware_Start(vIdx); 
                obj.MemoriaCeldasVideo{vIdx, 5}  = obj.TablaMarcas.Video_Start(vIdx);
                obj.MemoriaCeldasVideo{vIdx, 6}  = obj.TablaMarcas.Video_Finish(vIdx);
                obj.MemoriaCeldasVideo{vIdx, 7}  = NaN; 
                obj.MemoriaCeldasVideo{vIdx, 8}  = NaN; 
                obj.MemoriaCeldasVideo{vIdx, 9}  = '[? Desalineado / No asignado]';
                obj.MemoriaCeldasVideo{vIdx, 10} = obj.TablaMarcas.Monitor_Origen(vIdx);
            end
            
            obj.ejecutarPropagacionHardware(1, 1);
            obj.desplegarGUICuradorClasico();
        end
        
        %% 3) REPRODUCTOR DE VIDEO INTERACTIVO NATIVO MULTI-VIDEO
        function reproducirTrial(obj, idxTrial, velocidad, clu)
            if nargin < 3 || isempty(velocidad), velocidad = 1.0; end
            if nargin < 4 || isempty(clu), clu = obj.clusterDefecto; end
            
            if idxTrial < 1 || idxTrial > height(obj.TablaMarcas)
                error('Índice de Trial fuera de los límites de la TablaMarcas.');
            end
                      
            nombreArchivo = obj.TablaMarcas.Archivo{idxTrial};
            
            tInicioLocal = double(obj.TablaMarcas.Video_Start(idxTrial));
            tFinLocal = double(obj.TablaMarcas.Video_Finish(idxTrial));
            if tInicioLocal < 0, tInicioLocal = 0.0; end
            
            rutaVideoAbs = fullfile(obj.RutaCarpeta, char(nombreArchivo));
            if ~exist(rutaVideoAbs, 'file')
                errordlg(sprintf('No se encuentra el video: %s', nombreArchivo), 'Error');
                return;
            end
            
            % --- EXTRACCIÓN CON LA SINTAXIS DE CRABDATA ---
            datosGrafico = struct('t_ball', [], 'vTras', [], 't_ephys', [], 'fRates', [], ...
                                  'existe', false, 'preStimTime', obj.preStimTime);
            
            if ~isempty(obj.crabData)
                try
                    idHwTrial = obj.TablaMarcas.ID_Hardware_Trial(idxTrial);
                    
                    % Llamada a la estructura unificada (Acepta clu = 1 sin restricciones)
                    resStruct = obj.crabData.getRunAndFireRate(clu, 0, 'stimind', idHwTrial);
                    
                    datosGrafico.fRates = resStruct.fRates;
                    datosGrafico.t_ephys = resStruct.t_ephys;
                    
                    if isfield(resStruct, 'runs') && isstruct(resStruct.runs)
                        datosGrafico.vTras = resStruct.runs.vTras;
                        datosGrafico.t_ball = resStruct.runs.time+obj.offsetRun;
                        datosGrafico.existe = true;
                    end
                    
                catch ME
                    warning('Error al ejecutar getRunAndFireRate para clu=%d, TrialHW=%d: %s', clu, idHwTrial, ME.message);
                    datosGrafico.existe = false;
                end
            end
            
            % Lanzar motor gráfico pasando clu para control interno
            obj.ejecutarEngineVideoConGrafico(rutaVideoAbs, tInicioLocal, tFinLocal, velocidad, idxTrial, datosGrafico, clu);
        end
        
    end
    
    methods (Access = private)
        %% --- MOTOR MATEMÁTICO BASADO EN TIEMPOS DE HARDWARE ---
        function ejecutarPropagacionHardware(obj, desdeIdxCSV, idCompAncla)
            nMarcasCSV = size(obj.MemoriaCeldasVideo, 1);
            nTrialsComp = length(obj.DuracionesComp);
            
            t_hw_ancla = obj.MemoriaCeldasVideo{desdeIdxCSV, 4};
            t_ephys_ancla = obj.StructComp(idCompAncla).start;
            offsetRelojHwVsEphys = t_ephys_ancla - t_hw_ancla;
            
            dur_hw_ancla = obj.MemoriaCeldasVideo{desdeIdxCSV, 3};
            dur_ephys_ancla = obj.DuracionesComp(idCompAncla);
            offsetDuracionExperimento = round(dur_ephys_ancla - dur_hw_ancla); 
            obj.preStimTime = 10 - abs((offsetDuracionExperimento/4));
            
            compCursor = idCompAncla;
            
            for vIdx = desdeIdxCSV:nMarcasCSV
                if compCursor > nTrialsComp
                    obj.MemoriaCeldasVideo{vIdx, 7} = NaN;
                    obj.MemoriaCeldasVideo{vIdx, 8} = NaN;
                    obj.MemoriaCeldasVideo{vIdx, 9} = '[⚠️ Fin de registro Ephys]';
                    continue;
                end
                
                t_hw_actual = obj.MemoriaCeldasVideo{vIdx, 4};
                dur_hw_actual = obj.MemoriaCeldasVideo{vIdx, 3};
                
                t_estimado_ephys = t_hw_actual + offsetRelojHwVsEphys;
                t_real_ephys = obj.StructComp(compCursor).start;
                dur_real_ephys = obj.DuracionesComp(compCursor);
                
                distanciaReloj = abs(t_real_ephys - t_estimado_ephys);
                errorDuracion = abs(dur_real_ephys - (dur_hw_actual + offsetDuracionExperimento));
                
                if distanciaReloj <= obj.ToleranciaAlgoritmo && errorDuracion <= obj.ToleranciaAlgoritmo
                    obj.MemoriaCeldasVideo{vIdx, 7} = compCursor;
                    obj.MemoriaCeldasVideo{vIdx, 8} = dur_real_ephys;
                    obj.MemoriaCeldasVideo{vIdx, 9} = sprintf('🔗 HW OK (Δt Dur: %ds)', offsetDuracionExperimento);
                    compCursor = compCursor + 1;
                else
                    obj.MemoriaCeldasVideo{vIdx, 7} = NaN;
                    obj.MemoriaCeldasVideo{vIdx, 8} = NaN;
                    obj.MemoriaCeldasVideo{vIdx, 9} = '[❌ Desalineado / Salto de HW]';
                end
            end
        end
        %% --- ENGINE MOTOR GRÁFICO CON TIEMPO DE GRÁFICO BASADO EN EPHYS ---
        function ejecutarEngineVideoConGrafico(obj, rutaVideo, tInicio, tFin, velocidad, numeroTrial, datosGrafico, clu)
            vidObj = VideoReader(rutaVideo);
            vidObj.CurrentTime = tInicio;
            
            [~, fileName, fileExt] = fileparts(rutaVideo);
            
            % Crear figura interactiva
            hFig = figure('Name', sprintf('%s%s - Desde: %.2f Hasta %.2f',fileName, fileExt, tInicio,tFin), ...
                          'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
                          'Position', [200, 50, 850, 780], 'KeyPressFcn', @obj.cb_teclado);
                      
            % Eje Superior: Video
            hAxVideo = axes('Parent', hFig, 'Position', [0.05, 0.36, 0.9, 0.6]);
            axis(hAxVideo, 'image'); axis(hAxVideo, 'off');
            
            % Eje Inferior: Datos Biológicos / Comportamiento
            hAxGrafico = axes('Parent', hFig, 'Position', [0.1, 0.08, 0.78, 0.24]);
            hCursor = [];
            
            fixedStringTitle = sprintf('Fecha: %s | Crab ID %1.0f | Trial %2.0f | Codigo: %1.0f', ...
                       string(obj.crabData.date),...
                       obj.crabData.crabID,...
                       numeroTrial,...
                       obj.crabData.stims(numeroTrial).code);
            
            % Graficar siempre que existan datos válidos en la estructura
            if datosGrafico.existe && ~isempty(datosGrafico.t_ball)
                
                % --- EJE IZQUIERDO: VELOCIDAD DE LA PELOTA (Comportamiento) ---
                 yyaxis(hAxGrafico, 'left');
                plot(hAxGrafico, datosGrafico.t_ball, datosGrafico.vTras, 'LineWidth', 1.5, 'Color', [0, 0.45, 0.74]);
                ylabel(hAxGrafico, 'Vel. Pelota vTras (cm/s)');
                set(hAxGrafico, 'YColor', [0, 0.45, 0.74]);
                grid(hAxGrafico, 'on');
                
                % --- EJE DERECHO: FIRING RATE (Electrofisiología) ---
                yyaxis(hAxGrafico, 'right');
                plot(hAxGrafico, datosGrafico.t_ephys, datosGrafico.fRates, 'LineWidth', 1.2, 'Color', [0.85, 0.33, 0.1]);

                % --- Ploteo el estimulo
%                 if isfield(obj.crabData.stims,'reg')
%                     limits = [min(obj.crabData.stims(numeroTrial).reg(:,2)) max(obj.crabData.stims(numeroTrial).reg(:,2))+1]
%                     addaxis(obj.crabData.stims(numeroTrial).reg(:,1),...
%                             obj.crabData.stims(numeroTrial).reg(:,2),...
%                             limits)
%                 end

                % Si clu == 1, le damos un toque estético al eje derecho para indicar que está vacío
                if clu == 1
                    ylabel(hAxGrafico, '(Sin Cluster)');
                    set(hAxGrafico, 'YColor', [0.6 0.6 0.6]);
                else
                    ylabel(hAxGrafico, 'Frecuencia Neuronal fRates (Hz)');
                    set(hAxGrafico, 'YColor', [0.85, 0.33, 0.1]);
                    fixedStringTitle = sprintf('%s | Cluster %1.0f', ...
                                        fixedStringTitle,...
                                        clu);
                end

                % Límites del eje X basados estrictamente en el ephys devuelto
                minX = min([min(datosGrafico.t_ball), min(datosGrafico.t_ephys)]);
                maxX = max([max(datosGrafico.t_ball), max(datosGrafico.t_ephys)]);
                xlim(hAxGrafico, [minX, maxX]);
                xlabel(hAxGrafico, 'Tiempo del Experimento Ephys (t = 0 es Inicio Stim)');
                
                % Línea vertical indicando el T=0 (Inicio real del movimiento del estímulo)
                hold(hAxGrafico, 'on');
                line(hAxGrafico, [0 0], get(hAxGrafico, 'YLim'), 'Color', [0.5 0.5 0.5], 'LineWidth', 1, 'LineStyle', ':');
                
                % Marcador Vertical Móvil del tiempo actual
                yyaxis(hAxGrafico, 'left');
                limsY = get(hAxGrafico, 'YLim');
                tInicialGrafico = -datosGrafico.preStimTime;
                hCursor = line(hAxGrafico, [tInicialGrafico, tInicialGrafico], limsY, ...
                               'Color', [0.2, 0.2, 0.2], 'LineWidth', 1.8, 'LineStyle', '--');
            else
                % Mensaje de contingencia si falló la comunicación por completo con crabData
                text(hAxGrafico, 0.5, 0.5, 'Error crítico al recuperar datos del experimento', ...
                     'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', [0.5 0.5 0.5]);
                set(hAxGrafico, 'XTick', [], 'YTick', []);
            end
            
            title(fixedStringTitle)
            
            % Persistencia en la appdata de la figura
            setappdata(hFig, 'vidObj', vidObj);
            setappdata(hFig, 'tInicio', tInicio);
            setappdata(hFig, 'tFin', tFin);
            setappdata(hFig, 'velocidad', velocidad);
            setappdata(hFig, 'reproduciendo', true);
            setappdata(hFig, 'hCursor', hCursor);
            setappdata(hFig, 'preStimTime', datosGrafico.preStimTime);

            % Bucle Principal de Renderizado Nativo
            while ishandle(hFig)
                reproduciendo = getappdata(hFig, 'reproduciendo');
                velActual = getappdata(hFig, 'velocidad');
                tActualVideo = vidObj.CurrentTime;
                
                % Equivalencia temporal crítica
                deltaVideo = tActualVideo - tInicio;
                tActualGrafico = -datosGrafico.preStimTime + deltaVideo;
                
                % Título superior interactivo
                strTitle = sprintf('%s | Vel: x%.1f | Tiempo Ephys: %.2fs | Tiempo video: %.2f', ...
                                   obj.obtenerStatusStr(reproduciendo, tActualVideo, tFin),...
                                   velActual,...
                                   tActualGrafico,...
                                   tActualVideo);
                if ishandle(hFig)
                    % Actualizar posición del marcador vertical
                    if ishandle(hCursor)
                        set(hCursor, 'XData', [tActualGrafico, tActualGrafico]);
                    end
                end
                
                if reproduciendo
                    tic;
                    if tActualVideo >= tFin
                        setappdata(hFig, 'reproduciendo', false);
                        continue;
                    end
                    
                    if hasFrame(vidObj)
                        frame = readFrame(vidObj);
                        if ~ishandle(hFig), break; end
                        imshow(frame, 'Parent', hAxVideo);
                        title(hAxVideo, strTitle, 'FontSize', 11, 'FontWeight', 'bold');
                        drawnow limitrate;
                    else
                        setappdata(hFig, 'reproduciendo', false);
                    end
                    
                    tProc = toc;
                    tEspera = (1 / (vidObj.FrameRate * velActual)) - tProc;
                    if tEspera > 0, pause(tEspera); end
                else
                    pause(0.04);
                end
            end
        end
        
        %% --- INTERFAZ GRÁFICA CLÁSICA ---
        function desplegarGUICuradorClasico(obj)
            obj.hFigGUI = figure('Name', 'Curador Guiado por Hardware - VideoData', ...
                                 'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
                                 'Position', [100, 100, 1150, 650]);
                              
            txtInstr = ['🎯 CONTROL DE CALIDAD DE HARDWARE: Seleccione la marca de Hardware desalineada a la izquierda, ' ...
                        'busque el Trial real de Ephys correlativo a la derecha, y presione "Vincular y Re-alinear Cascada". ' ...
                        'El programa recalculará el offset de reloj y el desfase constante de duración (0-20s) automáticamente.'];
            uicontrol('Style', 'text', 'Parent', obj.hFigGUI, 'String', txtInstr, ...
                      'Position', [20, 580, 1110, 50], 'FontWeight', 'bold', 'FontSize', 10, ...
                      'ForegroundColor', [0.1, 0.3, 0.5], 'HorizontalAlignment', 'left');
                
            uicontrol('Style', 'text', 'Parent', obj.hFigGUI, 'String', '📋 REGISTROS CONTINUOS DE HARDWARE (.csv)', ...
                      'Position', [20, 550, 400, 20], 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
            obj.hListVideo = uicontrol('Style', 'listbox', 'Parent', obj.hFigGUI, ...
                                       'Position', [20, 110, 530, 430], 'FontName', 'monospace');
            
            uicontrol('Style', 'text', 'Parent', obj.hFigGUI, 'String', '🧠 REGISTROS ELECTROFISIOLÓGICOS (STRUCT)', ...
                      'Position', [600, 550, 400, 20], 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'ForegroundColor', [0.5, 0.1, 0.1]);
            obj.hListStruct = uicontrol('Style', 'listbox', 'Parent', obj.hFigGUI, ...
                                        'Position', [600, 110, 530, 430], 'FontName', 'monospace');
            
            uicontrol('Style', 'pushbutton', 'Parent', obj.hFigGUI, 'String', '⚡ Vincular Selección y Re-alinear Cascada', ...
                      'Position', [340, 60, 470, 40], 'FontWeight', 'bold', 'FontSize', 11, ...
                      'BackgroundColor', [0.12, 0.45, 0.74], 'ForegroundColor', 'white', ...
                      'Callback', @(src, event) obj.cb_vincular_y_propagar_hardware());
                           
            uicontrol('Style', 'pushbutton', 'Parent', obj.hFigGUI, 'String', '💾 Guardar Curaduría y Finalizar', ...
                      'Position', [420, 12, 310, 35], 'FontWeight', 'bold', ...
                      'BackgroundColor', [0.15, 0.55, 0.25], 'ForegroundColor', 'white', ...
                      'Callback', @(src, event) obj.cb_guardar_final_hardware());
                 
            obj.hLblStatus = uicontrol('Style', 'text', 'Parent', obj.hFigGUI, 'String', 'Listo.', ...
                                       'Position', [20, 15, 380, 20], 'ForegroundColor', [0.4, 0.4, 0.4], 'HorizontalAlignment', 'left');

            obj.actualizarListasClasicas();
            uiwait(obj.hFigGUI);
        end
        
        function actualizarListasClasicas(obj)
            nMarcasCSV = size(obj.MemoriaCeldasVideo, 1);
            itemsVideo = cell(nMarcasCSV, 1);
            for i = 1:nMarcasCSV
                idHw    = obj.MemoriaCeldasVideo{i, 2};
                durHW   = obj.MemoriaCeldasVideo{i, 3};
                t_hw    = obj.MemoriaCeldasVideo{i, 4};
                vStart  = obj.MemoriaCeldasVideo{i, 5};
                idEphys = obj.MemoriaCeldasVideo{i, 7};
                estado  = obj.MemoriaCeldasVideo{i, 9};
                
                if isnan(idEphys)
                    asocStr = '⚠️ NaN';
                else
                    asocStr = sprintf('Ephys #%d', idEphys);
                end
                
                if vStart < 0
                    camStr = '[CORTADO/NO FILMADO]';
                else
                    camStr = '[FILMADO OK]';
                end
                
                itemsVideo{i} = sprintf('Fila %02d -> Trial HW #%02d (T_Hw: %6.1fs | Dur_Hw: %4.1fs) %s ===> %s (%s)', ...
                                       i, idHw, t_hw, durHW, camStr, asocStr, estado);
            end
            set(obj.hListVideo, 'String', itemsVideo, 'Value', min(get(obj.hListVideo, 'Value'), nMarcasCSV));
            
            nTrialsComp = length(obj.DuracionesComp);
            itemsStruct = cell(nTrialsComp, 1);
            
            idsReclamados = [obj.MemoriaCeldasVideo{:, 7}];
            idsReclamados = idsReclamados(~isnan(idsReclamados));
            
            for j = 1:nTrialsComp
                durC = obj.DuracionesComp(j);
                t_start = obj.StructComp(j).start;
                pantalla = upper(obj.StructComp(j).screen);
                
                if any(idsReclamados == j)
                    marcaUso = ' OK (Asignado)';
                else
                    marcaUso = '*LIBRE*';
                end
                
                itemsStruct{j} = sprintf('Trial Ephys #%02d | T_Start: %6.1fs | Dur: %4.1fs | Mon: %s | %s', ...
                                         j, t_start, durC, pantalla, marcaUso);
            end
            set(obj.hListStruct, 'String', itemsStruct, 'Value', min(get(obj.hListStruct, 'Value'), nTrialsComp));
        end
        
        %% --- CALLBACKS INTERNOS DE LA GUI ---
        function cb_vincular_y_propagar_hardware(obj)
            idxCSVSeleccionado = get(obj.hListVideo, 'Value');
            idEphysSeleccionado = get(obj.hListStruct, 'Value');
            
            if isempty(idxCSVSeleccionado) || isempty(idEphysSeleccionado)
                warndlg('Debe seleccionar un elemento de cada lista para poder sincronizar.', 'Falta Selección');
                return;
            end
            
            set(obj.hLblStatus, 'String', sprintf('Propagando alineación de Hardware desde la fila %d...', idxCSVSeleccionado));
            drawnow;
            
            obj.ejecutarPropagacionHardware(idxCSVSeleccionado, idEphysSeleccionado);
            obj.actualizarListasClasicas();
            set(obj.hLblStatus, 'String', 'Sincronización por hardware completada hacia abajo.');
        end
        
        function cb_guardar_final_hardware(obj)
            nMarcas = size(obj.MemoriaCeldasVideo, 1);
            registrosSincFinal = cell(nMarcas, 8);
            
            for r = 1:nMarcas
                idCompManual = obj.MemoriaCeldasVideo{r, 7};
                if isempty(idCompManual) || isnan(idCompManual)
                    idCompManual = NaN;
                    t_comp_start = NaN;
                    t_comp_finish = NaN;
                    screen_val = 'Ninguno';
                else
                    idCompManual = double(idCompManual);
                    t_comp_start = obj.StructComp(idCompManual).start;
                    t_comp_finish = obj.StructComp(idCompManual).finish;
                    screen_val = obj.StructComp(idCompManual).screen;
                end
                
                registrosSincFinal(r, :) = { ...
                    obj.MemoriaCeldasVideo{r, 1}, ... 
                    obj.MemoriaCeldasVideo{r, 2}, ... 
                    obj.MemoriaCeldasVideo{r, 5}, ... 
                    obj.MemoriaCeldasVideo{r, 6}, ... 
                    idCompManual, ...                  
                    t_comp_start, ...                  
                    t_comp_finish, ...                 
                    screen_val ...                      
                };
            end
            
            obj.TablaSincronizada = cell2table(registrosSincFinal, 'VariableNames', ...
                {'ArchivoVideo', 'ID_Trial_Hardware', 'Video_Start_Local', 'Video_Finish_Local', ...
                 'ID_Trial_Comportamiento', 'Ephys_Start', 'Ephys_Finish', 'Monitor_Estimulo'});
             
            fprintf('\n💾 Curaduría guardada con éxito bajo la clase VideoData.\n');
            delete(obj.hFigGUI); 
        end
        
        %% --- ENGINE MOTOR GRÁFICO REPRODUCTOR INTERACTIVO ---
        function ejecutarEngineVideo(obj, rutaVideo, tInicio, tFin, velocidad, numeroTrial)
            vidObj = VideoReader(rutaVideo);
            vidObj.CurrentTime = tInicio;
            
            hFig = figure('Name', sprintf('Reproduciendo %s - Trial #%d',  numeroTrial), ...
                          'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
                          'KeyPressFcn', @obj.cb_teclado); % <--- Apunta correctamente a cb_teclado
            hAx = axes('Parent', hFig);
            axis(hAx, 'image');
            
            % Almacenar variables de estado dinámicas en la appdata de la figura
            setappdata(hFig, 'vidObj', vidObj);
            setappdata(hFig, 'tInicio', tInicio);
            setappdata(hFig, 'tFin', tFin);
            setappdata(hFig, 'velocidad', velocidad);
            setappdata(hFig, 'reproduciendo', true);
            setappdata(hFig, 'numeroTrial', numeroTrial);
            
            % Bucle de renderizado cuadro por cuadro
            while ishandle(hFig)
                reproduciendo = getappdata(hFig, 'reproduciendo');
                velActual = getappdata(hFig, 'velocidad');
                
                % Actualizar el título dinámico con los comandos
                strTitle = sprintf('Trial %d | Estado: %s | Vel: x%.1f | Teclas: [Espacio]Pausa | [Flechas <>] +/-1s | [+/- o Flechas] Vel', ...
                                   numeroTrial, obj.obtenerStatusStr(reproduciendo, vidObj.CurrentTime, tFin), velActual);
                
                if ishandle(hFig)
                    title(hAx, strTitle, 'FontSize', 9, 'FontWeight', 'bold');
                end
                
                if reproduciendo
                    tic;
                    if vidObj.CurrentTime >= tFin
                        setappdata(hFig, 'reproduciendo', false);
                        continue;
                    end
                    
                    if hasFrame(vidObj)
                        frame = readFrame(vidObj);
                        if ~ishandle(hFig), break; end
                        imshow(frame, 'Parent', hAx);
                        drawnow limitrate;
                    else
                        setappdata(hFig, 'reproduciendo', false);
                    end
                    
                    % Sincronización del framerate por software
                    tiempoProcesamiento = toc;
                    tiempoEspera = (1 / (vidObj.FrameRate * velActual)) - tiempoProcesamiento;
                    if tiempoEspera > 0, pause(tiempoEspera); end
                else
                    pause(0.05); % Evita el sobrecalentamiento del procesador estando en pausa
                end
            end
        end
        
        function str = obtenerStatusStr(~, repro, tCur, tFin)
            if tCur >= tFin
                str = '🛑 TERMINADO (Fin de Trial)';
            elseif repro
                str = '▶';
            else
                str = '⏸';
            end
        end
        
        %% --- CONTROLADOR DEL EVENTO DE TECLADO (RESTAURADO) ---
        function cb_teclado(~, src, event)
            % Evitar caídas catastróficas si se llama con elementos destruidos
            if ~ishandle(src), return; end
            
            vidObj      = getappdata(src, 'vidObj');
            repro       = getappdata(src, 'reproduciendo');
            vel         = getappdata(src, 'velocidad');
            tInicio     = getappdata(src, 'tInicio');
            tFin        = getappdata(src, 'tFin');
            
            switch event.Key
                case 'space'
                    if vidObj.CurrentTime >= tFin
                        vidObj.CurrentTime = tInicio;
                        setappdata(src, 'reproduciendo', true);
                    else
                        setappdata(src, 'reproduciendo', ~repro);
                    end
                    
                case 'rightarrow'
                    nuevoTiempo = vidObj.CurrentTime + 1.0;
                    if nuevoTiempo < vidObj.Duration, vidObj.CurrentTime = nuevoTiempo; end
                    
                case 'leftarrow'
                    nuevoTiempo = vidObj.CurrentTime - 1.0;
                    if nuevoTiempo >= 0, vidObj.CurrentTime = nuevoTiempo; end
                    
                case 'uparrow'
                    vel = vel * 1.3;
                    setappdata(src, 'velocidad', vel);
                    
                case 'downarrow'
                    vel = max(0.1, vel / 1.3);
                    setappdata(src, 'velocidad', vel);
                    
                case 'escape'
                    if ishandle(src), close(src); end
            end
        end
    end
end