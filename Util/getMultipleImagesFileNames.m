% Open multiple files from a given directory
function allNames = getMultipleImagesFileNames(directory)
    % Get all file names
    allFiles = dir(directory);
    % Get only the names of the images inside the folder
    allNames = cell({allFiles.name});
    allNames = filterFileNames(allNames);
end