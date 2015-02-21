function varargout = GUI_Matching_CHistHoG(varargin)
% GUI_MATCHING_CHISTHOG MATLAB code for GUI_Matching_CHistHoG.fig
%      GUI_MATCHING_CHISTHOG, by itself, creates a new GUI_MATCHING_CHISTHOG or raises the existing
%      singleton*.
%
%      H = GUI_MATCHING_CHISTHOG returns the handle to a new GUI_MATCHING_CHISTHOG or the handle to
%      the existing singleton*.
%
%      GUI_MATCHING_CHISTHOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_MATCHING_CHISTHOG.M with the given input arguments.
%
%      GUI_MATCHING_CHISTHOG('Property','Value',...) creates a new GUI_MATCHING_CHISTHOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_Matching_CHistHoG_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_Matching_CHistHoG_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_Matching_CHistHoG

% Last Modified by GUIDE v2.5 21-Feb-2015 17:03:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_Matching_CHistHoG_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_Matching_CHistHoG_OutputFcn, ...
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

% --- Executes just before GUI_Matching_CHistHoG is made visible.
function GUI_Matching_CHistHoG_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_Matching_CHistHoG (see VARARGIN)

% Choose default command line output for GUI_Matching_CHistHoG
handles.output = hObject;

    fimg1='./data/edge_test_amul2.png';
    fimg2='./data/edge_test_mul2.png';
% %     fimg1='./data/lena.png';
% %     fimg2='./data/lena.png';
% %     fimg1='./data/Lines_Various_Angles_resiz.tif';
% %     fimg2='./data/Lines_Various_Angles_resiz.tif';
% %     fimg1='./data/g_test.png';
% %     fimg2='./data/g_test.png';
    
    handles.d = struct();
    handles.d.fimg1=fimg1;
    handles.d.fimg2=fimg2;
    handles.d.imgc1=imread(fimg1);
    handles.d.imgc2=imread(fimg2);
    if ~ismatrix(handles.d.imgc1)
        handles.d.img1=im2double(rgb2gray(handles.d.imgc1));
    else
        handles.d.img1=im2double(handles.d.imgc1);
    end
    if ~ismatrix(handles.d.imgc2)
        handles.d.img2=im2double(rgb2gray(handles.d.imgc2));
    else
        handles.d.img2=im2double(handles.d.imgc2);
    end
    handles.d.imgVis1=handles.d.imgc1;
    handles.d.imgVis2=handles.d.imgc2;
    %
% %     handles.d.paramRad=[1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31];
    handles.d.paramRad=[3,7,11,15,19,23,27,31];
    handles.d.nbinHoG=16;
    handles.d.radNum=numel(handles.d.paramRad);
    handles.d.radMax=handles.d.paramRad(handles.d.radNum);
    handles.d.Thresh=0.9;
    %
    handles.d.dscMapCHist1=[];
    handles.d.dscMapCHist2=[];
    handles.d.dscMapHOG1=[];
    handles.d.dscMapHOG2=[];
    handles.d.ptsQ=[];
    handles.d.ptsF=[];
    handles.d.pts1=[];
    handles.d.pts2=[];
    %
    handles.d.mapDst=[];
    handles.d.mapAng=[];
% Update handles structure
guidata(hObject, handles);
    helperCalcDscMap(hObject);
    helperShowImages(hObject);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using GUI_Matching_CHistHoG.
if strcmp(get(hObject,'Visible'),'off')
    plot(rand(5));
end

