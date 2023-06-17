classdef Epochs 

    methods (Static)
        function imStack = loadAnalysisVideo(epoch)
            fileName = epoch.getExptFile('AnalysisVideo');
            imStack = aod.util.readers.TiffReader.read(fileName);
            imStack = im2double(imStack);
            imStack(:,:,1) = [];    % remove first blank frame


            siftTransform = epoch.get('Registration', {'GroupName', 'SIFT'});
            if ~isempty(siftTransform)
                fprintf('Applying transform... ');
                imStack = sara.modules.Registrations.apply(siftTransform, imStack);
                fprintf('Done\n');
            end
        end
    end
end