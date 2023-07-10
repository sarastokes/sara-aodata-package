classdef Experiments 

    methods (Static)
        function fPath = getAnalysisFolder(obj)
            aod.util.mustBeEntityType(obj, 'Experiment');
            
            fPath = fullfile(obj.homeDirectory, 'Analysis');
        end
    end
end 