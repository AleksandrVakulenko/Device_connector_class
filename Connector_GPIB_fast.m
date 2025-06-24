% Date: 2025.02.28
% Version: 1.0
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% Connector_GPIB is a subclass of Connector, specified for maintain
% connection by GPIB line using Low-level instance of Matlab built-in
% visa object.
% ------------

% TODO list:
% 1) adlink, mcc, ni, keysight VISA?
% 2) port_name variants string? char? num?
% 3) timeout
% 4) !!! in send: find all "\n" & "\r" and delete them, push_back "\n"
% 5) Add port name to debug_msg

classdef Connector_GPIB_fast < Connector
    methods
        function obj = Connector_GPIB_fast(port_name, options)
            arguments
                port_name;
                options.timeout double = 0.5; %FIXME: magic constant
            end
            DEBUG_MSG("Connector_GPIB_fast: create 'visa_obj'", "red", "ctor")
            port_name_full = con_utils.GPIB_port_name_convert(port_name);
            obj.visa_obj = visa('ni', port_name_full);
            obj.visa_obj.Timeout = options.timeout;
            DEBUG_MSG("CON_FAST: open GPIB visa", 'red', 'tab')
            fopen(obj.visa_obj);
        end

        function delete(obj)
            DEBUG_MSG("CON_FAST: close GPIB visa", "red", "dtor")
            fclose(obj.visa_obj);
        end
    end

    methods (Access = protected)
        function send_data(obj, bytes)
            fwrite(obj.visa_obj, bytes);
        end

        function data = read_data(obj)
            data = obj.visa_obj.fscanf();
            data = con_utils.discard_termination(data);
        end
    end

end
