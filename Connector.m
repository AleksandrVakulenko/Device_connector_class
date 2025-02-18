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
% 1) connect_init function:
% - must be called in subclass constructor;
% - sets property visa_obj to low-level connection class instance
% 
% 2) send_text function (Abstract):
% - sends ASCII text to the device;
% - overrided by subclass;
% 
% 3) send_bytes function (Abstract):
% - sends ASCII text to the device;
%  - overrided by subclass;
% 
% 4) visa_obj property:
% - saves a handle to build-in Matlab class instance (serialport for example);
% - inappropriate use of visa_obj property lead to undefined behavior;
% 
% ------------


classdef Connector < handle

    methods (Access = public)
        function status = connection_status(obj)
            status = ~isempty(obj.visa_obj) && ...
                isa(obj.visa_obj, 'handle') && ...
                isvalid(obj.visa_obj);
        end
    end

    methods (Access = public)
        function delete(obj)
            if connection_status(obj)
                delete(obj.visa_obj)
                disp('Connector kills visa_obj')
            else
                disp('nothing to disconnect')
            end
        end
    end

    % FIXME: close del to private
    methods (Access = protected)
        function connection_assert(obj)
            if ~obj.connection_status
                error('disconnected object');
            end
        end
    end

    methods (Abstract, Access = public)
%         FIXME: add read functions
        send_text(obj, text);
        send_bytes(obj, bytes);
    end

    methods (Abstract, Access = protected)
        connect_init(obj, port_name, options);
    end


    methods (Static, Access = protected)
        function text = string_to_char(text)
            if class(text) == "string"
                text = char(text);
            elseif class(text) ~= "char"
                error(['Class of text is ' class(text)]);
            end
        end
    end


    properties (Access = protected)
        visa_obj;
    end

end


