function [visa_addr, SerialNumber] = ...
    find_visa_dev_by_name(Name, SerialNumber, Type_select)
% NOTE: If new options are added, the following functions must also
% be updated:
% - parse_resource_name(Resource)
% - is_usb(Str, Type)
% - get_addr(Tokens, Type)
arguments
    Name string
    SerialNumber = [];
    Type_select string {mustBeMember(Type_select, ...
        ["USB", "GPIB", "COM", "ASRL", "TCPIP"])} = string.empty
end
Type_select(Type_select == "") = [];

dev_table = visadevlist;

if ~isempty(SerialNumber) && ~isempty(char(SerialNumber))
    range = dev_table.SerialNumber == string(SerialNumber);
    dev_table = dev_table(range, :);
end

range = dev_table.Model == Name;
dev_table = dev_table(range, :);

ResourceName = dev_table.ResourceName;
if numel(ResourceName) == 0
    Str = adev_utils.get_dev_list_str(dev_table);
    error(['No device "' char(Name) '"' ' with serial number "' ...
        char(SerialNumber) '" in list: ' newline Str]);
elseif numel(ResourceName) > 1
    % NOTE: case of multiple options;
    Type = get_type_from_resname(ResourceName);

    if ~isempty(Type_select)
        ind_type_s = false(1, numel(Type));
        for i = 1:numel(Type_select)
            ind_type_s = ind_type_s | Type == Type_select(i);
        end
        dev_table = dev_table(ind_type_s, :);
        ResourceName = dev_table.ResourceName;
        Type = get_type_from_resname(ResourceName);
    end

    % NOTE: select order USB > TCPIP > GPIB > COM
    % NOTE: If new options are added, the following functions must also
    % be updated:
    % - parse_resource_name(Resource)
    if any(Type == "USB")
        ind_type = find(Type == "USB");
    elseif any(Type == "TCPIP")
        ind_type = find(Type == "TCPIP");
    elseif any(Type == "GPIB")
        ind_type = find(Type == "GPIB");
    elseif any(Type == "COM")
        ind_type = find(Type == "COM");
    else
        error('unreachable')
    end
    
    dev_table = dev_table(ind_type, :);

    [ind_instr] = filter_INSTR(dev_table.ResourceName);
    dev_table = dev_table(ind_instr, :);

    if size(dev_table, 1) > 1
        dev_table = dev_table(1, :);
        warning("The choice of connection type is still ambiguous; " + ...
            "first is selected")
    end

end

visa_addr = dev_table.ResourceName;
SerialNumber = dev_table.SerialNumber;

% [Type, Num, Addr] = parse_resource_name(visa_addr);
% disp(['Type:       ' char(Type) '<' char(Num) '> <' char(Addr) '>'])
% disp(['VISA addr:  ' char(visa_addr)])

end


function Type = get_type_from_resname(ResourceName)
    Type = strings(1, numel(ResourceName));
    for i = 1:numel(ResourceName)
        Resource = ResourceName(i);
        Type(i) = parse_resource_name(Resource);
    end
end

function [ind] = filter_INSTR(visa_addr_list)
ind = false(1, numel(visa_addr_list));
for i = 1:numel(visa_addr_list)
    Str = visa_addr_list(i);
    Tokens = tokenizer(Str, ":");
    ind(i) = Tokens(end) == "INSTR";
end
ind = find(ind);
end

function [Type, Num, Addr] = parse_resource_name(Resource)
    %NOTE: If new options are added, the following functions must also
    % be updated: 
    % - is_usb(Str, Type)
    % - get_addr(Tokens, Type)
    Types = ["USB", "COM", "GPIB", "TCPIP"];
    
    flag = false;
    for i = 1:numel(Types)
        Type = Types(i);
        [status, Num, Addr] = is_usb(Resource, Type);
        if status
            flag = true;
            break;
        end
    end
    
    if ~flag
        error(['no matching Resource type for: <' char(Resource) '>'])
    end
end


function [status, Num, Addr] = is_usb(Str, Type)
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
    Tokens = tokenizer(Str, ":");

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
                Addr = string(get_addr(Tokens, Type));
            end
        else
            status = false;
        end
    end
end


function Addr = get_addr(Tokens, Type)
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


function Tokens = tokenizer(Str, delimiters)
    remain = Str;
    Tokens = string.empty;
    i = 0;
    while ~isempty(char(remain))
        [token_new, remain] = strtok(remain, delimiters);
        i = i + 1;
        Tokens(i) = string(token_new);
    end
end

function Str = get_dev_list_str(dev_table)
    arguments
        dev_table = [];
    end

    if isempty(dev_table)
        dev_table = visadevlist;
    end
    Str = '';
    for i = 1:size(dev_table, 1)

        Vendor = char(dev_table{i, "Vendor"});
        Model = char(dev_table{i, "Model"});
        SerialNumber = char(dev_table{i, "SerialNumber"});
        Type = char(dev_table{i, "Type"});

        if isempty(Vendor)
            Vendor = 'no vendor';
        end

        if isempty(Model)
            Model = 'no model';
        end

        if isempty(SerialNumber)
            SerialNumber = 'no serial number';
        end

        Str = [Str num2str(i) '| ' ...
               Vendor ' | ' ...
               Model  ' | ' ...
               SerialNumber ' | ' ...
               '<' Type '>' newline];
    end
end