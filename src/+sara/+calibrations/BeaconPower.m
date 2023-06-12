classdef BeaconPower < aod.builtin.calibrations.PowerMeasurement
% BEACONPOWER
%
% Description:
%   Power measurements of wavefront-sensing beacon
%
% Parent:
%   aod.builtin.calibrations.PowerMeasurement
%
% Constructor:
%   obj = sara.calibrations.BeaconPower(calibrationDate, varargin)

% By Sara Patterson, 2023 (sara-aodata-package)
% -------------------------------------------------------------------------

    methods
        function obj = BeaconPower(calibrationDate, varargin)
            obj = obj@aod.builtin.calibrations.PowerMeasurement(...
                [], calibrationDate, 847, ["Voltage", "Power"],... 
                ["microampere", "microwatt"], varargin{:});
        end
    end
end 