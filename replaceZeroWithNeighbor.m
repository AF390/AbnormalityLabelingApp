function outputArray = replaceZeroWithNeighbor(inputArray, N)
    % Create a copy of the input array to avoid modifying the original array
    outputArray = inputArray;

    % Iterate through each element of the array
    for i = 1:length(inputArray)
        if inputArray(i) == 0
            % Check the previous N values
            for j = max(1, i-N):min(length(inputArray), i+N)
                if inputArray(j) ~= 0
                    outputArray(i) = inputArray(j);
                    break;
                end
            end
        end
    end
end
