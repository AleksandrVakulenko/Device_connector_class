

classdef Connector_empty < Connector

    methods (Access = public)
        function send_text(obj, text)
            error('empty connector class')
        end

        function send_bytes(obj, bytes)
            error('empty connector class')
        end
    end
end



















