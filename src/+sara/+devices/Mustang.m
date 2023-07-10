classdef Mustang < aod.builtin.devices.LightSource

    methods
        function obj = Mustang(parent, varargin)
            obj = obj@aod.builtin.devices.LightSource(488,...
                "Manufacturer", "Qiotopic", "Model", "IFLEX-Mustang",... 
                varargin{:});
        end
    end
end