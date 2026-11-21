% FIXME: add text parser
% FIXME: GPIB could have different number GPIB0, GPIB1, GPIB2, ...
function port = GPIB_port_name_convert(port_arg, num)
arguments
    port_arg
    num = 0
end
    if class(port_arg) == "char" || class(port_arg) == "string"
        Port_N = str2num(port_arg);
        if ~isempty(Port_N) && isreal(Port_N) % for case "23j", "14i", ...
            con_utils.GPIB_validation(Port_N);
            port = ['GPIB' num2str(num) '::' num2str(Port_N) '::INSTR'];
        end
    elseif isnumeric(port_arg) && isreal(port_arg)
        con_utils.GPIB_validation(port_arg);
        port = ['GPIB' num2str(num) '::' num2str(port_arg) '::INSTR'];
    else
        error("port must be a real number or char of string")
    end
end