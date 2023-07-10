classdef SiftRegistration < aod.builtin.registrations.RigidRegistration
% SIFTREGISTRATION
%
% Description:
%   Transformation matrix obtained from ImageJ's SIFT Registration plugin
%
% Parent:
%   aod.builtin.registrations.RigidRegistration
%
% Constructor:
%   obj = SiftRegistration(registrationDate, data, ID)
%
% Required parameters:
%   ReferenceID             Epoch ID used as starting point
% Optional parameters:
%   All the parameters presented in the SIFT user interface
% -------------------------------------------------------------------------
    methods
        function obj = SiftRegistration(registrationDate, data, varargin)
            obj = obj@aod.builtin.registrations.RigidRegistration(...
                'SIFT', registrationDate, data, varargin{:});
           
            obj.setAttr('Software', "ImageJ-SIFTRegistrationPlugin");
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.builtin.registrations.RigidRegistration();
            
            value.add('ReferenceID',  ...
                "Class", "double", "Size", "(1,1)",...
                "Description", 'Epoch ID used as template for registration');
            value.add('HistogramMatching', ...
                "Class", "logical", "Size", "(1,1)", "Default",  false,...
                "Description", 'Whether Histogram Matching was performed first.');
            value.add('WhichStack', ...
                "Class", "string", "Size", "(1,1)", "Default", "SUM",...
                "Description", "Which stack was used for registration");

            % The default parameters for SIFT, only need to specify if one
            % of the defaults presented in ImageJ is changed
            value.add('InitialGaussianBlur',...
                "Default", 1.6, "Size", "(1,1)", "Class", "double");
            value.add('StepsPerScaleOctave',...
                "Default", 3, "Size", "(1,1)", "Class", "double");
            value.add('MinimumImageSize', ...
                "Class", "double", "Size", "(1,1)", "Default", 64);
            value.add('MaximumImageSize', ...
                "Class", "double", "Size", "(1,1)", "Default", 1024);
            value.add('FeatureDescriptorSize', ...
                "Class", "double", "Size", "(1,1)", "Default", 4);
            value.add('FeatureDescriptorOrientationBins', ...
                "Class", "double", "Size", "(1,1)", "Default", 8);
            value.add('ClosestNextClosestRatio', ...
                "Class", "double", "Size", "(1,1)", "Default", 4);
            value.add('MaximalAlignmentRatio',  ...
                "Class", "double", "Size", "(1,1)", "Default", 25);
            value.add('InlierRatio', ...
                "Class", "double", "Size", "(1,1)", "Default", 0.05);
            value.add('ExpectedTransformation',...
                "Class", "string", "Size", "(1,1)", "Default", "rigid",...
                "Function", @(x) ismember(lower(x), ["translation", "rigid", "affine", "similarity"]));
            value.add('Interpolate', ...
                "Class", "logical", "Size", "(1,1)", "Default", true);
        end
    end
end