function SaveAlgorithmResults(filename, fitnesses)
fileId = fopen(filename, 'w');
fprintf(fileId, '%.13f\n', fitnesses);
fclose(fileId);
end