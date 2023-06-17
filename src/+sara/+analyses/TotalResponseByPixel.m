classdef TotalResponseByPixel < aod.core.Analysis

    properties (SetAccess = protected)
        waveType                string = string.empty()
        pixelResponse           double
        stimulusConditions      
        allConditions      
        epochIDs                double 
        stats                   table = table.empty()
    end

    properties (Transient, Access = protected)
        Stimuli
    end

    methods 
        function obj = TotalResponseByPixel(name, parent, waveType, varargin)
            obj = obj@aod.core.Analysis(name,...
                'Parent', parent, varargin{:});

            waveType = lower(waveType);
            mustBeMember(waveType, ["square", "sine", "onsaw", "offsaw"]);
            obj.waveType = waveType;
        end

        function getEpochs(obj, varargin)
            if nargin < 2
                obj.Stimuli = obj.Parent.get('Stimulus',... 
                    {'Dataset', 'protocolClass', @(x) contains(x, "TemporalModulation")},... 
                    {'GroupName', @(x) contains(x, obj.waveType, 'IgnoreCase', true)});
            else
                obj.Stimuli = obj.Parent.get('Stimulus', varargin{:});
            end

            if isempty(stimuli)
                error('getEpochs:NoMatches',...
                    'No Matches were found for %s', obj.waveType);
            else
                fprintf('\tIdentified %u stimuli\n', numel(stimuli));
            end

            obj.allConditions = stimuli.getAttr('temporalFrequency');
            obj.stimulusConditions = sort(unique(obj.allConditions));

            epochs = getParent(stimuli);
            obj.epochIDs = getProp(epochs, 'ID');
        end 

        function go(obj, varargin)
            ip = aod.util.InputParser();
            addParameter(ip, 'Padding', [], @(x)isnumeric && numel(x)==4);
            parse(ip, varargin{:});

            if ~ismember('Padding', ip.UsingDefaults)
                obj.setAttr('Padding', ip.Results.Padding);
                padding = ip.Results.Padding;
            else
                padding = obj.getAttr('Padding');
            end

            % Create the table
            obj.stats = table(obj.allConditions', NaN(numel(obj.allConditions), 1),...
                'VariableNames', {"Frequency", "Value"});

            for i = 1:numel(obj.allConditions)
                obj.stats{i,"Value"} = mean(...
                    obj.pixelResponse(padding(1)+1:end-padding(2), padding(3)+1:padding(4)), "all");
            end
        end

        function calculate(obj, idx)
            epoch = obj.Parent.id2epoch(obj.epochIDs(i));
            imStack = sara.modules.Epochs.loadAnalysisVideo(epoch);
            if isempty(obj.pixelResponse)
                obj.pixelResponse = zeros(size(imStack,1), size(imStack, 2), numel(obj.stimulusConditions));
            end

            [stimStart, stimStop] = sara.modules.Stimuli.getStimRange(obj.Stimuli(idx));
            windowTime = (stimStop-stimStart) / obj.Stimuli(idx).frameRate;

            bkgd = squeeze(mean(imStack2(:,:,bkgdWindow(1):bkgdWindow(2)), 3));
            resp = squeeze(mean(imStack2(:, :, window2idx(hzWindow)), 3));
            obj.pixelResponse(:,:,idx) = resp - bkgd;
        end
    end

    % Move to module once working
    methods
        function h = plot(obj)
            h = axes('Parent', figure());
            [G, groupNames] = findgroups(obj.allConditions);
            meanValues = splitapply(@mean, obj.stats.Value/max(abs(obj.stats.Value)), G);
            stdValues = splitapply(@std, obj.stats.Value/max(abs(obj.stats.Value)), G);
            area(groupNames, meanValues,...
                'FaceColor', hex2rgb('334de6'), 'FaceAlpha', 0.2,... 
                'LineWidth', 2);
            errorbar(groupNames, meanValues, stdValues,...
                'Marker', 'o', 'LineStyle', 'none',...
                'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k',...
                'MarkerSize', 7);
            xlabel('Temporal Frequency (Hz)'); xticks(groupNames);
            xlim([0.2 100]); ylim([0 1]);
            set(gca, 'XScale', 'log', 'Grid', 'on');
            ylabel('Average dF (norm.)');
            title(sprintf('Temporal tuning (%s)', obj.waveType));
            figPos(h.Parent, 0.75, 0.75);
            tightfig(gcf);
        end
    end

    methods (Static)
        function p = specifyAttributes()
            p = specifyAttributes@aod.core.Analysis();

            p.add('BkgdWindow', [150 498], @(x) isnumeric(x) && numel(x) == 2,...
                'Start and stop frames for calculating the baseline response');
            p.add('Padding', [5 15 15 15], @(x) isnumeric(x) && numel(x) == 4,...
                'Analysis window, left/right, top/bottom');
        end
    end
end 