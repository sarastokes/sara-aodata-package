classdef ContrastRamp < sara.protocols.SpectralProtocol
% CONTRASTRAMP
%
% Description:
%   A sinusoidal modulation linearly increasing in contrast
%
% Parent:
%   sara.protocols.SpectralProtocol
%
% Constructor:
%   obj = sara.protocols.ContrastRamp(calibration, varargin)
%
% Properties:
%   temporalFrequency               Frequency of the modulation (Hz)
%   minContrast                     Minimum contrast (0-1)
%   maxContrast                     Maximum contrast (0-1)
%   reversed                        Reverse stimulus (high to low contrast)
% Properties (inherited)
%   preTime
%   stimTime
%   tailTime
%   baseIntensity

% By Sara Patterson, 2023 (sara-aodata-package)
% --------------------------------------------------------------------------

    properties
        temporalFrequency           double  {mustBePositive}
        minContrast                 double  {mustBePositive}
        maxContrast                 double  {mustBePositive}
        reversed                    logical 
    end

    methods
        function obj = ContrastRamp(calibration, varargin)
            obj = obj@sara.protocols.SpectralProtocol(...
                calibration, varargin{:});

            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'MinContrast', 0.02, @isnumeric);
            addParameter(ip, 'MaxContrast', 1, @isnumeric);
            addParameter(ip, 'TemporalFrequency', 10, @isnumeric);
            addParameter(ip, 'Reversed', false, @islogical);
            parse(ip, varargin{:});

            obj.temporalFrequency = ip.Results.TemporalFrequency;
            obj.minContrast = ip.Results.MinContrast;
            obj.maxContrast = ip.Results.MaxContrast;
            obj.reversed = ip.Results.Reversed;

            % Overwrites
            obj.contrast = obj.maxContrast;
        end
        
        function stim = generate(obj)
            sampleTime = 1/obj.stimRate;  % sec
            cnstPts = obj.sec2pts(obj.stimTime);
            cnstDelta = (obj.maxContrast - obj.minContrast) / cnstPts;

            stim = zeros(1, cnstPts);
            for i = 1:cnstPts
                x = i*sampleTime;
                stim(i) = (obj.minContrast+i*cnstDelta) * ...
                    sin(2*pi*x*obj.temporalFrequency) *...
                    obj.baseIntensity + obj.baseIntensity;
            end

            if obj.reversed
                stim = fliplr(stim);
            end

            % Add pre time and tail time
            stim = obj.appendPreTime(stim);
            stim = obj.appendTailTime(stim);
        end

        function ledValues = mapToStimulator(obj)
            ledValues = mapToStimulator@sara.protocols.SpectralProtocol(obj);
        end

        function fName = getFileName(obj)
            % GETFILENAME
            %
            % Syntax:
            %   fName = getFileName(obj)
            % -------------------------------------------------------------
            if obj.reversed
                stimName = 'reverse_contrastramp';
            else
                stimName = 'contrastramp';
            end
            
            fName = sprintf('%s_%s_%uhz_%us_%up_%ut',... 
                lower(char(obj.spectralClass)), stimName,...
                obj.temporalFrequency, obj.stimTime,...
                100*obj.baseIntensity, floor(obj.totalTime));
        end
    end
end