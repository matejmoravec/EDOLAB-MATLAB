function SaveAlgorithmResults(filename, fitnesses)
fileId = fopen(filename, 'w');
if fileId == -1
    error('Failed to open file for writing: %s', filename);
end
fprintf(fileId, '%.13f\n', fitnesses);
fclose(fileId);
end