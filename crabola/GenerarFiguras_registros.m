list = readtable('/home/usuario/Registros/recording_list.txt', 'delimiter', ',');
tic
for f = 1:height(list)
    recs(f) = CrabolaEphysRec('file', char(list.folder(f)), 'SampleFreq', list.sampleFreq(f));
end
disp('Cargar los archivos me tomó:')
toc
tic
params.stims = [2,33,34,25,26,150];
params.title = {'looming', 'cuadrado BTF', 'cuadrado FTB', 'flujo BTF', 'flujo FTB', 'caminata pasiva'};
prams.xlim = {[-10,13],[-10 10], [-10 10], [-10 25], [-10 25], [-10 600]};
params.binSize = [50 50 50 50 50 2000];
for f = 1:length(recs)
    cd('/home/usuario/Registros/Graficos')
    mkdir(recs(f).date);
    cd([pwd '/' recs(f).date])
    for n = 1:length(recs(f).stims)
        recStims(n) = recs(f).stims(n).code;
    end
    
    for c = 2:length(recs(f).neurons)
        for p = 1:length(params.stims)
            
            if any(recStims == params.stims(p))
                recs(f).makeMixedPlots(params.stims(p), c, 'xlim', prams.xlim{p},...
                                       'title', params.title{p}, 'behavior',...
                                       'tras', 'BinSize', params.binSize(p),...
                                       'plotMean', true)
                figName = ['ID' num2str(recs(f).crabID) '_clu-' num2str(c) '_' params.title{p} '_tras.pdf'];
                saveas(gcf, figName)
                figName = ['ID' num2str(recs(f).crabID) '_clu-' num2str(c) '_' params.title{p} '_tras.png'];
                saveas(gcf, figName)
                close all;
                recs(f).makeMixedPlots(params.stims(p), c, 'xlim', prams.xlim{p}, ...
                                       'title', params.title{p}, 'behavior',...
                                       'rot', 'BinSize', params.binSize(p),...
                                       'plotMean', true)
                figName = ['ID' num2str(recs(f).crabID) '_clu-' num2str(c) '_' params.title{p} '_rot.pdf'];
                saveas(gcf, figName)
                figName = ['ID' num2str(recs(f).crabID) '_clu-' num2str(c) '_' params.title{p} '_rot.png'];
                saveas(gcf, figName)
                close all
            end
        end
    end
end
disp('generar los gráficos me tomó:' )
toc
