function groupList = addToList(handles, groupList)

neuronList = get(handles.neuronList, 'String');

%levanto los indices de las neuronas seleccionadas
NLindex = get(handles.neuronList, 'Value');

%si la lista de neuronas seleccionadas esta� vacia le asigno la neurona que
%esta seleccionada en ese momento
if isempty(groupList)
    groupList = repmat({''},length(NLindex),1);
    for i = 1:length(NLindex)
        groupList{i} = neuronList{NLindex(i)};
    end
else
    %si no estaba vacía
    for index = NLindex
        %checkeo si la neurona ya esta en la lista
        if sum(strcmp(groupList, neuronList{index}))
            %si está en la lista la ignoro
            continue
        end
        %si no esta la agrego a la lista
        groupList{length(groupList)+1} = neuronList{index};
    end
end