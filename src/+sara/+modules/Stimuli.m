classdef Stimuli
% STIMULI
%
% Description:
%   A collection of functions to be applied to Stimulus entities
%
% Methods:
%   [startFrame, stopFrame] = getBackgroundRange(Stimulus)
%   [stimStart, stimStop] = getStimRange(Stimulus, varargin)
%   [ups, downs] = getModWindows(Stimulus, varargin)

% By Sara Patterson, 2023 (sara-aodata-package)
% --------------------------------------------------------------------------

    methods (Static)
        function [startFrame, stopFrame] = getBackgroundRange(Stimulus)
            %GETBACKGROUNDRANGE Get the frame window for estimating bkgd
            %
            %  [STARTFRAME, STOPFRAME] = GETBACKGROUNDRANGE(STIMULUS) 
            %   returns the start and stop frames of the background time 
            %   (preTime). The first 30% of the preTime is excluded from 
            %   the background along with the last five frames. If the 
            %   preTime=0, the entire stimulus is used for background.
            %
            % Inputs:
            %   Stimulus        aod.builtin.stimuli.VisualStimulus
            % Outputs:
            %   startFrame      double
            %       Frame number to start background estimation
            %   stopFrame       double
            %       Frame number to stop background estimation
            % --------------------------------------------------------------
            arguments
                Stimulus aod.builtin.stimuli.VisualStimulus
            end
            
            preTime = Stimulus.getAttr('preTime');
            if isempty(preTime)
                startFrame = 1;
                stopFrame = Stimulus.getAttr('totalSamples');
                return
            end
            sampleRate = Stimulus.getAttr('sampleRate');

            stimStart = round(preTime * sampleRate);
            stopFrame = stimStart - 5;
            startFrame = stimStart - (0.7 * stimStart);
        end

        function [stimStart, stimStop] = getStimRange(Stimulus, varargin)
            %GETSTIMRANGE Get the start and stop times of the stimulus
            %
            %   [STIMSTART, STIMSTOP] = GETSTIMRANGE(STIMULUS, VARARGIN)
            %   returns the start (STIMSTART) and stop (STIMSTOP) times of 
            %   the stimulus (excluding preTime and tailTime). If the "LED" 
            %   key/value pair is provided, the start and stop times will 
            %   be judged based on the trace of a specific LED. If the 
            %   "Output" key/value pair is provided, the output can be 
            %   changed from frames to seconds (as double or duration). 
            %
            % Inputs:
            %   Stimulus        sara.stimuli.SpectralStimulus
            % Optional key/value inputs:
            %   LED             1, 2 or 3
            %       Which LED to use (default is to sum RG&B)
            %   Output          "frames", "duration", "time"
            %       Whether to return frames, time (double) or duration
            %       (default = "frames")
            %
            % Outputs:
            %   stimStart       double or duration
            %       Start time of stimulus
            %   stimStop        double or duration
            %       Stop time of stimulus
            % -------------------------------------------------------------
            aod.util.mustBeEntityType(Stimulus, 'Stimulus');

            ip = aod.util.InputParser();
            addParameter(ip, 'LED', [],... 
                @(x) ismember(x, [1 2 3]));
            addParameter(ip, 'Output', "frames",...
                @(x) ismember(x, ["frames", "duration", "time"]));
            parse(ip, varargin{:});
            
            
            if ~isempty(ip.Results.LED)
                if ip.Results.LED == 1
                    trace = Stimulus.presentation.R;
                elseif ip.Results.LED == 2
                    trace = Stimulus.presentation.G;
                elseif ip.Results.LED == 3
                    trace = obj.presentation.B;
                end
            else
                trace = Stimulus.presentation.R + Stimulus.presentation.G + Stimulus.presentation.B;
            end

            bkgdValue = trace(1);
            idx = find(trace ~= bkgdValue);
            stimStart = idx(1); 
            stimStop = idx(end);

            if ip.Results.Output ~= "frames"
                stimStart = Stimulus.presentation.Time(stimStart);
                stimStop = Stimulus.presentation.Time(stimStop);
                if ip.Results.Output == "time"
                    stimStart = double(stimStart);
                    stimStop = double(stimStop);
                end
            end
        end

        function [ups, downs] = getModWindows(Stimulus, varargin)
            %GETMODWINDOWS Return increments and decrements times
            %
            %   [UPS, DOWNS] = GETMODWINDOWS(OBJ, STIMULUS)
            %   returns increment times (UPS) and decrement times (DOWNS) 
            %   relative to the baseline light level (assumed to be the 
            %   LED voltages at the first frame)
            % -------------------------------------------------------------

            aod.util.mustBeEntityType(Stimulus, 'Stimulus');

            ip = aod.util.InputParser();
            addParameter(ip, 'LED', [],... 
                @(x) ismember(x, [1 2 3]));
            addParameter(ip, 'Output', "frames",...
                @(x) ismember(x, ["frames", "seconds"]));
            parse(ip, varargin{:});

            if ~isempty(ip.Results.LED)
                if ip.Results.LED == 1
                    trace = Stimulus.presentation.R;
                elseif ip.Results.LED == 2
                    trace = Stimulus.presentation.G;
                elseif ip.Results.LED == 3
                    trace = obj.presentation.B;
                end
            else
                trace = Stimulus.presentation.R + Stimulus.presentation.G + Stimulus.presentation.B;
            end

            bkgd = trace(1);
            changes = [0; diff(trace)];
            idx = find(changes ~= 0);
            idx = [idx; numel(trace)];
           
            ups = []; downs = [];
            for i = 1:numel(idx)-1
                newValue = trace(idx(i));
                if newValue > bkgd
                    ups = cat(1, ups, [idx(i) idx(i+1)-1]);
                elseif newValue < bkgd
                    downs = cat(1, downs, [idx(i) idx(i+1)-1]);
                end
            end
            %ups = reshape(ups, [numel(ups)/2, 2]);
            
        end
    end
end