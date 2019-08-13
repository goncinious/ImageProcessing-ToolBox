function [im_filt] = IP_StatFiltering(im, kernel, k_size, border)
%% [im_filt] = IP_StatFiltering(im, kernel, k_size, border)
% This function applies a non linear kernel to the image (im).
% Non linear kernels used: median, minr ,max or midpoint filter.
% The input image is padded using the border strategy selected prior to the
% filtering operation. This function only works for kernels with odd
% number size.
%
% INPUTS
% [im] (double) % image
% [kernel] (string) % 'Min', 'Median', 'Max' or 'Midpoint'
% [border] (string) % 'zero-pad', 'copy' or 'mirror'
%
% OUTPUTS
% [im_filt] (double) % resulting image after filtering
%
% EXAMPLES
% Compute 3x3 median filter to I using zero-pad at the borders:
% [I1] = IP_StatFiltering(I, 'Median',3, 'zero-pad')
%
%%
im = double(im);
[n_row, n_col, n_ch] = size(im);
nk = k_size;
ck = k_size;

% strategies to generate fake pixels around the image
if strcmp(border,'zero-pad')
    [n_row, n_col, n_ch] = size(im);
    n_pad = max([(nk-1)/2 (ck-1)/2]); % n pixels to pad around the image
    im_pad = zeros([n_row+2*n_pad n_col+2*n_pad n_ch]); % pad matrix with right size (*2 - pad in both sides)
    im_pad((1:n_row)+n_pad, (1:n_col)+n_pad, :) = im; % using masking to select central region
    n_pad_row = n_pad;
    n_pad_col = n_pad;
    
elseif strcmp(border,'copy')
    im_pad = repmat(im,[3,3]);
    n_pad_row = n_row;
    n_pad_col = n_col;
    
elseif strcmp(border,'mirror')
    im_pad = [im(end:-1:1,end:-1:1,:) im(end:-1:1,:,:) im(end:-1:1,end:-1:1,:);
        im(:,end:-1:1,:)        im               im(:,end:-1:1,:);
        im(end:-1:1,end:-1:1,:) im(end:-1:1,:,:) im(end:-1:1,end:-1:1,:)];
    n_pad_row = n_row;
    n_pad_col = n_col;
end

%% apply filtering

im_filt = im; % initialised filtered image

for ch = 1:n_ch % for each colour channel
    for i = 1+n_pad_row:n_row+n_pad_row % for each real row of the padded image
        for j = 1+n_pad_col:n_col+n_pad_col % for each real column of the padded image
            
            
            conv = im_pad(i-(nk-1)/2:i+(nk-1)/2,j-(ck-1)/2:j+(ck-1)/2,ch); % get patch
            conv_sort = sort(conv(:)); % vector form - sort patch
            
            if strcmp(kernel,'Median')
                conv = conv_sort(floor(length(conv_sort)/2)); % get middle value
            end
            if strcmp(kernel,'Min')
                conv = conv_sort(1);
            end
            if strcmp(kernel,'Max')
                conv = conv_sort(end);
            end
            if strcmp(kernel,'Midpoint')
                conv = round((conv_sort(1)+conv_sort(end))/2); % compute mid point and round
            end
            
            im_filt(i-n_pad_row,j-n_pad_col,ch) = conv;
            
        end
    end
end

end
