classdef SpatialPhysiologyEpoch < sara.epochs.onephotonaoslo.Epoch
% SPATIALPHYSIOLOGYEPOCH
%
% Description:
%   An epoch on the 1P primate system with spatial stimulus presentation
%   through the AOSLO.
%
% Superclasses:
%   sara.epochs.onephotonaoslo.Epoch

% By Sara Patterson, 2023 (sara-aodata-package)
% --------------------------------------------------------------------------
    methods
        function obj = SpatialPhysiologyEpoch(varargin)
            obj = obj@sara.epochs.onephotonaoslo.Epoch(varargin{:});
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@sara.epochs.onephotonaoslo.Epoch()

            value.add("StimulusName", ...
                "Size", "(1,1)", "Class", "string", ...
                "Description", "Stimulus file name (if applicable)");
            value.add("BackgroundStimulusName", ...
                "Size", "(1,1)", "Class", "string", ...
                "Description", "Background stimulus file name (if applicable)");
            value.add("SpatialStimulusIntensity",...
                "Size", "(1,1)", "Class", "double",...
                "Function", @(x) mustBeInRange(x, 0, 100), "Units", "percent", ...
                "Description", "AOM value for the stimuli presented through the AOSLO");
        end
    end
end 