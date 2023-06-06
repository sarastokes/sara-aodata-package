classdef FluorescenceImaging < sara.channels.Channel 
% Fluorescence imaging channel for calcium imaging
%
% Parent:
%   sara.channels.Channel
%
% Constructor:
%   obj = sara.channels.FluorescenceImaging(laserName, varargin)
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

% 
% -------------------------------------------------------------------------

    properties (Constant, Access = private)
        LASERS = ["Toptica", "Mustang"]
    end

    methods
        function obj = FluorescenceImaging(laserName, varargin)
            obj@sara.channels.Channel('FluorescenceImaging', varargin{:});

            laserName = convertCharsToStrings(laserName);
            if ~ismember(laserName, obj.LASERS)
                error('FluorescenceImaging:InvalidLaser',...
                    'Laser %s not recognized', laserName);
            end

            ip = aod.util.inputParser();
            addParameter(ip, 'LaserLine', [], @isnumeric);
            parse(ip, varargin{:});

            laserLine = ip.Results.LaserLine;

            obj.createChannel(laserLine);
        end
    end

    methods (Access = protected)
        function createChannel(obj)        
            channel.add(aod.builtin.devices.PMT('VisiblePMT', ...
                'Manufacturer', "Hamamatsu", 'Model', "H16722"));
            if strcmp(laserName, 'Mustang')
                obj.add(aod.builtin.devices.LightSource(488, ...
                    'Manufacturer', "Qioptiq", 'Model', "Mustang"));
                obj.addBandpassFilter('520_15');
            else
                obj.add(sara.devices.Toptica(laserLine));
            end
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@sara.channels.Channel();

            value.add('Fluorophore', [], @isstring,...
                'Fluorophore being imaged by the channel');
        end
    end
end 