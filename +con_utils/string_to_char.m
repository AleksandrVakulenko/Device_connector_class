function text = string_to_char(text)
if class(text) == "string"
    text = char(text);
elseif class(text) ~= "char"
    error(['Class of text is ' class(text)]);
end
end