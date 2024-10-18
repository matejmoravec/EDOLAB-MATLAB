function results = GetFitnessBeforeChange(currentPerformance, sampleInterval, changeFrequency, environmentNumber)
% Estimate the size of results
estimatedSize = floor((length(currentPerformance) / sampleInterval)) + environmentNumber - 1;

% Preallocate results with zeros
results = zeros(1, estimatedSize);

% Assign the known values (1st, and max between 2nd and SampleIntervalth)
results(1) = [max(currentPerformance(1:sampleInterval))];

% Populate the rest of the results array
index = 2;
for i = sampleInterval:sampleInterval:length(currentPerformance)-sampleInterval
    if mod(i+sampleInterval, changeFrequency) == 0
        results(index) = max(currentPerformance(i+1:i+sampleInterval));
        index = index + 1;
        if i + sampleInterval ~= changeFrequency * environmentNumber
            results(index) = currentPerformance(i+sampleInterval+1);
        end
    else
        results(index) = max(currentPerformance(i+1:i+sampleInterval));
    end
    index = index + 1;
end
end