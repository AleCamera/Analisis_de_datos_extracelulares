classdef NVDataManager
    properties
        data
    end
    methods
        function obj = NVDataManager(neurons)
            if nargin == 1
                obj.data = neurons;
            end
        end
        function showNames
            for i = 1:length(data)
                data{i}.name
            end
        end
    end
end
