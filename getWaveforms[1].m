function waves = getWaveforms(path, nCluster)
cd(path)
%[FileName,~,~] = uigetfile('*.spkDAT.mat','Seleccione archivo *spkDAT.mat para usar');
[FileName,~,~] = uigetfile('*.mat','Seleccione archivo *spkDAT.mat para usar');
load([path '/' FileName]);

[nWavePoints, nElectrodes, nSpikes] = size(Spk.Segs);

if length(Spk.CluID) > nSpikes
    Spk.CluID = Spk.CluID(1:nSpikes);
end
for clu = min(Spk.CluID):max(Spk.CluID)
    spkIndx = find(Spk.CluID == clu);
    for elec = 1:nElectrodes
        for spk = 1:length(spkIndx)
            try
                cluster{clu}(elec).voltage(:,spk) = Spk.Segs(:, elec, spkIndx(spk));
            catch ME
                clu
                elec
                spk
                assignin('base', 'spkIndx', spkIndx)
                rethrow(ME)
            end
        end
        %aplico un detrend para remover el offset que hay por los LFPs
        cluster{clu}(elec).voltage = detrend(cluster{clu}(elec).voltage);
    end
end

bestCh = zeros(max(Spk.CluID),1); 
maxSpike = zeros(max(Spk.CluID),1);
for clu = min(Spk.CluID):max(Spk.CluID)
    for elec = 1:nElectrodes
        if max(abs(mean(cluster{clu}(elec).voltage'))) > maxSpike(clu)
            maxSpike(clu) = max(abs(mean(cluster{clu}(elec).voltage')));
            bestCh(clu) = elec;
        end
    end
end
%figure
%plot(cluster{nCluster}(bestCh(nCluster)).voltage(:,randi(length(cluster{nCluster}(bestCh(nCluster)).voltage), 1, 20)))
waves = mean(cluster{nCluster}(bestCh(nCluster)).voltage');
end