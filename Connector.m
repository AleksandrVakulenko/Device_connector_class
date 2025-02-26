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
% - must be overrided by subclass;
%
% 4) query function (Abstrtact):
% - sends ASCII text to the device and return a response;
% - must be overrided by subclass;
%
% 5) visa_obj property:
% - saves a handle to build-in Matlab class instance (serialport for example);
% - inappropriate use of visa_obj property lead to undefined behavior;
%
% ------------

% TODO:
% 1) replace send_bytes and send_text to one function 
%    (send text by "send_bytes")
% 2) replace query
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

    end
    
    % abstract send/receive (FIXME: make protected)
    methods (Abstract, Access = public)
        send_bytes(obj, bytes);
        send_text(obj, text);
        data = read_data(obj)
        query(obj, text);
    end

    properties (Access = protected)
        visa_obj;
    end
end


