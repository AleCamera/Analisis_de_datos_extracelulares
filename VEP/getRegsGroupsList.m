function groupList = getRegsGroupsList(regsList)
groupList = {};
for r = 1:length(regsList)
    grps = regsList(r).groupList;
    for g = 1:length(grps)
        if ~any(strcmp(groupList, grps{g}))
            groupList{end+1} = grps{g};
        end
    end
end