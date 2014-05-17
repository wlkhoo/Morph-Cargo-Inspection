function varargout = gammagui(varargin)
% GAMMAGUI M-file for gammagui.fig
%      GAMMAGUI, by itself, creates a new GAMMAGUI or raises the existing
%      singleton*.
%
%      H = GAMMAGUI returns the handle to a new GAMMAGUI or the handle to
%      the existing singleton*.
%
%      GAMMAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAMMAGUI.M with the given input arguments.
%
%      GAMMAGUI('Property','Value',...) creates a new GAMMAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gammagui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gammagui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help gammagui

% Last Modified by GUIDE v2.5 20-Aug-2008 10:25:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gammagui_OpeningFcn, ...
                   'gui_OutputFcn',  @gammagui_OutputFcn, ...
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

%% ========================================================================
%% 
%% Written by Wai Khoo
%%
%% The program read in two images and two sets of initial points.
%% The user can add/remove/modify those points.
%% Once the user is satisfied, click 'Done' to produce intermediate views.
%%
%% ========================================================================

% --- Executes just before gammagui is made visible.
function gammagui_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to gammagui (see VARARGIN)
    global img1 img2 pt1 pt2 filename ROWS disimg

    % Choose default command line output for gammagui
    handles.output = hObject;

    answer = questdlg('Which pair of images?','Gamma Init','0 degree vs. 10 degree','10 degree vs. 20 degree', '0 degree vs. 10 degree');
    if strcmp(answer,'0 degree vs. 10 degree')
        img1 = imread('VIIZeroDegree.tif');
        img2 = imread('VIITenDegree.tif');
        filename = 'images/ZeroMorphTen_%d.jpg';
        answer2 = questdlg('Whole or part of the image? Perhaps starting from scratch?', 'Gamma Init', 'Whole', 'Part', 'From scratch', 'Whole');
        if strcmp(answer2, 'Whole')
            pt1 = load('degree00_10_1');    % modified
            pt2 = load('degree00_10_2');
        elseif strcmp(answer2, 'Part')
            pt1 = load('degree00_10_1_part');   % part
            pt2 = load('degree00_10_2_part');
        else
            pt1 = load('points10-00_2');  % 0-degree img coordinates
            pt2 = load('points10-00_1');  % 10-degree img coordinates
            %% only the 1st time when you load in new points; add 4 corners.
            [ROWS COLS CHANNELS] = size(img1);
            corners = [0.9,0.9; 0.9,ROWS+0.1; COLS+0.1,0.9; COLS+0.1,ROWS+0.1];
            pt1 = cat(1, pt1, corners);
            pt2 = cat(1, pt2, corners);
        end
    else
        img1 = imread('VIITenDegree.tif');
        img2 = imread('VIITwentyDegree.tif');
        filename = 'images/TenMorphTwenty_%d.jpg';
        answer2 = questdlg('Whole or part of the image? Perhaps starting from scratch?', 'Gamma Init', 'Whole', 'Part', 'From scratch', 'Whole');
        if strcmp(answer2, 'Whole')
            pt1 = load('degree10_20_1');
            pt2 = load('degree10_20_2');
        elseif strcmp(answer2, 'Part')
            pt1 = load('degree10_20_1_part');
            pt2 = load('degree10_20_2_part');
        else
            pt1 = load('points10-20_1');  % 10-degree img coordinates
            pt2 = load('points10-20_2');  % 20-degree img coordinates
            %% only the 1st time when you load in new points; add 4 corners.
            [ROWS COLS CHANNELS] = size(img1);
            corners = [0.9,0.9; 0.9,ROWS+0.1; COLS+0.1,0.9; COLS+0.1,ROWS+0.1];
            pt1 = cat(1, pt1, corners);
            pt2 = cat(1, pt2, corners);
        end
    end
    
    [ROWS COLS CHANNELS] = size(img1);
    disimg = [img1; img2];
    axes(handles.Image_plot);
    imshow(disimg);
    hold on;

    [Npt DUMB] = size(pt1);
    cnt = 1;
    while (cnt <= Npt)
        % draw point
        plot(pt1(cnt,1), pt1(cnt,2), 'r*');
        plot(pt2(cnt,1), ROWS+pt2(cnt,2), 'b*');
        drawnow;
        cnt = cnt + 1;
    end

    % update delaunay triangles
    tri1 = delaunay(pt1(:,1), pt1(:,2), {'Qt','Qbb','Qc','Qz'});
    tri2 = delaunay(pt2(:,1), pt2(:,2), {'Qt','Qbb','Qc','Qz'});
    triplot(tri1, pt1(:,1), pt1(:,2), 'g');
    triplot(tri2, pt2(:,1), ROWS+pt2(:,2), 'g');
    
    % update status
    set(handles.statusText, 'String', sprintf('\nReady'));

    % Update handles structure
    guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = gammagui_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes on button press in add_button.
