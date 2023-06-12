classdef Rois < aod.builtin.annotations.Rois
% Regions of interest with unique IDs
% 
% Description:
%   ROIs in physiology experiment with UIDs that are consistent between 
%   different experiments.
% 
% Superclasses:
%   aod.builtin.annotations.Rois
%
% Constructor:
%   obj = sara.annotations.Rois(name, roiFileName, imSize, varargin)
%   obj = sara.annotations.Rois(name, roiFileName, imSize, 'Source', source)
%
% Optional Parameters:
%   Size            % needed for loading ImageJRois, otherwise calculated
% Optional Parameters (inherited from aod.core.Annotation):
%   Source          aod.core.Source
%
% Methods:
%   ID = parseRoi(obj, ID)
%   roiID = uid2roi(obj, UID)
%   uid = roi2uid(obj, roiID)
%   addRoiUID(obj, roiID, roiUID)
%   setRoiUIDs(obj, roiUIDs)
%
% Inherited methods:
%   load(obj)
%   reload(obj)
%   setImage(obj, im)
%
% Protected methods:
%   setMap(obj, map);

% By Sara Patterson, 2023 (sara-aodata-package)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % Unique identifiers of ROIs
        metadata            table            = table.empty()
    end

    methods
        function obj = Rois(name, roiFileName, imSize, varargin)
            % Constructor
            %
            % Syntax:
            %   obj = sara.annotations.Rois(name, roiFileName, imSize, varargin)
            % -------------------------------------------------------------
            fileReader = aod.builtin.readers.ImageJRoiReader(...
                roiFileName, imSize);
            obj = obj@aod.builtin.annotations.Rois(name, fileReader, varargin{:});
            obj.setAttr('Size', imSize);
        end
    end

    methods
        function load(obj, rois)
            % Load the ROIs from a file
            %
            % Syntax:
            %   load(obj)
            % -------------------------------------------------------------
            load@aod.builtin.annotations.Rois(obj, rois);
            obj.setMetadata();
        end

        function reload(obj)
            % Reload the ROIs from a file without disrupting metadata
            %
            % Syntax:
            %   reload(obj)
            % -------------------------------------------------------------
            reload@aod.builtin.annotations.Rois(obj);
            obj.setMetadata();
        end
    end

    % Metadata-related methods
    methods
        function ID = parseRoi(obj, ID)
            % Ensure ROI is valid and in numeric format
            %
            % Syntax:
            %   uid = parseRoi(obj, roiID)
            % -------------------------------------------------------------

            if ischar(ID)
                ID = string(upper(ID));
            end
            if isstring(ID)
                ID = obj.uid2roi(ID);
                return;
            end
            assert(ID <= obj.numRois, 'ROI is not within count!');
        end
        
        function roiID = uid2roi(obj, uid)
            % Given a UID, return the ROI ID. Given ROI ID, return as is
            %
            % Syntax:
            %   uid = roi2uid(obj, roiID)
            % -------------------------------------------------------------

            if isnumeric(uid)
                roiID = uid;
                return
            end
            roiID = find(obj.metadata.UID == uid);
        end

        function uid = roi2uid(obj, roiID)
            % Given a roi ID, returns the UID. Given a UID, return as is
            %
            % Syntax:
            %   uid = roi2uid(obj, roiID)
            % -------------------------------------------------------------

            if isstring && strlength(3)
                uid = roiID;
                return
            end
            if roiID > height(obj.metadata)
                error('Roi ID %u not in metadata', roiID);
            end
            uid = obj.metadata{roiID, 'UID'};
        end
        
        function addRoiUID(obj, roiID, roiUID)
            % Assign a specific roi UID
            %
            % Syntax:
            %   addRoiUID(obj, roiID, UID)
            % -------------------------------------------------------------

            if ~aod.util.isempty(roiUID)
                assert(isstring(roiUID) & strlength(roiUID) == 3, ...
                    'roiUID must be empty or a string 3 characters long')
            end
            obj.metadata(obj.metadata.ID == roiID, 'UID') = roiUID;
        end

        function setRoiUIDs(obj, roiUIDs)
            % Assign a table or array to the roiUIDs property
            %
            % Syntax:
            %   setRoiUIDs(obj, roiUIDs)
            % -------------------------------------------------------------
            arguments 
                obj 
                roiUIDs         table 
            end

            assert(height(roiUIDs) == obj.Count,...
                'Number of UIDs must equal number of ROIs');
            assert(~isempty(cellfind(roiUIDs.Properties.VariableNames, 'UID')),...
                'roiUID table must have a column named UID');
            assert(~isempty(cellfind(roiUIDs.Properties.VariableNames, 'ID')),...
                'roiUID table must have a column named ID');

            obj.metadata = roiUIDs; 
            obj.metadata = sortrows(obj.metadata, 'ID');
        end
    
        function clearMetadata(obj)
            % Clear all the UIDs
            %
            % Syntax:
            %   clearMetadata(obj)
            % -------------------------------------------------------------
            obj.createMetadata(true);
        end
    end

    methods (Access = protected)
        function setMetadata(obj)
            if isempty(obj.Data)
                return
            end
            if ~isempty(obj.metadata)
                % If there were existing ROIs, make sure to append to  
                % Metadata rather than erasing existing table
                newROIs = obj.numRois - height(obj.metadata);
                newTable = table(height(obj.metadata) + rangeCol(1, newROIs),...
                    repmat("", [newROIs, 1]), 'VariableNames', {'ID', 'UID'});
                newTable = [obj.metadata; newTable];
                obj.metadata = newTable;
            else
                obj.createMetadata();
            end
        end

        function createMetadata(obj, forceOverwrite)
            if nargin < 2
                forceOverwrite = false;
            end
            if isempty(obj.metadata) || forceOverwrite
                obj.metadata = table(rangeCol(1, obj.numRois), ...
                    repmat("", [obj.numRois, 1]),...
                    'VariableNames', {'ID', 'UID'});
            end
        end
    end

    methods (Static)
        function p = specifyAttributes()
            p = specifyAttributes@aod.builtin.annotations.Rois();

            p.add('Size', [], @(x) numel(x) == 2 & isrow(x),...
                'Image size necessary for ImageJ ROI import');
        end

        function d = specifyDatasets(d)
            d = specifyDatasets@aod.builtin.annotations.Rois(d);

            d.set('metadata',...
                'Class', 'table',...
                'Description', 'Unique identifiers of all ROIs');
        end
    end
end
