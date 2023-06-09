classdef SawtoothModulation < sara.protocols.SpectralProtocol
% TEMPORALMODULATION
%
% Description:
%   Periodic sawtooth modulation
%
% Parent:
%   sara.protocols.SpectralProtocol
%
% Constructor:
%   obj = TemporalModulation(calibration, varargin)
%
% Properties:
%   preTime
%   stimTime
%   tailTime
%   baseIntensity
%   contrast
%   temporalFrequency               Hz
%   polarityClass                   'positive' or 'negative'           
% -------------------------------------------------------------------------

    properties 
        temporalFrequency
        polarityClass
    end

    methods 
        function obj = SawtoothModulation(calibration, varargin)
            obj = obj@sara.protocols.SpectralProtocol(...
                calibration, varargin{:});
            
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'TemporalFrequency', 5, @isnumeric);
            addParameter(ip, 'PolarityClass', 'positive',...
                @(x) ismember(x, {'positive', 'negative'}));
            parse(ip, varargin{:});

            obj.temporalFrequency = ip.Results.TemporalFrequency;
            obj.polarityClass = ip.Results.PolarityClass;
        end
    end

    methods
        function stim = generate(obj)
            % Sawtooth is calculated at 1 Hz and temporal frequency is 
            % accounted for by adjusting the time scaling. I'm using this 
            % because there were odd artifacts in the builtin sawtooth 
            % function so I have a work-around with the Symbolic Math 
            % Toolbox below that calculates sawtooths only at 1 Hz. 
            % It's slow, but it's working... might go back and make this 
            % better at some point.
            dt = obj.temporalFrequency / obj.stimRate;
            t = dt:dt:obj.stimTime*obj.temporalFrequency;

            %stim = sawtooth(2 * pi * obj.temporalFrequency * t);

            digits(6)
            syms f(x);
            f(x) = x-fix(x);
            stim = double(f(t));
            stim = stim/max(stim);

            if strcmp(obj.polarityClass, 'positive')
                stim = fliplr(stim);
                % Remove first drop
                [~, firstPeak] = findpeaks(stim);
                for i = 1:firstPeak
                    if stim(i) < 0.5
                        stim(i) = 0.5;
                    end
                end
            end
            stim = 2*obj.amplitude * stim;

            stim = obj.appendPreTime(stim);
            stim = obj.appendTailTime(stim);
        end

        function ledValues = mapToStimulator(obj)
            ledValues = mapToStimulator@sara.protocols.SpectralProtocol(obj);
        end

        function fName = getFileName(obj)
            if obj.contrast < 1
                contrastTxt = sprintf('%uc_', 100*obj.contrast);
            else
                contrastTxt = '';
            end
            if strcmp(obj.polarityClass, 'positive')
                polarityTxt = 'on';
            else
                polarityTxt = 'off';
            end
            fName = sprintf('%s_%s_sawtooth_%uhz_%s%up_%ut',...
                lower(char(obj.spectralClass)), polarityTxt,... 
                obj.temporalFrequency, contrastTxt,... 
                100*obj.baseIntensity, obj.totalTime);
        end
    end
end 