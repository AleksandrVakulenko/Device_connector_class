% Date: 2025.02.18
% Version: 0.9
% Author: Aleksandr Vakulenko
%
% ----INFO----:
% Connector(handle) is an abstract class  for wraping RS232,
% USB(virtual COM port) and GPIB connections to an arbitraty I/O device.
%
% Real connection is maintaned by inherited subclasses, scesialized for
% some kind of interface type.
%
% Abstract functions must be overrided by the subclass.
%
% Destruction of low-level resources instance is produced by Connector class
% delete function, by calling visa_obj.delete.
%
% 1) 
%
% 2) read_data function (Abstract, protected):
% - reads responce from the divece;
% - must be overrided by subclass;
%
% 3) send_data function (Abstract, protected):
% - sends ASCII text of bytes array to the device;
% - must be overrided by subclass;
% 
% 4) send function (public):
% - high-level wrapper of an abstract send_data
%
% 5) read function (public):
% - high-level wrapper of an abstract read_data
% 
% 
% 6) query function (public):
%    NOTE: NOT ABSTRACT 2025.02.26
% - sends ASCII text to the device and return a response;
% - must be overrided by subclass;
%
% 7) visa_obj property:
% - saves a handle to build-in Matlab class instance (serialport for example);
% - inappropriate use of visa_obj property lead to undefined behavior;
%
% ------------

% TODO:
% 1) Add public read_function
% 2) 
% 3) may be discard termination in base class?
% 4) create error MSG with stacktrace
% 5) 


classdef Connector < handle

    methods (Access = private)
        function visa_obj_delete(obj)
            if isa(obj.visa_obj, 'handle')
                if isvalid(obj.visa_obj)
                    delete(obj.visa_obj);
                    disp('Delete visa_obj (handle)')
                else
                    warning(['invalid handle visa_obj ...' ...
                        'in Connector.delete'])
                end
            else
                disp('Delete visa_obj (not handle)')
            end
        end
    end

    methods (Access = public)
        function delete(obj)
            disp("Connector D-tor")
            if ~isempty(obj.visa_obj)
                obj.visa_obj_delete;
            else
                warning('empty visa_obj in Connector.delete')
            end
        end
    end

    % general send/receive
    methods (Access = public)
        function send(obj, data)
            if class(data) == "string" || class(data) == "char"
                data = uint8(char(data));
                obj.send_data(data);
            end
            if class(data) == "uint8" || class(data) == "int8"
                data = uint8(data);
                obj.send_data(data);
            end
        end

        function data = read(obj)
            data = obj.read_data;
        end

        function response = query(obj, data)
            obj.send(data);
            pause(0.05); % FIXME: magic constant
            response = obj.read_data;
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


