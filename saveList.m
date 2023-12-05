function saveList(handles, selectedList)
[file,path] = uiputfile('*.mat', 'Guardar la lista', 'ClusterType.mat');
if path == 0
    return
end
%cargo la lista de neuronas
neuronList = get(handles.neuronList, 'String');
%neurons es un cell array que va a contener a todas las neuronas a guardar
neurons =cell(1,length(selectedList));
found = 0;
%recorro la lista de todas las neuronas
for i = 1:length(neuronList)
    if sum(strcmp(neuronList{i}, selectedList))
        %si la neurona esta en la lista de las seleccionadas la guardo
        found = found+1;
        neurons{found} = handles.neurons{i};
    end
end
%guardo las neuronas
save([path, '/', file], 'neurons')
