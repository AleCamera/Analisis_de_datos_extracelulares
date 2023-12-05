function plotPSH(handles)

if handles.stimMethod == "Code"
    indices = ismember(handles.Estimulos(:,1), handles.stims2plot);
    lista = find(indices);
    stims = zeros(length(lista),3);
    for i = 1:length(lista)
        stims (i,:) = handles.Estimulos (lista(i),:);
    end
    clear lista
    clear indices
elseif handles.stimMethod == "List"
    stims = zeros(length(handles.stims2plot),3);
    for i = 1:length(handles.stims2plot)
        stims(i,:) = handles.Estimulos(handles.stims2plot(i),:);
    end
end
tPre = str2double(get(handles.tPreStimEdit, 'string'));
tPost = str2double(get(handles.tPostStimEdit, 'string'));
[raster,index] = Sync(handles.data(:,handles.cluster),stims(:,2),'durations',[-tPre; tPost]);     % compute spike raster data
nBins = (tPre + tPost)*10;
[m,t] = SyncHist(raster, index,'mode', 'mean','durations',[-tPre; tPost], 'nBins', nBins);
t = -tPre:(nBins/(10*(nBins-1))):tPost;
figure(1);clf;bar(t,m);
figure(2);clf;  
PlotSync(raster,index, 'durations', [-tPre; tPost]);             % plot spike raster
hold on
for nStim = 1:length(stims)
    x = [stims(nStim, 3), stims(nStim, 3)+0.5];
    y = [nStim-1, nStim-0.5 ];
    annotation('arrow', x,y);
end
hold off
end