
rootPaths = {'C:\_tmi_experiments\HRF\validation', ...
             'C:\_tmi_experiments\HRF\test', ...
             'C:\_tmi_experiments\HRF\training', ...
             'C:\_tmi_experiments\HRF-DR\validation', ...
             'C:\_tmi_experiments\HRF-DR\test', ...
             'C:\_tmi_experiments\HRF-DR\training', ...
             'C:\_tmi_experiments\HRF-G\validation', ...
             'C:\_tmi_experiments\HRF-G\test', ...
             'C:\_tmi_experiments\HRF-G\training', ...
             'C:\_tmi_experiments\HRF-H\validation', ...
             'C:\_tmi_experiments\HRF-H\test', ...
             'C:\_tmi_experiments\HRF-H\training'};

for i = 1 : length(rootPaths)

    rootPath = rootPaths{i};

    disp(strcat(num2str(i), '/', num2str(length(rootPaths))));
    
    [images, allNames] = openMultipleImages(strcat(rootPath, filesep, 'images'));
    [images] = resizeImages(images, 0.5);
    for j = 1 : length(images)
        imwrite(images{j},strcat(rootPath, filesep, 'images', filesep, allNames{j}));
    end

    [labels, allNames] = openMultipleImages(strcat(rootPath, filesep, 'labels'));
    for j = 1 : length(labels)
        labels{j} = labels{j} > 0;
    end
    [labels] = resizeImages(labels, 0.5);
    for j = 1 : length(labels)
        imwrite(labels{j},strcat(rootPath, filesep, 'labels', filesep, strtok(allNames{j}, '.'), '.png'));
    end

    [masks, allNames] = openMultipleImages(strcat(rootPath, filesep, 'masks'));
    for j = 1 : length(masks)
        mask = masks{j};
        masks{j} = sum(mask,3) > 0;
    end
    [masks] = resizeImages(masks, 0.5);
    for j = 1 : length(masks)
        imwrite(masks{j},strcat(rootPath, filesep, 'masks', filesep, strtok(allNames{j}, '.'), '.png'));
    end

end