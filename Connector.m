% Date: 2025.02.28
% Version: 1.0
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% Connector(handle) is an abstract class  for wraping RS232,
% USB(virtual COM port) and GPIB connection to an arbitraty I/O device.
%
% Real connection is maintaned by inherited subclasse, scesialized for
% some kind of interface type.
%
% Abstract functions must be overrided by the subclass:
%
% Destruction of low-level serial instance is produced by Connector class
% delete function, by calling visa_obj.delete.
%
% 1) read_data function (Abstract, protected):
% - reads responce from the divece;
% - must be overrided by subclass;
%
% 2) send_data function (Abstract, protected):
% - sends ASCII text of bytes array to the device;
% - must be overrided by subclass;
% 
% 3) send function (public):
% - high-level wrapper of an abstract send_data
%
% 4) read function (public):
% - high-level wrapper of an abstract read_data
% 
% 5) query function (public):
% - sends ASCII text to the device and return a response;
%
% 6) visa_obj property:
% - saves a handle to build-in Matlab class instance (serialport for example);
% - inappropriate use of visa_obj property lead to undefined behavior;
%
% ------------

% TODO:
% 1) maybe discard termination in base class?
% 2) create more error MSG
% 3) refactor visa_obj_delete !!!


classdef Connector < handle

    methods (Access = private)
        function visa_obj_delete(obj)
            if isa(obj.visa_obj, 'handle')
                if isvalid(obj.visa_obj)
                    delete(obj.visa_obj);
                    DEBUG_MSG('Delete visa_obj (handle)', 'red', 'tab')
                else
                    DEBUG_MSG("invalid visa_obj handle in Connector.delete", ...
                        "orange", "tab")
                end
            else
                try % try to delete (it is useful for gpib)
                    delete(obj.visa_obj)
                    DEBUG_MSG('Delete visa_obj (not handle)', 'red', 'tab')
                catch
                    DEBUG_MSG('visa_obj (not handle) could not be deleted', ...
                        'red', 'tab')
                end
            end
        end
    end

    methods (Access = public)
        function delete(obj)
            DEBUG_MSG("Connector :", "red", "dtor")
            if class(obj) ~= "Connector_empty"
                if ~isempty(obj.visa_obj)
                    obj.visa_obj_delete;
                else
                    DEBUG_MSG("empty visa_obj in Connector.delete",...
                        "orange", "tab")
                end
            else
                DEBUG_MSG("ignore empty connector", "orange", "tab")
            end
        end
    end

    % general send/receive
    methods (Access = public)
        function send(obj, data)
            %FIXME: refactor
            if class(data) == "string" || class(data) == "char"
                data = uint8(char(data));
                obj.send_data(data);
                DEBUG_MSG("CONNECTOR SEND: """ + string(char(data)) + """", 'red')
            elseif class(data) == "uint8" || class(data) == "int8"
                data = uint8(data);
                obj.send_data(data);
                DEBUG_MSG("SEND: """ + string(char(data)) + """", 'red')
            end
        end

        function data = read(obj)
            data = obj.read_data;
            DEBUG_MSG("CONNECTOR READ: """ + string(data) + """", 'red')
        end

        function response = query(obj, CMD, speed)
            arguments
                obj
                CMD (1,1) string
                speed {mustBeMember(speed, ["norm", "fast", "no delay"])} = "norm"
            end
            switch speed
                case "norm"
                    Delay = 0.05;
                case "fast"
                    Delay = 0.01;
                case "no delay"
                    Delay = 0;
                otherwise
                    Delay = 0.05;
                    warning('Wrong Delay value')
            end
            obj.send(CMD);
            pause(Delay); % FIXME: magic constant
            response = obj.read_data;
            DEBUG_MSG("CONNECTOR RESP: """ + string(response) + """", 'red')
            % FIXME: timeout?
        end

    end
    
    % abstract send/receive (FIXME: make protected)
    methods (Abstract, Access = protected)
        send_data(obj, bytes);
        data = read_data(obj);
    end

    properties (Access = protected)
        visa_obj;
    end
end