% UIWAIT makes GUI_Matching_CHistHoG wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
function ret = helperShowImages(hObject)
    h=guidata(hObject);
    % Query Axes
    lstDscCHist ={};
    lstDscHOG   ={};
    lstDscLegend={};
    lstDscColor ={};
    axes(h.axesImg1);
    cla;
    hTmp=image(h.d.imgVis1, 'CDataMapping', 'scaled');
    set(hTmp,'HitTest','Off');
    set(h.axesImg1,'buttondownfcn',@axesImg1_ButtonDownFcn);
    if ~isempty(h.d.ptsQ)
        tmpRect =[h.d.ptsQ(1)-h.d.radMax, h.d.ptsQ(2)-h.d.radMax, 2*h.d.radMax,2*h.d.radMax];
        tmpRect2=[h.d.ptsQ(1)-5, h.d.ptsQ(2)-5, 2*5,2*5];
        hTmp=rectangle('Position', tmpRect,  'Curvature',[1,1], 'EdgeColor','g', 'LineWidth', 2);
        set(hTmp,'HitTest','Off');
        hTmp=rectangle('Position', tmpRect2, 'Curvature',[1,1], 'EdgeColor','g', 'LineWidth', 2);
        set(hTmp,'HitTest','Off');
        cropImg=imcrop(h.d.imgc1,tmpRect);
        axes(h.axesTQ);
        imshow(cropImg);
        axes(h.axesImg1);
        if (~isempty(h.d.dscMapCHist1)) && (~isempty(h.d.dscMapHOG1))
            posDsc=numel(lstDscCHist)+1;
            lstDscCHist {posDsc}=reshape(h.d.dscMapCHist1(h.d.ptsQ(2), h.d.ptsQ(1), :), 1, []);
            lstDscHOG   {posDsc}=reshape(h.d.dscMapHOG1  (h.d.ptsQ(2), h.d.ptsQ(1), :), 1, []);
            lstDscLegend{posDsc}='Query';
            lstDscColor {posDsc}='g';
        end
    end
    set(h.axesImg1, 'XTickLabel','', 'YTickLabel','');
    % FindResults Axes
    axes(h.axesImg2);
    cla;
    hTmp = image(h.d.imgVis2);
    set(h.axesImg2, 'XTickLabel','', 'YTickLabel','');
    set(hTmp,'HitTest','Off');
    set(h.axesImg2,'buttondownfcn',@axesImg2_ButtonDownFcn);
    if ~isempty(h.d.ptsF)
        tmpRect=[h.d.ptsF(1)-h.d.radMax, h.d.ptsF(2)-h.d.radMax, 2*h.d.radMax,2*h.d.radMax];
        hTmp=rectangle('Position', [h.d.ptsF(1)-5, h.d.ptsF(2)-5, 2*5,2*5],...
            'Curvature',[1,1], 'EdgeColor','r', 'LineWidth', 2);
        set(hTmp,'HitTest','Off');
        hTmp=rectangle('Position', tmpRect,...
            'Curvature',[1,1], 'EdgeColor','r', 'LineWidth', 1);
        cropImg=imcrop(h.d.imgc2,tmpRect);
        axes(h.axesTF);
        imshow(cropImg);
        axes(h.axesImg2);
        if (~isempty(h.d.dscMapCHist2)) && (~isempty(h.d.dscMapHOG2))
            posDsc=numel(lstDscCHist)+1;
            lstDscCHist {posDsc}=reshape(h.d.dscMapCHist2(h.d.ptsF(2), h.d.ptsF(1), :), 1, []);
            lstDscHOG   {posDsc}=reshape(h.d.dscMapHOG2  (h.d.ptsF(2), h.d.ptsF(1), :), 1, []);
            lstDscLegend{posDsc}='Search Result';
            lstDscColor {posDsc}='r';
        end
    end
    if ~isempty(h.d.pts2)
        tmpRect=[h.d.pts2(1)-h.d.radMax, h.d.pts2(2)-h.d.radMax, 2*h.d.radMax,2*h.d.radMax];
        hTmp=rectangle('Position', [h.d.pts2(1)-7, h.d.pts2(2)-7, 2*7,2*7],...
            'Curvature',[1,1], 'EdgeColor','b', 'LineWidth', 2);
        set(hTmp,'HitTest','Off');
        cropImg=imcrop(h.d.imgc2,tmpRect);
        axes(h.axesTC);
        imshow(cropImg);
        axes(h.axesImg2);
        if (~isempty(h.d.dscMapCHist2)) && (~isempty(h.d.dscMapHOG2))
            posDsc=numel(lstDscCHist)+1;
            lstDscCHist {posDsc}=reshape(h.d.dscMapCHist2(h.d.pts2(2), h.d.pts2(1), :), 1, []);
            lstDscHOG   {posDsc}=reshape(h.d.dscMapHOG2  (h.d.pts2(2), h.d.pts2(1), :), 1, []);
            lstDscLegend{posDsc}='Current';
            lstDscColor {posDsc}='b';
        end
    end
    %
    axes(h.axesPlotCHist);
    cla;
    hold on;
    for ii=1:numel(lstDscCHist)
        plot(lstDscCHist{ii}, lstDscColor{ii});
    end
    hold off;
    legend(lstDscLegend);
    %
    axes(h.axesPlotHOG);
    cla;
    hold on;
    for ii=1:numel(lstDscHOG)
        plot(lstDscHOG{ii}, lstDscColor{ii});
    end
    hold off;
    legend(lstDscLegend);
    %
    guidata(hObject, h);
    ret=true;
