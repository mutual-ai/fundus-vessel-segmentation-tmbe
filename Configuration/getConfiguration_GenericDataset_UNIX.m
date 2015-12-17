
function [config] = getConfiguration_GenericDataset_UNIX(datasetName, datasetPath, resultsPath, learnC, crfVersion, cValue)
% getConfiguration_GenericDataset_UNIX  Get a generic configuration
% structure (for UNIX platforms)
%   [config] = getConfiguration_GenericDataset_UNIX(datasetName, datasetPath, resultsPath, learnC, crfVersion, cValue)
%   datasetName: name of the data set
%   datasetPath: path where the data set is stored
%   resultsPath: path where the results are going to be stored
%   learnC: a boolean value indicating if C is going to be learned or not
%   crfVersion: CRF version (up, local-neighborhood-based, fully-connected)
%   cValue: default C value (it will be only used if learnC=0)


    % ---------------------------------------------------------------------

    % Identify data set
    config.dataset = datasetName;

    % Configure paths
    config.dataset_path = datasetPath;
    
    % Results path
    if (~strcmp(resultsPath, 'training'));
        resultsPath = strcat(resultsPath, filesep, crfVersion);
        if (~exist(resultsPath,'dir'))
            config.output_path = resultsPath;
            mkdir(resultsPath);
        end
    end
    config.resultsPath = resultsPath;
    
    % output path
    outputpath = strcat(resultsPath, filesep, 'model_selection');
    if (~exist(outputpath,'dir'))
        config.output_path = outputpath;
        mkdir(outputpath);
    end
    
    % image, labels and masks original folder
    config.training_data_path = strcat(config.dataset_path, filesep, 'training');
    config.validation_data_path = strcat(config.dataset_path, filesep, 'validation');
    config.test_data_path = strcat(config.dataset_path, filesep, 'test');

    % ---------------------------------------------------------------------
    % Scale factor
    config.scale_factor = estimateScaleFactor('/home/ignacioorlando/_tmi_experiments/DRIVE/training', config.training_data_path);
    
    % ---------------------------------------------------------------------
    % Parameters to learn
    config.learn.modelSelection = 0;
    config.learn.theta_p = 0 * config.learn.modelSelection;
    config.learn.C = learnC;
    
    % ---------------------------------------------------------------------
    % CRF configuration
    % CRF version
    if strcmp(crfVersion, 'up')
        config.crfVersion = 'fully-connected';
    else
        config.crfVersion=crfVersion;
    end
    config.experiment = crfVersion;

    config.theta_p.initialValue = 1;
    config.theta_p.increment = 2;
    config.theta_p.lastValue = 15;

    % ---------------------------------------------------------------------
    % SOSVM configuration
    config.C.initialPower = 0;
    config.C.lastPower = 4;
    if (~config.learn.C)
        config.C.value = cValue;
    end
    
    % ---------------------------------------------------------------------
    % General configuration
    [config] = getGeneralConfiguration(config);
    config.compute_scores = 1;
    
    % ---------------------------------------------------------------------
    % Unary features
    config.features.unary.unaryFeatures = zeros(config.features.numberFeatures, 1);
    config.features.unary.unaryFeatures(1) = 1;     % Nguyen
    config.features.unary.unaryFeatures(2) = 1;     % Soares
    %config.features.unary.unaryFeatures(3) = 1;     % Zana

    % Pairwise features
    config.features.pairwise.pairwiseFeatures = zeros(config.features.numberFeatures, 1);
    config.features.pairwise.pairwiseFeaturesDimensions = ones(length(config.features.features),1);
    if ~strcmp(crfVersion, 'up')
        %config.features.pairwise.pairwiseFeatures(1) = 1;  % Nguyen
        %config.features.pairwise.pairwiseFeatures(2) = 1;  % Soares
        config.features.pairwise.pairwiseFeatures(3) = 1;  % Zana
    end

end