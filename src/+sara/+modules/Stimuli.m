classdef Stimuli 

    methods (Static)

        function [stimStart, stimStop] = getStimRange(Stimulus, varargin)
            %GETSTIMRANGE Get the start and stop times of the stimulus
            %
            %   [STIMSTART, STIMSTOP] = GETSTIMRANGE(STIMULUS, VARARGIN)
            %
            % Inputs:
            %   Stimulus        sara.stimuli.SpectralStimulus
            % Optional key/value inputs:
            %   LED             1, 2 or 3
            %       Which LED to use (default is to sum RG&B)
            %   Output          "frames", "duration", "time"
            %       Whether to return frames, time (double) or duration
            %       (default = "frames")
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