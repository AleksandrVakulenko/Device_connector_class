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
% 1) add more options in constructor
% 2) add read functions overrides


%      Bytes_count = serial_obj.NumBytesAvailable;
%
%         if Bytes_count == Obj.number_of_bytes
%             Data = read(serial_obj, Bytes_count, "uint8");
%             stop = 1;
%         end

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
                %FIXME: update options
            end
            options.speed = speed;
            % FIXME: add arg check
            obj.connect_init(port_name, options);
        end
    end

    methods (Access = public)
        function send_text(obj, text)
            obj.connection_assert();
            text = string_to_char(text);
            write(obj.visa_obj, uint8(text), "uint8");
        end

        function send_bytes(obj, bytes)
            obj.connection_assert();
            write(obj.visa_obj, uint8(bytes), "uint8");
        end
    end

    methods (Access = protected)
        function connect_init(obj, port_name, options)
            options % DEBUG MODE
%             obj.visa_obj = serialport(port_name, speed, ...
%                 'DataBits', 8, ...
%                 'StopBits', 1, ...
%                 'Parity', 'odd');
        end
    end

end


