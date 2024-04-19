% Project 3 - Movement Detection
% Nicholas Lubold & Suraj Kumar

function proj3main(dirstring, maxframenum, abs_diff_threshold, alpha_parameter, gamma_parameter)
    % initialize the grayscale image matrix from the specified directory
    filePath = dirstring;
    jpgFiles = dir(fullfile(filePath, '*.jpg'));

    images = cell(1, numel(jpgFiles));
    for i = 1:numel(jpgFiles)
        imagePath = fullfile(filePath, jpgFiles(i).name);
        image = rgb2gray(imread(imagePath));  % convert color image to grayscale
        images{i} = image;
    end

    fig = figure('Position', [100, 100, 1000, 800]);  % create a figure window for displaying images
    currentImage = 1;  % start from the first image

    % define the movement detection threshold
    thresholdValue = abs_diff_threshold;

    % initialize background frames for each motion detection algorithm
    sbsFrame = images{1};  % for simple background subtraction
    sfdFrame = images{1};  % for simple frame differencing
    absFrame = double(images{1});  % for adaptive background subtraction, using double for precision
    pfdFrame = images{1};  % for persistent frame differencing
    history = zeros(size(images{1}));  % initialize history array for persistent differencing

    % set up adaptive background subtraction by averaging the first few frames
    numInitialFrames = 5;
    for k = 2:min(numInitialFrames, numel(images))
        absFrame = absFrame + double(images{k]);
    end
    absFrame = absFrame / min(numInitialFrames, numel(images));  % compute the average

    % set persistence threshold for detecting motion in persistent frame differencing
    persistenceThreshold = 30;

    % process each frame until the specified maximum frame number is reached
    while currentImage <= maxframenum && ishandle(fig)

        % compute differences and detect motion for each algorithm
        diff1 = abs(sbsFrame - images{currentImage});
        model1 = diff1 > thresholdValue;  % binary image from simple background subtraction
        diff2 = abs(sfdFrame - images{currentImage});
        model2 = diff2 > thresholdValue;  % binary image from simple frame differencing
        diff3 = abs(absFrame - double(images{currentImage}));
        model3 = diff3 > thresholdValue;  % binary image from adaptive background subtraction
        diff4 = abs(double(pfdFrame) - double(images{currentImage}));
        currentMotion = diff4 > persistenceThreshold;
        history = max(history - gamma_parameter, 0);  % apply decay to the history
        history(currentMotion) = min(history(currentMotion) + 255, 255);  % update history where motion is detected
        model4 = history / 255;  % scale history to range 0-1 for display

        % update reference frames for next iteration
        sfdFrame = images{currentImage]; 
        absFrame = alpha_parameter * double(images{currentImage}) + (1 - alpha_parameter) * absFrame;
        pfdFrame = images{currentImage};

        % concatenate the four models into a single quad image
        quadImage = [custom_mat2gray(model1) custom_mat2gray(model2); custom_mat2gray(model3) model4];

        % generate filename and save the quad image
        filename = sprintf('output_%04d.jpg', currentImage);
        fullFileName = fullfile(filePath, filename);
        imwrite(quadImage, fullFileName);

        % increment the current image index
        currentImage = currentImage + 1;
    end

    close(fig); % close the figure after finishing the loop
end

% custom function to normalize an array to the range [0,1]
function output = custom_mat2gray(input)
    minVal = min(input(:));
    maxVal = max(input(:));
    output = (input - minVal) / (maxVal - minVal);
end
