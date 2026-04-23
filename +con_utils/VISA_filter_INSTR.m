function [ind] = VISA_filter_INSTR(visa_addr_list)
ind = false(1, numel(visa_addr_list));
for i = 1:numel(visa_addr_list)
    Str = visa_addr_list(i);
    Tokens = con_utils.VISA_tokenizer(Str);
    ind(i) = Tokens(end) == "INSTR";
end
ind = find(ind);
end
