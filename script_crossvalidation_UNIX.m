
warning('off','all');

% Datasets names
datasetsNames = {'STARE-C'};
%datasetsNames = {'CHASEDB1-B'};

% Flag indicating if the value of C is going to be tuned according to the
% validation set
learnC = 1;
% CRF versions that are going to be evaluated
crfVersions = {'up','fully-connected'};
% C values
cValue = 10;

% Root dir where the data sets are located
rootDatasets = '/home/ignacioorlando/_tmi_experiments/';

% Root folder where the results are going to be stored
rootResults = '/home/ignacioorlando/results-last-all';



% Creating data set paths
datasetsPaths = cell(length(datasetsNames), 1);
for i = 1 : length(datasetsNames)
    datasetsPaths{i} = strcat(rootDatasets, datasetsNames{i});
end

% Creating results paths
resultsPaths = cell(length(datasetsNames), 1);
for i = 1 : length(datasetsNames)
    resultsPaths{i} = strcat(rootResults, filesep, datasetsNames{i});
end


for experiment = 1 : length(datasetsNames)

    for crfver = 1 : length(crfVersions)

        
        % Get the configuration
        [config] = getConfiguration_CrossValidation_UNIX(datasetsNames{experiment}, datasetsPaths{experiment}, resultsPaths{experiment}, learnC, crfVersions{crfver}, cValue);
        config.experiment = crfVersions{crfver};
        root = config.resultsPath;

        % Code name of the expected files
        pairwisedeviations = strcat(config.data_path, filesep, 'pairwisedeviations.mat');

        % Open all images, labels and masks on the training set
        [data.images, data.labels, data.masks, data.numberOfPixels] = openLabeledData(config.data_path, config.preprocessing);

%         % If the pairwise deviation file does not exist
%         if (exist(pairwisedeviations, 'file')~=2)
%             % Compute all possible features
%             [allfeatures, numberOfDeviations] = extractFeaturesFromImages(data.images, data.masks, config, ones(size(config.features.numberFeatures)), false);
%             % Compute pairwise deviations
%             pairwiseDeviations = getPairwiseDeviations(allfeatures, numberOfDeviations);
%             % Save pairwise deviations
%             save(pairwisedeviations, 'pairwiseDeviations');
%         else
%             % Load pairwise deviations
%             load(pairwisedeviations); 
%         end

%         % Assign precomputed deviations to the param struct
%         config.features.pairwise.pairwiseDeviations = pairwiseDeviations;
%         clear 'pairwiseDeviations';

        % Extract unary features
        fprintf('Computing unary features\n');
        % Compute unary features on data
        [data.unaryFeatures, config.features.unary.unaryDimensionality] = ...
            extractFeaturesFromImages(data.images, ...
                                      data.masks, ...
                                      config, ...
                                      config.features.unary.unaryFeatures, ...
                                      true);

        % Compute pairwise features on data
        % Extract pairwise features
        fprintf('Computing pairwise features\n');
        [data.pairwiseFeatures, config.features.pairwise.pairwiseDimensionality] = ...
            extractFeaturesFromImages(data.images, ...
                                      data.masks, ...
                                      config, ...
                                      config.features.pairwise.pairwiseFeatures, ...
                                      false);
%         config.features.pairwise.pairwiseDeviations = config.features.pairwise.pairwiseDeviations(generateFeatureFilter(config.features.pairwise.pairwiseFeatures, config.features.pairwise.pairwiseFeaturesDimensions));
%         data.pairwiseKernels = getPairwiseFeatures(pairwisefeatures, config.features.pairwise.pairwiseDeviations);

        % Filter the value of theta_p
        config.theta_p.finalValues = ...
            config.theta_p.values(generateFeatureFilter(config.features.pairwise.pairwiseFeatures, config.features.pairwise.pairwiseFeaturesDimensions));





        % CROSS VALIDATION -------------------------------------------------------

        models = cell(length(data.images), 1);
        results.segmentations = cell(length(data.images), 1);
        results.qualityMeasures.se = [];
        results.qualityMeasures.sp = [];
        results.qualityMeasures.acc = [];
        results.qualityMeasures.precision = [];
        results.qualityMeasures.recall = [];
        results.qualityMeasures.fMeasure = [];
        results.qualityMeasures.matthews = [];
        results.qualityMeasures.dice = [];
        results.qualityMeasures.scores = [];
        results.qualityMeasures.auc = [];
        results.qualityMeasures.unaryPotentials = [];
        results.qualityMeasures.aucUP = [];

        for i = 1 : length(data.images)
            
            disp(strcat(num2str(i), '/', num2str(length(data.images))));

            % Generate indexes of all the images
            allimages = 1:1:length(data.images);

            % Remove the index corresponding to the test image
            allimages(i) = [];
            % Select randomly 20% of the images for validation
            numvalidation = floor((length(allimages)) * 0.30);
            sample = randsample(length(allimages),numvalidation);
            % Get validation indexes
            idx_validation = allimages(sample);
            % Get training indexes
            idx_training = allimages;
            idx_training(sample) = [];

            % no validation data will be used
            validationdata.images = data.images(idx_validation);
            validationdata.labels = data.labels(idx_validation);
            validationdata.masks = data.masks(idx_validation);
            pixelcount = sum(sum(data.masks{i}>0));
            for j = 1 : length(validationdata.masks)
                pixelcount = pixelcount + sum(sum(data.masks{j}>0));
            end
            validationdata.numberOfPixels = data.numberOfPixels - pixelcount;
            validationdata.unaryFeatures =data.unaryFeatures(idx_validation); 
            validationdata.pairwiseFeatures = data.pairwiseFeatures(idx_validation);
            %validationdata.pairwiseKernels = data.pairwiseKernels(idx_validation);
