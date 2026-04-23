% FIXME: move to con_utils
function GPIB_validation(GPIB_num)
mustBeNumeric(GPIB_num);
mustBeInteger(GPIB_num);

if GPIB_num < 0
    error('GPIB address must be greater than or equal to 0.')
end

if GPIB_num > 30
    error('GPIB address must be less than or equal to 30.')
end

end
