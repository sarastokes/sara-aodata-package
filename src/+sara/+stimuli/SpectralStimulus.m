classdef SpectralStimulus < aod.builtin.stimuli.VisualStimulus
% A spatially-uniform visual stimulus presented with 3 primaries
%
% Parent:
%   aod.builtin.stimuli.VisualStimulus
%
% Constructor:
%   obj = SpectralStimulus(parent, protocol, presentation)
%
% See also:
%   sara.calibrations.MaxwellianView
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        % LED voltages at each sample time (V)
        presentation
        % LED voltages at each stimulus update (V)
        voltages
        % Frame rate calculated from frame times (Hz)
        frameRate
    end

    % Derived properties
    properties (SetAccess = protected)
        % Background intensity (uW)
        intensityMean
        % Minimum and maximum intensity (uW)
        intensityRange
    end

    methods
        function obj = SpectralStimulus(protocol)
            obj = obj@aod.builtin.stimuli.VisualStimulus(protocol);
            
        end

        function setFrameRate(obj, frameRate)
            assert(isnumeric(frameRate), 'frameRate must be a number');
            obj.frameRate = frameRate;
        end

        function setPresentation(obj, presentation)
            obj.presentation = presentation;
        end

        function setVoltages(obj, voltages)
            obj.voltages = voltages;
        end

        function loadFrames(obj, fName)
            % Get the LED values during each frame
            %
            % Syntax:
            %   loadFrames(obj, fName)
            % -------------------------------------------------------------
            reader = sara.readers.LedFrameTableReader(fName);
            obj.setPresentation(reader.readFile());
            obj.setFrameRate(reader.frameRate);
            obj.setFile('FrameLedVoltages', fName);

            if isempty(obj.intensityMean)
                obj.getStimulusPower();
            end
        end

        function loadVoltages(obj, fName)
            % Get the command voltages in LED timing
            % -------------------------------------------------------------
            reader = sara.readers.LedVoltageReader(fName);
            obj.setVoltages(reader.readFile());
            obj.setFile('FrameLedVoltages', fName);

            if isempty(obj.intensityMean)
                obj.getStimulusPower();
            end
        end
    end

    methods (Access = protected)
        function getStimulusPower(obj)
            if isempty(obj.Calibration)
                warning('getStimulusPower:NoCalibrationFound',...
                    'Calibration must be set to determine power');
                return
            end

            if isempty(obj.presentation)
                RGB = obj.voltages;
            else
                RGB = obj.presentation;
            end 

            % Assume the first voltage is the background intensity
            

        end
    end
end