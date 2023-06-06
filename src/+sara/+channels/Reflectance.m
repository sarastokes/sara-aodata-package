classdef Reflectance < sara.channels.Channel 
% Reflectance imaging channel

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
            if isempty(obj.get('Device', {'Name', @(x) contains('Pinhole')}))
                obj.addPinhole(20);
            end
        end
    end
end