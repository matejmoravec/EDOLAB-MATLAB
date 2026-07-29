function writeTraceLine_SPSO_AP_AD(FE, src, X, fit)
persistent initialized
if isempty(initialized)
    fid0 = fopen('spso_trace_matlab.txt','w');
    if fid0 ~= -1
        fclose(fid0);
    end
    initialized = true;
end
fid = fopen('spso_trace_matlab.txt','a');
if fid == -1
    return;
end
fprintf(fid, 'FE=%d SRC=%s X=[', FE, src);
for d = 1:numel(X)
    if d > 1, fprintf(fid, ' '); end
    fprintf(fid, '%.16g', X(d));
end
fprintf(fid, '] FIT=%.16g\n', fit);
fclose(fid);
end
