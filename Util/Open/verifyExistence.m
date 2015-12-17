
function []= verifyExistence(path)

    % if the dir doesn't exists
    if (exist(path,'dir') == 0)
        mkdir(path);
    end

end