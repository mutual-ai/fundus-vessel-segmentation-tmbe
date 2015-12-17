
% Get configuration
[config] = getConfiguration_STARE();



% Code name of the expected files
pairwisedeviations = strcat(config.training_data_path, filesep, 'pairwisedeviations.mat');

% Open images, labels and masks on the training set
[trainingdata.images, trainingdata.labels, trainingdata.masks, trainingdata.numberOfPixels] = openLabeledData(config.training_data_path, config.preprocessing);
% Open images, labels and masks for the validation set
[validationdata.images, validationdata.labels, validationdata.masks, validationdata.numberOfPixels] = openLabeledData(config.validation_data_path, config.preprocessing);

% If the pairwise deviation file does not exist
if (exist(pairwisedeviations, 'file')~=2)
    % Compute all possible features
    [allfeatures, numberOfDeviations] = extractFeaturesFromImages(trainingdata.images, trainingdata.masks, config, ones(size(config.features.numberFeatures)), false);
    % Compute pairwise deviations
    pairwiseDeviations = getPairwiseDeviations(allfeatures, numberOfDeviations);
    % Save pairwise deviations
    save(pairwisedeviations, 'pairwiseDeviations');
else
    % Load pairwise deviations
    load(pairwisedeviations); 
end

% Assign precomputed deviations to the param struct
config.features.pairwise.pairwiseDeviations = pairwiseDeviations;
clear 'pairwiseDeviations';

% If model selection have to be performed
if (config.learn.modelSelection == 1)

    % Learn the CRF and get the best model
    [model, config.qualityOverValidation, config] = completeModelSelection(config, trainingdata, validationdata);

else

    % Extract unary features
    fprintf('Computing unary features\n');
    % Compute unary features on training data
    [trainingdata.unaryFeatures, config.features.unary.unaryDimensionality] = ...
        extractFeaturesFromImages(trainingdata.images, ...
                                  trainingdata.masks, ...
                                  config, ...
                                  config.features.unary.unaryFeatures, ...
                                  true);
    % Compute unary features on validation data
    validationdata.unaryFeatures = extractFeaturesFromImages(validationdata.images, ...
                                                             validationdata.masks, ...
                                                             config, ...
                                                             config.features.unary.unaryFeatures, ...
                                                             true);

    % Compute pairwise features on training data
    % Extract pairwise features
    fprintf('Computing pairwise features\n');
    [pairwisefeatures, config.features.pairwise.pairwiseDimensionality] = ...
        extractFeaturesFromImages(trainingdata.images, ...
                                  trainingdata.masks, ...
                                  config, ...
                                  config.features.pairwise.pairwiseFeatures, ...
                                  false);
    config.features.pairwise.pairwiseDeviations = config.features.pairwise.pairwiseDeviations(generateFeatureFilter(config.features.pairwise.pairwiseFeatures, config.features.pairwise.pairwiseFeaturesDimensions));
    trainingdata.pairwiseKernels = getPairwiseFeatures(pairwisefeatures, config.features.pairwise.pairwiseDeviations);

    % Compute pairwise features on validation data
    pairwisefeatures = extractFeaturesFromImages(validationdata.images, ...
                                                 validationdata.masks, ...
                                                 config, ...
                                                 config.features.pairwise.pairwiseFeatures, ...
                                                 false);
    validationdata.pairwiseKernels = getPairwiseFeatures(pairwisefeatures, config.features.pairwise.pairwiseDeviations);
    
    % Filter the value of theta_p
    config.theta_p.finalValues = ...
        config.theta_p.values(generateFeatureFilter(config.features.pairwise.pairwiseFeatures, config.features.pairwise.pairwiseFeaturesDimensions));

    % Train with this configuration and return the model
    [model, config.qualityOverValidation, config] = learnCRFPotentials(config, trainingdata, validationdata);

end

% Open test data
[testdata.images, testdata.labels, testdata.masks, testdata.numberOfPixels] = openLabeledData(config.test_data_path);

% Extract unary features
fprintf(strcat('Computing unary features\n'));
[testdata.unaryFeatures, config.features.unary.unaryDimensionality] = ...
    extractFeaturesFromImages(testdata.images, ...
                              testdata.masks, ...
                              config, ...
                              config.features.unary.unaryFeatures, ...
                              true);

% Extract pairwise features
fprintf(strcat('Computing pairwise features\n'));
[pairwisefeatures, config.features.pairwise.pairwiseDimensionality] = ...
    extractFeaturesFromImages(testdata.images, ...
                              testdata.masks, ...
                              config, ...
                              config.features.pairwise.pairwiseFeatures, ...
                              false);

% Compute the pairwise kernels
fprintf(strcat('Computing pairwise kernels\n'));
testdata.pairwiseKernels = getPairwiseFeatures(pairwisefeatures, config.features.pairwise.pairwiseDeviations);

% Segment test data to evaluate the model
[results.segmentations, results.qualityMeasures] = getBunchSegmentations(config, testdata, model);

