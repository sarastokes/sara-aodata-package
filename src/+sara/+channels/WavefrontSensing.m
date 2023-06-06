classdef WavefrontSensing < sara.channels.Channel 

    methods
        function obj = WavefrontSensing(varargin)
            obj@sara.channels.Channel('WavefrontSensing', varargin{:});
        end
    end
end 