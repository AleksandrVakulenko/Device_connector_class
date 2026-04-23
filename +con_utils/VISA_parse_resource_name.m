function [Type, Num, Addr] = VISA_parse_resource_name(Resource)
    %NOTE: If new options are added, the following functions must also
    % be updated: 
    % - VISA_is_type(Str, Type)
    % - VISA_get_addr(Tokens, Type)
    Types = ["USB", "COM", "GPIB", "TCPIP"];
    
    flag = false;
    for i = 1:numel(Types)
        Type = Types(i);
        [status, Num, Addr] = con_utils.VISA_is_type(Resource, Type);
        if status
            flag = true;
            break;
        end
    end
    
    if ~flag
        error(['no matching Resource type for: <' char(Resource) '>'])
    end
end