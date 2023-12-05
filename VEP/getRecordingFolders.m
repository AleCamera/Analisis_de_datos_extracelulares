function folders = getRecordingFolders(fileList)
nFiles = length(fileList);
for f = 1:nFiles
    folders{f} = getDateName(fileList{f});
    
end

end

function dateName = getDateName(file)
    f = file(25:end);
    for ch = 1:length(f)
        if f(ch) == 't'
            dateName = f(1:ch-2);
            return
        end
    end
    error('no puedo resolver el nombre del archivo')
end