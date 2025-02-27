% FIXME: add text parser
function port = GPIB_port_name_convert(port)
    if class(port) == "char" || class(port) == "string"
        Num = str2num(port);
        if ~isempty(Num) && isreal(Num) % for case "23j", "14i", ...
            port = ['GPIB0::' num2str(Num) '::INSTR'];
        end
    elseif isnumeric(port) && isreal(port)
        port = ['GPIB0::' num2str(port) '::INSTR'];
    else
        error("port must be a real number or char of string")
    end
end