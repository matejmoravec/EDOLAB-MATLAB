% --- One trace line per evaluation: FE, source, position, fitness ---
function writeTraceLine_PSPSO(FE, src, X, fit)
persistent initialized
if isnan(fit)   % fitness() returned without evaluating (pending change or budget spent)
    return;
end
if isempty(initialized)
    fid0 = fopen('pspso_trace_matlab.txt','w');
    if fid0 ~= -1
        fclose(fid0);
    end
    initialized = true;
end
fid = fopen('pspso_trace_matlab.txt','a');
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
