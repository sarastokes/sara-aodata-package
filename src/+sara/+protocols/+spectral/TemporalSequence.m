classdef TemporalSequence < sara.protocols.SpectralProtocol 

    properties 
        stepTime
        intensity
    end   
    
    properties (SetAccess = private)
        numSteps
    end

    methods
        function obj = TemporalSequence(calibration, stimTime, varargin)
            obj = obj@sara.protocols.SpectralProtocol( ...
                calibration, 'StimTime', stimTime, varargin{:});

            ip = aod.util.InputParser();
            addParameter(ip, 'StepTime', [1 3 5 10], @isnumeric);
            addParameter(ip, 'Intensity', [], @isnumeric);
            parse(ip, varargin{:});

            obj.intensity = ip.Results.Intensity;
            obj.stepTime = ip.Results.StepTime;

            % Input checking
            assert(nnz(obj.stepTime > obj.stimTime) == 0, ...
                'Intensities are lower than baseIntensity');

            % Derived properties
            obj.numSteps = numel(obj.stepTime);
            obj.contrast = (ip.Results.Intensity - obj.baseIntensity) ...
                / obj.baseIntensity;
        end

        function stim = generate(obj)
            stim = obj.baseIntensity + zeros(1, obj.totalPoints);

            prePts = obj.sec2pts(obj.preTime);
            stimPts = obj.sec2pts(obj.stimTime);

            for i = 1:obj.numSteps
                stepPts = obj.sec2pts(obj.stepTime(i));
                stim(prePts + ((i - 1) * stimPts) + 1:prePts + ((i - 1) * stimPts) + stepPts) = obj.intensity;
            end

        end

        function ledValues = mapToStimulator(obj)
            ledValues = mapToStimulator@sara.protocols.SpectralProtocol(obj);
        end

        function fName = getFileName(obj)
            fName = sprintf('%s_temporal_seq', lower(char(obj.spectralClass)));

            for i = 1:obj.numSteps
                fName = sprintf('%s_%us', fName, obj.stepTime(i));
            end

            fName = sprintf('%s_%ui_%up_%ut', fName, ...
                round(100*obj.intensity), round(100 * obj.baseIntensity), obj.totalTime);
        end
    end

    methods (Access = protected)
        function value = calculateTotalTime(obj)
            value = obj.preTime + (obj.numSteps * obj.stimTime) + obj.tailTime;
        end
    end
end 