% GetSPKWF
%
% Hace una spike triger de la señal del electrodo (n canales)
% y guarda una matriz *.spkFIL.#CLU de  [samples electrode spktime] 
%
% length: el ancho de waveform a cargar en ms
% type: define si uso el archivo 'fil' o 'dat'
% Pico del spike centrado en 2/5 de la ventana
% Usa funciones: LoadPar - LoadCluRes - LoadSegs

function GetSPKWF(varargin)
waveLen = 7; %ms
fileType = "fil";
for arg = 1:2:length(varargin)
    switch lower(varargin{arg})
        case 'length'
            waveLen = varargin{arg+1};
        case 'type'
            fileType = string(varargin{arg+1});
    end
end

[FileName,PathName,~] = uigetfile(['*.' char(fileType)],['Seleccione archivo *.'  char(fileType) ' para analizar']);
cd(PathName)
[FileNameXML,PathNameXML,~] = uigetfile('*.xml','Seleccione archivo *.xml para analizar');

[PathNameXML, FileNameXML(1:end-4)];
FileInfo = LoadPar([PathNameXML, FileNameXML(1:end-4)]);
A = dir([FileInfo.FileName,'.res*']);
Ventana = waveLen / (1000 / FileInfo.SampleRate);
tAlpico = Ventana*2/5;



for IND = 1 : length(A)
    
    miFile = A(IND);
    
    I4 = strfind(miFile.name,'res.');
    miElectrodo = miFile.name(I4+4:end);
    
    [Tspk,CluID,Map,Par_clu] = LoadCluRes (FileInfo.FileName,miElectrodo);
    
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

    [Segs, ~] = LoadSegs([FileInfo.FileName,'.',char(fileType)], Tspk-tAlpico, Ventana,...
        FileInfo.nChannels, FileInfo.SpkGrps(IND).Channels, FileInfo.SampleRate);
    
    %Editado por Ale 28/01/2020
    %vuelvo a la numeración de clusters que corresponde con el archuvo .clu
    CluID = CluID+1;
    %salvo el archivo
    miFileName = [FileInfo.FileName '.', num2str(miElectrodo),'_SPK_',char(fileType),'.mat'];
    Spk.Segs = Segs;
    Spk.CluID = CluID;
    Spk.sampleRate = FileInfo.SampleRate;
    save(miFileName,'Spk');
    disp('_SPK_ file saved')
end

