function abnormality_labeling_app(fpath_to_video)
    % Create the main figure
    fig = uifigure('Name', 'MATLAB App', 'Position', [100, 100, 900, 500]);
    
    % Create the axes for video display
    ax = uiaxes(fig, 'Position', [20, 150, 640, 360]);
    ax.XTick = [];
    ax.YTick = [];
    
    % Initialize the video reader
    video = VideoReader(fpath_to_video);
    
    % Create the slider for frame selection
    frameSlider = uislider(fig, 'Position', [20, 100, 640, 3], ...
        'Limits', [1, video.NumFrames], 'Value', 1, 'ValueChangingFcn', @updateFrame);
    
    % Create the slider for frame rating (horizontal)
    ratingSlider = uislider(fig, 'Position', [680, 400, 150, 3], ...
        'Limits', [0, 1], 'Value', 0, ...
        'MajorTicks', 0:0.2:1, ...
        'MajorTickLabels', {'0', '0.2', '0.4', '0.6', '0.8', '1'}, ...
        'ValueChangingFcn', @updateRating);
    ratingLabel = uilabel(fig, 'Position', [680, 400, 100, 22], ...
        'Text', 'Suspiciousness');
    
    speed_labels=0:2:10; speed_labels(1)=0.1;
    % Create the slider for playback speed control
    speedSlider = uislider(fig, 'Position', [680, 450, 150, 3], ...
        'Limits', [0.1, 10], 'Value', 1, ...
        'MajorTicks', speed_labels);
        % 'MajorTickLabels', {'0.1', '0.6', '1.1', '1.6', '2.1', '2.6', '3'} ...
        % );
    speedLabel = uilabel(fig, 'Position', [680, 470, 150, 22], ...
        'Text', 'Playback Speed');
    
    % Create the play button
    playButton = uibutton(fig, 'Text', 'Play', 'Position', [680, 320, 100, 30], ...
        'ButtonPushedFcn', @playVideo);
    
    % Create the save button
    saveButton = uibutton(fig, 'Text', 'Save', 'Position', [680, 280, 100, 30], ...
        'ButtonPushedFcn', @saveData);
    
    % Create the quit button
    quitButton = uibutton(fig, 'Text', 'Quit', 'Position', [680, 240, 100, 30], ...
        'ButtonPushedFcn', @quitApp);
    
    % Create a label to display the current frame number
    frameLabel = uilabel(fig, 'Position', [680, 200, 150, 22], 'Text', 'Frame number: 1');
    
    % Initialize a data structure to store frame ratings
    ratings = zeros(video.NumFrames, 1);
    
    % Variable to control playback
    isPlaying = false;
    
    % Update frame display
    function updateFrame(src, event)
        frameNumber = round(event.Value);
        frameLabel.Text = ['Frame number: ', num2str(frameNumber)];
        video.CurrentTime = (frameNumber - 1) / video.FrameRate;
        frame = read(video, frameNumber);  % Read the specific frame
        imshow(frame, 'Parent', ax);
    end
    
    % Update rating value
    function updateRating(src, event)
        frameNumber = round(frameSlider.Value);
        ratings(frameNumber) = event.Value;
    end
    
    % Play video function
    function playVideo(~, ~)
        isPlaying = true;
        while hasFrame(video) && isPlaying
            frame = readFrame(video);
            imshow(frame, 'Parent', ax);
            frameNumber = round(video.CurrentTime * video.FrameRate);
            if frameNumber >= video.NumFrames
                frameNumber = video.NumFrames;
                isPlaying = false;
            end
            frameSlider.Value = frameNumber;
            frameLabel.Text = ['Frame number: ', num2str(frameNumber)];
            ratings(frameNumber) = ratingSlider.Value;
            pause(1 / (video.FrameRate * speedSlider.Value));  % Adjust playback speed
            drawnow;  % Allow UI to update
        end
    end
    
    % Save data function
    function saveData(~, ~)
        isPlaying = false;  % Stop the playback
        frameNumber = round(frameSlider.Value);
        ratings(frameNumber) = ratingSlider.Value;
        T = table((1:video.NumFrames)', ratings, 'VariableNames', {'FrameNumber', 'Rating'});
        writetable(T, 'frame_ratings.csv');
    end
    
    % Quit and save data function
    function quitApp(~, ~)
        isPlaying = false;  % Stop the playback
        frameNumber = round(frameSlider.Value);
        ratings(frameNumber) = ratingSlider.Value;
        T = table((1:video.NumFrames)', ratings, 'VariableNames', {'FrameNumber', 'Rating'});
        writetable(T, 'frame_ratings.csv');
        delete(fig);
    end
end
