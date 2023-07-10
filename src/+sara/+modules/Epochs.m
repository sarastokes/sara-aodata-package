classdef Epochs 

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
end