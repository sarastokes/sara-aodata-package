classdef SpectralPhysiologyEpoch < sara.epochs.onephotonaoslo.Epoch 
% SPECTRALPHYSIOLOGYEPOCH
%
% Description:
%   An epoch on the 1P primate system with a spectral stimulus presented 
%   through a Maxwellian View
%
% Superclasses:
%   sara.epochs.onephotonaoslo.Epoch
 
% By Sara Patterson, 2023 (sara-aodata-package)
% -------------------------------------------------------------------------

    methods
        function obj = SpectralPhysiologyEpoch(varargin)
            obj = obj@sara.epochs.onephotonaoslo.Epoch(varargin{:});
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@sara.epochs.onephotonaoslo.Epoch();

            value.add("StimulusName", ...
                "Size", "(1,1)", "Class", "string", ...
                "Description", "Stimulus file name (if applicable)");
            value.add('IntervalTime',...
                "Size", "(1,1)", "Class", "double",...
                "Function", {@mustBePositive},...
                "Description", "The stimulus presentation update rate");
            value.add("IntervalUnit",...
                "Size", "(1,1)", "Class", "string",...
                "Default", "ms",...
                "Description", "The unit of the interval time");
        end
    end
end