return

function ret = helperCalcDscMap(hObject)
    h=guidata(hObject);
    hWait=waitbar(0.3, 'Build DSC-Maps...');
    [h.d.dscMapCHist1, h.d.dscMapHOG1 ]=fun_calc_CHistHoG( h.d.img1, h.d.paramRad, h.d.nbinHoG);
    waitbar(0.7,hWait, 'Build DSC-Maps...');
    [h.d.dscMapCHist2, h.d.dscMapHOG2 ]=fun_calc_CHistHoG( h.d.img2, h.d.paramRad, h.d.nbinHoG);
    waitbar(0.9,hWait, 'Build DSC-Maps...');
% %     h.d.dscMapCHist1=rand(size(h.d.img1,1),size(h.d.img1,2),h.d.radNum-1);
% %     h.d.dscMapCHist2=rand(size(h.d.img1,1),size(h.d.img1,2),h.d.radNum-1);
% %     h.d.dscMapHOG1=rand(size(h.d.img1,1),size(h.d.img1,2),h.d.nbinHoG);
% %     h.d.dscMapHOG2=rand(size(h.d.img1,1),size(h.d.img1,2),h.d.nbinHoG);
    guidata(hObject, h);
    close(hWait);
    ret=true;
return

function ret = helperMatchTemplate(hObject)
    h=guidata(hObject);
    if ~isempty(h.d.ptsQ)
        tmpDscQCHist=reshape(h.d.dscMapCHist1(h.d.ptsQ(2), h.d.ptsQ(1), :), 1, []);
        tmpDscQHOG  =reshape(h.d.dscMapHOG1  (h.d.ptsQ(2), h.d.ptsQ(1), :), 1, []);
% %         dstCHist=2-reshape(pdist2(reshape(h.d.dscMapCHist2,[],h.d.radNum-1),tmpDscQCHist),size(h.d.img2,1),size(h.d.img2,2));
% %         dstHOG  =2-reshape(pdist2(reshape(h.d.dscMapHOG2,  [],h.d.nbinHoG ),tmpDscQHOG  ),size(h.d.img2,1),size(h.d.img2,2));
% %         dstAll=dstCHist.*dstHOG;
        [dstAll, dstAng]=fun_calc_dst_CHistHoG(h.d.dscMapCHist2, h.d.dscMapHOG2, tmpDscQCHist, tmpDscQHOG);
        h.d.mapDst=dstAll;
        h.d.mapAng=dstAng;
        vMax=max(dstAll(:));
        vMaxTh=vMax*h.d.Thresh;
        [RR,CC]=find(dstAll==vMax);
        h.d.ptsF=[CC,RR];
        dstAllImg=h.d.imgc2;
        for ii=1:size(h.d.imgc2,3)
            tmp=dstAllImg(:,:,ii);
            if ii==1
                tmp(dstAll>vMaxTh)=255;
            else
                tmp(dstAll>vMaxTh)=0;
            end
            dstAllImg(:,:,ii)=tmp;
        end
        h.d.imgVis2=dstAllImg;
    end
    guidata(hObject, h);
    ret=true;
return

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

% --- Outputs from this function are returned to the command line.
function varargout = GUI_Matching_CHistHoG_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axesImg1);
cla;

popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1
        plot(rand(5));
    case 2
        plot(sin(1:0.01:25.99));
    case 3
        bar(1:.5:10);
    case 4
        plot(membrane);
    case 5
        surf(peaks);
end


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


% --- Executes on button press in pushbuttonQuit.
function pushbuttonQuit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonQuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close;
return


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    disp('Search');
    hWait=waitbar(0.3, 'Searching...');
    helperMatchTemplate(hObject);
    waitbar(0.7, hWait, 'Searching...');
    helperShowImages(hObject);
    close(hWait);
