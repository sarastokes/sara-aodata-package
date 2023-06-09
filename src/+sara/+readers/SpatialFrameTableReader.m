classdef SpatialFrameTableReader < aod.common.FileReader

    properties (SetAccess = protected)
        frameRate
    end

    methods 
        function obj = SpatialFrameTableReader(fName)
            obj = obj@aod.common.FileReader(fName);
        end

        function out = readFile(obj)
            warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
            T = readtable(obj.fullFile);
            if isempty(T)
                out = [];
                return
            end
            T = T(:, [1, 3, 4, 7:11]);
            T.Properties.VariableNames = {'Frame', 'TimeStamp',...
                'TimeInterval', 'StimIndex',...
                'Background', 'StimLocX', 'StimLocY', 'TrackingStatus'};
            warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');

            out = T.TimeStamp - T.TimeStamp(1) + T.TimeInterval(1);
            out = out / 1000;

            obj.Data = out;

            obj.frameRate = 1000/mean(T.TimeInterval);
        end
    end

    methods (Static)
        function out = read(fName)
            obj = sara.readers.SpatialFrameTableReader(fName);
            out = obj.readFile();
        end
    end
end