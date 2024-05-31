function videoLabelingApp(fpath_to_video)
    % Create the main figure
    fig = uifigure('Name', 'MATLAB App');
    
    % Create the axes for video display
    ax = uiaxes(fig, 'Position', [20, 150, 640, 360]);
    ax.XTick = [];
    ax.YTick = [];
    
    % Create the slider for frame selection
    frameSlider = uislider(fig, 'Position', [20, 100, 640, 3], ...
        'Limits', [1, 100000], 'Value', 1, 'ValueChangedFcn', @updateFrame);
    
    % Create the slider for frame rating (horizontal)
    ratingSlider = uislider(fig, 'Position', [20, 50, 640, 3], ...
        'Limits', [0, 1], 'Value', 0);
    ratingLabel = uilabel(fig, 'Position', [680, 45, 100, 22], ...
        'Text', 'Level of abnormality');
    
    % Create the play button
    playButton = uibutton(fig, 'Text', 'Play', 'Position', [20, 20, 100, 30], ...
        'ButtonPushedFcn', @playVideo);
    
    % Create the quit button
    quitButton = uibutton(fig, 'Text', 'Quit', 'Position', [560, 20, 100, 30], ...
        'ButtonPushedFcn', @quitApp);
    
    % Create a label to display the current frame number
    frameLabel = uilabel(fig, 'Position', [680, 100, 100, 22], 'Text', 'Frame number: 1');
    
    % Initialize the video reader
    video = VideoReader(fpath_to_video);
    
    % Initialize a data structure to store frame ratings
    ratings = zeros(video.NumFrames, 1);
    
    % Variable to control playback
    isPlaying = false;
    
    % Update frame display
    function updateFrame(~, ~)
        frameNumber = round(frameSlider.Value);
        frameLabel.Text = ['Frame number: ', num2str(frameNumber)];
        video.CurrentTime = (frameNumber - 1) / video.FrameRate;
        frame = readFrame(video);
        imshow(frame, 'Parent', ax);
    end
    
    % Play video function
    function playVideo(~, ~)
        isPlaying = true;
        while hasFrame(video) && isPlaying
            frame = readFrame(video);
            imshow(frame, 'Parent', ax);
            frameSlider.Value = video.CurrentTime * video.FrameRate;
            frameNumber = round(frameSlider.Value);
            frameLabel.Text = ['Frame number: ', num2str(frameNumber)];
            ratings(frameNumber) = ratingSlider.Value;
            pause(1 / video.FrameRate);
            drawnow;  % Allow UI to update
        end
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
