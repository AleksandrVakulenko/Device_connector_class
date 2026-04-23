



function [visa_addr, SerialNumber] = VISA_str2gpib(Input_str, Dev_Name, Type_select)
% NOTE: If new options are added, the following functions must also
% be updated:
% - VISA_find_dev_by_name
arguments
    Input_str
    Dev_Name string
    Type_select string {mustBeMember(Type_select, ...
        ["USB", "GPIB", "COM", "ASRL", "TCPIP"])} = string.empty
end

try
    [~, ~, visa_addr] = ...
        con_utils.VISA_parse_GPIB_string(Input_str);
    SerialNumber = [];
catch
    Serial_number = Input_str;
    [visa_addr, SerialNumber] = con_utils.VISA_find_dev_by_name(Dev_Name, ...
        Serial_number, ["USB", "GPIB"]);
end

end

