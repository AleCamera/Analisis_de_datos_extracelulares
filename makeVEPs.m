function makeVEPs(fileList)

%veo en que SO estoy trabajando
if isunix
    slash = '/'; 
elseif ispc
    slash = '\';
end

for f = 1:length(fileList)
    fileName = fileList{f};
    
    GetVEP_fromDAT(fileName)
    
end

end