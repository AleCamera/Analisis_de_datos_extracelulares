function compareVEPs(allNeurons, selectedNeurons, stim, varargin)
%Plotea los gráficos de los VEPs individuales y promedio de las neuronas
%en respuesta a el estimulo stim. Genera graficos para las neuronas 
%seleccionadas por un lado y para el resto de la lista por el otro
%argumentos opcionales:
%
%       'legend' ---> un cell array de dos strings que tienen los nombres
%                     que van a ir al grafico de el resto de las neuronas y
%                     de las neuronas seleccionadas
%                     Ejemplo: {'no direccionales', 'direccionales'}
%                   
%       'xlim'   ---> matriz de 1x2 con los valores de los limites del eje
%                     horizontal ejemplo: [-2 4]
%
%       'smooth' ---> setea si suavizar las curvas con la funcion "smooth"
%
%       'span'   ---> setea el ancho de la ventana de la función "smooth".
%                     No hace nada si no está activada la opción de
%                     suavizado
leg = {'otras', 'seleccionadas'};
xlimit = [-4, 19];
useSmooth = false;
span = 3;
for arg = 1:2:length(varargin)
    switch lower(varargin{arg})
        case 'legend'
            leg = varargin{arg+1};
        case 'xlim'
            xlimit = varargin{arg+1};
        case 'smooth'
            useSmooth = varargin{arg+1};
        case 'span'
            span = varargin{arg+1};
        otherwise
            disp('"', varargin{arg}, '" is not a valid argument');
    end
end

selFileList = getFileList(selectedNeurons);
nSel = length(selFileList);

othersFileList = getFileList(allNeurons);
nOthers = length(othersFileList);
for n = length(othersFileList):-1:1
    if sum(strcmp(selFileList, othersFileList{n}))
        othersFileList(n) = [];
    end
end
nOthers = length(othersFileList);


regSel = loadVEPs(selFileList);

for r = 1:nSel
   [timeSel(:,r), vepSel(:,r)] = regSel(r).getVEP2plot(stim, 'mean', true);
   if useSmooth
       vepSel(:,r) = smooth(vepSel(:,r), span);
   end
end
figure
hold on
plot(timeSel, vepSel)
xlim(xlimit)
title(leg{2})
hold off
regOthers = loadVEPs(othersFileList);
for r = 1:nOthers
    [timeOthers(:,r), vepOthers(:,r)] = regOthers(r).getVEP2plot(stim, 'mean', true);
    if useSmooth
        vepOthers(:,r) = smooth(vepOthers(:,r), span);
    end
end
figure
hold on
plot(timeOthers, vepOthers)
xlim(xlimit)
title(leg{1})
hold off
figure
hold on
plot(mean(timeOthers, 2), mean(vepOthers,2), 'k', mean(timeSel, 2), mean(vepSel,2), 'r')
legend(leg)
xlim(xlimit)
hold off
end