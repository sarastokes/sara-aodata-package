classdef ReflectancePower < aod.builtin.calibrations.PowerMeasurement
% REFLECTANCEPOWER
%
% Description:
%   Power measurements of reflectance source
%
% Parent:
%   aod.builtin.calibrations.PowerMeasurement
%
% Constructor:
%   obj = sara.calibrations.ReflectancePower(calibrationDate);

% By Sara Patterson, 2023 (sara-aodata-package)
% -------------------------------------------------------------------------

    methods
        function obj = ReflectancePower(calibrationDate, varargin)
            obj = obj@aod.builtin.calibrations.PowerMeasurement(...
                [], calibrationDate, 796, ["Setting", "Power"],...
                ["none", "microwatt"], varargin{:});
        end
    end
end