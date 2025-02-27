% Date: 2025.02.28
% Version: 1.0
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% Connector_GPIB is a subclass of Connector, specified for maintain
% connection by GPIB line using Low-level instace of Matlab built-in
% visa object.
% ------------

% TODO list:
% 1) adlink, mcc, ni, keysight VISA?
% 2) port_name variants string? char? num?
% 3) timeout

classdef Connector_GPIB < Connector
    methods
        function obj = Connector_GPIB(port_name, options)
            arguments
                port_name;
                options.timeout double = 0.5; %FIXME: magic constant
            end
            DEBUG_MSG("Connector_GPIB", "red", "ctor")
            port_name_full = con_utils.GPIB_port_name_convert(port_name);
            obj.visa_obj = visa('ni', port_name_full);
            obj.visa_obj.Timeout = options.timeout;
        end

        function delete(obj)
            DEBUG_MSG("Connector_GPIB", "red", "dtor")
        end
    end

    methods (Access = protected)
        function f_close(obj) % FIXME: debug/delete
            fclose(obj.visa_obj);
        end

        function send_data(obj, bytes)
            fopen(obj.visa_obj);
            try
                fwrite(obj.visa_obj, bytes);
            catch e
                fclose(obj.visa_obj);
                error(e.message)
            end
            fclose(obj.visa_obj);
        end

        function data = read_data(obj)
            fopen(obj.visa_obj);
            try
                data = obj.visa_obj.fscanf();
            catch e
                fclose(obj.visa_obj);
                error(e.message)
            end
            fclose(obj.visa_obj);
            data = con_utils.discard_termination(data);
        end
    end

end
