function md = loadBallData(path, varargin)

%Factor de conversi�n de unidades de mouse a cm
convK = 0.00661;
diametro = 20.5;
% keywords = {'crabola', 'data'};
keyword_old = 'crabola';
keyword_new = 'data';
multi = false;
for arg = 1:2:length(varargin)
    switch lower(varargin{arg})
        case 'factor'
            convK = varargin{arg+1};
        case 'diameter'
            diametro = varargin{arg+1};
        case 'keyword'
            keywords = varargin{arg+1};
        case 'multi'
            multi = varargin{arg+1};
    end
end

cd(path)
files = dir;
if multi
    nFiles = 0;
    for f = 1:length(files)
        name = string(files(f).name);
        if name.contains(keyword_old)
            nFiles = nFiles+1;
            file_multi(nFiles) = name;
            old_format = true;
        elseif name.contains(keyword_new)
            nFiles = nFiles+1;
            file_multi(nFiles) = name;
            old_format = false;
            
        end
        
        %     if name.contains(keywords)
        %         file = name;
        %         break
        %     end
        if f == length(files) && nFiles == 0
            error('I cannot find the crabola data file');
        end
    end
else
    nFiles = 1;
end

for f = 1:length(files)
    name = string(files(f).name);
    if name.contains(keyword_old)
        file = name;
        old_format = true;
        break
    elseif name.contains(keyword_new)
        file = name;
        old_format = false;
        break
    end
        
%     if name.contains(keywords)
%         file = name;
%         break
%     end
    if f == length(files)
        error('I cannot find the crabola data file');
    end
end

%preparo un ID vacio
crabID = '';
for i = 1:nFiles
    if multi
        file = file_multi(i);
    end
if old_format
    %levanto los datos en el formato nuevo
    rawData = csvread(fullfile(path, file));
    %genero el vector de tiempos
    time = rawData(:,5) + (rawData(:,6)/1000000);
    time = time - time(1,1);
    
    %busco los índices de inicio y final de cada estímulo.
    stimStartIND = find(rawData(:,1) == 130);
    stimFinishIND = find(rawData(:,1) == 131);
    nStims = length(stimStartIND);
    
    %me fijo los tiempos de inicio y final de cada estímulo
    stimStart = time(stimStartIND);
    stimFinish = time(stimFinishIND);
    
    %Genero el una matriz con los datos del mouse
    miceData(:,1:4) = rawData(:,1:4);
    %elimino las marcas de inicio y final los datos de mouse y de los tiempos:
    for n = nStims:-1:1
        time(stimFinishIND(n)) = [];
        time(stimStartIND(n)) = [];
        miceData = removerows(miceData, 'ind', stimFinishIND(n));
        miceData = removerows(miceData, 'ind', stimStartIND(n));
    end
else
    %levanto los datos en el formato nuevo
    dataTable = readtable(file);
    miceData = [dataTable.x1, dataTable.y1, dataTable.x2, dataTable.y2];
    %cargo el vector tiempos
    time = dataTable.time;
    
    %Cargo el ID en el caso de estar presente
    fileParts = file.split('-');
    for p = 1:length(fileParts)
        part = char(fileParts(p));
        if length(part) > 2 && contains(part,'ID') 
            crabID = part(3:end);
        end
    end
    
    file_char = char(file);
    %Ahora busco el archivo de los timeStamps
    dataFileMark = file_char(1:end-8);
    tsFile = [dataFileMark, 'timeStamps.txt'];
    tsTable = readtable(tsFile);
%     ts = csvread(fullfile(path, tsFile));
%     assignin('base', 'time', time);
%     assignin('base', 'ts', ts);
    %y genero los vectores con los tiempos de inicio y final de cada
    %estimulo.
%     stimStart = ts(:,1);
%     stimFinish = ts(:,2);
    stimStart = tsTable.t_start;
    stimFinish = tsTable.t_finish;
    
    nStims = length(stimStart);
    
    %me quedo con los datos de la crabola
%     miceData = rawData(:,1:4);
    %assignin('base', 'miceData', miceData)
    
end
%calculo cuando más lee un mouse que el otro
relacionM2M1 = sum(abs(miceData(:,4)))/sum(abs(miceData(:,2)));

%transformo los datos de desplazamiento en unidades de mouse a cm.
miceData(:,1:2) =  miceData(:,1:2) * convK;
miceData(:,3:4) = miceData(:,3:4) * convK/relacionM2M1;

%ahora que tengo los datos en centímietros genero mi set de datos.
md(i) = MiceData(miceData, time, stimStart, stimFinish, nStims, diametro, crabID);
end
end