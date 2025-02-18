% Date: 2025.02.18
% Version: 1.0
% Author: Aleksandr Vakulenko
%
% ----INFO----:
% Connector_COM_USB is a subclass of Connector_COM_RS232, specified for maintain
% connection by USB in virtual COM port mode. For this case there no need to
% specify any of COM port properties.
% 
%-------------

classdef Connector_COM_USB < Connector_COM_RS232
    methods (Access = public)
        function obj = Connector_COM_USB(port_name)
            obj@Connector_COM_RS232(port_name, 9600);
        end
    end
end
