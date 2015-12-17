
function [features, dimensionality] = extractFeaturesFromImages(images, masks, config, selectedFeatures, unary)
% extractFeaturesFromImages Extract features from a given list of images
% [features, dimensionality] = extractFeaturesFromImages(images, masks, config, selectedFeatures, unary)
% OUTPUT: features: a cell-array with all the features extracted from all
% the images.
% INPUT: images: a cell-array containing grayscale images
%        masks: a cell-array containing FOV masks
%        config: configuration structure
%        selectedFeatures: a list of the features that were selected
%        isUnary: a boolean flag indicating if the features are unary or
%        pairwise

    % Preallocate the cell array where the features will be stored
    features = cell(size(images));

    % For each image
    parfor i = 1:length(images)
        
        fprintf('Extracting features from %i/%i\n',i,length(images));
        
        % Compute the raw features
        features{i} = extractFeaturesFromImage(images{i}, masks{i}, config, selectedFeatures, unary);
        
    end
    
    % Return the dimensionality of the feature vector
    dimensionality = size(features{1}, 2);

end
