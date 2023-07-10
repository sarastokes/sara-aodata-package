classdef TotalResponseByPixel < aod.core.Analysis

    properties (SetAccess = protected)
        waveType                string = string.empty()
        pixelResponse           double
        omissionMask            double {mustBeInteger}
        stimulusConditions      
        allConditions      
        epochIDs                double 
        stats                   table = table.empty()
    end

    properties (Transient, SetAccess = protected)
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

            if isempty(obj.Stimuli)
                error('getEpochs:NoMatches',...
                    'No Matches were found for %s', obj.waveType);
            else
                fprintf('\tIdentified %u stimuli\n', numel(obj.Stimuli));
            end

            obj.allConditions = getAttr(obj.Stimuli, 'temporalFrequency');
            obj.stimulusConditions = sort(unique(obj.allConditions));

            epochs = getParent(obj.Stimuli);
            obj.epochIDs = getProp(epochs, 'ID');

            % Get epoch-specific metadata
            obj.getOmissionMask();
        end 

        function getOmissionMask(obj)
            obj.omissionMask = sara.modules.Registrations.getTotalOmissions(...
                obj.Parent, obj.epochIDs);
        end

        function go(obj, varargin)
            % Get the pixel responses per epoch
            for i = 1:numel(obj.allConditions)
                obj.calculate(i);
            end
            
            obj.getStats();
        end

        function getStats(obj)
            obj.stats = table(...
                obj.allConditions, NaN(size(obj.allConditions)),...
                'VariableNames', ["Frequency", "Mean"]);

            for i = 1:numel(obj.allConditions)
                tmp = obj.pixelResponse(:,:,i);
                obj.stats.Mean(i) = mean(tmp(obj.omissionMask==0), "all");
            end
            obj.stats = sortrows(obj.stats, "Frequency");
        end

        function calculate(obj, idx)
            % Get the relevant parameters
            bkgdWindow = obj.getAttr('BackgroundFrames');
            [stimStart, stimStop] = sara.modules.Stimuli.getStimRange(obj.Stimuli(idx));
            obj.setAttr('StimFrames', [stimStart, stimStop]);


            epoch = obj.Parent.id2epoch(obj.epochIDs(idx));
            imStack = sara.modules.Epochs.loadAnalysisVideo(epoch);
            if isempty(obj.pixelResponse) 
                obj.pixelResponse = zeros(...
                    size(imStack,1), size(imStack, 2),... 
                    numel(obj.stimulusConditions));
            end

            bkgd = squeeze(mean(imStack(:,:,bkgdWindow(1):bkgdWindow(2)), 3, "omitnan"));
            resp = squeeze(mean(imStack(:, :, window2idx([stimStart, stimStop])), 3, "omitnan"));
            obj.pixelResponse(:,:,idx) = resp - bkgd;
        end
    end

    % Move to module once working
    methods
        function ax = plot(obj)
            [G, groupNames] = findgroups(obj.stats.Frequency);
            meanValues = splitapply(@mean, obj.stats.Mean/max(abs(obj.stats.Mean)), G);
            stdValues = splitapply(@std, obj.stats.Mean/max(abs(obj.stats.Mean)), G);
            
            ax = axes('Parent', figure());
            hold(ax, 'on'); grid(ax, 'on');
            area(groupNames, meanValues,...
                'FaceColor', hex2rgb('334de6'), 'FaceAlpha', 0.2,... 
                'LineWidth', 2);
            errorbar(groupNames, meanValues, stdValues,...
                'Color', 'k', 'Marker', 'o',... 
                'LineStyle', 'none', 'LineWidth', 1.5,...
                'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k',...
                'MarkerSize', 7);
            xlabel('Temporal Frequency (Hz)'); 
            xticks(groupNames); yticks(0:0.5:1);
            xlim([1 100]); ylim([0 1.1*max(meanValues+stdValues)]);
            set(gca, 'XScale', 'log', 'XTickLabelRotation', 45);
            ylabel('Average dF (norm.)');
            title(sprintf('Temporal tuning (%s)', obj.waveType));
            figPos(ax.Parent, 0.65, 0.65);
            tightfig(gcf);
        end
    end

    methods (Static)
        function p = specifyAttributes()
            p = specifyAttributes@aod.core.Analysis();

            p.add('BackgroundFrames', [150 498], @(x) isnumeric(x) & numel(x) == 2,...
                'Start and stop frames for calculating the baseline response');
            p.add('StimFrames', @(x) isnumeric(x) & numel(x) == 2);
            %p.add('Padding', [5 15 15 15], @(x) isnumeric(x) && numel(x) == 4,...
            %    'Analysis window, left/right, top/bottom');
        end
    end
end 