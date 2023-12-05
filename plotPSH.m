function hPlot = plotPSH(freq, t, stims, tPre, tPost,titulo, varargin)
hold on
plotLines = false;
lineColor = [0 0 0];
customColor = false;
addDecorations = true;
addStdError = false;
useDoubleAxis = false;
lineWidth = 2;
stimHeigth = 0.5;
stimUnderPlot = false;
topLimit = [];
for arg = 1:2:length(varargin)
    switch lower(varargin{arg})
        case 'plotlines'
            plotLines = varargin{arg+1};
        case 'color'
            lineColor = varargin{arg+1};
            customColor = true;
        case 'decorations'
            addDecorations = varargin{arg+1};
        case 'doubleaxis'
            useDoubleAxis = varargin{arg+1};
        case 'stimheigth'
            stimHeigth = varargin{arg+1};
        case 'stimunderplot'
            stimUnderPlot = varargin{arg+1};
        case 'toplimit'
            topLimit = varargin{arg+1};
    end
end


%si no hay datos reemplazo al vector tiempo por un vector vacio
if isempty(freq)
    hPlot = [];
    return
elseif plotLines
    vargs = {'LineWidth', lineWidth};
    if customColor
        vargs = [vargs, 'Color', lineColor];
    end
    if isvector(freq)
        hPlot = plot(t, freq, vargs{:});
    else
        %determino si las frecuencias esta en filas o columnas y arreglo
        %para que cada columna sea una serie.
        [rows, cols] = size(freq);
        if cols > rows
            freq = freq';
        end
        [rows, cols] = size(t);
        %seteo que el vector de tiempo también este en una columna
        if cols > rows
            t = t';
        end
        [~, cols] = size(freq);
        if useDoubleAxis
            if cols ~= 2
                error ('Sólo se puede usar doble eje Y cuando hay dos series a plotear')
            end
            yyaxis left
            hPlot(1) = plot(t, freq(:,1), 'color', lineColor{1}, 'lineWidth', lineWidth);
            yyaxis right
            hPlot(2) = plot(t, freq(:,2), 'color', lineColor{2}, 'lineWidth', lineWidth);
        end
        for group = 1:cols
            hPlot(group) = plot(t, freq(:,group), 'color', lineColor{group}, 'lineWidth', lineWidth);
        end
    end
else
%ploteo el histograma encima
hPlot = bar(t,freq);
end
% y lo adorno (acá se agregan los detalles de los graficos)
if isempty(topLimit)
    topLimit = max(max(freq)) * 1.2;
end
tFinalMedio = mean(stims(:,3)-stims(:,2));
if addDecorations
    addPSHDecorations(stims, tFinalMedio, topLimit*0.85, 'Heigth', stimHeigth, 'StimUnderPlot', stimUnderPlot)
end
%y seteo los limites de los ejes
xlim([-tPre tPost]);
title(titulo);
ylabel('freq (Hz)');
xlabel('time (s)');
if isempty(varargin)
    ylim([0,topLimit]);
    hold off
    return;
else
    for arg = 1:2:length(varargin)
        switch lower(varargin{arg})
            case 'rasters'
                rasters = varargin{arg+1};
            case 'index'
                index = varargin{arg+1};
        end
    end
end

hold off