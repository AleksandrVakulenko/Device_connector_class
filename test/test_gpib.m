
% obj1 = instrfind('Type', 'visa-gpib', 'RsrcName', 'GPIB0::15::INSTR')

clc

visa_obj = visa('ni', "GPIB::15::INSTR")

visa_obj.Timeout

fopen(visa_obj)

fwrite(visa_obj, uint8('freq?'));

visa_obj.ValuesReceived
visa_obj.BytesAvailable
visa_obj.readasync
% visa_obj.size
data = fread(visa_obj)
data = fscanf(visa_obj)


visa_obj.fscanf()

fclose(visa_obj)
delete(visa_obj)

%%

clc

A = Connector_GPIB(15);
% resp = A.query('freq?')

A.send('freq?');
% pause(1)
% A.bytes_available()
data = A.read

delete(A)


%%

clc
disp(datetime)

% resp = nyan('freq?')
% resp = nyan('ampl?')
resp = nyan('ampl 1;ampl?')

% uint8(resp)


function resp = nyan(CMD)
    A = Connector_GPIB(15);
    resp = A.query(CMD);
end





