classdef Chirp < sara.protocols.SpectralProtocol
% CHIRP
%
% Description:
%   A sinusoidal modulation linearly increasing in temporal frequency
%
% Parent:
%   sara.protocols.SpectralProtocol
%
% Constructor:
%   obj = Chirp(calibration, varargin)
%
% Properties:
%   startFreq                       First frequency (hz)
%   stopFreq                        Final frequency (hz)
%   reversed                        Reverse chirp (high to low freqs)
% Properties (inherited)
%   preTime
%   stimTime
%   tailTime
%   baseIntensity
%

% By Sara Patterson, 2023 (sara-aodata-package)
% --------------------------------------------------------------------------

    properties
        startFreq
        stopFreq
        reversed
        square
    end

    methods
        function obj = Chirp(calibration, varargin)
            obj = obj@sara.protocols.SpectralProtocol(...
                calibration, varargin{:});

            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'StartFreq', 0.5, @isnumeric);
            addParameter(ip, 'StopFreq', 30, @isnumeric);
            addParameter(ip, 'Reversed', false, @islogical);
            addParameter(ip, 'Square', false, @islogical);
            parse(ip, varargin{:});

            obj.startFreq = ip.Results.StartFreq;
            obj.stopFreq = ip.Results.StopFreq;
            obj.reversed = ip.Results.Reversed;
            obj.square = ip.Results.Square;

        end
        
        function stim = generate(obj)
            sampleTime = 1/obj.stimRate;  % sec
            chirpPts = obj.sec2pts(obj.stimTime);
            hzPerSec = obj.stopFreq / obj.stimTime;

            stim = zeros(1, chirpPts);
            if obj.square
                for i = 1:chirpPts
                    x = i*sampleTime;
                    stim(i) = obj.contrast * sign(sin(pi*hzPerSec*x^2))...
                        * obj.baseIntensity + obj.baseIntensity;
                end
            else
                for i = 1:chirpPts
                    x = i*sampleTime;
                    stim(i) = obj.contrast * sin(pi*hzPerSec*x^2)...
                        * obj.baseIntensity + obj.baseIntensity;
                end
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
                stimName = 'reverse_chirp';
            else
                stimName = 'chirp';
            end
            if obj.square
                stimName = ['square_', stimName];
            end

            if obj.contrast ~= 1
                stimContrast = sprintf('%uc_', 100*obj.contrast);
            else
                stimContrast = '';
            end
            
            fName = sprintf('%s_%s_%s%us_%up_%ut',... 
                lower(char(obj.spectralClass)), stimName, stimContrast, obj.stimTime,...
                100*obj.baseIntensity, floor(obj.totalTime));
        end
    end
end