function [im_stat,im_mean] = IP_AdaptThr(im, k_size, border, stat, meantype)
%% [im_stat, im_mean] = IP_AdaptThr(im, k_size, border, stat, meantype)

% This function obtains the local statistical values from the image to later apply the adaptive thresholding operation.
% It compute the mean in at each local neighborhood k_size if 'local' or
% gets the global mean.
% The variance or standard deviation can be computed in each location -
% determined by parameter stat.

% The input image is padded using the border strategy selected prior to the
% filtering operation. This function only works for kernels with odd
% number size.
%
% INPUTS
% [im] (double) % image
% [k_size] (double) % neighborhood size (odd number)
% [border] (string) % 'zero-pad', 'copy' or 'mirror'
% [stat] (string) % 'var' or 'std'
% [meantype] (sring) % 'local' or 'global'
%
% OUTPUTS
% [im_filt] (double) % resulting image after filtering
%
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

im_stat = NaN(size(im)); % initialised stat image (var or std)
im_mean = NaN(size(im)); % initialised mean image

for ch = 1:n_ch % for each colour channel
    for i = 1+n_pad_row:n_row+n_pad_row % for each real row of the padded image
        for j = 1+n_pad_col:n_col+n_pad_col % for each real column of the padded image

            neigh = im_pad(i-(nk-1)/2:i+(nk-1)/2,j-(ck-1)/2:j+(ck-1)/2,ch);
            neigh = neigh(:);
            mu = sum(neigh)/length(neigh);
            
            if strcmp(meantype,'local')
                im_mean(i-n_pad_row,j-n_pad_col,ch) = mu;
            end
            
            if strcmp(stat,'var')
                im_stat(i-n_pad_row,j-n_pad_col,ch) = sum((neigh - mu).^2)/length(neigh);
            elseif strcmp(stat,'std')
                 im_stat(i-n_pad_row,j-n_pad_col,ch) = sqrt(sum((neigh - mu).^2)/length(neigh));
            else
                % do nothing
            end

        end
    end
end

if nargin==5 && strcmp(meantype,'global') % get global image mean
   im_mean = sum(im(:))/length(im(:));
end


end