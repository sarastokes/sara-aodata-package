classdef LEDPower < aod.builtin.calibrations.PowerMeasurement
% Power measurements for Maxwellian View which can have 1-3 LEDs
%
% Parent:
%   aod.builtin.calibrations.PowerMeasurement
%
% Syntax:
%   obj = sara.calibrations.LEDPower(calibrationDate, whichLEDs)
%
% Example:
%   obj = sara.calibrations.LEDPower('20220823', [420, 530, 660]);
% -------------------------------------------------------------------------

    methods
        function obj = LEDPower(calibrationDate, whichLEDs)
            obj = obj@aod.builtin.calibrations.PowerMeasurement(...
                [], calibrationDate, whichLEDs, 'SettingUnit', 'V');
        end
    end
end
