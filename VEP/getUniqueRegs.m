function uniqueRegs = getUniqueRegs(regsList)
nameList = getRegsNameList(regsList);
uniqueRegs = regsList;
uniqueNameList = unique(nameList);
for un = 1:length(uniqueNameList)
    found = 0;
    indx = [];
    for n = 1:length(nameList)
        if strcmp(uniqueNameList{un}, nameList{n})
            found = found + 1;
            indx(found) = n;
        end
        
    end
    if found > 1
        for f = length(indx):-1:2
            nameList(indx(f)) = [];
            uniqueRegs(indx(f)) = [];
        end
    end
end
                
            
end