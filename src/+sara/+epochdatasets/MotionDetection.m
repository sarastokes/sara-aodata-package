classdef MotionDetection < aod.core.EpochDataset
    % Detect pixels with motion artifact or zeroed after registration
    %
    % Parent:
    %   aod.core.EpochDataset
    %
    % Constructor:
    %   obj = sara.epochdatasets.MotionArtifact(fileName, varargin)
    %
    % Inputs:
    %   fileName            char/string
    %       File name to analyze
    %
    % Attributes:
    %   OmissionThreshold               0.5
    %       The minimum percentage of 0s assigned for omission
    % Files:
    %   Data                            []
    %       File provided for analysis

    % By Sara Patterson, 2023 (sara-aodata-package)
    % -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % Final mask calculated from the previous three
        omissionMask
        % Pixelwise record of % timepoints at zero [X, Y]
        zeroPct
    end

    methods
        function obj = MotionDetection(varargin)
            obj@aod.core.EpochDataset("ArtifactDetection", varargin{:});
            
            % Parent Epoch is required for data file access
            mustHaveParent(obj);
            obj.setFile('Data', obj.Parent.getFile('AnalysisVideo'));

            % Set a default description
            obj.setDescription(...
                "Locations of pixels with significant motion artifact " + ...
                "calculated from the percent of timepoints equal to zero.");

            obj.go();
        end

    end

    methods
        function go(obj)
            % Main analysis function
            %
            % Syntax:
            %   go(obj)
            % -------------------------------------------------------------

            imStack = obj.loadData();
            [x, y, t] = size(imStack);
            obj.zeroPct = zeros(x, y);

            for i = 1:x
                for j = 1:y
                    pixelData = squeeze(imStack(i, j, :))';
                    % Determine the percentage of pixels at 0
                    obj.zeroPct(i, j) = 1 - (nnz(pixelData) / t);
                end
            end
            obj.getOmissionMask();
        end

        function getOmissionMask(obj, omissionThreshold)
            % Decide which pixels to omit
            % 
            % Description:
            %   When there's motion at the edge of a frame, a significant
            %   number of pixels will 0. If more then OmissionThreshold % is 
            %   zero, the pixel is omitted.
            %
            % Syntax:
            %   getOmissionMask(obj)
            %   getOmissionMask(obj, omissionThreshold)
            % -------------------------------------------------------------
            if nargin > 1
                obj.setAttr('OmissionThreshold', omissionThreshold);
            else
                omissionThreshold = obj.getAttr('OmissionThreshold');
            end

            % Calculate the omission mask
            obj.omissionMask = obj.zeroPct > omissionThreshold;
            fprintf('Epoch %u - %u pixels omitted (%.2f%%)\n', ...
                obj.Parent.ID, nnz(obj.omissionMask), ...
                nnz(obj.omissionMask) / numel(obj.omissionMask));
        end

        function imStack = loadData(obj)
            % Load data from epoch
            imStack = sara.util.loadEpochVideo(obj.Parent);
        end

    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.core.EpochDataset();

            value.add('OmissionThreshold', 0.5, @(x) iswithin(x,0,1), ...
                'Pixel omission threshold: % of timepoints at 0');
        end

    end

end
