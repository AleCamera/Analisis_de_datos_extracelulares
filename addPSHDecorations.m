function addPSHDecorations(stims, tFinalMedio, topLimit, varargin)

color = [0.6, 0.6, 0.6];
transparency = 0.6;
heigth = 0.5;
stimUnderPlot = false;
ofFreq = 0;
for arg = 1:2:length(varargin)
    switch lower(varargin{arg})
        case 'color'
            color = varargin{arg+1};
        case 'transparency'
            transparency = varargin{arg+1};
        case 'heigth'
            if heigth < 0
                error ('La altura del estimulo no puede ser menor a 0')
            else
                heigth = varargin{arg+1};
            end
        case 'stimunderplot'
            stimUnderPlot = varargin{arg+1};
        case 'opticflow'
            ofFreq = varargin{arg+1};
        otherwise
            disp(['"', varargin{arg}, '" is not a valid argument'])
    end
end
%agrego barras de escala en los ejes X e Y
%xScale = rectangle('position', [tFinalMedio, topLimit/12, tFinalMedio+1, topLimit/20], 'FaceColor', [0 0 0], 'LineStyle', 'none');
%xScaleLabel = text(tFinalMedio, topLimit/15, '1 sec');
%yScale = rectangle('position', [tFinalMedio, topLimit/9, tFinalMedio+0.1, (topLimit/9 + 10)], 'FaceColor', [0 0 0], 'LineStyle', 'none');
%yScaleLabel = text(-9.6, (topLimit/9 + (topLimit/9 + 10))/2, '1 sec');
if ofFreq
    nRects = floor(15 * ofFreq/2);
    pos = [0 0 1/ofFreq topLimit*heigth];
    color = [color, transparency];
    for r = 1:nRects
        rect = rectangle('position', pos, 'FaceColor', color, 'LineStyle', 'none');
        uistack(rect, 'bottom')
        pos(1) = pos(1) + 2/ofFreq;
    end
elseif stimsAreUnique(96, stims(:,1))
    %fondo gris durante los periodos oscuros del estimulo 96
    color = [color, transparency]; %agrego un cuarto valor al color que es la transparencia (es así para rectángulos)
    if stimUnderPlot
        position1 = [-2; -topLimit; 2; topLimit];
        position2 = [ 2; -topLimit; 2; topLimit];
    else
        position1 = [-2; 0; 2; topLimit];
        position2 = [ 2; 0; 2; topLimit];
    end
    R1 = rectangle('position', position1, 'FaceColor', color, 'LineStyle', 'none');
    R2 = rectangle('position', position2, 'FaceColor', color, 'LineStyle', 'none');
    uistack(R1, 'bottom')
    uistack(R2, 'bottom')
else
    %agrego la linea que marca la aparicion del estimulo
    line ([-5, -5], [0, topLimit], 'Color', [0.7, 0.7, 0.0],'LineWidth', 1.5, 'LineStyle', '--')
    %la linea que marca la desaparicion
    line([tFinalMedio+5, tFinalMedio+5], [0, topLimit], 'Color', [0.7, 0.7, 0.0],'LineWidth', 1.5, 'LineStyle', '--')
    %la linea que marca el inicio
    line( [0,0], [0, topLimit*heigth], 'Color', [0.1, 0.8, 0.1], 'LineWidth', 0.5, 'LineStyle', '-');
    if stimsAreUnique(2, stims(:,1))
        %dibujo un looming si el estímulo es el 2
        sizeCM = 17;
        t = 0:(tFinalMedio/1000):tFinalMedio;
        y = zeros(1,length(t));
        for i = 1:length(t)
            y(i) = 2*((20*sizeCM)/(500 - (142.5*t(i))));
        end
        %agrego el punto donde aparece el looming
        t= [-5, t];
        %extiendo el tiempo hasta el punto en el que desaparece el looming
        t = [t, (t(end)+5)];
        %y = y - y(1);
        y = y*topLimit/(max(y)/heigth);
        %extiendo agrego el punto donde aparece el cuadrado
        y = [y(1), y];
        %extiendo el valor de tamaño angular hasta que desaparece el looming
        y = [y, y(end)];
        y2 = zeros(1,length(y));
        yy = [y, fliplr(y2)];
        if stimUnderPlot
            yy = yy - max(yy);
        end
        %L1 = line(t,y,'Color', 'k');
        A1 = fill([t,fliplr(t)],yy, color);
        %uistack(L1, 'bottom')
        uistack(A1, 'bottom')
        set(A1, 'facealpha', transparency, 'edgealpha', transparency, 'edgecolor', color)
        %arrow coordinates
        %     Xarrow(1) = (tPre/(tPre+tPost));
        %     Xarrow(2) = Xarrow(1);
        %     Yarrow = [0.2, 0];
        %
        %     annotation('arrow',Xarrow,Yarrow )
    elseif length(unique(stims(:,1))) == 1 || stimsAreUnique([25, 26], stims(:,1)) || stimsAreUnique([33,34 37 38 39 40 41 42 43 44 45 46 47 48], stims(:,1))
        %sino pongo un fondo gris durante la duracion del estimulo si hay un
        %sólo tipo de estimulo o son los dos flujos o los cuadrados
        color = [color, transparency]; %agrego un cuarto valor al color que es la transparencia (es así para rectángulos)
        if stimUnderPlot
            position = [0,-topLimit*heigth, tFinalMedio,topLimit*heigth];
        else
            position = [0, 0, tFinalMedio, topLimit*heigth];
        end
        R1 = rectangle('position', position', 'FaceColor', color, 'LineStyle', 'none');
        uistack(R1, 'bottom')
    end
    if stimUnderPlot
        yLimits = ylim;
        yLimits = [-topLimit*heigth, yLimits(2)];
        ylim(yLimits)
    end
end