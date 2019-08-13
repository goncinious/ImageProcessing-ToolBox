function varargout = Demo(varargin)
% DEMO MATLAB code for Demo.fig
%      DEMO, by itself, creates a new DEMO or raises the existing
%      singleton*.
%
%      H = DEMO returns the handle to a new DEMO or the handle to
%      the existing singleton*.
%
%      DEMO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEMO.M with the given input arguments.
%
%      DEMO('Property','Value',...) creates a new DEMO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Demo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Demo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Demo

% Last Modified by GUIDE v2.5 06-Mar-2019 19:17:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Demo_OpeningFcn, ...
    'gui_OutputFcn',  @Demo_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Demo is made visible.
function Demo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Demo (see VARARGIN)

% Choose default command line output for Demo
handles.output = hObject;
addpath('aux_fun/')
set(handles.axes1,'visible', 'off');
set(handles.axes2,'visible', 'off');
set(handles.axes3,'visible', 'off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Demo wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Demo_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in processingMenu.
function processingMenu_Callback(hObject, eventdata, handles)
% hObject    handle to processingMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns processingMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from processingMenu


% --- Executes during object creation, after setting all properties.
function processingMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processingMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadBtn.
function loadBtn_Callback(hObject, eventdata, handles)
% hObject    handle to loadBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% READ IMAGE 1
[filename,path] = uigetfile({'*.bmp;*.tif;*.tiff;*.png;*.jpg;*.raw'},'File Selector');
im_path = strcat(path, filename);
format = strsplit(filename,'.');

if strcmp(format{2},'raw')
    % get dimensions from user
    prompt = {'Enter row size:','Enter column size:','Enter channel number:'};
    title = 'Image Dimensions';
    dims = [1 35];
    definput = {'512','512','1'};
    answer = inputdlg(prompt,title,dims,definput);
    row=str2double(answer{1}); col=str2double(answer{2}); channels=str2double(answer{3});
    
    % read raw uint8 image
    fin=fopen(im_path,'r');
    I=fread(fin,row*col*channels,'uint8=>uint8'); 
    Z=reshape(I,[row,col,channels]);
    handles.OriginalImage1 = double(Z');

else
    handles.OriginalImage1 = double(imread(im_path));
end
handles.CurrentImage = handles.OriginalImage1;
axes(handles.axes1);
imshow(uint8(handles.OriginalImage1))
guidata(hObject, handles); % update handle
%%
% --- Executes on button press in applyBtn.
function applyBtn_Callback(hObject, eventdata, handles)
% hObject    handle to applyBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% APPLY PROCESSING TO SINGLE IMAGE
% can apply multiple processing on image 1
% if applied on image 2, it overwrites image 2

v = get(handles.processingMenu,'Value'); % get currently selected option from processing menu
im_id = get(handles.menuImSelec,'Value'); % get currently selected option from image selected

if im_id == 1; I_tmp = handles.CurrentImage; else; I_tmp = handles.OriginalImage2; end

handles.UndoImage = I_tmp;

if isfield(handles,'ImageROI')
    I_tmp = handles.ImageROI;
end


if v == 2 % negative / negative linear transform
    I_tmp = 255.0 - I_tmp;
    
elseif v == 3 % shifting
    
    % get shifting factor
    s = str2double(get(handles.factorValue,'String'));
    
    while mod(s,1) ~= 0 % while fraction
        f = errordlg('Enter positive or negative integer.','Factor Error');
        s = 0;
    end
    
    I_tmp2 = s + I_tmp;
    I_tmp2 = round(I_tmp2);
    I_tmp2(I_tmp2>255) = 255;
    I_tmp2(I_tmp2<0) = 0;
    I_tmp = I_tmp2;
    
elseif v == 4 % re-scaling
    % get scaling factor
    s = str2double(get(handles.factorValue,'String'));
    
    while s<0 | s>2
        f = errordlg('Enter value between 0-2.','Factor Error');
        s = 0;
    end
    
    I_tmp2 = s.*I_tmp;
    I_tmp2 = round(I_tmp2);
    I_tmp2(I_tmp2>255) = 255;
    I_tmp2(I_tmp2<0) = 0;
    I_tmp = I_tmp2;
    
elseif v == 5 % add random noise (0-255) and re-scale
    
    rand_noise = round(255*rand(size(I_tmp)));
    I_tmp2 = rand_noise + I_tmp;
    
    % normalise image between 0-255
    I_tmp2 = IP_Normalise(I_tmp2);

    I_tmp = I_tmp2;
    
elseif v == 6 % bitwise NOT
    
    % convert to 8-integer
    I_tmp2 = uint8(I_tmp);
    
    % compute bitwise complement by executing the not operation on the binary
    % values of each byte (ie. image is first converted to 8-bit
    % reppresentation and the NOT operation is performed)
    
    I_tmp = double(bitcmp(I_tmp2));
    
elseif v==7 % logarithmic function
    
    % compute c factor (obtained by mapping 0 to 0 and 255-255)
    c = 255.0/log10(256.0);
    I_tmp =  c*log10(1+I_tmp);
    I_tmp = round(I_tmp); % round to integers
    
elseif v==8 % Power law function
    
    % get exponent
    p = str2double(get(handles.factorValue,'String'));
    
    if p<0.01 | p>25
        f = errordlg('Enter value between 0.01-25.','Power Error');
        p = 0;
    end
    
    % compute c scaling factor in order to maintain dynamic range
    c = 255.0^(1-p);
    
    
    I_tmp =  c*(I_tmp.^p);
    I_tmp = round(I_tmp);
    
elseif v==9 % apply random look-up table
    
    % generate lookup table with random numbers
    rand_table = round(255*rand(1,256));
    
    % find correspondences
    I_tmp = rand_table(I_tmp+1);
    
elseif v==10 % bit-slice image
    
    % get slice number
    s = str2double(get(handles.factorValue,'String'));
    
    if s<0 | s>7
        f = errordlg('Enter value between 0-7. Showing bit-slice=0 by default.','Slice Error');
        s = 0;
    end
    
    % Assumes that we are using a grayscale image - no color channels
    % considered here
    bit_im = NaN(size(I_tmp,1),size(I_tmp,2),8);

    for i = 1:size(I_tmp,1)
        for j = 1:size(I_tmp,2)
            % get 8 bit representation and add to bit_im matrix
            bit_im(i,j,:) = bitget(uint8(I_tmp(i,j)),8:-1:1);
        end
    end
    
    bit_im = bit_im(:,:,s+1); % select slice number
    
    % convert 1 to 255 for display
    bit_im(bit_im==1)=255.0;
    I_tmp = double(bit_im);
    
else
    ; % do nothing
end


if im_id == 1
    if isfield(handles,'ImageROI') 
        handles.CurrentImage(handles.ROIxy(2):handles.ROIxy(4),handles.ROIxy(1):handles.ROIxy(3),:) = I_tmp;
        handles.ImageROI = I_tmp;
    else
        handles.CurrentImage = I_tmp;
    end
    
    axes(handles.axes2);
    imshow(uint8(handles.CurrentImage))
    
else
    if isfield(handles,'ImageROI')
        handles.OriginalImage2(handles.ROIxy(2):handles.ROIxy(4),handles.ROIxy(1):handles.ROIxy(3),:) = I_tmp;
        handles.ImageROI = I_tmp;
    else
        handles.OriginalImage2 = I_tmp;
    end
    axes(handles.axes3);
    imshow(uint8(handles.OriginalImage2))
end
guidata(hObject, handles); % update handle


function factorValue_Callback(hObject, eventdata, handles)
% hObject    handle to factorValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of factorValue as text
%        str2double(get(hObject,'String')) returns contents of factorValue as a double


% --- Executes during object creation, after setting all properties.
function factorValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to factorValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in resetBtn.
function resetBtn_Callback(hObject, eventdata, handles)
% hObject    handle to resetBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.CurrentImage = handles.OriginalImage1;
axes(handles.axes2);
imshow(uint8(handles.CurrentImage))

axes(handles.axes1); hold off
imshow(uint8(handles.OriginalImage1))


if isfield(handles,'uip_panel')
    handles.uip_panel.delete
    clear handles.uip_panel.delete
end

if isfield(handles,'ImageROI')
     handles = rmfield(handles,'ROIxy');
     handles = rmfield(handles,'ImageROI');
end
if isfield(handles,'ThrFound')
    set(handles.ThrFound,'String',' ');
end

clear handles.OriginalImage2
set(handles.axes3,'visible', 'off');

guidata(hObject, handles); % update handle



% --- Executes on button press in loadBtn2.
function loadBtn2_Callback(hObject, eventdata, handles)
% hObject    handle to loadBtn2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% READ IMAGE 2
[filename,path] = uigetfile({'*.bmp;*.tif;*.tiff;*.png;*.jpg;*.raw'},'File Selector');
im_path = strcat(path, filename);
format = strsplit(filename,'.');

if strcmp(format{2},'raw')
    % get dimensions from user
    prompt = {'Enter row size:','Enter column size:','Enter channel number:'};
    title = 'Image Dimensions';
    dims = [1 35];
    definput = {'512','512','1'};
    answer = inputdlg(prompt,title,dims,definput);
    row=str2double(answer{1}); col=str2double(answer{2}); channels=str2double(answer{3});
    
    % read raw uint8 image
    fin=fopen(im_path,'r');
    I=fread(fin,row*col*channels,'uint8=>uint8'); 
    Z=reshape(I,[row,col,channels]);
    handles.OriginalImage2 = double(Z');

else
    handles.OriginalImage2 = double(imread(im_path));
end

axes(handles.axes3);
imshow(uint8(handles.OriginalImage2))
guidata(hObject, handles); % update handle


% --- Executes on selection change in processingMenu2.
function processingMenu2_Callback(hObject, eventdata, handles)
% hObject    handle to processingMenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns processingMenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from processingMenu2


% --- Executes during object creation, after setting all properties.
function processingMenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processingMenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in applyBtn2.
function applyBtn2_Callback(hObject, eventdata, handles)
% hObject    handle to applyBtn2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% APPLY PROCESSING USING 2 IMAGES (only applied on originals images)
v = get(handles.processingMenu2,'Value'); % get currently selected option from menu
handles.UndoImage = handles.CurrentImage;

im1_sz = size(handles.OriginalImage1);
im2_sz = size(handles.OriginalImage2);

if (length(im1_sz) == length(im2_sz) && sum(im1_sz(1:2)==im2_sz(1:2))==2)
    if v == 2 % addition
        handles.CurrentImage = handles.OriginalImage1 + handles.OriginalImage2;

        % normalise (shift and scale)
        handles.CurrentImage = round(IP_Normalise(handles.CurrentImage));
        axes(handles.axes2);
        imshow(uint8(handles.CurrentImage))
        guidata(hObject, handles); % update handle

    elseif v == 3 % subtraction

        handles.CurrentImage = handles.OriginalImage1 - handles.OriginalImage2;

        % normalise (shift and scale)
        handles.CurrentImage = round(IP_Normalise(handles.CurrentImage));
        axes(handles.axes2);
        imshow(uint8(handles.CurrentImage))
        guidata(hObject, handles); % update handle

    elseif v == 4 % multiplication

        if length(unique(handles.OriginalImage2)) == 2 % check if its mask image
            handles.OriginalImage2(handles.OriginalImage2==255) = 1;
        end

        handles.CurrentImage = handles.OriginalImage1 .* handles.OriginalImage2;

        % normalise (shift and scale)
        handles.CurrentImage = round(IP_Normalise(handles.CurrentImage));
        axes(handles.axes2);
        imshow(uint8(handles.CurrentImage))
        guidata(hObject, handles); % update handle


    elseif v == 5 % division

        handles.CurrentImage = handles.OriginalImage1 ./ handles.OriginalImage2;

        % normalise (shift and scale)
        handles.CurrentImage = round(IP_Normalise(handles.CurrentImage));
        axes(handles.axes2);
        imshow(uint8(handles.CurrentImage))
        guidata(hObject, handles); % update handle

    elseif v == 6 % bitwise AND
        

        % convert to 8-integer and then compute bitwise AND by executing the AND operation on the binary
        % values between the bytes of each image
        handles.CurrentImage = bitand(uint8(handles.OriginalImage1),uint8(handles.OriginalImage2));

        axes(handles.axes2);
        imshow(uint8(handles.CurrentImage))
        handles.CurrentImage2 = double(handles.CurrentImage);
        guidata(hObject, handles); % update handle

    elseif v == 7 % bitwise OR

        % convert to 8-integer and then compute bitwise OR by executing the OR operation on the binary
        % values between the bytes of each image
        handles.CurrentImage = bitor(uint8(handles.OriginalImage1),uint8(handles.OriginalImage2));

        axes(handles.axes2);
        imshow(uint8(handles.CurrentImage))
        handles.CurrentImage = double(handles.CurrentImage);
        guidata(hObject, handles); % update handle

    elseif v == 8 % bitwise XOR

        % convert to 8-integer and then compute bitwise XOR by executing the XOR operation on the binary
        % values between the bytes of each image
        handles.CurrentImage = bitxor(uint8(handles.OriginalImage1),uint8(handles.OriginalImage2));

        axes(handles.axes2);
        imshow(uint8(handles.CurrentImage))
        handles.CurrentImage = double(handles.CurrentImage);
        guidata(hObject, handles); % update handle

    end
else
   f = errordlg('Dimensions do not match.','Dimensionality error.');
end

% --- Executes on selection change in menuImSelec.
function menuImSelec_Callback(hObject, eventdata, handles)
% hObject    handle to menuImSelec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menuImSelec contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menuImSelec


% --- Executes during object creation, after setting all properties.
function menuImSelec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menuImSelec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveBtn.
function saveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to saveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filter = {'*.jpg';'*.tif';'*.png';'*.bmp';};
[file, path] = uiputfile(filter);

if file ~= 0
    filename = strcat(path,file);
    imwrite(uint8(handles.CurrentImage), filename);
end


% --- Executes on button press in DisHistBtn.
function handles = DisHistBtn_Callback(hObject, eventdata, handles)
% hObject    handle to DisHistBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

im_id = get(handles.menuImSelec,'Value'); % get currently selected option from image selected
if im_id == 1; I_temp = handles.CurrentImage; else; I_temp = handles.OriginalImage2; end


if isfield(handles,'ImageROI')
    I_temp = handles.ImageROI;
end

%% Compute histogram of current image
n_ch = size(I_temp,3);
h = zeros(n_ch,256);
for ch = 1:n_ch
    I_temp1 = I_temp(:,:,ch); % get pixel values for channel ch
    I_temp1 = I_temp1(:); % flatten matrix to vector
    
    for i = 1:size(I_temp1,1)
        % add 1 to bin corresponding to pixel value
        h(ch,I_temp1(i)+1) = h(ch,I_temp1(i)+1) + 1; 
    end
    
    % normalise histogram for that channel by total counts (get PDF) - sum to 1
    h(ch,:) = h(ch,:)/sum(h(ch,:));
end

% Display histogram

if isfield(handles,'uip_panel') % clear if already exists
    handles.uip_panel.delete
    clear handles.uip_panel.delete
end

uip = uipanel('Position',[0.53 0.15 0.45 0.26]);
if n_ch == 3 % RGB
    ax1 = subplot(1,3,1, 'Parent', uip);
    bar(ax1,0:255,h(1,:),'r'); ylim([0 max(h(:))]); grid on; xlabel('Bins'); ylabel('Normalized counts'); title('Red')
    ax2 = subplot(1,3,2, 'Parent', uip);
    bar(ax2,0:255,h(2,:),'g'); ylim([0 max(h(:))]); grid on; xlabel('Bins'); title('Green')
    ax3 = subplot(1,3,3, 'Parent', uip);
    bar(ax3,0:255,h(3,:),'b'); ylim([0 max(h(:))]); grid on; xlabel('Bins'); title('Blue')
    
else % grayscale
    ax = axes(uip);
    bar(ax,0:255,h(1,:),'k'); ylim([0 max(h(:))]); grid on; xlabel('Bins'); ylabel('Normalized counts')
end

% update handle
handles.CurrentHist = h;
handles.uip_panel = uip;
guidata(hObject, handles); % update handle

% --- Executes on button press in EqHistBtn.
function EqHistBtn_Callback(hObject, eventdata, handles)
% hObject    handle to EqHistBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'CurrentHist') % if this button is clicked first, generate histogram
   handles = DisHistBtn_Callback(handles.DisHistBtn,eventdata,handles); 
   h = handles.CurrentHist;
else
   h = handles.CurrentHist;
end

n_ch = size(h,1);

CDF = zeros(n_ch,256);

% compute CDF from PDF
for ch = 1:n_ch
    summ = 0;
    for i = 1:size(h,2)
       CDF(ch,i) = summ + h(ch,i);
       summ = summ + h(ch,i); 
    end
end

% Obtain Look-up table
% Multiply CDF by max value (L-1 = 255) and round values
LUT = round(CDF * 255.0);

im_id = get(handles.menuImSelec,'Value'); % get currently selected option from image selected
if im_id == 1; I_temp = handles.CurrentImage; else; I_temp = handles.OriginalImage2; end

handles.UndoImage = I_temp;

if isfield(handles,'ImageROI')
    I_temp = handles.ImageROI;
end

I_temp2 = NaN(size(I_temp));

% update image
for ch = 1:n_ch
    LUT_temp = LUT(ch,:);
    I_temp2(:,:,ch) = LUT_temp(I_temp(:,:,ch)+1);
end


if im_id == 1
    if isfield(handles,'ImageROI') 
        handles.CurrentImage(handles.ROIxy(2):handles.ROIxy(4),handles.ROIxy(1):handles.ROIxy(3),:) = I_temp2;
        handles.ImageROI = I_temp2;
    else
        handles.CurrentImage = I_temp2;
    end
    
    axes(handles.axes2);
    imshow(uint8(handles.CurrentImage))
    
else
    if isfield(handles,'ImageROI')
        handles.OriginalImage2(handles.ROIxy(2):handles.ROIxy(4),handles.ROIxy(1):handles.ROIxy(3),:) = I_temp2;
        handles.ImageROI = I_temp2;
    else
        handles.OriginalImage2 = I_temp2;
    end
    axes(handles.axes3);
    imshow(uint8(handles.OriginalImage2))
end

% update histogram
handles.uip_panel.delete
guidata(hObject, handles); % update handle
DisHistBtn_Callback(handles.DisHistBtn,eventdata,handles);


% --- Executes on button press in UndoBtn.
function UndoBtn_Callback(hObject, eventdata, handles)
% hObject    handle to UndoBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im_id = get(handles.menuImSelec,'Value'); % get currently selected option from image selected
if im_id == 1
    handles.CurrentImage = handles.UndoImage;
    axes(handles.axes2);
    imshow(uint8(handles.CurrentImage))
else
    handles.OriginalImage2 = handles.UndoImage;
    axes(handles.axes3);
    imshow(uint8(handles.OriginalImage2))
end

if isfield(handles,'ImageROI')
    sp = handles.ROIxy;
    handles.ImageROI = handles.UndoImage(sp(2):sp(4), sp(1): sp(3),:);
end




guidata(hObject, handles); % update handle


% --- Executes on button press in ROIBtn.
function ROIBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ROIBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

im_id = get(handles.menuImSelec,'Value'); % get currently selected option from image selected
if im_id == 1
    I_tmp = handles.CurrentImage;
    sp=getrect(handles.axes1);
    
    % Get the x and y co-ordinates
    % Get the x and y co-ordinates
    sp(1) = max(floor(sp(1)), 1); %xmin
    sp(2) = max(floor(sp(2)), 1);%ymin
    sp(3)= min(ceil(sp(1) + sp(3))); %xmax
    sp(4)=min(ceil(sp(2) +sp(4))); %ymax
    % Index into the original image to create the new image
    handles.ImageROI = I_tmp(sp(2):sp(4), sp(1): sp(3),:);
    handles.ROIxy = sp;
    axes(handles.axes1); hold on
    plot([sp(1) sp(1)], [sp(2) sp(4)],'-r','linewidth',2)
    plot([sp(3) sp(3)], [sp(2) sp(4)],'-r','linewidth',2)
    plot([sp(1) sp(3)], [sp(2) sp(2)],'-r','linewidth',2)
    plot([sp(1) sp(3)], [sp(4) sp(4)],'-r','linewidth',2)

else
    sp=getrect(handles.axes3);
    I_tmp = handles.OriginalImage2;
    
    % Get the x and y co-ordinates
    % Get the x and y co-ordinates
    sp(1) = max(floor(sp(1)), 1); %xmin
    sp(2) = max(floor(sp(2)), 1);%ymin
    sp(3)= min(ceil(sp(1) + sp(3))); %xmax
    sp(4)=min(ceil(sp(2) +sp(4))); %ymax
    % Index into the original image to create the new image
    handles.ImageROI = I_tmp(sp(2):sp(4), sp(1): sp(3),:);
    handles.ROIxy = sp;
    axes(handles.axes3); hold on
    plot([sp(1) sp(1)], [sp(2) sp(4)],'-r','linewidth',2)
    plot([sp(3) sp(3)], [sp(2) sp(4)],'-r','linewidth',2)
    plot([sp(1) sp(3)], [sp(2) sp(2)],'-r','linewidth',2)
    plot([sp(1) sp(3)], [sp(4) sp(4)],'-r','linewidth',2)
end

guidata(hObject, handles); % update handle


% --- Executes on selection change in FiltMenu.
function FiltMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FiltMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FiltMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FiltMenu


% --- Executes during object creation, after setting all properties.
function FiltMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FiltMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in FiltApply.
function FiltApply_Callback(hObject, eventdata, handles)
% hObject    handle to FiltApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

im_id = get(handles.menuImSelec,'Value'); % get currently selected option from image selected
if im_id == 1; I_tmp = handles.CurrentImage; else; I_tmp = handles.OriginalImage2; end

handles.UndoImage = I_tmp;

if isfield(handles,'ImageROI')
    I_tmp = handles.ImageROI;
end

%% Get filter size and type
mask_size_str = handles.Maskuibuttongroup.SelectedObject.String; % get radio button selected
if strcmp(mask_size_str,'3x3')
    mask_size = 3;
elseif strcmp(mask_size_str,'5x5')
    mask_size = 5;
else
    mask_size = 7;
end

% get filter type
idx = get(handles.FiltMenu,'Value'); % get currently selected option from menu
type = handles.FiltMenu.String{idx};


% convolution operation
if idx>=2 && idx<=12 % linear operation
    % get mask
    K = IP_getFilt(type,mask_size);
    % border strategy used: mirror image at the borders
    I_tmp = IP_LinearFiltering(I_tmp,K,'mirror');
else % non-linear
    I_tmp = IP_StatFiltering(I_tmp,type,mask_size,'mirror');
end

% prepare for visualisation
if idx==2 || idx==3 % mean and gaussian filters
    I_tmp = round(I_tmp); % convert to integers 0-255
  
elseif idx>=4 && idx<=5 %% laplacian kernels
    % absolute value conversion followed by scale
    I_tmp = round(IP_Normalise(abs(I_tmp)));

    if mask_size>3
        f = errordlg('Only mask 3x3 available for Laplacian kernels.','Mask size error.');
    end
elseif idx>=6 && idx <=7 %% laplacian enhancement
    % remove out of range pixels
    I_tmp(I_tmp>255) = 255;
    I_tmp(I_tmp<0) = 0;
    if mask_size>3
        f = errordlg('Only mask 3x3 available for Laplacian kernels.','Mask size error.');
    end    
    
elseif idx>=8  && idx<=12 %% 8-12 Sobel, Roberts and LoG
    I_tmp = round(IP_Normalise(abs(I_tmp)));
    
    if (mask_size>3 && ~strcmp(type,'LoG')) || (mask_size~=5 && strcmp(type,'LoG'))
        f = errordlg('Only mask 3x3 available for Sobel and Roberts and 5x5 for LoG kernel.','Mask size error.');
    end
    
else %% 13-16 min, max, midpoint and median
    % do nothing
    
end


if im_id == 1
    if isfield(handles,'ImageROI') 
        handles.CurrentImage(handles.ROIxy(2):handles.ROIxy(4),handles.ROIxy(1):handles.ROIxy(3),:) = I_tmp;
        handles.ImageROI = I_tmp;
    else
        handles.CurrentImage = I_tmp;
    end
    
    axes(handles.axes2);
    imshow(uint8(handles.CurrentImage))
    
else
    if isfield(handles,'ImageROI')
        handles.OriginalImage2(handles.ROIxy(2):handles.ROIxy(4),handles.ROIxy(1):handles.ROIxy(3),:) = I_tmp;
        handles.ImageROI = I_tmp;
    else
        handles.OriginalImage2 = I_tmp;
    end
    axes(handles.axes3);
    imshow(uint8(handles.OriginalImage2))
end

guidata(hObject, handles); % update handle


% --- Executes on button press in AddSPbutton.
function AddSPbutton_Callback(hObject, eventdata, handles)
% hObject    handle to AddSPbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im_id = get(handles.menuImSelec,'Value'); % get currently selected option from image selected
if im_id == 1; I_tmp = handles.CurrentImage; else; I_tmp = handles.OriginalImage2; end

handles.UndoImage = I_tmp;

if isfield(handles,'ImageROI')
    I_tmp = handles.ImageROI;
end

I_tmp1 = I_tmp;
perc = 20; % salt and pepper will be added to 20% of the pixels

for i = 1:size(I_tmp,1) % for every pixel
   for j = 1:size(I_tmp,1)
       if randi(perc) == perc    % pick pixel with 20% chance
           I_tmp1(i,j,:) = round(rand(1))*255; % replace by either 0 or 255 (50% chance)
       end
   end
end

if im_id == 1
    if isfield(handles,'ImageROI') 
        handles.CurrentImage(handles.ROIxy(2):handles.ROIxy(4),handles.ROIxy(1):handles.ROIxy(3),:) = I_tmp1;
        handles.ImageROI = I_tmp1;
    else
        handles.CurrentImage = I_tmp1;
    end
    
    axes(handles.axes2);
    imshow(uint8(handles.CurrentImage))
    
else
    if isfield(handles,'ImageROI')
        handles.OriginalImage2(handles.ROIxy(2):handles.ROIxy(4),handles.ROIxy(1):handles.ROIxy(3),:) = I_tmp1;
        handles.ImageROI = I_tmp1;
    else
        handles.OriginalImage2 = I_tmp1;
    end
    axes(handles.axes3);
    imshow(uint8(handles.OriginalImage2))
end

guidata(hObject, handles); % update handle



function ThrVal1_Callback(hObject, eventdata, handles)
% hObject    handle to ThrVal1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ThrVal1 as text
%        str2double(get(hObject,'String')) returns contents of ThrVal1 as a double


% --- Executes during object creation, after setting all properties.
function ThrVal1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThrVal1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in thrBtn.
function thrBtn_Callback(hObject, eventdata, handles)
% hObject    handle to thrBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This is a demonstration of how to compute mean and std from image
% histogram.
% These variables are not used in the following processing.
if isfield(handles,'CurrentHist')
    % Computing average and std from histogram:
    % the average of the image is the weighted averaged of normalised
    % histogram:
    h = handles.CurrentHist; % [1x256]
    average = sum([0:255].*h); % bins .* probabilities

    % The variance is the weighted averaged of the squares diff from the mean:
    variance = sum((([0:255]-average).^2).*h);
    % std = sqrt(var):
    standev = sqrt(variance);
    clear h average variance standev
end

im_id = get(handles.menuImSelec,'Value'); % get currently selected option from image selected
if im_id == 1; I_tmp = handles.CurrentImage; else; I_tmp = handles.OriginalImage2; end

handles.UndoImage = I_tmp;

if isfield(handles,'ImageROI')
    I_tmp = handles.ImageROI;
end

I_tmp1 = zeros(size(I_tmp)); % create binary image

idx = get(handles.ThrMenu,'Value'); % get currently selected option from thr menu


if idx == 2 % manual thresholding
    thr = str2double(get(handles.ThrVal1,'String'));
    
    if (thr<0 || thr>255 || isnan(thr))
        f = errordlg('Enter value between 0-255.','Threshold error.');
        thr = 0;
    end
    
    I_tmp1(I_tmp>=thr) = 255.0;
    I_tmp1(I_tmp<thr) = 0;
    set(handles.ThrFound,'String',num2str(thr));

    
elseif idx == 3 % automated thresholding
    
    % initialise means (background and object)
    % mu bkg - four corners
    mu_b = I_tmp(1,1) + I_tmp(1,size(I_tmp,2)) + I_tmp(size(I_tmp,1),1) + I_tmp(size(I_tmp,1),size(I_tmp,2));
    mu_b = mu_b/4.0;
    
    % mu object
    mu_o = I_tmp;
    % set contributions of the corners to 0
    mu_o(1,1)=0;
    mu_o(1,size(mu_o,2))=0;
    mu_o(size(mu_o,1),1)=0;
    mu_o(size(mu_o,1),size(mu_o,2))=0;
    mu_o = mu_o(:); % convert matrix to vector
    mu_o = sum(mu_o)/(length(mu_o)-4); % get average, without corner contribution
    
    thr = (mu_b + mu_o) /2.0;
    er = 1;
    
    while er>0.0001 % run until error is small
    mu_b = I_tmp(I_tmp<thr);
    mu_b = sum(mu_b)/length(mu_b);
    
    mu_o = I_tmp(I_tmp>=thr);
    mu_o = sum(mu_o)/length(mu_o);
    
    thr1 = (mu_b + mu_o) /2.0;
    
    er = abs(thr1 - thr); % compute deviation
    thr = thr1; % update threshold
    end
    
    % threshold image using thr found in last iteration
    I_tmp1(I_tmp>=thr) = 255.0;
    I_tmp1(I_tmp<thr) = 0;
    
    set(handles.ThrFound,'String',num2str(thr));

elseif idx==4 % adaptive
    
   a = str2double(get(handles.ThrVal1,'String'));
   b = str2double(get(handles.ThrVal2,'String'));
   w_size = str2double(get(handles.ThrVal3,'String'));
   mean_type = handles.popupmenu7.String{handles.popupmenu7.Value};
   [Ivar, Imean] = IP_AdaptThr(I_tmp, w_size, 'mirror', 'var', mean_type); % get mean and variance images using [w_size x w_size] neighorhood
   
   I_tmp1 = (I_tmp > a*Ivar) & (I_tmp > b*Imean); % get thresholded image using a,b parameters
   I_tmp1 = double(I_tmp1); % convert from logical to double
   I_tmp1(I_tmp1==1) = 255.0;

   set(handles.ThrFound,'String','-1');

else
       
end


% display
if im_id == 1
    if isfield(handles,'ImageROI') 
        handles.CurrentImage(handles.ROIxy(2):handles.ROIxy(4),handles.ROIxy(1):handles.ROIxy(3),:) = I_tmp1;
        handles.ImageROI = I_tmp1;
    else
        handles.CurrentImage = I_tmp1;
    end
    
    axes(handles.axes2);
    imshow(uint8(handles.CurrentImage))
    
else
    if isfield(handles,'ImageROI')
        handles.OriginalImage2(handles.ROIxy(2):handles.ROIxy(4),handles.ROIxy(1):handles.ROIxy(3),:) = I_tmp1;
        handles.ImageROI = I_tmp1;
    else
        handles.OriginalImage2 = I_tmp1;
    end
    axes(handles.axes3);
    imshow(uint8(handles.OriginalImage2))
end

guidata(hObject, handles); % update handle


% --- Executes on selection change in ThrMenu.
function ThrMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ThrMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ThrMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ThrMenu


% --- Executes during object creation, after setting all properties.
function ThrMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThrMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ThrVal2_Callback(hObject, eventdata, handles)
% hObject    handle to ThrVal2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ThrVal2 as text
%        str2double(get(hObject,'String')) returns contents of ThrVal2 as a double


% --- Executes during object creation, after setting all properties.
function ThrVal2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThrVal2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ThrVal3_Callback(hObject, eventdata, handles)
% hObject    handle to ThrVal3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ThrVal3 as text
%        str2double(get(hObject,'String')) returns contents of ThrVal3 as a double


% --- Executes during object creation, after setting all properties.
function ThrVal3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThrVal3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7


% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
