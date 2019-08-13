function [im_filt] = IP_LinearFiltering(im, kernel, border)
%% [im_filt] = IP_LinearFiltering(im, kernel, border)
% This function computes the 2D convolution of the im with kernel.
% The input image is padded using the border strategy selected prior to the
% convolution operation. This function only works for kernels with odd
% number size.
%
% INPUTS
% [im] (double) % image
% [kernel] (double) % convolution kernel
% [border] (string) % 'zero-pad', 'copy' or 'mirror'
%
% OUTPUTS
% [im_filt] (double) % resulting image after the convolution operation
%
% EXAMPLES
% Compute convolution between I and the 3x3 kernel K1 using zero-padding to
% deal with the border issues:
% [I1] = IP_LinearFiltering(I, K1, 'zero-pad')
%
%%
im = double(im);
kernel = double(kernel);
[n_row, n_col, n_ch] = size(im);
[nk, ck, ~] = size(kernel);

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
% flip kernel horizontally for convolution
K = kernel(:,end:-1:1);

im_filt = im; % initialised filtered image

for ch = 1:n_ch % for each colour channel
    for i = 1+n_pad_row:n_row+n_pad_row % for each real row of the padded image
        for j = 1+n_pad_col:n_col+n_pad_col % for each real column of the padded image
            
            conv = K.*im_pad(i-(nk-1)/2:i+(nk-1)/2,j-(ck-1)/2:j+(ck-1)/2,ch); % element-wise product between kernel and image patch
            conv = sum(conv(:)); % summation
            
            im_filt(i-n_pad_row,j-n_pad_col,ch) = conv;
            
        end
    end
end

end