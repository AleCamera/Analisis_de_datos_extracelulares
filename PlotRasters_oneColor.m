function PlotRasters_oneColor(raster, index, xLimits,maxfreq, varargin)

if isempty(raster)
    return
end
%cargo los argumentos por default (los reemplazo luego si especifiqué
%otros)
linewidth = 0.1; %ancho por default
color = [0 0 0]; %color por default
useSingleColor = false; %me indica si pedi explicitamente un solo color
useColorList = false; %me indica si pedi explicitamente una lista de colores
sticklength = 0.8; %largo por default
showSections = false;
rasterPositions =  unique(index);
location = '';
relativeSize = 0.1;
if isempty(varargin)
    xlim(xLimits)
else
    %levanto los argumentos que haya puesto
    for arg = 1:2:length(varargin)
        switch lower(varargin{arg})
            case 'color'
                color = varargin{arg+1};
                useSingleColor = true;
            case 'linewidth' 
                linewidth = varargin{arg+1};
            case 'relativesize'
                relativeSize = varargin{arg+1};
            case 'position'
                location = varargin{arg+1};
            case 'colorlist'
                colorList = varargin{arg+1};
                if length(colorList) == max(index)
                    useColorList = true;
                else
                    warning('el tamaño de la lista de colores no coincide con el numero de trials, ignoro esta opcion')
                end
            case 'showsections'
                sectionLimits = varargin{arg+1};
                showSections = true;
            otherwise
                disp(['"', varargin{arg}, '" is not va valid argument'])
        end
    end
    %si estoy ploteando sobre el PSH defino que la altura del raster va a
    %ser una fraccion de la altura del PSH.
    if ~isempty(location) && ~isempty(relativeSize)
        rasterheigth = maxfreq * (relativeSize);
        initialPosition = rasterheigth / (length(rasterPositions));
        %generamos las nuevas posiciones de los rasters:
        newPositions = (initialPosition/2):initialPosition: rasterheigth;
        sticklength = initialPosition*0.8;
        if strcmp(location, 'bottom')
            %las colocamos debajo del PSH
            newPositions = -newPositions;
            ylim([-rasterheigth, maxfreq*1.2])
        elseif strcmp(location, 'top')
            %las colocamos por encima del PSH y no cambiamos el valor
            %inferior del eje
            yLimits = ylim;
            newPositions = newPositions + maxfreq*1.03;
            ylim([min(yLimits), (max(newPositions)*1.1)])
        end
        %actualizo el index para que contenga las nuevas posiciones
        for trial = 1:length(rasterPositions)
            trialIND = rasterPositions(trial);
            index(index == trialIND) = newPositions(trial);
%             if showSections
%                 if trial == length(rasterPositions)
%                     sectionLimits(sectionLimits == trial) = newPositions(trial);
%                 else
%                     sectionLimits(sectionLimits == trial) = (newPositions(trial)+newPositions(trial+1))/2;
%                 end
%             end
        end
        %armo un vector con todas las nuevas posiciones
        rasterPositions = unique(index);
    end
end

if useColorList && useSingleColor
    warning('como se selecciono una lista de colores se ignora el color unico')
end
if showSections
    section=1;
end
%recorro todos los trials
for trial = 1:length(rasterPositions)
    %levanto la posicion en Y de cada trial
    position = rasterPositions(trial);
    %levanto los spikes que correspondan a ese trial
    crntRaster = raster(index == position);
    %defino los parametros en Y de las barritas (spikes)
    y = [position-(sticklength/2), position+(sticklength/2)];
    if useColorList == true
        color = colorList{trial};
        if showSections
            if trial == 1
                sectionLimits(section) = -rasterheigth;
                section = section+1;
            elseif colorList{trial} ~= colorList{trial-1}
                sectionLimits(section) = mean([rasterPositions(trial), rasterPositions(trial-1)]);
                section = section + 1;
            end
        end
    end
    %recorro el vector de spikes y grafico las lineas una por una
    for spk = 1:length(crntRaster)
        x = [crntRaster(spk),crntRaster(spk)];
        line(x, y, 'Color', color, 'LineWidth', linewidth)
    end
end
%sectionLimits(end) = 0;
if showSections
    thick = 5;
    thin = 2.5;
    x = [xLimits(1), xLimits(1)];
    for section = 1:(length(sectionLimits)-1)
        if mod(section, 2)
            width = thin;
        else
            width = thick;
        end
        args = {x, [sectionLimits(section), sectionLimits(section+1)], ...
            'lineWidth', width, 'Color', [0 0 0]};
        line(args{:})
    end
end
%elimino los ticks del eje y que tengan valores negativos (los que estan en
%el raster y no en el PSH
yt = yticks;
yt = yt(yt>=0);
yt = yt(yt<=maxfreq);
yticks(yt);
xlim(xLimits)
end