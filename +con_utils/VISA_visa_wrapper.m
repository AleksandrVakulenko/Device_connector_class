
%       ni             National Instruments VISA.
%       keysight       Keysight Technologies VISA.
%       tek            Tektronix VISA.
%       rs             Rohde & Schwarz VISA.

function visa_obj = VISA_visa_wrapper(visa_addr)
Visa_vendor_list = ["ni", "keysight", "tek", "rs"];
visa_obj = [];
for i = 1:numel(Visa_vendor_list)
    Vendor = Visa_vendor_list(i);
    try
        visa_obj = visa(Vendor, visa_addr);
    catch err
%         err.identifier
        if (err.identifier == "instrument:visa:adaptorNotFound") || ...
            (err.identifier == "instrument:visa:invalidVENDOR")
            continue;
        elseif err.identifier == "instrument:visa:invalidRSRCNAMESpecified"
            error('Invalid visa address')
        end
    end
    break
end

if isempty(visa_obj)
    error(['No visa verndor is found:' newline ...
        '- Keysight' newline ...
        '- National Instruments' newline ...
        '- Tektronix' newline ...
        '- Rohde & Schwarz'])
end

end





