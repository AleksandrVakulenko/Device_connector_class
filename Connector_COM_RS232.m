% Date: 2025.02.18
% Version: 0.9
% Author: Aleksandr Vakulenko
%
% ----INFO----:
% Connector_COM_RS232 is a subclass of Connector, specified for maintain
% connection by RS232 line by Low-level instace of Matlab built-in
% serialport object.
%
%-------------

% TODO list:
% 1) 
% 2) 


classdef Connector_COM_RS232 < Connector
    methods (Access = public)
        function obj = Connector_COM_RS232(port_name, speed, options)
            arguments
                port_name char;
                speed (1,1) double;
                options.DataBits {mustBeMember(options.DataBits,...
                    [5, 6, 7, 8])} = 8;
                options.StopBits {mustBeMember(options.StopBits, [1, 2])} ...
                    = 1;
                options.Parity {mustBeMember(options.Parity,...
                    ["none", "even", "odd"])} = "none";
            end
            % FIXME: add arg check
            obj.visa_obj = serialport(port_name, speed, ...
                'DataBits', options.DataBits, ...
                'StopBits', options.StopBits, ...
                'Parity', options.Parity);
        end
    end

    methods (Access = public)
        function send_data(obj, bytes)
            write(obj.visa_obj, uint8(bytes), "uint8");
        end

        function Data = read_data(obj)
            serial_obj = obj.visa_obj;
            Bytes_count = serial_obj.NumBytesAvailable;
            if Bytes_count > 0
                Data = read(serial_obj, Bytes_count, "uint8");
            else
                Data = [];
            end
        end

    end
end


