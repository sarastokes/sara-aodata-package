classdef BackgroundEpoch < sara.epochs.Epoch
% BACKGROUNDEPOCH
%
% Description:
%   An epoch measuring the background noise without stimuli
%
% Parent:
%   sara.epochs.Epoch
%
% Constructor:
%   obj = BackgroundEpoch(parent, ID, varargin)
%
% Properties:
%   meanValue
%   stdValue
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        meanValue
        stdValue
    end

    methods
        function obj = BackgroundEpoch(ID, varargin)
            obj@sara.epochs.Epoch(ID, sara.epochs.EpochTypes.BACKGROUND, varargin{:});
        end
    end

    methods
        function getStatistics(obj)
            imStack = obj.getStack();
            obj.meanValue = mean(imStack(:), 'omitnan');
            obj.stdValue = std(imStack(:), 'omitnan');
        end

        function R = getMean(obj)
            R = obj.getResponse('aod.builtin.responses.Mean');
        end
    end
end