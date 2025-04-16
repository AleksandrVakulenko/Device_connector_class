% Date: 2025.02.28
% Version: 1.0
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% Connector_GPIB_Q is a subclass of Connector, specified for maintain
% connection by GPIB line using Low-level instace of Matlab built-in
% visadev object.

% Uses callback read function.
% ------------

% TODO list:
% 1) 
% 2) 


classdef Connector_GPIB_Q < Connector
    properties
        queue GPIB_resp_queue
        last_hash = []
        timeout
    end

    methods
        function obj = Connector_GPIB_Q(port_name, options)
            arguments
                port_name;
                options.timeout double = 0.5; %FIXME: magic constant
            end
            DEBUG_MSG("Connector_GPIB: create 'visa_obj'", "red", "ctor")
            port_name_full = con_utils.GPIB_port_name_convert(port_name);
            obj.timeout = options.timeout;
            obj.visa_obj = visadev(port_name_full);
            try
                obj.visa_obj.UserData = obj;
                configureCallback(obj.visa_obj, "terminator", @read_callback);
                obj.visa_obj.Timeout = options.timeout;
                obj.queue = GPIB_resp_queue;
            catch err
                delete(obj.visa_obj)
                rethrow(err)
            end
        end

        function delete(obj)
            delete(obj.visa_obj)
        end

        function qh = get_queue_obj(obj)
            qh = obj.queue;
        end
    end

    methods (Access = protected)
        function send_data(obj, bytes)
            hash = obj.queue.add_request;
            obj.last_hash = hash;
            dev = obj.visa_obj;
            write(dev, bytes, "uint8");
        end

        function data = read_data(obj)
            if ~isempty(obj.last_hash)
                hash = obj.last_hash;
                obj.last_hash = [];
                data = obj.get_resp_pr(hash);
            else
                data = [];
            end
        end
    end

    methods (Access = private)
        function resp = get_resp_pr(obj, hash)
            Timer = tic;
            resp = [];
            stop = false;
            while ~stop
                time = toc(Timer);
                data = obj.queue.get_response(hash);
                if ~isempty(data)
                    resp = char(data);
                    break;
                end
                if time > 1
%                     disp('TIMEOUT')
                    obj.queue.resp_data
                    stop = true;
                end
                pause(0.00001) % NOTE: must be any pause
            end
        end

    end

end



function read_callback(src, ~)
% disp('CALLBACK')
con_obj = src.UserData;
Queue = con_obj.get_queue_obj;

data = readline(src);
Queue.add_response(data);
end




