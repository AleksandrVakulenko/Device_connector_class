function [status, Num, Addr] = VISA_is_type(Str, Type)
arguments
    Str string
    Type {mustBeMember(Type, ["USB", "GPIB", "COM", "ASRL", "TCPIP"])}
end
    Type = string(Type);
    if Type == "COM"
        Type = "ASRL";
    end
    N = numel(char(Type));
    Num = [];
    Addr = [];
    Tokens = con_utils.VISA_tokenizer(Str);

    if isempty(Tokens)
        status = false;
    else
        Str = char(Tokens(1));
        if numel(Str)>=N && Str(1:N) == Type
            status = true;
            Str(1:N) = [];
            if ~isempty(Str)
                Num = string(Str);
            end
            if numel(Tokens) > 1
                Addr = string(con_utils.VISA_get_addr(Tokens, Type));
            end
        else
            status = false;
        end
    end
end