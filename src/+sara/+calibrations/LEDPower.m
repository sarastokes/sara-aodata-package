classdef LEDPower < aod.builtin.calibrations.PowerMeasurement
% Power measurements for Maxwellian View which can have 1-3 LEDs
%
% Parent:
%   aod.builtin.calibrations.PowerMeasurement
%
% Syntax:
%   obj = sara.calibrations.LEDPower(calibrationDate, whichLEDs, varargin)
%
% Example:
%   obj = sara.calibrations.LEDPower('20220823', [420, 530, 660]);
%   obj.setMeasurements({5, 0.32, 0.34, 0.78})

% By Sara Patterson, 2023 (sara-aodata-package)
% -------------------------------------------------------------------------

    methods
        function obj = LEDPower(calibrationDate, whichLEDs, varargin)
            powers = repmat("Power", [1 numel(whichLEDs)]);
            for i = 1:numel(whichLEDs)
                powers(i) = string(num2str(whichLEDs(i))) + powers(i);
            end
            obj = obj@aod.builtin.calibrations.PowerMeasurement(...
                "LEDPower", calibrationDate, whichLEDs, ["Voltage", powers],...
                ["V", repmat("microwatt", [1 numel(whichLEDs)])], varargin{:});
        end
    end

    methods (Access = protected)
        function value = specifyLabel(obj)
            value = specifyLabel@aod.builtin.calibrations.PowerMeasurement(obj);
            ndf = obj.getAttr('NDF');
            value = value + sprintf("_ND%.1f", ndf);
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.builtin.calibrations.PowerMeasurement();
            
            value.add('NDF', 0, @(x) isnumeric(x), "Neutral density filter");
        end
    end
end
