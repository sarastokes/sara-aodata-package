classdef MaxwellianView < sara.channels.Channel 
% Represents the Maxwellian View stimulator on the 1P primate system
%
% Superclasses:
%   sara.channels.Channel
%
% Constructor:
%   obj = sara.channels.MaxwellianView(varargin)
%
% Examples:
%   obj = sara.channels.MaxwellianView('NDF', 0.6);
%   obj.setStimPositionImage('myimage.png');

% By Sara Patterson, 2023 (sara-aodata-package)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % Image of stimulus location on model eye
        stimPositionImage
    end

    methods
        function obj = MaxwellianView(varargin)
            obj@sara.channels.Channel('MaxwellianView', varargin{:});

            obj.createChannel();
        end

        function setStimPositionImage(obj, fName)
            % Add an image of the stimulus position on the model eye
            %
            % Syntax:
            %   setStimPositionImage(obj, fName)
            % -------------------------------------------------------------
            if nargin < 2
                fName = uigetfile();
            end

            obj.stimPositionImage = imread(fName);
            obj.setFile('StimPosition', fName);
        end
    end

    methods (Access = protected)
        function createChannel(obj)
            % Add the LEDs
            obj.add(aod.builtin.devices.LightSource(660, ...
                'Manufacturer', "ThorLabs", 'Model', "M660L4"));
            obj.add(aod.builtin.devices.LightSource(530, ...
                'Manufacturer', "ThorLabs", 'Model', "M530L4"));
            obj.add(aod.builtin.devices.LightSource(420, ...
                'Manufacturer', "ThorLabs", 'Model', "M420L4"));

            % Add the dichroic filters
            ff470 = aod.builtin.devices.DichroicFilter(470, "high", ...
                'Manufacturer', "Semrock", 'Model', "FF470-Di01");
            ff470.setTransmission(sara.resources.getResource('FF470_Di01.txt'));
            obj.add(ff470);
            ff562 = aod.builtin.devices.DichroicFilter(562, "high", ...
                'Manufacturer', "Semrock", 'Model', "FF562_Di03");
            ff562.setTransmission(sara.resources.getResource('FF562_Di03.txt'));
            obj.add(ff562);
            ff649 = aod.builtin.devices.DichroicFilter(649, "high", ...
                'Manufacturer', "Semrock", 'Model', "FF649-Di01");
            ff649.setTransmission(sara.resources.getResource('FF649_Di01.txt'));
            obj.add(ff649);
        end
    end
end 