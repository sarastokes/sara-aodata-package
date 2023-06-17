classdef EpochTypes

    enumeration
        SPECTRAL
        SPATIAL
        ANATOMYONECHANNEL
        ANATOMYTWOCHANNEL
        BACKGROUND
    end

    methods
        function tf = isPhysiology(obj)
            import sara.epochs.EpochTypes;
            switch obj
                case {EpochTypes.SPECTRAL, EpochTypes.SPATIAL}
                    tf = true;
                otherwise
                    tf = false;
            end
        end

        function value = numChannels(obj)
            if obj == sara.epochs.EpochTypes.ANATOMYONECHANNEL
                value = 1;
            else
                value = 2;
            end
        end
    end

    methods (Static)
        function obj = init(eType)
            if isa(eType, sara.epochs.EpochTypes)
                obj = eType;
                return 
            end

            switch lower(eType)
                case 'spectral'
                    obj = sara.epochs.EpochTypes.SPECTRAL;
                case 'spatial'
                    obj = sara.epochs.EpochTypes.SPATIAL;
                case 'anatomy1'
                    obj = sara.epochs.EpochTypes.ANATOMYONECHANNEL;
                case 'anatomy2'
                    obj = sara.epochs.EpochTypes.ANATOMYTWOCHANNEL;
                case 'background'
                    obj = sara.epochs.EpochTypes.BACKGROUND;
                otherwise
                    error('Unrecognized epoch type: %s', eType);
            end
        end
    end
    
end