classdef NVDataManager
    properties
        list
    end
    methods
        function obj = NVDataManager(neurons)
            if nargin == 1
                obj.list = neurons;
            end
        end
        function showNames(obj)
            for i = 1:length(obj.list)
                obj.list{i}.name
            end
        end
    end
end
