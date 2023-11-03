classdef Epochs < sara.Epoch
% EPOCHS
%
% Description:
%   A collection of methods for core and persistent epoch objects.

% By Sara Patterson, 2023 (sara-aodata-package)
% -------------------------------------------------------------------------

    methods (Static)
        function imStack = loadAnalysisVideo(epoch)
            tic;
            fileName = epoch.getExptFile('AnalysisVideo');
            fprintf("Loading %s... ", epoch.groupName);
            imStack = aod.util.readers.TiffReader.read(fileName);
            imStack = im2double(imStack);
            imStack(:,:,1) = [];    % remove first blank frame


            siftTransform = epoch.get('Registration', {'GroupName', 'SIFT'});
            if ~isempty(siftTransform)
                fprintf('Applying transform... ');
                imStack = sara.modules.Registrations.apply(siftTransform, imStack);
            end
            fprintf("Done. Time elapsed = %.2f\n", toc);
        end
    end

    methods (Static)
        function makeStackSnapshots(epoch, fPath)
            % MAKESTACKSNAPSHOTS
            %
            % Description:
            %   Mimics the Z-projections created by ImageJ and saves an
            %   AVG, MAX, SUM and STD projection to 'Analysis/Snapshots/'
            %
            % Syntax:
            %   obj.makeStackSnapshots(fPath);
            %
            % Optional Inputs:
            %   fPath       char
            %       Where to save (default = 'Analysis/Snapshots/')
            % -------------------------------------------------------------
            
            aod.util.mustBeEntityType(epoch, 'Epoch');
            if nargin < 2
                fPath = fullfile(epoch.getHomeDirectory(), 'Analysis', 'Snapshots');
            end

            if ~isscalar(epoch)
                arrayfcn(@(x) makeStackSnapshots(x, fPath), epoch);
                return
            end 

            baseName = ['_', 'vis_', int2fixedwidthstr(epoch.ID, 4), '.png'];
            imStack = epoch.loadAnalysisVideo();

            imSum = sum(im2double(imStack), 3);
            imwrite(uint8(255 * imSum / max(imSum(:))), ...
                fullfile(fPath, ['SUM', baseName]), 'png');
            imwrite(uint8(mean(imStack, 3)), ...
                fullfile(fPath, ['AVG', baseName]), 'png');
            imwrite(im2uint8(imadjust(std(im2double(imStack), [], 3))), ...
                fullfile(fPath, ['STD', baseName]), 'png');
        end
    end
end