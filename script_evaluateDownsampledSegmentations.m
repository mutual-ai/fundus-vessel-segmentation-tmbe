
rootPaths = {...
             %'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\results\HRF-DR' ...
             %'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\results\HRF-G' ...
             %'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\results\HRF-H' ...
             'C:\Users\USUARIO\Documents\RetinalImaging\TMI 2015\results-last-all\HRF'...
             %'G:\Dropbox\RetinalImaging\Writing\tmi2015paper\results2\HRF'...
             };
         
testPaths = {...
             %'C:\_tmi_experiments\HRF-DR\test' ...
             %'C:\_tmi_experiments\HRF-G\test' ...
             %'C:\_tmi_experiments\HRF-H\test' ...
             'C:\_tmi_experiments\HRF\test' ...
             };
         
algorithmModes = {'up', 'fully-connected'};
%algorithmModes = {'up'};
%algorithmModes = {'fully-connected'};



for experiment = 1 : length(rootPaths)
    
    for algorithm_mode = 1 : length(algorithmModes)
        
        % Load the results
        load(strcat(rootPaths{experiment}, filesep, algorithmModes{algorithm_mode}, filesep, 'results.mat'));
        segmentations = results.segmentations;
        
        % Remove the structure
        clear results
        
        % Upsample the images to the original size
        [upsampledSegmentations] = resizeImages(segmentations, 2);
        
        % Threshold at 50%
        for i = 1 : length(upsampledSegmentations)
            upsampledSegmentations{i} = upsampledSegmentations{i} > 0.5;
        end
        
        % Open labels and masks
        [labels, allNames] = openMultipleImages(strcat(testPaths{experiment}, filesep, 'labels-up'));
        [masks, ~] = openMultipleImages(strcat(testPaths{experiment}, filesep, 'masks-up'));
        for i = 1 : length(masks)
            mask = masks{i};
            masks{i} = (mask(:,:,1) + mask(:,:,2) + mask(:,:,3)) > 0;
        end
        
        % Evaluate
        [results.qualityMeasures, averageQualityMeasures] = compareGivenSegmentations(upsampledSegmentations, masks, labels);
        
        % Generate results structure
        results.segmentations = upsampledSegmentations;
        results.table = [results.qualityMeasures.se; results.qualityMeasures.sp; results.qualityMeasures.acc; results.qualityMeasures.precision; results.qualityMeasures.recall; results.qualityMeasures.fMeasure; results.qualityMeasures.matthews];
        results.table = results.table';
        
        % Save results and images generated
        save(strcat(rootPaths{experiment}, filesep, algorithmModes{algorithm_mode}, filesep, 'results-upsampled.mat'), 'results');
        for i = 1 : length(upsampledSegmentations)
            imwrite(upsampledSegmentations{i}, strcat(rootPaths{experiment}, filesep, algorithmModes{algorithm_mode}, filesep, strtok(allNames{i}, '.'), '.png'));    
        end
        
        
    end
    
end