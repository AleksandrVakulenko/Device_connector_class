% Date: 2025.02.19
% Author: Aleksandr Vakulenko

% ----INFO----:
% FIXME: update
%-------------

% TODO list:
% 1) refactor
% 2) add options

function output = discard_termination(input, term_list)
    arguments
        input;
        term_list uint8 = [uint8(10) uint8(13)]
    end

    input_class = class(input);
    input = uint8(input);
    stop = false;
    while ~stop && ~isempty(input)
        [input, stop] = cut_single_term(input, term_list);
    end
    if input_class == "char"
        output = char(input);
    elseif input_class == "uint8" || input_class == "int8"
        output = input;
    else
        error(['input class is <' input_class '>'])
    end
end


% bytes/term_list must contain at least one element
function [bytes, status] = cut_single_term(bytes, term_list)
    status = true;
    for i = 1:numel(term_list)
        if bytes(end) == term_list(i)
            bytes(end) = [];
            status = false;
            break;
        end
    end
end
