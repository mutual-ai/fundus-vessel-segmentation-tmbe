
function [I, mask, label] = openSingleImage(folder, image_filename, label_filename, mask_filename, config)

    % open image only if the name is provided
    if ~strcmp(image_filename,'')
        I = imread(strcat(folder, filesep, 'images', filesep, image_filename));
    else
        I = 0;
    end
    % open image only if the name is provided
    if ~strcmp(label_filename,'')
        label = imread(strcat(folder, filesep, 'labels', filesep, label_filename)) > 0;
    else
        label = 0;
    end
    % open image only if the name is provided
    if ~strcmp(mask_filename,'')
        mask = imread(strcat(folder, filesep, 'masks', filesep, mask_filename)) > 0;
        mask = mask(:,:,1)>0;
    else
        mask = 0;
    end
    
    % preprocessing of the image
    I = preprocessing(I, mask, config.preprocessing);

end