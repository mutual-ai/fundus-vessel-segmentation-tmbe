
function [X] = extractFeaturesFromImage(image, mask, config, selectedFeatures, isUnary)
% extractFeaturesFromImage Extract features from a given image
% [X] = extractFeaturesFromImage(image, mask, config, selectedFeatures, isUnary)
% OUTPUT: X: features extracted from the image
% INPUT: image: grayscale image
%        mask: FOV mask
%        config: configuration structure
%        selectedFeatures: a list of the features that were selected
%        isUnary: a boolean flag indicating if the features are unary or
%        pairwise

    % Remove features we will not include
    featureList = config.features.features;
    featureConfiguration = config.features.featureParameters;
    featureList(selectedFeatures==0) = [];
    featureConfiguration(selectedFeatures==0) = [];

    % Generic function to compute features
    computedFeature = cell(size(featureList));
    for i = 1 : length(featureList)
        g = @(myfunction) myfunction(image, mask, isUnary, featureConfiguration{i});
        % Feature computation
        feat = cellfun(g, {featureList{i}}, 'UniformOutput', false);
        computedFeature{i} = feat{1};
    end

    % Get the amount of pixels and the dimension of the feature vector
    dim1 = length(find(mask(:)==1));
    dim2 = 0;
    for i = 1 : length(computedFeature)
        dim2 = dim2 + size(computedFeature{i},3);
    end;
    X = zeros(dim1, dim2);
    
    % Encode feature vectors
    count = 1;
    for i = 1 : length(computedFeature)
        % Take the feature vectors of the i-th image
        feat = computedFeature{i};
        % If the feature vectors have 1 dimensionality
        if size(computedFeature{i},3)==1
            % Recover the feature vector inside the mask
            X(:,count) = feat(mask==1);
            count = count + 1;
        else
            % For each single feature in the feature vector
            for j = 1 : size(computedFeature{i},3)
                % Recover the j-th feature
                f = feat(:,:,j);
                % Get only the feature vector inside the mask
                X(:,count) = f(mask==1);
                count = count + 1;
            end
        end
    end
    
    % Feature scaling
    mu = mean(X);
    stds = std(X);
    stds(stds==0) = 1;
    X = bsxfun(@minus, X, mu);
    X = bsxfun(@rdivide, X, stds);

end