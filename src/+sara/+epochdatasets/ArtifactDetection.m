classdef ArtifactDetection < aod.core.EpochDataset
% Detect pixels with motion artifact or zeroed after registration
%
% Parent:
%   aod.core.EpochDataset
%
% Constructor:
%   obj = sara.epochdatasets.ArtifactDetection('Parent', parent, varargin)
% 
% Attributes:
%   SampleRate                  25.3
%       The sample rate in Hz. Will try to extract from Epoch
%   ArtifactFrequency           0.22
%       The frequency of the motion artifact, in Hz
%   HighPass                    0.01
%       The cutoff frequency for optional high pass filtering, in Hz
%   ClipThreshold               0.65
%       The minimum percentage of 0s assigned for omission
%   FreqThreshold               0.9
%       Minimum percentage of max frequency assigned for omission

% By Sara Patterson, 2023 (sara-aodata-package)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % Final mask calculated from the previous three
        omissionMask
        % Power at the motion artifact frequency
        artifactPower
        % Percent power at motion artifact frequency vs full frequency range
        artifactPct
        % Percent timepoints where signal is 0 (clipped by registration)
        clippedPct
    end

    methods
        function obj = ArtifactDetection(varargin)
            obj@aod.core.EpochDataset("ArtifactDetection", varargin{:});

            if isempty(obj.Parent)
                error('ArtifactDetection:NoParent',...
                    'Optional input "Parent" must be provided');
            end

            % If parent Epoch has SampleRate attribute set, override
            if obj.Parent.hasAttr('SampleRate') ...
                    && ~isempty(obj.Parent.getAttr('SampleRate'))
                obj.setAttr('SampleRate', obj.Parent.getAttr('SampleRate'));
            end

            obj.setDescription('Dataset shows locations of pixels with significant motion artifact');
        end
    end

    methods 
        function go(obj)
            % Get the relevant attributes
            sampleRate = obj.getAttr('SampleRate');
            highCut = obj.getAttr('HighPass');
            artifactFrequency = obj.getAttr('ArtifactFrequency');

            % Get the data
            imStack = obj.loadData();
            [x, y, t] = size(imStack);
            
            obj.artifactPower = zeros(x, y);
            obj.artifactPct = zeros(x, y);
            obj.clippedPct = zeros(x, y);
            for i = 1:x
                for j = 1:y
                    pixelData = squeeze(imStack(i, j, :))';
                    % Determine the percentage of pixels at 0
                    obj.clippedPct(i,j) = 1 - (nnz(pixelData) / t);
                    % Optional high pass filtering
                    if ~isempty(highCut)
                        pixelData = signalHighPassFilter(pixelData, highCut, sampleRate);
                    end
                    % Get the power spectrum and assess artifact frequency
                    [p, f] = signalPowerSpectrum(pixelData, sampleRate);
                    obj.artifactPower(i,j) = p(findclosest(f, artifactFrequency));
                    obj.artifactPct(i,j) = obj.artifactPower(i,j) / max(p);
                end
            end

            obj.determineOmissionMask();
        end

        function determineOmissionMask(obj)
            % Decide which pixels to omit

            % For now, using the simplest approach
            % When there's motion at the edge of a frame, a significant 
            % number of pixels will 0. 
            obj.omissionMask = obj.clippedPct > obj.getAttr('ClipThreshold');
            fprintf('Epoch %u - %u pixels omitted (%.2f%%)\n',...
                obj.Parent.ID, nnz(obj.omissionMask),...
                nnz(obj.omissionMask)/numel(obj.omissionMask));
        end

        function imStack = loadData(obj)
            reader = aod.util.findFileReader(...
                obj.Parent.getExptFile('AnalysisVideo'));
            imStack = reader.readFile();
            imStack = im2double(imStack);
            % Record the video used 
            obj.setFile('Video', obj.Parent.getExptFile('AnalysisVideo'));
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.core.EpochDataset();

            value.add('SampleRate', 25.3, @isnumeric,...
                'Sample rate for data acquisition, in Hz');
            value.add('ArtifactFrequency', 0.22, @isnumeric,...
                'Frequency of the motion artifact, in Hz');
            value.add('HighPass', 0.01, @isnumeric,...
                'Cutoff for optional high pass filtering, in Hz');
            value.add('FreqThreshold', 0.9, @isnumeric,...
                'Minimum percentage of max frequency assigned for omission');
            value.add('ClipThreshold', 0.5, @isnumeric,...
                'Percentage of timepoints at zero assigned for omission');
        end
    end
end 