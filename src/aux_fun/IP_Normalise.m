function im_norm = IP_Normalise(I_temp)
% This function takes an image and normalises it between 0-255.
% If colour image is provided, the normalisation is performed across the 3
% channels (ie. not performed in each channel individually).
%
    im_norm = I_temp - min(I_temp(:)); % between 0 and max value (shift)
    im_norm = im_norm / max(im_norm(:)); % scale between 0-1
    im_norm = im_norm * 255; % between 0-255

end
