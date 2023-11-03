classdef EpochParameterReader < aod.util.readers.TxtReader 
% EPOCHPARAMETERREADER
%
% Description:
%   Reads epoch parameter files and makes according adjustments to epoch
%
% Superclasses:
%   aod.util.readers.TxtReader
%
% Syntax:
%   obj = sara.readers.EpochParameterReader(fileName)
%
% Notes:
%   readFile() requires an Epoch as an input - attributes will be directly
%   assigned to the epoch to reduce complexity of passing them back

% By Sara Patterson, 2023 (sara-aodata-package)
% -------------------------------------------------------------------------

    methods
        function obj = EpochParameterReader(varargin)
            obj@aod.util.readers.TxtReader(varargin{:});
        end

        function ep = readFile(obj, ep)
            txt = obj.readText('Date/Time = ');
            txt = erase(txt, ' (yyyy-mm-dd:hh:mm:ss)');
            ep.setStartTime(datetime(txt, 'InputFormat', 'yyyy-MM-dd HH:mm:ss'));
            
            % Additional file names
            ep.setFile('TrialFile', obj.readText('Trial file name = '));
            txt = strsplit(ep.files('TrialFile'), filesep);
            ep.setAttr('StimulusName', txt{end});

            txt = obj.readText('Scanner FOV = ');
            txt = erase(txt, ' (496 lines) degrees');
            txt = strsplit(txt, ' x ');
            ep.setAttr('FieldOfView', [str2double(txt{1}), str2double(txt{2})]);

            % Fluorescence imaging window
            x = obj.readNumber('ImagingWindowX = ');
            y = obj.readNumber('ImagingWindowY = ');
            dx = obj.readNumber('ImagingWindowDX = ');
            dy = obj.readNumber('ImagingWindowDY = ');
            ep.setAttr('FluorescenceImagingWindow', [x y dx dy]);

            % Reflectance imaging window
            x = obj.readNumber('ReflectanceWindowX = ');
            y = obj.readNumber('ReflectanceWindowY = ');
            dx = obj.readNumber('ReflectanceWindowDX = ');
            dy = obj.readNumber('ReflectanceWindowDY = ');
            ep.setAttr('ReflectanceImagingWindow', [x y dx dy]);

            if ep.isExpected('IntervalValue', 'attribute')
                ep.setAttr('IntervalValue', value);
                ep.setAttr('IntervalUnit', obj.readText('Interval unit = '));
            end
            
            % Channel parameters
            ep.setAttr('ReflectanceAdcGain', obj.readNumber('ADC channel 1, gain = '));
            ep.setAttr('FluorescenceAdcGain', obj.readNumber('ADC channel 2, gain = '));
            ep.setAttr('ReflectanceAdcOffset', obj.readNumber('ADC channel 1, offset = '));
            ep.setAttr('FluorescenceAdcOffset', obj.readNumber('ADC channel 2, offset = '));
            ep.setAttr('ReflectancePmtGain', obj.readNumber('Reflectance PMT gain  = '));
            ep.setAttr('FluorescencePmtGain', obj.readNumber('Fluorescence PMT gain = '));
            ep.setAttr('ImagingLightIntensity', obj.readNumber('AOM_VALUE1 = '));
            if ep.isExpected('SpatialStimulusIntensity', 'attribute')
                ep.setAttr('SpatialStimulusIntensity', obj.readNumber('AOM_VALUE3 = '));
            end
        end
    end

    methods (Static)
        function obj = init(filePath, ID)
            fileName = sara.readers.EpochParameterReader.getFileName(filePath, ID);
            obj = sara.readers.EpochParameterReader(fileName);
        end 

        function fileName = getFileName(filePath, ID)
            files = ls(filePath);
            files = deblank(string(files));
            files = files(contains(files, '.txt'));
            [~, idx] = extractMatches(files,... 
                digitBoundary + int2fixedwidthstr(ID, 4) + digitBoundary);

            if numel(idx) > 1
                files = files(idx);
                % Choose the shortest
                [~, minIdx] = min(strlength(files));
                fileName = char(files(minIdx));
            elseif isempty(idx)
                error('File for ID %u not found in %s!', ID, filePath);
            else
                fileName = char(files(idx));
            end
            fileName = fullfile(filePath, fileName);
        end
    end
end