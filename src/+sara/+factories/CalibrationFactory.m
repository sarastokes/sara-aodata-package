classdef CalibrationFactory < aod.util.Factory

    methods
        function obj = CalibrationFactory()
        end

        function cal = get(obj, name, calibrationDate)
            switch name 
                case 'MaxwellianView'
                    cal = sara.calibrations.MaxwellianView(date);     
                case 'TopticaNonlinearity'
                    cal = sara.calibrations.TopticaNonlinearity(561, '20210801');
                otherwise
                    error("CalibrationFactory:UnregisteredCalibration",...
                        "Calibration %s not supported by factory", date);
            end
        end
    end

    methods (Static)
        function cal = create(name, calibrationDate)
            obj = sara.factories.CalibrationFactory;
            cal = obj.get(name, calibrationDate);
        end
    end
end 