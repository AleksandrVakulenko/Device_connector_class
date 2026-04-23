function Addr = VISA_get_addr(Tokens, Type)
arguments
    Tokens string
    Type {mustBeMember(Type, ["USB", "GPIB", "COM", "ASRL", "TCPIP"])}
end
    switch Type
        case {"USB", "TCPIP"}
            Addr = '';
            for i = 2:numel(Tokens)-1
                if isempty(Addr)
                    Addr = [Addr char(Tokens(i))];
                else
                    Addr = [Addr '::' char(Tokens(i))];
                end
            end
        case "GPIB"
            Addr = Tokens(2);
    
        case {"COM", "ASRL"}
            Str = char(Tokens(1));
            result = Str(isstrprop(Str, 'digit'));
            Addr = result;
    end
end