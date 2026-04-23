function Str = VISA_get_dev_list_str(dev_table)
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