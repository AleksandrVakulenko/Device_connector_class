

classdef GPIB_resp_queue < handle
    properties (Access = private)
        resp_data = {}
        hash_list uint32
    end


    methods
        function obj = GPIB_resp_queue() % FIXME: do nothing
            obj.resp_data = {};
            obj.hash_list = [];
        end

        function hash = add_request(obj)
            hash = obj.gen_hash;
            obj.hash_list = [obj.hash_list hash];
        end

        function add_response(obj, data)
            obj.resp_data{end+1} = data;
        end

        function data = get_response(obj, hash)
            data = [];
            ind = obj.find_hash(hash);
            if ~isempty(ind)
                N = numel(obj.resp_data);
                if ind <= N
                    data = obj.resp_data{ind};
                    obj.resp_data(ind) = [];
                    obj.hash_list(ind) = [];
                end
            end
        end
    end



    methods (Access = private)
        function hash = gen_hash(obj)
            stop = false;
            while ~stop
                hash = uint32(rand(1)*(uint32(2)^32-1));
                if isempty(obj.find_hash(hash))
                    stop = true;
                end
            end
        end

        function ind = find_hash(obj, hash)
            Table = obj.hash_list;
            ind = find(Table == hash);
        end
    end

end









