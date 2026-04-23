function [GPIB_num, GPIB_addr, full_address] = VISA_parse_GPIB_string(Name)
    if isempty(Name)
        error("GPIB adress must not be empty")
    end
    if isnumeric(Name)
        if numel(Name) > 1
            error('GPIB address number must be scalar');
        end
        if abs(round(Name) - Name) > 1e-6
            error('GPIB address number must be integer');
        end
    
        GPIB_num = 0;
        GPIB_addr = Name;
    else
        try
            [~, GPIB_num, GPIB_addr] = con_utils.VISA_parse_resource_name(Name);
        catch err
            error('Not a GPIB type')
        end
        if isempty(char(GPIB_num)) && isempty(char(GPIB_addr))
            error(['Both GPIB controller number and GPIB address ...' ...
                'are not provided']);
        end
        if isempty(char(GPIB_num))
            GPIB_num = 0;
        else
            GPIB_num = real(str2num(GPIB_num));
        end
        if isempty(char(GPIB_addr)) && ~isempty(GPIB_num)
            GPIB_addr = GPIB_num;
            GPIB_num = 0;
        else
            GPIB_addr = real(str2num(GPIB_addr));
        end
    
        if isempty(GPIB_num)
            error('Wrong number of GPIB controller')
        end
    
    end
    con_utils.GPIB_validation(GPIB_addr);
    full_address = con_utils.GPIB_port_name_convert(GPIB_addr, GPIB_num);
end