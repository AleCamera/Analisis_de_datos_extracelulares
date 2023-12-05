function reg = loadVEPs(fileList, path, varargin)
%Toma el string de una carpeta archivo o un cell array con una serie
%carpetas y me devuelve los VEPrecordings que corresponden a esos archivos;
%veo en que SO estoy trabajando
if isunix
    slash = '/';
elseif ispc
    slash = '\';
end
if nargin == 1
    if iscell(fileList)
        for f = 1:length(fileList)
            fileName = fileList{f};
            disp('loading...')
            disp(fileName)
            cd(fileName)
            if ~isfile('VEPs.mat')
                GetVEP_fromDAT(fileName)
            end
            load('VEPs.mat', 'trialVEPs')
            rec(f).path = fileName;
            rec(f).VEPs = trialVEPs;
            rec(f).sampleRate = 3000;
            reg(f) = VEPrecording(rec(f));
        end
    elseif isstring(fileList) || ischar(fileList)
        fileName = fileList;
        disp('loading...')
        disp(fileName)
        cd(fileName)
        if ~isfile('VEPs.mat')
            GetVEP_fromDAT(fileName)
        end
        load('VEPs.mat', 'trialVEPs')
        reg.path = fileName;
        reg.VEPs = trialVEPs;
        reg.sampleRate = 3000;
        reg = VEPrecording(reg);
    end
else
    if iscell(fileList)
        for f = 1:length(fileList)
            file = fileList{f};
            disp('loading...')
            disp(file)
            load(fullfile(path, file), 'trialVEPs');
            rec(f).path = path;
            rec(f).VEPs = trialVEPs;
            rec(f).sampleRate = 3000;
            rec(f).name = file(1:end-4);
            reg(f) = VEPrecording(rec(f));
        end
    else
        file = fileList;
        disp('loading...')
        disp(file)
        load(fullfile(path, file), 'trialVEPs');
        reg.path = path;
        reg.VEPs = trialVEPs;
        reg.sampleRate = 3000;
        reg.name = file(1:end-4);
        reg = VEPrecording(reg);
    end
end

end