
function [rho] = estimateScaleFactor(pretrained_path, newset_path)
% estimateScaleFactor  Estimate the scale factor to adjust the parameters
% of the image features.
%   rho = estimateScaleFactor(pretrained_path, newset_path) estimates the
%   scale factor as the proportion between the average FOV width of the
%   masks in the newset_path with and the average FOV width of the masks in
%   the pretrained_path.

    % Identify the paths to locate the masks
    masks_drive_Folder = strcat(pretrained_path, filesep, 'masks', filesep);
    masks_newset_Folder = strcat(newset_path, filesep, 'masks', filesep);

    % Open the masks
    masks_drive = openMultipleImages(masks_drive_Folder);
    masks_newset = openMultipleImages(masks_newset_Folder);
    
    % Estimate the average width and height on each set
    [drive_height, drive_width] = getAverageDiameters(masks_drive);
    [newset_height, newset_width] = getAverageDiameters(masks_newset);
    
    % Compute the scales ratio on each diameter
    rho_height = newset_height / drive_height;
    rho_width = newset_width / drive_width;
    
    % Return the scale factor
    rho = rho_width;

end


function [height, width] = getAverageDiameters(masks)
% getAverageDiameters  Get the average FOV width from a given array of
% masks.
%   [height, width] = getAverageDiameters(masks) return the average height
%   and the average width of the FOV in masks.

    heights = zeros(length(masks),1);
    widths = zeros(length(masks),1);
    for i = 1 : length(masks)
        
        % Get the mask
        mask = masks{i};
        % Logicalize it
        mask = mask(:,:,1) > 0;
        
        % Sum on each dimension to estimate the height and width
        heights(i) = max(sum(mask,1));
        widths(i) = max(sum(mask,2));
        
    end
    
    % return the mean values
    height = mean(heights(:));
    width = mean(widths(:));

end