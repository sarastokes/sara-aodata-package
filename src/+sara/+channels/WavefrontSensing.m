classdef WavefrontSensing < sara.channels.Channel 
% By Sara Patterson, 2023 (sara-aodata-package)
% -------------------------------------------------------------------------

    methods
        function obj = WavefrontSensing(varargin)
            obj@sara.channels.Channel('WavefrontSensing', varargin{:});

            obj.createChannel();
        end
    end

    methods (Access = protected)
        function createChannel(obj)
            obj.add(aod.builtin.devices.LightSource(847,...
                'Manufacturer', "QPhotonics"));
            obj.add(aod.core.Device('MEMS Deformable Mirror',...
                'Manufacturer', "Boston Micromachines Corporation"));
            obj.add(aod.core.Device('Shack-Hartmann Wavefront Sensor',...
                "Manufacturer", "Adaptive Optics Associates"));
            obj.add(aod.builtin.devices.PMT("Wavefront Sensing PMT"));
        end
    end
end 