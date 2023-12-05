%toma datos de neuronViewer y los convierte al formato NeuronViewer2.0¡
classdef NVDataUpdater
    properties
        list
    end
    methods
        function obj = NVDataUpdater(neurons)
            if nargin == 1
                obj.list = neurons;
            end
        end
        function updateList(obj)
            for i = 1:length(obj.list)
                obj.list{i}.name
                newInfo =  clusterName2_0(obj.list{i});
                obj.list{i}.fecha = newInfo.fecha;
                obj.list{i}.registro = newInfo.registro;
                obj.list{i}.cluster = newInfo.cluster;
                obj.list{i}.actvidad = newInfo.actividad;
                obj.list{i}.categoria = newInfo.categoria;
                obj.list{i}.direccional = newInfo.direccional;
                obj.list{i}.rtaLooming = newInfo.rtaLooming;
                obj.list{i}.rtaCuadrados = newInfo.rtaCuadrados;
                obj.list{i}.rtaFlujos = newInfo.rtaFlujos;
                obj.list{i}.rtaContraste = newInfo.rtaContraste;
            end
            [file,path] = uiputfile('*.mat', 'Guardar la lista', 'ClusterType.mat');
            if path == 0
                return
            end
            neurons = obj.list;
            %guardo las neuronas
            save([path, '/', file], 'neurons');
        end
    end
end