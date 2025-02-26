

% [14 0 uint8(ArgA) 0 0]


clc
disp(datetime)

% ArgA = 0
% resp = nyan(uint8([14 0 uint8(ArgA) 0 0]))

CMD_datareq = uint8([10 0 0 0 0]);
resp = nyan(CMD_datareq)


%%

resp = nyan([])

%%

function resp = nyan(CMD)
    A = Connector_COM_USB("COM4");
    %     resp = A.query(CMD);
    if ~isempty(CMD)
        A.send(CMD)
    end
    pause(0.05)
    resp = A.read
end


