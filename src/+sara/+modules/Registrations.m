classdef Registrations 

    methods (Static)
        function nOmittedMask = getTotalOmissions(expt, epochIDs)
            if nargin < 2
                epochIDs = expt.epochIDs;
            end
            
            epochDsets = expt.getByEpoch(epochIDs, "EpochDataset",...
                {'GroupName', 'MotionDetection'});
            allMasks = getProp(epochDsets, "omissionMask");
            nOmittedMask = sum(double(allMasks), 3);
        end

        function imStack = apply(registration, imStack, varargin)
            tform = registration.transform;

            if ismatrix(imStack)
                refObj = imref2d([size(imStack, 1), size(imStack, 2)]);
                imStack = imwarp(imStack, refObj, tform,...
                    'OutputView', refObj, varargin{:});
            else
                tForm = sara.modules.Registrations.affine2d_to_3d(tform);
                viewObj = affineOutputView(size(imStack), tForm,...
                    'BoundsStyle', 'SameAsInput');
                imStack = imwarp(imStack, tForm, 'OutputView', viewObj, varargin{:});
            end
        end
        
        function tform = affine2d_to_3d(T)
            % Converts affine2d to affine3d
            %
            % Description:
            %   Converts affine2d to affine3d so a full video or stack of
            %   images can be transformed without using a long for loop
            %
            % Syntax:
            %   tform = affine2d_to_3d
            %
            % Inputs:
            %   T           affine3d or 3x3 transformation matrix
            %       The affine transform matrix
            %
            % Outputs:
            %   tform       affine3d
            %       A 3D affine transform object
            % -------------------------------------------------------------
            if isa(T, 'affine2d')
                T = T.T;
            end

            T2 = eye(4);
            T2(2, 1) = T(2, 1);
            T2(1, 2) = T(1, 2);
            T2(4, 1) = T(3, 1);
            T2(4, 2) = T(3, 2);

            tform = affine3d(T2);
        end
    end
end 