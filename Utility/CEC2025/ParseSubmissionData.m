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
        
        % ---- Informational display for tracking ----
        currentTaskMsg = append("[", algStr, "]", ...
            "[PeakNumber=",      string(peakNumber), ...
            ",ChangeFrequency=", string(changeFrequency), ...
            ",Dimension=",       string(dimension), ...
            ",ShiftSeverity=",   string(shiftSeverity), "]");
        disp(currentTaskMsg)
        
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

        best    = min(trend(:));
        worst   = max(trend(:));
        average = task.Result.E_o.mean;
        median  = task.Result.E_o.median;
        stdErr  = task.Result.E_o.StdErr;
        
        disp("Best: " + string(best));
        disp("Worst: " + string(worst));
        disp("Average: " + string(average));
        disp("Median: " + string(median));
        disp("Standard deviation: " + string(stdErr));

        %avgCheck = mean(trend(:));
    end
end
