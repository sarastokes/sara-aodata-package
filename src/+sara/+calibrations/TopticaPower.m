classdef TopticaPower < aod.builtin.calibrations.PowerMeasurement 
% TOPTICAPOWER
%
% Description:
%   Power measurements for the Toptica laser
%
% Parent:
%   aod.builtin.calibrations.PowerMeasurement
%
% Constructor:
%   obj = TopticaPower(calibrationDate, wavelength, varargin)
% -------------------------------------------------------------------------

    methods
        function obj = TopticaPower(calibrationDate, wavelength, varargin)
            laserLines = [488, 515, 561, 640];
            assert(ismember(wavelength, laserLines), 'TopticaPower: Invalid laser line!');
            
            obj = obj@aod.builtin.calibrations.PowerMeasurement(...
                "TopticaPower", calibrationDate, wavelength,... 
                ["Toptica", "Software", "Power"], ["normalized", "normalized", "microwatt"], varargin{:});
        end
    end

    methods (Access = protected)
        function value = setLabel(obj)
            value = sprintf('TopticaPower%unm', obj.wavelength);
        end
    end
end 