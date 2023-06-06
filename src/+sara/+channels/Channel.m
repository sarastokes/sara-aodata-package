classdef Channel < aod.core.Channel 
% Channel with convenience methods for adding common components
%
% Parent:
%   aod.core.Channel
%
% Constructor:
%   obj = sara.channels.Channel(name, varargin)
%
% Optional key/value inputs:
%   pinhole             double
%       Diameter in microns
%   NDF                 double
%       Neutral density filter attenuation
%   BandpassFilter      char
%       Filter name 'wavelength_bandwidth'
% -------------------------------------------------------------------------

    methods 
        function obj = Channel(name, varargin)
            obj@aod.core.Channel(name, varargin{:});

            ip = aod.util.InputParser();
            addParameter(ip, 'NDF', [], @isnumeric);
            addParameter(ip, 'Pinhole', [], @isnumeric);
            addParameter(ip, 'BandpassFilter', [], @istext);
            parse(ip, varargin{:});

            if ~isempty(ip.Results.NDF)
                obj.addNDF(ip.Results.NDF);
            end

            if ~isempty(ip.Results.Pinhole)
                obj.addPinhole(ip.Results.Pinhole);
            end

            if ~isempty(ip.Results.BandpassFilter)
                obj.addBandpassFilter(ip.Results.BandpassFilter);
            end
        end
    end

    methods (Access = protected)
        function addPinhole(obj, diameter)
            % Adds a pinhole
            %
            % Syntax:
            %   addNDF(obj, diameter)
            %
            % Inputs:
            %   diameter            double
            %       Pinhole diameter in microns
            % -------------------------------------------------------------

            pinhole = aod.builtin.devices.Pinhole(diameter, ...
                'Manufacturer', "ThorLabs",... 
                'Model', sprintf("P%uK", diameter));
            obj.add(pinhole);
        end

        function addNDF(obj, attenuation)
            % Adds a neutral density filter
            %
            % Syntax:
            %   addNDF(obj, attenuation)
            %
            % Inputs:
            %   attenuation          double
            %       NDF attenuation, generally > 0, < ~5
            % -------------------------------------------------------------

            arguments
                obj
                attenuation         double 
            end

            ndf = aod.builtin.devices.NeutralDensityFilter(attenuation, ...
                'Manufacturer', "ThorLabs", ...
                'Model', sprintf("NE%uA-A", 10 * attenuation));
            ndf.setTransmission(sara.resources.getResource( ...
                sprintf('NE%uA.txt', 10 * attenuation)));
            obj.add(ndf);
        end

        function addBandpassFilter(obj, filterName)
            % Add a commonly-used bandpass filter for fluorescence
            %
            % Syntax:
            %   addBandpassFilter(obj, filterName)
            %
            % Inputs:
            %   filterName          char  
            %       Either '520_15', '585_40', '590_20' or '607_70'
            % -------------------------------------------------------------
            
            arguments
                obj
                filterName      char 
            end
            
            switch filterName 
                case '520_15'
                    filter = aod.builtin.devices.BandpassFilter(520, 15, ...
                        'Manufacturer', "Semrock", 'Model', "FF01-520/15");
                    filter.setTransmission(sara.resources.getResource('FF01-520_15.txt'));
                case '585_40'
                    filter = aod.builtin.devices.BandpassFilter(585, 40, ...
                        'Manufacturer', "Semrock", 'Model', "FF01-585/40");
                    filter.setTransmission(sara.resources.getResource('FF01-585_40.txt'));
                case '590_20'
                    filter = aod.builtin.devices.BandpassFilter(590, 20, ...
                        'Manufacturer', "Semrock", 'Model', "FF01-590/20");
                    filter.setTransmission(sara.resources.getResource('FF01-590_20.txt'));
                case '607_70'
                    filter = aod.builtin.devices.BandpassFilter(607, 70, ...
                        'Manufacturer', "Semrock", 'Model', "FF01-670/20");
                    filter.setTransmission(sara.resources.getResource('FF01-607_70.txt'));

                otherwise
                    warning('Filter not set. Unrecognized name: %s', filterName);
                    return
            end

            obj.add(filter);
        end
    end
end 