return


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    h=guidata(hObject);
    disp('Show DST-Map');
    if (~isempty(h.d.mapDst)) && (~isempty(h.d.mapAng))
        figure('Name', 'Distance & Angle distribution Map'),
        subplot(1,2,1), imshow(h.d.mapDst,[]), title('Distance Map');
        subplot(1,2,2), imshow(h.d.mapAng,[]), title('Angle-Distribution Map');
    else
        errordlg('Distance map is not calculated. Press SEARCH to build distance map.');
    end
    guidata(hObject,h);
return


% --- Executes on mouse press over axes background.
function axesImg1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axesImg1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    disp('OnClick Axes#1');
    tmpPnt=get(hObject, 'CurrentPoint');
    tmpPnt=round(tmpPnt(1,1:2));
    disp(tmpPnt);
    h=guidata(hObject);
    h.d.ptsQ=tmpPnt;
    set(h.editPosQX, 'String', num2str(tmpPnt(1)));
    set(h.editPosQY, 'String', num2str(tmpPnt(2)));
    guidata(hObject,h);
    helperShowImages(hObject);
return

% --- Executes on mouse press over axes background.
function axesImg2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axesImg2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    disp('OnClick Axes#2');
    tmpPnt=get(hObject, 'CurrentPoint');
    tmpPnt=round(tmpPnt(1,1:2));
    disp(tmpPnt);
    h=guidata(hObject);
    h.d.pts2=tmpPnt;
    set(h.editPosFX, 'String', num2str(tmpPnt(1)));
    set(h.editPosFY, 'String', num2str(tmpPnt(2)));
    guidata(hObject,h);
    helperShowImages(hObject);
return



function editPosQX_Callback(hObject, eventdata, handles)
% hObject    handle to editPosQX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPosQX as text
%        str2double(get(hObject,'String')) returns contents of editPosQX as a double


% --- Executes during object creation, after setting all properties.
function editPosQX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPosQX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPosQY_Callback(hObject, eventdata, handles)
% hObject    handle to editPosQY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPosQY as text
%        str2double(get(hObject,'String')) returns contents of editPosQY as a double


% --- Executes during object creation, after setting all properties.
function editPosQY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPosQY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonPosQ.
function pushbuttonPosQ_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPosQ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    h=guidata(hObject);
    posQX=round(str2double(get(h.editPosQX, 'String')));
    posQY=round(str2double(get(h.editPosQY, 'String')));
    set(h.editPosQX, 'String', num2str(posQX));
    set(h.editPosQY, 'String', num2str(posQY));
    h.d.ptsQ=[posQX, posQY];
    guidata(hObject,h);
    helperShowImages(hObject);
return



function editPosFX_Callback(hObject, eventdata, handles)
% hObject    handle to editPosFX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPosFX as text
%        str2double(get(hObject,'String')) returns contents of editPosFX as a double


% --- Executes during object creation, after setting all properties.
function editPosFX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPosFX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPosFY_Callback(hObject, eventdata, handles)
% hObject    handle to editPosFY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPosFY as text
%        str2double(get(hObject,'String')) returns contents of editPosFY as a double


% --- Executes during object creation, after setting all properties.
function editPosFY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPosFY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonPosF.
function pushbuttonPosF_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPosF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    h=guidata(hObject);
    posFX=round(str2double(get(h.editPosFX, 'String')));
    posFY=round(str2double(get(h.editPosFY, 'String')));
    set(h.editPosFX, 'String', num2str(posFX));
    set(h.editPosFY, 'String', num2str(posFY));
    h.d.pts2=[posFX, posFY];
    guidata(hObject,h);
    helperShowImages(hObject);
return



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSetPosQ.
function pushbuttonSetPosQ_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetPosQ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    h=guidata(hObject);
    h.d.imgVis2=h.d.imgc2;
    guidata(hObject,h);
    helperShowImages(hObject);
return


% --- Executes on button press in pushbuttonQ2F.
function pushbuttonQ2F_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonQ2F (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    h=guidata(hObject);
    set(h.editPosFX,'String', get(h.editPosQX,'String'));
    set(h.editPosFY,'String', get(h.editPosQY,'String'));
    guidata(hObject,h);
return


% --- Executes on button press in pushbuttonF2Q.
function pushbuttonF2Q_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonF2Q (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    h=guidata(hObject);
    set(h.editPosQX,'String', get(h.editPosFX,'String'));
    set(h.editPosQY,'String', get(h.editPosFY,'String'));
    guidata(hObject,h);
return
