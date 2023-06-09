classdef EpochParameterReader < aod.util.readers.TxtReader 
% EPOCHPARAMETERREADER
%
% Description:
%   Reads epoch parameter files and makes according adjustments to epoch
%
% Parent:
%   aod.util.readers.TxtReader
%
% Syntax:
%   obj = EpochParameterReader(fileName)
%
% Notes:
%   readFile() requires an Epoch as an input - attributes will be directly
%   assigned to the epoch to reduce complexity of passing them back
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

            % Imaging window
            x = obj.readNumber('ImagingWindowX = ');
            y = obj.readNumber('ImagingWindowY = ');
            dx = obj.readNumber('ImagingWindowDX = ');
            dy = obj.readNumber('ImagingWindowDY = ');
            ep.setAttr('ImagingWindow', [x y dx dy]);

            
            % Channel parameters
            ep.setAttr('RefGain', obj.readNumber('ADC channel 1, gain = '));
            ep.setAttr('VisGain', obj.readNumber('ADC channel 2, gain = '));
            ep.setAttr('RefOffset', obj.readNumber('ADC channel 1, offset = '));
            ep.setAttr('VisOffset', obj.readNumber('ADC channel 2, offset = '));
            ep.setAttr('RefPmtGain', obj.readNumber('Reflectance PMT gain  = '));
            ep.setAttr('VisPmtGain', obj.readNumber('Fluorescence PMT gain = '));
            ep.setAttr('AOM1', obj.readNumber('AOM_VALUE1 = '));
            ep.setAttr('AOM2', obj.readNumber('AOM_VALUE2 = '));
            ep.setAttr('AOM3', obj.readNumber('AOM_VALUE3 = '));
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