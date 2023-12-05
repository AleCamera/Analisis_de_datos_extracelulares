% GetVEP_fromDAT
%
% Hace un event triger de la señal .dat del electrodo (n canales)
% y guarda una matriz *.spkDAT.#CLU de  [samples electrode spktime] 
%
% Samples: las necesarias para ver los segundos que se quieran
% Pico del spike centrado en 2/5 de la ventana (en 1 ms)
% Usa funciones: LoadPar - LoadCluRes - LoadSegs


function GetVEP_fromDAT(varargin)

nf = 3000;%frecuencia a la que vamos a resamplear
if nargin == 0
    [FileName,PathName,~] = uigetfile('*.dat','Seleccione archivo *.dat para analizar');
    cd(PathName)
    [FileNameXML,PathNameXML,~] = uigetfile('*.xml','Seleccione archivo *.xml para analizar');
else
    cd(varargin{1})
    [FileName,PathName,~] = uigetfile('*.dat','Seleccione archivo *.dat para analizar');
    [FileNameXML,PathNameXML,~] = uigetfile('*.xml','Seleccione archivo *.xml para analizar');
end
[PathNameXML, FileNameXML(1:end-4)];
FileInfo = LoadPar([PathNameXML, FileNameXML(1:end-4)]);
A = dir([FileInfo.FileName,'.res*']);
t = 30; %segundos
Ventana =t*1000 / (1000 / FileInfo.SampleRate);
preSamples = round(Ventana/3);
of = FileInfo.SampleRate;
noCargados = [];
miss = 0;
for IND = 1 : length(A)
    
    miFile = A(IND);
    
    I4 = strfind(miFile.name,'res.');
    miElectrodo = miFile.name(I4+4:end);
    
    %[Tspk,CluID,Map,Par_clu] = LoadCluRes (FileInfo.FileName,miElectrodo);
    [stim, start, finish] = loadEvents([PathName, 'Estimulos.mat']);
%     I4 = strfind(FileName,'res.');
%     
%     miCluster = FileName(I4+4:end);
    
    %%modificado por Ale 04/02/20
    %si channels cuenta desde cero le sumo uno para que empiece desde 1.
    %ESTO ESTÁ MAL HECHO. SE VA A ROMPER SI TENGO MAS DE UN SpkGrp!!.
    %CORREGIR
    if find(FileInfo.SpkGrps(IND).Channels == 0)
        FileInfo.SpkGrps(IND).Channels = FileInfo.SpkGrps(IND).Channels + 1;
    end
    startSamples = start*FileInfo.SampleRate;
    for s = 1:length(stim)
        VEP(s).stim = stim(s);
        VEP(s).duration = finish(s) - start(s);
        try
            [VEP(s).traces, ~] = LoadSegs([FileInfo.FileName,'.dat'], startSamples(s)-preSamples, Ventana,...
                FileInfo.nChannels, FileInfo.SpkGrps(IND).Channels, FileInfo.SampleRate);
        catch ME
            
            miss = miss+1;
            noCargados(miss) = s;
            
        end
        if ~isempty(VEP(s).traces)
            for tr = 1:FileInfo.nChannels
                VEP(s).traces(:,tr) = removeSpks(VEP(s).traces(:,tr));
            end
        end
    end
    stimTypes = unique(stim);
    for s = 1:length(stimTypes)
        trialVEPs(s).stim = stimTypes(s);
        try
            trialVEPs(s).traces = getMeanTrialVEP(VEP, stimTypes(s));
        catch
            disp(['no pude cargar los trials del estimulo ', string(stimTypes(s))])
        end
    end
    trialVEPs = resampleVEPs(trialVEPs, nf, of);
    %salvo el archivo
    save('VEPs','trialVEPs');
end
end

function [stim, start, finish] = loadEvents(estimulosFile)

s = load(estimulosFile);
stim = s.Estimulos(:,1);
start = s.Estimulos(:,2);
finish = s.Estimulos(:,3);

end

function filtered = removeSpks(trace)
% d1 = designfilt('lowpassiir', 'FilterOrder', 12, 'HalfPowerFrequency', 0.01, 'DesignMethod', 'butter');
% filtered = filtfilt(d1, trace);
[c,d] = butter(2, 30/(30000/2));
filtered = filtfilt(c,d, trace);
end


function trialVEPs = getMeanTrialVEP(VEP, stimCode)
f = 0;
for s=1:length(VEP)
    if VEP(s).stim == stimCode && ~isempty(VEP(s).traces)
        f = f+1;
        trialVEPs(:,f) = mean(VEP(s).traces, 2);
    end
end
end