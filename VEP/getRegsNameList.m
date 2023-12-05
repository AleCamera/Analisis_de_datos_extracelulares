function nameList = getRegsNameList(regsList)
nameList = cell(length(regsList),1);
for r = 1:length(regsList)
    nameList{r} = regsList(r).name;
end
nameList = cellstr(nameList);
end