function add_button_Callback(hObject, eventdata, handles)
    % hObject    handle to add_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    global pt1 pt2 ROWS

    [Npt DUMB] = size(pt1);
    index = Npt + 1;

    set(handles.statusText, 'String', sprintf('\nSelect a point'));
    guidata(hObject, handles);
    axes(handles.Image_plot);    
    
    [X, Y] = ginput(1);
    if Y < ROWS     % pick a point in top image
        pt1(index, 1) = X;
        pt1(index, 2) = Y;
        plot(pt1(index, 1), pt1(index, 2), 'm+', 'LineWidth', 2, 'MarkerSize', 12);
        top = true;
        set(handles.statusText, 'String', sprintf('\nSelect the corresponding point in the bottom image'));
    else            % pick a point in bottom image
        pt2(index, 1) = X;
        pt2(index, 2) = Y - ROWS;
        plot(pt2(index, 1), ROWS+pt2(index, 2), 'm+', 'LineWidth', 2, 'MarkerSize', 12);
        top = false;
        set(handles.statusText, 'String', sprintf('\nSelect the corresponding point in the top image'));
    end
    guidata(hObject, handles);
    
    [X, Y] = ginput(1); % pick corresponding point
    if top
        pt2(index, 1) = X;
        pt2(index, 2) = Y - ROWS;
        plot(pt2(index, 1), ROWS+pt2(index, 2), 'm+', 'LineWidth', 2, 'MarkerSize', 12);
    else
        pt1(index, 1) = X;
        pt1(index, 2) = Y;
        plot(pt1(index, 1), pt1(index, 2), 'm+', 'LineWidth', 2, 'MarkerSize', 12);
    end

    set(handles.statusText, 'String', sprintf('\nPoints added'));
    guidata(hObject, handles);


% --- Executes on button press in remove_button.
function remove_button_Callback(hObject, eventdata, handles)
    % hObject    handle to remove_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    global pt1 pt2 ROWS disimg

    tri1 = delaunay(pt1(:,1), pt1(:,2), {'Qt','Qbb','Qc','Qz'});
    tri2 = delaunay(pt2(:,1), pt2(:,2), {'Qt','Qbb','Qc','Qz'});
    
    set(handles.statusText, 'String', sprintf('\nSelect a point to remove'));
    guidata(hObject, handles);
    
    axes(handles.Image_plot);
    [X, Y] = ginput(1);
    if Y < ROWS  % user picked a point in top image
        k = dsearch(pt1(:,1), pt1(:,2), tri1, X, Y);
    else        % user picked a point in bottom image
        k = dsearch(pt2(:,1), pt2(:,2), tri2, X, Y-ROWS);
    end
    
    plot(pt1(k,1), pt1(k,2), 'w*');
    plot(pt2(k,1), ROWS+pt2(k,2), 'w*');
    
    pt1(k,:) = [];  % delete points
    pt2(k,:) = [];   
    
    set(handles.statusText, 'String', sprintf('\nThe corresponding point has been removed'));
    guidata(hObject, handles);


