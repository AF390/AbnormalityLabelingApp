function abnormality_labeling_app(fpath_to_video)
    fig = uifigure('Name', 'MATLAB App', 'Position', [100, 100, 900, 500]);
    ax = uiaxes(fig, 'Position', [20, 150, 640, 360]);
    ax.XTick = [];
    ax.YTick = [];
    video = VideoReader(fpath_to_video);
    frameSlider = uislider(fig, 'Position', [20, 100, 640, 3], ...
        'Limits', [1, video.NumFrames], 'Value', 1, 'ValueChangingFcn', @updateFrame);
    ratingSlider = uislider(fig, 'Position', [680, 400, 150, 3], ...
        'Limits', [0, 1], 'Value', 0, 'MajorTicks', 0:0.2:1, 'MajorTickLabels', {'0', '0.2', '0.4', '0.6', '0.8', '1'}, 'ValueChangingFcn', @updateRating);
    ratingLabel = uilabel(fig, 'Position', [680, 400, 100, 22], ...
        'Text', 'Suspiciousness');
    speed_labels = 0:2:10; speed_labels(1) = 0.1;
    speedSlider = uislider(fig, 'Position', [680, 450, 150, 3], ...
        'Limits', [0.1, 10], 'Value', 1, 'MajorTicks', speed_labels);
    speedLabel = uilabel(fig, 'Position', [680, 470, 150, 22], ...
        'Text', 'Playback Speed');
    playButton = uibutton(fig, 'Text', 'Play', 'Position', [680, 320, 100, 30], ...
        'ButtonPushedFcn', @playVideo);
    saveButton = uibutton(fig, 'Text', 'Pause & save', 'Position', ...
        [680, 280, 100, 30], 'ButtonPushedFcn', @saveData);
    quitButton = uibutton(fig, 'Text', 'Quit', 'Position', ...
        [680, 240, 100, 30], 'ButtonPushedFcn', @quitApp);
    frameLabel = uilabel(fig, 'Position', [680, 200, 150, 22], ...
        'Text', 'Frame number: 1');
    ratings = zeros(video.NumFrames, 1);
    isPlaying = false;

    function updateFrame(src, event)
        frameNumber = round(event.Value);
        frameLabel.Text = ['Frame number: ', num2str(frameNumber)];
        video.CurrentTime = (frameNumber - 1) / video.FrameRate;
        frame = read(video, frameNumber);
        imshow(frame, 'Parent', ax);
    end

    function updateRating(src, event)
        frameNumber = round(frameSlider.Value);
        ratings(frameNumber) = event.Value;
    end

    function playVideo(~, ~)
        isPlaying = true;
        while hasFrame(video) && isPlaying
            frame = readFrame(video);
            imshow(frame, 'Parent', ax);
            frameNumber = round(video.CurrentTime * video.FrameRate);
            if (frameNumber >= video.NumFrames)
                frameNumber = video.NumFrames;
                isPlaying = false;
            end
            frameSlider.Value = frameNumber;
            frameLabel.Text = ['Frame number: ', num2str(frameNumber)];
            ratings(frameNumber) = ratingSlider.Value;
            pause(1 / (video.FrameRate * speedSlider.Value));
            drawnow;
        end
    end

    function saveData(~, ~)
        isPlaying = false;
        frameNumber = round(frameSlider.Value);
        ratings(frameNumber) = ratingSlider.Value;
        T = table((1:video.NumFrames)', ratings, 'VariableNames', {'FrameNumber', 'Rating'});
        vals=T.Rating;
        filtered=replaceZeroWithNeighbor(vals, 1);
        T.Rating=filtered;
        writetable(T, 'frame_ratings.csv');
    end

    function quitApp(~, ~)
        isPlaying = false;
        frameNumber = round(frameSlider.Value);
        ratings(frameNumber) = ratingSlider.Value;
        T = table((1:video.NumFrames)', ratings, 'VariableNames', {'FrameNumber', 'Rating'});
        writetable(T, 'frame_ratings.csv');
        delete(fig);
    end
end


