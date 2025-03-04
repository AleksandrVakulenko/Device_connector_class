% Date: 2025.02.28
% Version: 1.0
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% Connector_empty is a subclass of Connector and could be
% used as placeholder of initial(default value) of any variable
% of Connector type.
%
% Any attempt of executing public methods of Connector_empty
% lead to an error.
%-------------

classdef Connector_empty < Connector

    methods (Access = public)
        function obj = Connector_empty()
            obj.visa_obj = [];
        end
    end

    methods (Access = protected)
        function send_data(obj, bytes)
            error('empty connector class')
        end

        function data = read_data(obj)
            error('empty connector class')
        end
    end
end



