%             validationdata.images = [];
%             validationdata.labels = [];
%             validationdata.masks = [];
%             validationdata.unaryFeatures = [];
%             validationdata.pairwiseKernels = [];
            
            % Create the array with the training data
            trainingdata.images = data.images(idx_training);
            trainingdata.labels = data.labels(idx_training);
            trainingdata.masks = data.masks(idx_training);
            trainingdata.numberOfPixels = data.numberOfPixels - sum(sum(data.masks{i}>0));
            trainingdata.unaryFeatures =data.unaryFeatures(idx_training); 
            trainingdata.pairwiseFeatures = data.pairwiseFeatures(idx_training);
            %trainingdata.pairwiseKernels = data.pairwiseKernels(idx_training);
            
            % Compute all the features on the training data
            [allfeatures, numberOfDeviations] = extractFeaturesFromImages(trainingdata.images, trainingdata.masks, config, ones(size(config.features.numberFeatures)), false);
            % Compute pairwise deviations
            pairwiseDeviations = getPairwiseDeviations(allfeatures, numberOfDeviations);
            config.features.pairwise.pairwiseDeviations = pairwiseDeviations;
            config.features.pairwise.pairwiseDeviations = config.features.pairwise.pairwiseDeviations(generateFeatureFilter(config.features.pairwise.pairwiseFeatures, config.features.pairwise.pairwiseFeaturesDimensions));
            
            % Generate the pairwise kernels
            trainingdata.pairwiseKernels = getPairwiseFeatures(trainingdata.pairwiseFeatures, config.features.pairwise.pairwiseDeviations);
            validationdata.pairwiseKernels = getPairwiseFeatures(validationdata.pairwiseFeatures, config.features.pairwise.pairwiseDeviations);

            % Train with this configuration and return the model
            [models{i}, ~, config] = learnCRFPotentials(config, trainingdata, validationdata);

            % Test on the i-th image
            idx_test = i;

            % Create the array with the training data
            testdata.images = data.images(idx_test);
            testdata.labels = data.labels(idx_test);
            testdata.masks = data.masks(idx_test);
            testdata.unaryFeatures =data.unaryFeatures(idx_test); 
            testdata.pairwiseFeatures = data.pairwiseFeatures(idx_test);
            
            testdata.pairwiseKernels = getPairwiseFeatures(testdata.pairwiseFeatures, config.features.pairwise.pairwiseDeviations);

            %testdata.pairwiseKernels = data.pairwiseKernels(idx_test);

            % Segment test data to evaluate the model
            [segmentation, qualityMeasure] = getBunchSegmentations2(config, testdata, models{i});

            results.segmentations{i} = segmentation{1};
            results.qualityMeasures.se(i) = qualityMeasure.se;
            results.qualityMeasures.sp(i) = qualityMeasure.sp;
            results.qualityMeasures.acc(i) = qualityMeasure.acc;
            results.qualityMeasures.precision(i) = qualityMeasure.precision;
            results.qualityMeasures.recall(i) = qualityMeasure.recall;
            results.qualityMeasures.fMeasure(i) = qualityMeasure.fMeasure;
            results.qualityMeasures.matthews(i) = qualityMeasure.matthews;
            results.qualityMeasures.dice(i) = qualityMeasure.dice;
            results.qualityMeasures.scores = [results.qualityMeasures.scores; qualityMeasure.scores];
            results.qualityMeasures.auc = [results.qualityMeasures.auc; qualityMeasure.auc];
            results.qualityMeasures.unaryPotentials = [results.qualityMeasures.unaryPotentials; qualityMeasure.unaryPotentials];
            results.qualityMeasures.aucUP = [results.qualityMeasures.aucUP; qualityMeasure.aucUP];
            
            %figure, imshow(segmentation{1});

        end

        results.table = [results.qualityMeasures.se; results.qualityMeasures.sp; results.qualityMeasures.acc; results.qualityMeasures.precision; results.qualityMeasures.recall; results.qualityMeasures.fMeasure; results.qualityMeasures.matthews];
        results.table = results.table';


        SaveSegmentations(root, config, results, models);
        
    end
    
end
        
        