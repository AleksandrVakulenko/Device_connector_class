function Addr = VISA_parse_COM_string(Name)
    if isnumeric(Name)
        if numel(Name) > 1
            error('COM port number must be scalar');
        end
        if abs(round(Name) - Name) > 1e-6
            error('COM port number must be integer');
        end
        if Name <= 0
            error("COM port number must be > 0");
        end
    elseif any(class(Name) == ["string", "char"])
        Name = char(Name);
        Name = strrep(Name, "COM", "ASRL");
        try
            [Type, Addr, ~] = con_utils.VISA_parse_resource_name(Name);
            if any(class(Addr) == ["string", "char"])
                Addr = str2num(char(Addr));
                if imag(Addr) ~= 0
                    Addr = [];
                end
            end
        catch
            error('Not a COM type')
        end
        if Type ~= "COM"
            error('Not a COM type')
        end
        if isempty(Addr)
            error('COM port number does not provided')
        end
    end
end