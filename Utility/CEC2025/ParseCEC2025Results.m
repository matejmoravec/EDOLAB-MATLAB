%  Get the directory of the current script (same folder as the .mat files)
scriptDir = fileparts(mfilename('fullpath'));

% Get a list of all .mat files in the folder
matFiles = dir(fullfile(scriptDir, '*.mat'));

% Loop through each .mat file
for k = 1:length(matFiles)
    % Get the full path to the .mat file
    matFilePath = fullfile(scriptDir, matFiles(k).name);

    % Load the .mat file into a struct where fields are variables in the file
    loadedData = load(matFilePath);

    % Dynamically retrieve the variable name(s) present in the .mat fil
    variableNames = fieldnames(loadedData);
    if isempty(variableNames)
        error('The file %s contains no variables.', matFiles(k).name);
    end

    % Assume the first variable is the savedTasks struct array
    savedTasks = loadedData.(variableNames{1});

    % Validate we indeed have a non-empty struct array
    assert(isstruct(savedTasks) && ~isempty(savedTasks), ...
        'savedTasks must be a non-empty struct array.');

    % Iterate through each task (each element in the struct array)
    for t = 1:length(savedTasks)
        task = savedTasks(t);

        % ---- Benchmark parameters ---
        % Expecting nested fields: task.BenchmarkParameters.<param>.value
        % If any field is missing, throw a meaningful error.
        if ~isfield(task, 'BenchmarkParameters') || ~isstruct(task.BenchmarkParameters)
            error('Task %d: BenchmarkParameters missing or not a struct.', t);
        end
        bParam = task.BenchmarkParameters;

        requiredFields = {'PeakNumber','ChangeFrequency','Dimension','ShiftSeverity','EnvironmentNumber'};
        for rf = 1:numel(requiredFields)
            f = requiredFields{rf};
            if ~isfield(bParam, f) || ~isstruct(bParam.(f)) || ~isfield(bParam.(f), 'value')
                error('Task %d: BenchmarkParameters.%s.value is missing.', t, f);
            end
        end

        peakNumber        = bParam.PeakNumber.value;
        changeFrequency   = bParam.ChangeFrequency.value;
        dimension         = bParam.Dimension.value;
        shiftSeverity     = bParam.ShiftSeverity.value;
        environmentNumber = bParam.EnvironmentNumber.value;

        % ---- Output folder structure ----
        resultsRoot   = fullfile(scriptDir, "Results");
        folderName    = append("GMPB_Peaks",         string(peakNumber), ...
                               "_ChangeFrequency",   string(changeFrequency), ...
                               "_ShiftSeverity",     string(shiftSeverity), ...
                               "_Environments",      string(environmentNumber), ...
                               "_Dim",               string(dimension));
        fullFolderDir = fullfile(resultsRoot, folderName);
        if ~exist(fullFolderDir, 'dir')
            mkdir(fullFolderDir);
        end

        % File name: <Algorithm>_GMPB.txt
        % Note: if task.Algorithm is a struct or char, convert to string
        algStr = string(task.Algorithm);  % handles char or string; if struct, adjust as needed
        outFile = fullfile(fullFolderDir, append(algStr, '_', "GMPB", '.txt'));
        
        % ---- Informational display for tracking ----
        currentTaskMsg = append("[", algStr, "]", ...
            "[PeakNumber=",      string(peakNumber), ...
            ",ChangeFrequency=", string(changeFrequency), ...
            ",Dimension=",       string(dimension), ...
            ",ShiftSeverity=",   string(shiftSeverity), "]");
        disp(currentTaskMsg)
        
        % ---- Build FE indices to sample trend ----
        maxFEs = environmentNumber * changeFrequency;
        
        sampleInterval = 100;   % sample every 100 FEs
        FEindices = sort([1, ...
            sampleInterval:sampleInterval:maxFEs, ...
            (changeFrequency + 1):changeFrequency:maxFEs]);
        
        % Keep only valid indices (within 1..numCols)
        % trend will be 31 x numCols; we filter after retrieving numCols
        % ---- Retrieve trend from task results ----
        parentField = 'Result';
        if ~isfield(task, 'Result')
            error('Task %d: Result missing.', t);
        end

        % Validate nested fields Results.E_o.trend
        if ~isfield(task.(parentField), 'E_o') || ~isstruct(task.(parentField).E_o)
            error('Task %d: %s.E_o missing or not a struct.', t, parentField);
        end
        if ~isfield(task.(parentField).E_o, 'trend')
            error('Task %d: %s.E_o.trend not found.', t, parentField);
        end

        trend = task.Result.E_o.trend;  % Expected size: [numRuns x numCols]

        % ---- Shape and bounds checks ----
        if ~isnumeric(trend)
            error('Task %d: trend must be numeric.', t);
        end
        [numRuns, numCols] = size(trend);  % Should be [31 x 500000]

        % Filter FEindices to be within 1..numCols and unique
        FEindices = unique(FEindices(FEindices >= 1 & FEindices <= numCols));
        numFEs    = numel(FEindices);

        % Preallocate output (each column = a run; each row = an FE index)
        errors = nan(numFEs, numRuns);

        % ---- Extract values: for each run, pick columns at FEindices ----
        for runCounter = 1:numRuns
            % Row runCounter, columns FEindices => 1 x numFEs
            % Transpose to column to fit errors(:, runCounter)
            errors(:, runCounter) = trend(runCounter, FEindices).';
        end

        % ---- Write matrix to disk as CSV-like text (comma-separated) ----
        writematrix(errors, outFile, 'Delimiter', ',');
    end
end
