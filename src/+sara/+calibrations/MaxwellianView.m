classdef MaxwellianView < aod.core.Calibration
% LEDCALIBRATION
%
% Description:
%   Calibration for the 3 LED Maxwellian View system
%
% Parent:
%   aod.core.Calibration
%
% Constructor:
%   obj = MaxwellianView(calibrationDate, varargin{:})
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        stimPowers
        stimContrasts
        lookupTables
        stimulusImage
        spectra
    end

    methods
        function obj = MaxwellianView(calibrationDate, varargin)
            obj = obj@aod.core.Calibration("MaxwellianView",... 
                calibrationDate, varargin{:});
            obj.loadCalibrationFile()
        end

        function stim = calcStimulus(obj, whichStim, baseStim)
            if isa(whichStim, 'sara.SpectralTypes')
                whichStim = whichStim.getAbbrev();
            end

            dPower = obj.stimPowers.(whichStim)';
            bkgdPower = obj.stimPowers.Background';

            try
                stim = (dPower .* ((1/baseStim(1)) * ...
                    (baseStim-baseStim(1))) + bkgdPower);
            catch
                stim = zeros(3, numel(baseStim));
                for i = 1:3
                    stim(i,:) = (dPower(i) .* ((1/baseStim(1)) * ... 
                        (baseStim-baseStim(1))) + bkgdPower(i));
                end
            end
        end

        function setStimulusImage(obj, img)
            if istext(img) && isfile(img)
                reader = aod.util.findFileReader(img);
                obj.stimulusImage = reader.readFile();
                obj.setFile('StimulusImage', img);
            else
                obj.stimulusImage = img;
            end
        end
    end

    methods (Access = private)
        function loadCalibrationFile(obj)
            dataDir = [fileparts(fileparts(mfilename('fullpath'))),...
                filesep, '+resources', filesep];
            calibrationFile = [dataDir, 'LedCalibration', char(obj.calibrationDate), '.json'];
            S = loadjson(calibrationFile);
            
            % Datasets
            obj.stimContrasts = rmfield(S.Stimuli.Contrasts, {'Labels', 'Units'});
            obj.stimContrasts = struct2table(structfun(@(x) x', obj.stimContrasts,... 
                'UniformOutput', false));
            obj.stimPowers = rmfield(S.Stimuli.Powers, {'Labels', 'Units', 'Description'});
            obj.stimPowers = struct2table(structfun(@(x) x', obj.stimPowers,... 
                'UniformOutput', false));

            obj.lookupTables = table( ...
                S.LUTs.Voltages', S.LUTs.R', S.LUTs.G', S.LUTs.B', ...
                'VariableNames', {'Voltage', 'R', 'G', 'B'});
            obj.spectra = table(S.Spectra.Wavelengths', S.Spectra.R', ...
                S.Spectra.G', S.Spectra.B', ...
                'VariableNames', {'Wavelength', 'R', 'G', 'B'});

            % Attributes
            obj.setAttr('NDF', S.NDF);
            obj.setAttr("LedMaxPowers", S.LedMaxPowers_uW);
            obj.setAttr('WhitePointLedWeights', S.LedBackground_Norm);
            obj.setAttr('WhitePoint', S.MeanChromaticity_xyY);
            obj.setAttr('WhitePointPower', sum(obj.stimPowers.Background));


            % Files
            obj.setFile('CalibrationFile', calibrationFile);
            for i = 1:numel(S.Files.LUT)
                obj.setFile(sprintf('LUT%u', i), S.Files.LUT{i});
            end
            for i = 1:numel(S.Files.Spectra)
                obj.setFile(sprintf('Spectra%u', i), S.Files.Spectra{i});
            end
        end
    end

    methods (Access = protected)
        function value = specifyLabel(obj)
            value = "LedCalibration_" + string(obj.calibrationDate);
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Calibration();

            value.add("WhitePoint", ...
                "Class", "double", "Size", "(1,3)",...
                "Description", "CIE coordinates (xyY) of the white point");
            value.add("LedMaxPowers",...
                "Class", "double", "Size", "(1,3)", "Units", "microwatt",...
                "Description", "The maximum powers of each LED");
            value.add("WhitePointLedWeights",...
                "Class", "double", "Size", "(1,3)", "Units", "%",...
                "Description", "The percent of each LED's max output at the white point");
            value.add("WhitePointPower", ...
                "Class", "double", "Size", "(1,1)", "Units", "microwatt",...
                "Description", "The total power of the 3 LEDs at the white point");
            value.add("NDF",...
                "Class", "double", "Size", "(1,1)",...
                "Description", "The NDF used for scaling the LED powers");
        end

        function value = specifyDatasets(value)
            value = specifyDatasets@aod.core.Calibration(value);

            value.set("spectra",...
                "Class", "double", "Size", "(:,4)",...
                "Units", ["nm", "normalized", "normalized", "normalized"],...
                "Description", "The LED spectra");
            value.set("lookupTables",...
                "Class", "table", "Size", "(:,4)",...
                "Units", ["nm", "microwatt", "microwatt", "microwatt"], ...
                "Description", "The voltage-power lookup tables");
            value.set("stimPowers",...
                "Class", "table", "Units", "microwatt",...
                "Description", "The powers for each stimulus condition");
            value.set("stimContrasts", ...
                "Class", "table", "Units", "%", ...
                "Description", "The contrasts for each stimulus condition");
            value.set("stimulusImage",...
                "Function", @mustBeNumeric, "Size", "(:,:)",...
                "Description", "Image of the stimulus placement");
        end
    end
end