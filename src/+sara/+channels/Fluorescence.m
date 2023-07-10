classdef Fluorescence < sara.channels.Channel 
% Fluorescence imaging channel for calcium imaging
%
% Parent:
%   sara.channels.Channel
%
% Constructor:
%   obj = sara.channels.Fluorescence(laserName, varargin)
%
% Inputs:
%   laserName           string
%       "Mustang" or "Toptica"
%
% Optional key/value inputs:
%   laserLine           double
%       If laserName is "Toptica", specify which laser line
%   fluorophore         string
%       The fluorophore being imaged by the channel
%
% Additional key/value inputs are defined in sara.channels.Channel

% By Sara Patterson, 2023 (sara-aodata-package)
% -------------------------------------------------------------------------

    properties (Constant, Access = private)
        LASERS = ["Toptica", "Mustang"]
    end

    methods
        function obj = Fluorescence(laserName, varargin)
            obj@sara.channels.Channel('FluorescenceImaging', varargin{:});

            laserName = convertCharsToStrings(laserName);
            if ~ismember(laserName, obj.LASERS)
                error('FluorescenceImaging:InvalidLaser',...
                    'Laser %s not recognized', laserName);
            end

            ip = aod.util.InputParser();
            addParameter(ip, 'LaserLine', [], @isnumeric);
            parse(ip, varargin{:});

            laserLine = ip.Results.LaserLine;

            obj.createChannel(laserName, laserLine);
        end
    end

    methods (Access = protected)
        function createChannel(obj, laserName, laserLine)        
            obj.add(aod.builtin.devices.PMT('VisiblePMT', ...
                'Manufacturer', "Hamamatsu", 'Model', "H16722"));
            if strcmp(laserName, 'Mustang')
                obj.add(sara.devices.Mustang());
                obj.addBandpassFilter('517_20');
            else
                obj.add(sara.devices.Toptica(laserLine));
            end
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@sara.channels.Channel();

            value.add("Fluorophore",...
                "Class", "string", "Size", "(1,1)",...
                "Description", "Fluorphore being imaged by the channel");
        end
    end
end 