classdef CsvRandom < handle
    properties
        numbers double
        idx double = 1
    end

    methods
        function obj = CsvRandom(filename)
            if ~isfile(filename)
                error('CSV file not found: %s', filename);
            end
            txt = fileread(filename);
            toks = regexp(txt, '[,\s;]+', 'split');
            vals = [];
            for i = 1:numel(toks)
                t = strtrim(toks{i});
                if isempty(t), continue; end
                v = str2double(t);
                if ~isnan(v)
                    vals(end+1,1) = v; %#ok<AGROW>
                end
            end
            if isempty(vals)
                error('No numeric values found in CSV: %s', filename);
            end
            obj.numbers = vals;
        end

        function u = next01(obj)
            if obj.idx > numel(obj.numbers)
                obj.idx = 1; % wrap-around, same as Kotlin behavior
            end
            u = obj.numbers(obj.idx);
            obj.idx = obj.idx + 1;
        end

        function x = nextDouble(obj, from, to)
            if ~(to > from)
                error('Invalid range: from=%g to=%g', from, to);
            end
            u = obj.next01();
            x = from + u * (to - from);
        end

        function g = nextGaussian(obj)
            u1 = 0.0;
            u2 = 0.0;
            while u1 == 0.0
                u1 = obj.next01();
            end
            while u2 == 0.0
                u2 = obj.next01();
            end
            g = sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
        end
    end
end