classdef Epoch < aod.core.Epoch
% EPOCH
%
% Description:
%   Extends aod.core.Epoch to contain a video cache
%
% Superclasses:
%   aod.core.Epoch
%
% Constructor:
%   obj = Epoch(ID, epochType)
%
% Properties:
%   epochType           sara.epochs.EpochTypes
% Inherited properties:
%   ID                  epoch ID
%   startTime           datetime
%   EpochDatasets       aod.core.EpochDataset
%   Registrations       aod.core.Registration
%   Responses           aod.core.Response
%   Stimuli             aod.core.Stimuli
%   attributes          aod.common.KeyValueMap
%   files               aod.common.KeyValueMap
% Transient properties:
%   cachedData
%
% Public methods:
%   makeStackSnapshots(obj, fPath)
%   clearRigidTransform(obj)
% Inherited public methods:
%   clearVideoCache(obj)

% By Sara Patterson, 2023 (sara-aodata-package)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        epochType           sara.epochs.EpochTypes
    end

    properties (Hidden, Transient)
        cachedData
    end

    methods
        function obj = Epoch(ID, varargin)
            obj@aod.core.Epoch(ID, varargin{:});
        end
    end

    methods
        function clearVideoCache(obj)
            % CLEARVIDEOCACHE
            %
            % Syntax:
            %   obj.clearVideoCache()
            % -------------------------------------------------------------
            obj.cachedVideo = [];
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Epoch();

            value.add("SampleRate",...
                "Class", "double", "Size", "(1,1)", "Units", "Hz",...
                "Description", "Rate of data acquisition");
            value.add("Defocus",...
                "Class", "double", "Size", "(1,1)", "Units", "diopters",...
                "Description", "AO defocus during epoch");
        end
    end
end

