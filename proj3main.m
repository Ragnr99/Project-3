% Project 3 - Movement Detection
% Nicholas Lubold & Suraj Kumar

% Read video to grayscale matrix
filePath = uigetdir('Select the folder with images');
jpgFiles = dir(fullfile(filePath, '*.jpg'));

for i = 1:numel(jpgFiles)
    imagePath = fullfile(filePath, jpgFiles(i).name);
    image = rgb2gray(imread(imagePath));
    images{i} = image;
end

fig = figure('Position', [100, 100, 1000, 800]); 
currentImage = 1;

% Movement threshold
thresholdValue = 30;

% Simple Background Subtraction
sbsFrame = images{1};

% Simple Frame Differencing
sfdFrame = images{1};

% Adaptive Background Subtraction
absFrame = images{1};
alpha = 1.0;

% Persistent Frame Differencing
pfdFrame = images{1};
history = zeros(size(images{1}));

% Loop until exited
while ishandle(fig)

    % Simple Background Subtraction
    diff1 = abs(sbsFrame - images{currentImage});
    model1 = diff1 > thresholdValue;
    
    % Simple Frame Differencing
    diff2 = abs(sfdFrame - images{currentImage});
    model2 = diff2 > thresholdValue;
    sfdFrame = images{currentImage}; 
    
    % Adaptive Background Subtraction
    diff3 = abs(absFrame - images{currentImage});
    model3 = diff3 > thresholdValue;
    absFrame = alpha * images{currentImage} + (1 - alpha) * absFrame;
    
    % Persistent Frame Differencing
    diff4 = abs(pfdFrame - images{currentImage});
    tmp = max(history - 5, 0); 
    model4 = max(255 * model3, tmp);
    history = max(history - 2, 0); 
    pfdFrame = images{currentImage};
    
    % Setup grid
    subplot(2, 2, 1);
    imshow(model1, 'InitialMagnification', 'fit');
    title('Simple Background Subtraction');
    
    subplot(2, 2, 2);
    imshow(model2, 'InitialMagnification', 'fit');
    title('Simple Frame Differencing');
    
    subplot(2, 2, 3);
    imshow(model3, 'InitialMagnification', 'fit');
    title('Adaptive Background Subtraction');
    
    subplot(2, 2, 4);
    imshow(model4, 'InitialMagnification', 'fit');
    title('Persistent Frame Differencing');
    
    % Playback speed
    pause(0.005);
    
    % Loop video
    currentImage = mod(currentImage, numel(images)) + 1;
end
