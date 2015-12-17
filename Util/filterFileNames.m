
function [filteredNames] = filterFileNames(names)

    filteredNames = {};
    for i = 1:length(names)
        if (~strcmp(names{i},'..') && ~strcmp(names{i},'.'))
            if (isempty(filteredNames))
                filteredNames = names{i};
            else
                filteredNames = [filteredNames {names{i}}];
            end
        end
    end
    
end