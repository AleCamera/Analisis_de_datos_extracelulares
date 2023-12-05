function plotRasters(funct, raster, index, tPre, tPost, stims, color, lineWidth)
if isempty(raster)
    return
end

if isequal(@PlotSync, funct)
    PlotSync(raster,index, 'durations', [-tPre; tPost]);   % plot spike raster
elseif isequal(@PlotRasters_oneColor, funct)

    PlotRasters_oneColor(raster, index, [-tPre, tPost], [], 'Color', color, 'Linewidth', lineWidth);
else
    error('Wrong plotting function')
end

[nStims, ~]=size(stims);
if stimsAreUnique(96, stims(:,1))
    %fondo gris durante los periodos oscuros del estimulo 96
    R1 = rectangle('position', [-2,-0.5, 2,nStims+2]', 'FaceColor', [0.6 0.6 0.6], 'LineStyle', 'none');
    R2 = rectangle('position', [2,-0.5, 2,nStims+2]', 'FaceColor', [0.6 0.6 0.6], 'LineStyle', 'none');
    uistack(R1, 'bottom');
    uistack(R2, 'bottom');
    
else
    
    tFinal = stims(:, 3) - stims(:, 2);
    U = zeros(nStims,1);
    V = zeros(nStims,1) -0.1;
    if isequal(funct, @PlotSync)
        quiverPoint = 0.5:1:(nStims-0.5);
        ylim([-0.5, nStims-0.5]);
        set(gca,'ytick',[])
    else
        quiverPoint = 1.5:1:(nStims+0.5);
        ylim([0.4, nStims+0.6])
        set(gca, 'ytick',  (1:nStims))
        ylabel('Trial #')
    end
    %Pongo las flechas que marcan el final del estimulo
    quiver(tFinal, quiverPoint, U, V,  'LineStyle', 'none','Color', [0.6, 0.1, 0.1], ...
        'Marker', 'v', 'MarkerSize', 5, 'MarkerFaceColor', [0.8, 0.1,0.1]);
    %la linea que marca el inicio
    line ([0, 0], [-0.5, nStims+0.5], 'Color', [0.1, 0.8, 0.1],'LineWidth', 1)
    %la linea que marca la aparicion del estimulo
    line ([-5, -5], [-0.5, nStims+0.5], 'Color', [0.7, 0.7, 0.0],'LineWidth', 1.5, 'LineStyle', '--')
    %la linea que marca la desaparicion del estimulo
    quiver(tFinal+5, quiverPoint, U, V,  'LineStyle', 'none','Color', [0.6, 0.1, 0.1], ...
        'Marker', 'v', 'MarkerSize', 5, 'MarkerFaceColor', [0.7, 0.7,0]);
end
%seteo los limites del ploteo
if isequal(funct, @PlotSync)
    ylim([-0.5, nStims-0.5]);
    set(gca,'ytick',[])
else
    ylim([0.4, nStims+0.6])
    set(gca, 'ytick',  (1:nStims))
    ylabel('Trial #')
end

end