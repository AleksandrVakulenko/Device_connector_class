function Tokens = VISA_tokenizer(Str)
    remain = Str;
    Tokens = string.empty;
    i = 0;
    while ~isempty(char(remain))
        [token_new, remain] = strtok(remain, ":");
        i = i + 1;
        Tokens(i) = string(token_new);
    end
end