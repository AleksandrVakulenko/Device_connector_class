function [visa_addr, SerialNumber] = ...
    VISA_find_dev_by_name(Name, SerialNumber, Type_select)
% NOTE: If new options are added, the following functions must also
% be updated:
% - VISA_parse_resource_name(Resource)
% - is_usb(Str, Type)
% - VISA_get_addr(Tokens, Type)
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
%     Str = VISA_get_dev_list_str(dev_table);
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
    % - VISA_parse_resource_name(Resource)
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
    [ind_instr] = con_utils.VISA_filter_INSTR(dev_table.ResourceName);
    dev_table = dev_table(ind_instr, :);

    if size(dev_table, 1) > 1
%         dev_table = dev_table(1, :);
        disp(dev_table);
        error('The choice of connection type is still ambiguous.');
    end

end

visa_addr = dev_table.ResourceName;
SerialNumber = dev_table.SerialNumber;

% [Type, Num, Addr] = VISA_parse_resource_name(visa_addr);
% disp(['Type:       ' char(Type) '<' char(Num) '> <' char(Addr) '>'])
% disp(['VISA addr:  ' char(visa_addr)])

end






function Type = get_type_from_resname(ResourceName)
    Type = strings(1, numel(ResourceName));
    for i = 1:numel(ResourceName)
        Resource = ResourceName(i);
        Type(i) = con_utils.VISA_parse_resource_name(Resource);
    end
end














