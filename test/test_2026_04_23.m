% 2026.04.23

% 
% ----- COM port: -----
% 3 <string/char/double>
% "COM3" <string/char>
% "COM3::INSTR" <string/char>
% "ASRL3::INSTR" <string/char>
% 
% 
% 
% ----- VISA: ---------
% --- GPIB/USB/TCIP
% - [empty]
% - [serial number] <string/char>
% - 14 <string/char/double>
% - "GPIB14" <string/char>
% - "GPIB0::14" <string/char>
% - "GPIB0::14::INSTR" <string/char>
% 
% 
% -- USB-VISA:
% [serial number] <string/char>
% 
% 


clc

Name = "COM3";
% con_utils.VISA_maybe_COM_port(Name)
[Addr, Full_address] = con_utils.VISA_parse_COM_string(Name)

%%
clc

Name = "GPIB::";
[GPIB_num, Addr] = con_utils.VISA_parse_GPIB_string(Name)

%%

clc

Name = "GPIB::14";

COM_flag = con_utils.VISA_maybe_COM_port(Name)
GPIB_flag = con_utils.VISA_maybe_GPIB_port(Name)

if GPIB_flag && ~COM_flag

elseif ~GPIB_flag && COM_flag

elseif ~COM_flag && ~GPIB_flag

elseif GPIB_flag && COM_flag
    error('unreachable')
end







%%




% [Type, Num, addr] = con_utils.VISA_parse_resource_name(Name)



function status = VISA_maybe_COM_port(Name)
    status = true;
    try
        con_utils.VISA_parse_COM_string(Name);
    catch
        status = false;
    end
end






















