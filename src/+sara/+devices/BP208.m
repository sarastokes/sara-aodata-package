classdef BP208 < aod.builtin.devices.Pellicle 
% The primate 1P system's pellicle
%
% Superclasses:
%   BP208
%
% Constructor:
%   obj = BP208(varargin)

% By Sara Patterson, 2023 (sara-aodata-package)
% -------------------------------------------------------------------------
    methods
        function obj = BP208(varargin)
            obj = obj@aod.builtin.devices.Pellicle([8 92],...
                'Manufacturer', "ThorLabs", "Model", "BP208");

            specFile = sara.resources.getResource('BP208.txt');
            obj.setBoth(aod.util.readers.TxtReader.read(specFile));
            obj.setFile('FilterProperties', specFile);
        end
    end
end 