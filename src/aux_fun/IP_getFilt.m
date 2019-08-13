function K = IP_getFilt(filter,size)
% Get mask selected by user.


%% SMOOTHING FILTERS
%% Averaging
if strcmp(filter,'mean')
    K = ones(size,size);
    K = K/sum(K(:)); % normalise (sum to 1)
end

%% Weighted averaging
if strcmp(filter,'gaussian')
    switch size
        case 3
            K = [1 2 1;
                 2 4 2;
                 1 2 1];
            K = K/sum(K(:));
        case 5
            K = [1 4 7 4 1;
                 4 16 26 16 4;
                 7 26 41 26 7;
                 4 16 26 16 4;
                 1 4 7 4 1];
            K = K/sum(K(:));
        case 7
            K = [0 0 1 2 1 0 0;
                 0 3 13 22 13 3 0;
                 1 13 59 97 59 13 1;
                 2 22 97 159 97 22 2;
                 1 13 59 97 59 13 1;
                 0 3 13 22 13 3 0;
                 0 0 1 2 1 0 0];
             K = K/sum(K(:));
    end
end

%% Laplacian Enhancement
if strcmp(filter,'4-LaplacianEnh')
    K = [0 -1 0;
         -1 5 -1;
         0 -1 0];
end

if strcmp(filter,'8-LaplacianEnh')
    K = [-1 -1 -1;
         -1 9 -1;
         -1 -1 -1];
                  
end

%% EDGE DETECTION
%% Laplacian
if strcmp(filter,'4-Laplacian')
    K = [0 -1 0;
         -1 4 -1;
         0 -1 0];
end

if strcmp(filter,'8-Laplacian') %% include diagonals
    K = [-1 -1 -1;
         -1 8 -1;
         -1 -1 -1];
end

%% Roberts
if strcmp(filter,'L-Roberts')
    K = [0 0 0;
         0 0 -1;
         0 1 0]; 
end

if strcmp(filter,'R-Roberts')
    K = [0 0 0;
         0 -1 0;
         0 0 1]; 
end

%% Sobel
if strcmp(filter,'X-Sobel') %% vertical
    K = [-1 0 1;
         -2 0 2;
         -1 0 1]; 
end

if strcmp(filter,'Y-Sobel') %% horizontal sobel
    K = [-1 -2 -1;
         0 0 0;
         1 2 1]; 
end


%% Laplacian of gaussian
if strcmp(filter,'LoG')
    K = [0 0 -1 0 0;
         0 -1 -2 -1 0;
         -1 -2 16 -2 -1;
         0 -1 -2 -1 0;
         0 0 -1 0 0];
end


