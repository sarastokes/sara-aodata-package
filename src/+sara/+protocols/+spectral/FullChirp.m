classdef FullChirp < sara.protocols.SpectralProtocol

    properties 
        stepTime 
        crfTime 
        crfFreq
        chirpTime
        startFreq
        stopFreq 
        breakTime
        maxContrast 
        minContrast 
        startIntensity 
        stepIntensity
    end

    methods
        function obj = FullChirp(calibration, varargin)
            obj = obj@sara.protocols.SpectralProtocol(calibration, varargin{:});

            ip = aod.util.InputParser();
            addParameter(ip, 'StartIntensity', 0, @isnumeric);
            addParameter(ip, 'StepIntensity', 1, @isnumeric);
            addParameter(ip, 'ChirpTime', 100, @isnumeric);
            addParameter(ip, 'StartFreq', 0.5, @isnumeric);
            addParameter(ip, 'StopFreq', 30, @isnumeric);
            addParameter(ip, 'StepTime', 5, @isnumeric);
            addParameter(ip, 'CrfTime', 40, @isnumeric);
            addParameter(ip, 'CrfFreq', 8, @isnumeric);
            addParameter(ip, 'BreakTime', 5, @isnumeric);
            addParameter(ip, 'MaxContrast', 1, @isnumeric);
            addParameter(ip, 'MinContrast', 0, @isnumeric);
            parse(ip, varargin{:});

            obj.startIntensity = ip.Results.StartIntensity;
            obj.stepIntensity = ip.Results.StepIntensity;
            obj.chirpTime = ip.Results.ChirpTime;
            obj.startFreq = ip.Results.StartFreq;
            obj.stopFreq = ip.Results.StopFreq;
            obj.stepTime = ip.Results.StepTime;
            obj.crfTime = ip.Results.CrfTime;
            obj.crfFreq = ip.Results.CrfFreq;
            obj.breakTime = ip.Results.BreakTime;
            obj.maxContrast = ip.Results.MaxContrast;
            obj.minContrast = ip.Results.MinContrast;

        end

        function stim = generate(obj)
        
            sampleTime = 1/obj.stimRate;  % sec

            
            prePts = obj.sec2pts(obj.preTime);
            interPts = obj.sec2pts(obj.breakTime);
            tailPts = obj.sec2pts(obj.tailTime);

            % Pretime
            stim = obj.startIntensity + zeros(1, prePts);

            % Step
            stepPts = obj.sec2pts(obj.stepTime);
            step = cat(2, obj.stepIntensity + zeros(1, stepPts), ...
                obj.startIntensity + zeros(1, stepPts));
            stim = [stim, step];

            % Chirp
            chirpPts = obj.sec2pts(obj.chirpTime);
            hzPerSec = obj.stopFreq / obj.chirpTime;

            chirp = zeros(1, chirpPts);
            for i = 1:chirpPts
                x = i*sampleTime;
                chirp(i) = obj.contrast * sin(pi*hzPerSec*x^2)...
                    * obj.baseIntensity + obj.baseIntensity;
            end

            stim = [stim, obj.baseIntensity+zeros(1, interPts), chirp,... 
                obj.baseIntensity + zeros(1, interPts)];

            % Contrast sweep
            cnstPts = obj.sec2pts(obj.crfTime);
            cnstDelta = (obj.maxContrast - obj.minContrast) / cnstPts;

            cnst = zeros(1, cnstPts);
            for i = 1:cnstPts
                x = i*sampleTime;
                cnst(i) = (obj.minContrast+i*cnstDelta) * ...
                    sin(2*pi*x*obj.crfFreq) *...
                    obj.baseIntensity + obj.baseIntensity;
            end
            stim = [stim, cnst, obj.baseIntensity + zeros(1, interPts)];

            % Tail time
            stim = [stim, obj.startIntensity + zeros(1, tailPts)];
            
        end

        function ledValues = mapToStimulator(obj)
            ledValues = mapToStimulator@sara.protocols.SpectralProtocol(obj);
        end

        function fName = getFileName(obj)
            fName = sprintf('%s_fullchirp_%up_%ut',...
                lower(char(obj.spectralClass)), 100*obj.baseIntensity, floor(obj.totalTime));
        end

    end

    
    methods (Access = protected)
        function value = calculateTotalTime(obj)
            value = obj.preTime + (2*obj.stepTime) + ...
                obj.breakTime + obj.chirpTime + obj.breakTime + ...
                obj.crfTime + obj.breakTime + obj.tailTime;
        end
    end
end 