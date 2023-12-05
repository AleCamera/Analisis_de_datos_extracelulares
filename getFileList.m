function fileList = getFileList(neurons)
%Toma una lista de neuronas y devuelve una lista con todas las carpetas
%donde se registraron las neuronas de la lista (sin repetir carpetas).
% fileList es un cell array que tiene en cada celda el path a una carpeta
nFiles = 0;
fileList ={};
if isa(neurons, 'Neuron')
    for n = 1:length(neurons)
        if isempty(strcmp(fileList, neurons(n).folder)) | ~strcmp(fileList, neurons(n).folder)
            nFiles = nFiles + 1;
            fileList{nFiles,1} = char(neurons(n).folder);
        end       
    end
    fileList = sort(fileList);
else
    for n = 1:length(neurons)
        if isempty(strcmp(fileList, neurons{n}.file)) | ~strcmp(fileList, neurons{n}.file)
            nFiles = nFiles + 1;
            fileList{nFiles,1} = neurons{n}.file;
        end
        
    end
    fileList = sort(fileList);
end
end