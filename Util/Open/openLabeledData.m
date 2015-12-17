
function [images, labels, masks, numberOfPixels] = openLabeledData(folder, preprocessing_options)

    disp(strcat('Loading data from ', [' '], folder));

    % Get folder to open images, masks and labels
    imagesFolder = strcat(folder, filesep, 'images', filesep);
    masksFolder = strcat(folder, filesep, 'masks', filesep);
    labelsFolder = strcat(folder, filesep, 'labels', filesep);

    % Open images, masks and labels
    disp('Loading images');
    images = openMultipleImages(imagesFolder);
    disp('Loading masks');
    masks = openMultipleImages(masksFolder);
    disp('Loading labels');
    labels = openMultipleImages(labelsFolder);
    
    % For each image
    for i = 1:length(images)
        % Encode labels as logical matrices
        y = labels{i};
        labels{i} = y(:,:,1) > 0;
        % Encode masks as logical matrices
        mask = masks{i};
        masks{i} = mask(:,:,1) > 0;
    end
    
    % Count the number of pixels
    [numberOfPixels] = getNumberOfPixels(masks);
    
    % For each image, preprocess it
    disp('Preprocessing images');
    parfor i = 1 : length(images)
        fprintf('.');
        images{i} = preprocessing(images{i}, masks{i}, preprocessing_options);
    end
    fprintf('\n');
    disp('Loading finished');

end


function [numberOfPixels] = getNumberOfPixels(masks)
    % Count the number of pixels inside the FOV
    numberOfPixels = 0;
    for i = 1 : length(masks)
        numberOfPixels = numberOfPixels + length(find(masks{i}));
%         msk = masks{i};
%         numberOfPixels = numberOfPixels + length((msk(:)))
    end
end

