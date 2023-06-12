classdef Reflectance < sara.channels.Channel 
% Reflectance imaging channel

% By Sara Patterson, 2023 (sara-aodata-package)
% -------------------------------------------------------------------------

    methods
        function obj = Reflectance(varargin)
            obj@sara.channels.Channel('ReflectanceImaging', varargin{:});
            
            obj.createChannel();
        end
    end

    methods (Access = protected)
        function createChannel(obj)
            obj.add(aod.builtin.devices.LightSource(796, ...
                'Manufacturer', "SuperLum"));
            obj.add(aod.builtin.devices.PMT('ReflectancePMT',...
                "Manufacturer", "Hamamatsu"));
        end
    end
end