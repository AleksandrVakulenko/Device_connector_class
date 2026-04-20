% Date: 2025.02.28
% Version: 1.0
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% Connector(handle) is an abstract class  for wrapping RS232,
% USB(virtual COM port) and GPIB connection to an arbitrary I/O device.
%
% Real connection is maintained by inherited subclass, specialized for
% some kind of interface type.
%
% Abstract functions must be overridden by the subclass:
%
% Destruction of low-level serial instance is produced by Connector class
% delete function, by calling visa_obj.delete.
%
% 1) read_data function (Abstract, protected):
% - reads response from the device;
% - must be overridden  by subclass;
%
% 2) send_data function (Abstract, protected):
% - sends ASCII text of bytes array to the device;
% - must be overridden  by subclass;
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
% 4) update info

% 2026/04/20 update:
% 1) add Data_stash for reading num_of_bytes and saving unused part
% 2) add flush function
% 3) 


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

        function flush(obj)
            obj.read_data;
            obj.Data_stash = [];
        end

        function send(obj, data)
            if class(data) == "string" || class(data) == "char"
                data = uint8(char(data));
            elseif class(data) == "uint8" || class(data) == "int8"
                data = uint8(data);
            end
            obj.send_data(data);
            % FIXME: add binary detector for printing
            DEBUG_MSG(['CONNECTOR SEND: "' char(data) '"'], 'red')
        end


        function Data = read(obj, num_of_bytes, mode)
            arguments
                obj
                num_of_bytes (1,1) double {mustBeInteger(num_of_bytes)} = []
                mode {mustBeMember(mode, ["multiple", "exact"])} = "multiple";
            end
            Data = obj.read_data;
            Data = reshape(Data, 1, numel(Data));
            % FIXME: convert to uint8?
            Data = [obj.Data_stash Data];

            Bytes_count = numel(Data);

            if ~isempty(num_of_bytes) && num_of_bytes >= 0
                if mode == "exact"
                    Bytes_to_read = Bytes_count;
                    Bytes_to_stash = 0;
                elseif mode == "multiple"
                    Bytes_to_read = floor(Bytes_count/num_of_bytes) * num_of_bytes;
                    Bytes_to_stash = Bytes_count - Bytes_to_read;
                else
                    error('unreachable');
                end
            else
                Bytes_to_read = Bytes_count;
                Bytes_to_stash = 0;
            end
            
            obj.Data_stash = Data(Bytes_to_read+1 : end);
            Data(Bytes_to_read+1 : end) = [];

            DEBUG_MSG(['Data Stash size:' num2str(numel(obj.Data_stash))], "orange")
            % FIXME: add binary detector for printing
            DEBUG_MSG(['CONNECTOR READ: "' char(Data)  '"'], 'red')
        end


        function response = query(obj, CMD, speed)
            arguments
                obj
                CMD char
                speed {mustBeMember(speed, ["norm", "fast", "no delay"])} = "norm"
            end
            switch speed % FIXME: magic constant
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
            pause(Delay);
            response = obj.read_data;
            response = char(response);
            % FIXME: add binary detector for printing
            DEBUG_MSG(['CONNECTOR RESP: "' char(response) '"'], 'red')
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

    properties (Access = private)
        Data_stash = []; % add type
    end
end


