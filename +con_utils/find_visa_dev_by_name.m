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
init_dev_table = dev_table;

% 1) Select subtable by name.
range = dev_table.Model == Name;
dev_table = dev_table(range, :);

% 2) Select subtable by SerialNumber (if provided).
if ~isempty(SerialNumber) && ~isempty(char(SerialNumber))
    range = dev_table.SerialNumber == string(SerialNumber);
    dev_table = dev_table(range, :);
else
% 3) If SerialNumber is not provided and where is more than one serial 
% number for device resources with the same name - throw an error.
    SN_list = string(dev_table.SerialNumber);
    SN_list = strtrim(SN_list);
    SN_list = unique(SN_list);
    if numel(SN_list) > 1
        disp(['VISA device list for <' char(Name) '>:'])
        disp(dev_table)
        error(['More than one device of the same model are in list, ' ...
            'non-empty serial number argument is required.'])
    end
end



VISA_addr = dev_table.ResourceName;
if numel(VISA_addr) == 0
    disp(['VISA device list for <' char(Name) '>:'])
    disp(init_dev_table)
    error(['No device "' char(Name) '"' ' with serial number "' ...
        char(SerialNumber) '" is in list.']);
%     error(['More than one device of the same model are in list, ' ...
%         'non-empty serial number argument is required.'])
%     Str = get_dev_list_str(dev_table);
elseif numel(VISA_addr) > 1
    % NOTE: case of multiple options;
    Type = get_type_from_resname(VISA_addr);

    if ~isempty(Type_select)
        ind_type_s = false(1, numel(Type));
        for i = 1:numel(Type_select)
            ind_type_s = ind_type_s | Type == Type_select(i);
        end
        dev_table = dev_table(ind_type_s, :);
        VISA_addr = dev_table.ResourceName;
        Type = get_type_from_resname(VISA_addr);
    end

    % NOTE: select order USB > GPIB > TCPIP > COM
    % NOTE: If new options are added, the following functions must also
    % be updated:
    % - parse_resource_name(Resource)
    if any(Type == "USB")
        ind_type = find(Type == "USB");
    elseif any(Type == "GPIB")
        ind_type = find(Type == "GPIB");
    elseif any(Type == "TCPIP")
        ind_type = find(Type == "TCPIP");
    elseif any(Type == "COM")
        ind_type = find(Type == "COM");
    else
        error('unreachable')
    end
    
    dev_table = dev_table(ind_type, :);

    % NOTE: it also could be a "::socket" (not ::INSTR)
    [ind_instr] = filter_INSTR(dev_table.ResourceName);
    dev_table = dev_table(ind_instr, :);

    if size(dev_table, 1) > 1
%         dev_table = dev_table(1, :);
        disp(dev_table);
        error('The choice of connection type is still ambiguous.');
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