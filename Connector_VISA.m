% Date: 2026.04.22
% Version: 1.0
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:

% ------------

% TODO list:
% 1) get TODO list from GPIB classes


%       VENDOR         Description
%       ======         ===========
%       keysight       Keysight Technologies VISA.
%       ni             National Instruments VISA.
%       tek            Tektronix VISA.
%       rs             Rohde & Schwarz VISA.

classdef Connector_VISA < Connector
    properties (Access = private)
        fast_mode logical = false;
    end

    methods
        function obj = Connector_VISA(visa_addr, options)
            arguments
                visa_addr;
                options.fast_mode logical = false;
                options.timeout double = 0.5; %FIXME: magic constant
            end
            %FIXME: add variants on VISA vendor
            obj.visa_obj = visa('ni', visa_addr);
            % NOTE: maybe use new visa?
            % EXAMPLE: v = visadev('GPIB0::1::0::INSTR');
            obj.visa_obj.Timeout = options.timeout;
            obj.fast_mode = options.fast_mode;
            if obj.fast_mode
                fopen(obj.visa_obj);
            end
        end

        function delete(obj)
            if obj.fast_mode
                fclose(obj.visa_obj);
            end
        end
    end

    methods (Access = protected)
        function send_data(obj, bytes)
            if obj.fast_mode
                fwrite(obj.visa_obj, bytes);
            else
                fopen(obj.visa_obj);
                try
                    fwrite(obj.visa_obj, bytes);
                catch e
                    fclose(obj.visa_obj);
                    rethrow(e)
                end
                fclose(obj.visa_obj);
            end
        end

        function data = read_data(obj)
            if obj.fast_mode
                data = obj.visa_obj.fscanf();
                data = con_utils.discard_termination(data);
            else
                fopen(obj.visa_obj);
                try
                    data = obj.visa_obj.fscanf();
                catch e
                    fclose(obj.visa_obj);
                    rethrow(e)
                end
                fclose(obj.visa_obj);
                data = con_utils.discard_termination(data);
            end
        end
    end

end