% --- Executes on button press in modify_button.
function modify_button_Callback(hObject, eventdata, handles)
    % hObject    handle to modify_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    global pt1 pt2 ROWS disimg

    tri1 = delaunay(pt1(:,1), pt1(:,2), {'Qt','Qbb','Qc','Qz'});
    tri2 = delaunay(pt2(:,1), pt2(:,2), {'Qt','Qbb','Qc','Qz'});
    
    axes(handles.Image_plot);
    [X, Y] = ginput(1);
    if Y < ROWS  % user picked a point in top image
        k = dsearch(pt1(:,1), pt1(:,2), tri1, X, Y);
        plot(X, Y, 'mX', 'LineWidth', 2);
        top = true;
        set(handles.statusText, 'String', sprintf('\nModify the corresponding point in the bottom image'));
    else        % user picked a point in bottom image
        k = dsearch(pt2(:,1), pt2(:,2), tri2, X, Y-ROWS);
        plot(X, Y, 'mX', 'LineWidth', 2);
        top = false;
        set(handles.statusText, 'String', sprintf('\nModify the corresponding point in the top image'));
    end
    guidata(hObject, handles)
    
    % visually mark which pair points to modify
    plot(pt1(k, 1), pt1(k, 2), 'y*', 'LineWidth', 2);
    plot(pt2(k, 1), ROWS+pt2(k, 2), 'y*', 'LineWidth', 2);
    
    if top
        pt1(k,1) = X;  % replace points
        pt1(k,2) = Y;
        
        % pick corresponding point in bottom image
        [X, Y] = ginput(1);
        pt2(k,1) = X;
        pt2(k,2) = Y-ROWS;
    else
        pt2(k,1) = X;  % replace points
        pt2(k,2) = Y-ROWS;
        
        % pick corresponding point in top image
        [X, Y] = ginput(1);
        pt1(k,1) = X;
        pt1(k,2) = Y;
    end
    plot(X, Y, 'mX', 'LineWidth', 2);

    set(handles.statusText, 'String', sprintf('\nPoints modified'));
    guidata(hObject, handles)


% --- Executes on button press in done_button.
function done_button_Callback(hObject, eventdata, handles)
    % hObject    handle to done_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    global img1 img2 pt1 pt2 filename
    
    answer = questdlg('Are you satisfied with the result and ready to proceed to morphing?', 'Confirmation', 'Yes', 'No', 'No');
    if strcmp(answer, 'Yes')
        answer = questdlg('Do you want to save those points?', '', 'Yes', 'No', 'Yes');
        if strcmp(answer, 'Yes')
            [fname, pname, findex] = uiputfile('*.*', 'Save file name');
            if fname ~= 0
                fname1 = sprintf('%s_1', fname);
                fname2 = sprintf('%s_2', fname);
                save(fname1, 'pt1', '-ascii');
                save(fname2, 'pt2', '-ascii');
            end
        end

        set(handles.statusText, 'String', sprintf('\nMorphing...'));
        guidata(hObject, handles)
        axes(handles.Image_plot);
        clf;
        
        mkdir('images');
        frames = 101;    % it actually generate (frames-1) intermediate views.
        disp(sprintf('Generating %d intermediate views.', frames-1));
        tri = delaunay(pt2(:,1), pt2(:,2), {'Qt','Qbb','Qc','Qz'});
                
        tic
        for t = 1:frames-1
            disp(sprintf('\nComputing frame # %d ...', t));
            Tmorph = morph(img1, img2, pt1, pt2, t/frames, tri);
            imshow(Tmorph);
            drawnow;
            imwrite(Tmorph, sprintf(filename, t), 'jpg');
        end
        toc
        
        delete(gcf)
    end


% --- Executes on button press in update_button.
function update_button_Callback(hObject, eventdata, handles)
    % hObject    handle to update_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    global disimg pt1 pt2 ROWS

    set(handles.statusText, 'String', sprintf('\nUpdating...'));
    guidata(hObject, handles)
        
    axes(handles.Image_plot);
    imshow(disimg);

    [Npt DUMB] = size(pt1);
    cnt = 1;
    while (cnt <= Npt)
        % draw point
        plot(pt1(cnt,1), pt1(cnt,2), 'r*');
        plot(pt2(cnt,1), ROWS+pt2(cnt,2), 'b*');
        drawnow;
        cnt = cnt + 1;
    end

    % update delaunay triangles
    tri1 = delaunay(pt1(:,1), pt1(:,2), {'Qt','Qbb','Qc','Qz'});
    tri2 = delaunay(pt2(:,1), pt2(:,2), {'Qt','Qbb','Qc','Qz'});
    triplot(tri1, pt1(:,1), pt1(:,2), 'g');
    triplot(tri2, pt2(:,1), ROWS+pt2(:,2), 'g');
    
    set(handles.statusText, 'String', sprintf('\nReady'));
    guidata(hObject, handles)

