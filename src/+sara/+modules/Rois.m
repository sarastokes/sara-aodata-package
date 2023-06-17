classdef Rois

    % sara.annotations.Rois
    methods (Static)
        function ID = parseRoi(obj, ID)
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
            % UID2ROI
            %
            % Description:
            %   Given a UID, return the ROI ID. Given ROI ID, return as is
            %
            % Syntax:
            %   uid = obj.roi2uid(roiID)
            % -------------------------------------------------------------
            if isnumeric(uid)
                roiID = uid;
                return
            end

            roiID = find(obj.Metadata.UID == uid);
        end

        function uid = roi2uid(obj, roiID)
            % ROI2UID
            %
            % Description:
            %   Given a roi ID, returns the UID. Given a UID, return as is
            %
            % Syntax:
            %   uid = obj.roi2uid(roiID)
            % -------------------------------------------------------------
            if isstring && strlength(3)
                uid = roiID;
                return
            end

            if roiID > height(obj.Metadata)
                error('Roi ID %u not in metadata', roiID);
            end

            uid = obj.Metadata{roiID, 'UID'};
        end
    end
end 