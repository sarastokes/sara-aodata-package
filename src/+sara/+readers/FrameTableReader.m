classdef FrameTableReader < aod.common.FileReader 
% FRAMETABLEREADER
%
% Description:
%   Read first 3 columns of frame table .csv file and extract timing
%
% Parent:
%   aod.common.FileReader
%
% Constructor:
%   obj = FrameTableReader(fName)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        frameRate 
    end

    methods
        function obj = FrameTableReader(fName)
            obj = obj@aod.common.FileReader(fName);
            obj.readFile();
        end

        function out = readFile(obj)
            warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
            T = readtable(obj.fullFile);
            if isempty(T)
                out = [];
                return
            end
            T = T(:, 1:3);
            T.Properties.VariableNames = {'Frame', 'TimeInterval', 'TimeStamp'};
            warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');

            out = T.TimeStamp - T.TimeStamp(1) + T.TimeInterval(1);
            out = out / 1000;

            obj.Data = out;
            obj.frameRate = 1000/mean(T.TimeInterval);
        end
    end
end 