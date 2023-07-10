classdef Toptica < aod.builtin.devices.LightSource 
% TOPTICA
%
% Description:
%   Multiple wavelength laser
%
% Parent:
%   aod.core.LightSource
%
% Constructor:
%   obj = Toptica(laserLine, varargin)

% By Sara Patterson, 2023 (sara-aodata-package)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        laserLines
    end

    methods
        function obj = Toptica(laserLine, varargin)
            obj = obj@aod.builtin.devices.LightSource(laserLine,...
                'Manufacturer', "Toptica Photonics", 'Model', "iChrome MLE",...
                varargin{:});

            ip = aod.util.InputParser();
            addParameter(ip, 'HunterLab', false, @islogical);
            parse(ip, varargin{:});

            if ip.Results.HunterLab
                obj.laserLines = [480, 561, 630];
                obj.setDescription('Borrowed from Hunter lab');
            else
                obj.laserLines = [480, 515, 561, 630];
                obj.setAttr('SerialNumber', "30130");
            end
            %assert(ismember(laserLine, obj.laserLines), 'Invalid laser line');
            
            % obj.calibrationNames = 'sara.calibrations.TopticaPower';
        end
    end
end