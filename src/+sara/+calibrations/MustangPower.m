classdef MustangPower < aod.builtin.calibrations.PowerMeasurement 
% MUSTANGPOWER
%
% Description:
%   Power measurements of Mustang laser
%
% Parent:
%   aod.builtin.calibrations.PowerMeasurement(calibrationDate, varargin)
%
% Constructor:
%   obj = MustangPower(calibrationDate, parent);
% -------------------------------------------------------------------------

    methods
        function obj = MustangPower(calibrationDate, varargin)
            obj = obj@aod.builtin.calibrations.PowerMeasurement(...
                "MustangPower", calibrationDate, 488,...
                ["Setting", "Power"], ["normalized", "microwatts"],...
                varargin{:});
        end
    end
end 