function compareVEPandRasters(n, stim, varargin)
%Genera una figura y coloca en un subplot por trial los VEPs y rasters de
%la neurona seleccionada.
%
%
%   n       ---> una neurona(formato struct)
%
%   stim    ---> el codigo que corresponde a un estímulo (ej: 25)
%
%De momento no trabaja con la Clase "Neuron" ni con listas de estímulos
addPSH = false;
addDecorations = false;
xlimit = [];
for arg = 1:2:length(varargin)
    switch lower(varargin{arg})
        case 'psh'
            addPSH = varargin{arg+1};
        case 'decorations'
            addDecorations = varargin{arg+1};
        case 'xlim'
            xlimit = varargin{arg+1};
        otherwise
            disp(['"', varargin{arg}, '" is not a valid argument'])
    end
end
neuron = Neuron(n);

reg = loadVEPs(neuron.folder);
[time, VEP] = getVEP2plot(reg, stim);
[np, nt] = size(VEP);
[raster, index, stimList] = neuron.getRasters(stim, 'durations', [10, 5]);

figure
hold on
for t = 1:nt
    r = raster(index == t);
    ind = index(index == t);
    subplot(nt, 1, t)
    plot(time, VEP(:,t))
    maxFreq = 200;
    if addDecorations
        if stim == 25 || stim == 26
            vargs = {'OpticFlow', 18/6};
        else
            vargs = {};
        end
        addPSHDecorations(stim, neuron.getMeanStimDuration(stim), maxFreq, vargs{:})
        
    end
    PlotRasters_oneColor(r, ind, [-10 20],maxFreq, 'relativesize', 0.4, 'position', 'bottom')
    if xlimit
        xlim(xlimit)
    end
end
hold off
%get spike-potential correlation


for tr = 1:nt
    r = raster( index == tr);
    
    r = r(r>0 & r< 15);
    pot = zeros(length(r), 1);
    respTime = time(time> 0 & time< 5);
    stimResponseVEP = VEP(:,tr);
    stimResponseVEP = stimResponseVEP(time>0 & time< 15);
    for spk = 1:length(r)
        [~, i] = min(abs(respTime(:) - r(spk)));
        pot(spk) = stimResponseVEP(i);
    end
    figure
    hold on
    [N, edges] =  histcounts(pot, 'BinWidth', 5);
    N = N/max(N);
    plot(edges(2:end), N)
    [N, edges] =  histcounts(stimResponseVEP, 'BinWidth', 5);
    N = N/max(N);
    plot(edges(2:end), N);
    hold off
    
end
assignin('base', 'r', r)
assignin('base', 'VEP', VEP)
assignin('base', 'pot', pot)




end
