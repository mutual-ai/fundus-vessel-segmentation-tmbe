
warning('off','all');

% Datasets names
datasetsNames = {...
%    'DRIVE'
      %'DRIVE', ...
       %'STARE-A', ...
       %'STARE-B', ...
       'CHASEDB1-A',...
       %'CHASEDB1-B'...%, ...
       %'HRF'...
    };


humanObserverPerformances = [...
    0.7760, 0.9730; ...
    0.9385, 0.9365; ...
    0.9022, 0.9341; ...
    0.8362, 0.9724];
    


% Flag indicating if the value of C is going to be tuned according to the
% validation set
learnC = 1;
% CRF versions that are going to be evaluated
crfVersions = {'up','fully-connected'};

% C values
cValue = 10^2;% [10^4, 10^1; ...
          %10^4, 10^3];

% Root dir where the data sets are located
rootDatasets = 'C:\_tmi_experiments\';

% Root folder where the results are going to be stored
%rootResults = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\results2';
rootResults = 'G:\Dropbox\RetinalImaging\Writing\tmi2015paper\results2';


%exportfigures = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\paper\figures\rocCurves';
exportfigures = 'G:\Dropbox\RetinalImaging\Writing\tmi2015paper\paper\figures\rocCurves';



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
        
        % Load the configuration
        load(strcat(resultsPaths{experiment}, filesep, crfVersions{crfver}, filesep, 'config.mat'));
        root = strcat(resultsPaths{experiment}, filesep, crfVersions{crfver});
        config.compute_scores = 1;
        config.experiment = crfVersions{crfver};

        % Load the model
        load(strcat(resultsPaths{experiment}, filesep, crfVersions{crfver}, filesep, 'model.mat'));

        % Open test data
        [testdata.images, testdata.labels, testdata.masks, testdata.numberOfPixels] = openLabeledData(config.test_data_path, config.preprocessing);

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
        [results.segmentations, results.qualityMeasures] = getBunchSegmentations2(config, testdata, model);

        results.table = [results.qualityMeasures.se, results.qualityMeasures.sp, results.qualityMeasures.acc, results.qualityMeasures.precision, results.qualityMeasures.recall, results.qualityMeasures.fMeasure, results.qualityMeasures.matthews];
        disp(strcat('Se = ', num2str(mean(results.qualityMeasures.se))));
        disp(strcat('Sp = ', num2str(mean(results.qualityMeasures.sp))));
        disp(strcat('fMeasure = ', num2str(mean(results.qualityMeasures.fMeasure))));
        disp(strcat('matthews = ', num2str(mean(results.qualityMeasures.matthews))));
        

        if (config.compute_scores)
        
            % Encode labels
            yy = [];
            for i = 1 : length(testdata.labels)
                y = double(testdata.labels{i} > 0);
                y = y(testdata.masks{i});
                y(y==0) = -1;
                yy = [yy; y];
            end

            % If unary potentials
            if (strcmp(crfVersions{crfver},'up'))
                
                % Generate the ROC curve for unary potentials
                [ses,sps,infoUP] = vl_roc(double(yy), double(results.qualityMeasures.unaryPotentials));
                h_roc = figure;
                set(0,'CurrentFigure',h_roc)
                plot(1 - sps, ses, 'r');
                hold on
                
                
                % Generate the precision/recall curve using only the unary
                % potentials
                [recalls,precisions,infoUP_pr] = vl_roc(double(yy), double(results.qualityMeasures.unaryPotentials));
                h_pr = figure;
                set(0,'CurrentFigure',h_pr)
                plot(recalls, precisions, 'r');
                hold on
                
                results_up = results;
                save(strcat(exportfigures, filesep, datasetsNames{experiment}, '_up.mat'), 'results_up');
                
            else
                
                % Generate the ROC curve for unary and pairwise potentials
                [ses,sps,infoFCCRF] = vl_roc(double(yy), double(results.qualityMeasures.scores));
                set(0,'CurrentFigure',h_roc)
                plot(1 - sps, ses, 'b');
                xlabel('FPR (1 - Specificity)');
                ylabel('TPR (Sensitivity)');
                legend(strcat('Unary potentials - AUC = ',[''],num2str(infoUP.auc)), strcat('FC-CRF - AUC =',[''],num2str(infoFCCRF.auc)), 'Location','southeast');
                scatter(mean(1-results_up.qualityMeasures.sp), mean(results_up.qualityMeasures.se), 'MarkerEdgeColor','r', 'MarkerFaceColor','r');
                scatter(mean(1-results.qualityMeasures.sp), mean(results.qualityMeasures.se), 'MarkerEdgeColor','b', 'MarkerFaceColor','b');
                title(datasetsNames{experiment});
                hold off;
                
                % Generate the precision/recall curve using only the unary
                % and pairwise potentials
                [recalls,precisions,infoFCCRF_pr] = vl_pr(double(yy), double(results.qualityMeasures.scores));
                set(0,'CurrentFigure',h_pr)
                plot(recalls, precisions, 'b');
                xlabel('Recall');
                ylabel('Precision');
                legend(strcat('Unary potentials - AUC = ',[''],num2str(infoUP_pr.auc)), strcat('FC-CRF - AUC =',[''],num2str(infoFCCRF_pr.auc)), 'Location','southeast');
                scatter(mean(results_up.qualityMeasures.recall), mean(results_up.qualityMeasures.precision), 'MarkerEdgeColor','r', 'MarkerFaceColor','r');
                scatter(mean(results.qualityMeasures.recall), mean(results.qualityMeasures.precision), 'MarkerEdgeColor','b', 'MarkerFaceColor','b');
                title(datasetsNames{experiment});
                hold off;
                
                results_fullycrf = results;
                save(strcat(exportfigures, filesep, datasetsNames{experiment}, '_fccrf.mat'), 'results_fullycrf');
                
                
                saveas(h_roc,strcat(exportfigures, filesep, datasetsNames{experiment}, '_roc.pdf'));
                saveas(h_pr,strcat(exportfigures, filesep, datasetsNames{experiment}, '_precision_recall.pdf'));
                
            end
            
        end

        %SaveSegmentations(root, config, results, model);
        
    end
    
end
        