
function I = preprocessing(I, mask, options)
% preprocessing Preprocess the given image
% I = preprocessing(I, mask, options)
% OUTPUT: I: image preprocessed
% INPUT: I: image (it can be a RGB image)
%        mask: a binary mask indicating the FOV
%        options: a configuration structure containing the options

    if (~isfield(options, 'preprocess') || (isfield(options, 'preprocess') && options.preprocess))

        % get only the green band of the original color image
        I = double(I(:,:,2));

        % extend the borders using the fakepad function
        I = fakepad(I, mask, options.erosion, options.fakepad_extension);
               
    end
    
end