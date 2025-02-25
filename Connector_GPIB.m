% Date: 2025.02.19
% Version: 0.1
% Author: Aleksandr Vakulenko
%
% ----INFO----:

% ------------

% TODO list:
% 1) ni OR keysight VISA?
% 2) port_name variants string? char? num?
% 3) 

classdef Connector_GPIB < Connector
    methods
        function obj = Connector_GPIB(port_name, options)
            arguments
                port_name;
                options.timeout double = 0.5;
            end
            disp("Connector_GPIB C-tor") % FIXME: debug
            port_name_full = utils.GPIB_port_name_convert(port_name);
            obj.visa_obj = visa('ni', port_name_full);
            obj.visa_obj.Timeout = options.timeout;
        end

        function delete(obj)
            % FIXME: debug
            disp("Connector_GPIB D-tor")
        end
    end

    methods
        function f_close(obj) % FIXME: debug/delete
            fclose(obj.visa_obj);
        end

        function send_bytes(obj, bytes)
            fopen(obj.visa_obj);
            try
            fwrite(obj.visa_obj, bytes);
            catch
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
            data = utils.discard_termination(data);
        end

        function send_text(obj, text)
            % FIXME: check for '\n' in text
            % fprintf(obj.visa_obj, [text '\r\n']);
            % FIXME: wrong place for termination
            term1 = uint8(13);
            term2 = uint8(10);
            bytes = [uint8(text)];
            obj.send_bytes(bytes)
        end

        function response = query(obj, text)
            % FIXME: timeout?
            obj.send_text(text);
            response = obj.read_data;
        end
    end

end