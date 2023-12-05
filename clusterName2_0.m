function varargout = clusterName2_0(varargin)
% CLUSTERNAME2_0 MATLAB code for clusterName2_0.fig
%      CLUSTERNAME2_0 by itself, creates a new CLUSTERNAME2_0 or raises the
%      existing singleton*.
%
%      H = CLUSTERNAME2_0 returns the handle to a new CLUSTERNAME2_0 or the handle to
%      the existing singleton*.
%
%      CLUSTERNAME2_0('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLUSTERNAME2_0.M with the given input arguments.
%
%      CLUSTERNAME2_0('Property','Value',...) creates a new CLUSTERNAME2_0 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before clusterName2_0_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to clusterName2_0_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help clusterName2_0

% Last Modified by GUIDE v2.5 30-Oct-2019 15:21:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @clusterName2_0_OpeningFcn, ...
                   'gui_OutputFcn',  @clusterName2_0_OutputFcn, ...
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

% --- Executes just before clusterName2_0 is made visible.
function clusterName2_0_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to clusterName2_0 (see VARARGIN)

% Choose default command line output for clusterName2_0
handles.output = 'Yes';

% Update handles structure
guidata(hObject, handles);

if ~isempty(varargin)
    if isfield(varargin{1}, 'fecha')
        set(handles.fecha_edit,'String', varargin{1}.fecha);
    end
    if isfield(varargin{1}, 'registro')
        set(handles.registro_edit,'String', varargin{1}.registro);
    end
    if isfield(varargin{1}, 'cluster')
        set(handles.cluster_edit,'String', varargin{1}.cluster);
    end
    if isfield(varargin{1}, 'categoria')
        set(handles.categoria_edit,'String', varargin{1}.categoria);
    end
    if isfield(varargin{1}, 'actividad')
        set(handles.actividad_edit,'String', varargin{1}.actividad);
    end
    if isfield(varargin{1}, 'direccional')
        set(handles.direccional_edit,'String', varargin{1}.direccional);
    end
    if isfield(varargin{1}, 'rtaLooming')
        set(handles.rtaLooming_edit,'String', varargin{1}.rtaLooming);
    end
    if isfield(varargin{1}, 'rtaCuadrados')
        set(handles.rtaCuadrados_edit,'String', varargin{1}.rtaCuadrados);
    end
    if isfield(varargin{1}, 'rtaContrastes')
        set(handles.rtaContrastes_edit,'String', varargin{1}.rtaContrastes);
    end
    if isfield(varargin{1}, 'rtaFlujos')
        set(handles.rtaFlujos_edit,'String', varargin{1}.rtaFlujos);
    end
end

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.text1, 'String', varargin{index+1});
        end
    end
end


% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')

% UIWAIT makes clusterName2_0 wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = clusterName2_0_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);

% --- Executes on button press in save_push.
function save_push_Callback(hObject, eventdata, handles)
% hObject    handle to save_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
output.fecha = get(handles.fecha_edit,'String');
output.cluster = get(handles.cluster_edit,'String');
output.registro = get(handles.registro_edit,'String');
output.actividad = get(handles.actividad_edit,'String');
output.categoria = get(handles.categoria_edit,'String');
output.direccional = get(handles.direccional_edit,'String');
output.rtaLooming = get(handles.rtaLooming_edit,'String');
output.rtaFlujos = get(handles.rtaFlujos_edit, 'String');
output.rtaCuadrados = get(handles.rtaCuadrados_edit,'String');
output.rtaContraste = get(handles.rtaContraste_edit,'String');

handles.output = output;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

% --- Executes on button press in cancel_push.
function cancel_push_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = [];

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = 'No';
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.figure1);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.figure1);
end    



function editoutput_Callback(hObject, eventdata, handles)
% hObject    handle to editoutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editoutput as text
%        str2double(get(hObject,'String')) returns contents of editoutput as a double


% --- Executes during object creation, after setting all properties.
function editoutput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editoutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fecha_edit_Callback(hObject, eventdata, handles)
% hObject    handle to fecha_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fecha_edit as text
%        str2double(get(hObject,'String')) returns contents of fecha_edit as a double


% --- Executes during object creation, after setting all properties.
function fecha_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fecha_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function direccional_edit_Callback(hObject, eventdata, handles)
% hObject    handle to direccional_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of direccional_edit as text
%        str2double(get(hObject,'String')) returns contents of direccional_edit as a double


% --- Executes during object creation, after setting all properties.
function direccional_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to direccional_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cluster_edit_Callback(hObject, eventdata, handles)
% hObject    handle to cluster_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cluster_edit as text
%        str2double(get(hObject,'String')) returns contents of cluster_edit as a double


% --- Executes during object creation, after setting all properties.
function cluster_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cluster_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function registro_edit_Callback(hObject, eventdata, handles)
% hObject    handle to registro_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of registro_edit as text
%        str2double(get(hObject,'String')) returns contents of registro_edit as a double


% --- Executes during object creation, after setting all properties.
function registro_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to registro_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rtaLooming_edit_Callback(hObject, eventdata, handles)
% hObject    handle to rtaLooming_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rtaLooming_edit as text
%        str2double(get(hObject,'String')) returns contents of rtaLooming_edit as a double


% --- Executes during object creation, after setting all properties.
function rtaLooming_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rtaLooming_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rtaCuadrados_edit_Callback(hObject, eventdata, handles)
% hObject    handle to rtaCuadrados_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rtaCuadrados_edit as text
%        str2double(get(hObject,'String')) returns contents of rtaCuadrados_edit as a double


% --- Executes during object creation, after setting all properties.
function rtaCuadrados_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rtaCuadrados_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rtaFlujos_edit_Callback(hObject, eventdata, handles)
% hObject    handle to rtaFlujos_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rtaFlujos_edit as text
%        str2double(get(hObject,'String')) returns contents of rtaFlujos_edit as a double


% --- Executes during object creation, after setting all properties.
function rtaFlujos_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rtaFlujos_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rtaContraste_edit_Callback(hObject, eventdata, handles)
% hObject    handle to rtaContraste_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rtaContraste_edit as text
%        str2double(get(hObject,'String')) returns contents of rtaContraste_edit as a double


% --- Executes during object creation, after setting all properties.
function rtaContraste_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rtaContraste_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function actividad_edit_Callback(hObject, eventdata, handles)
% hObject    handle to actividad_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of actividad_edit as text
%        str2double(get(hObject,'String')) returns contents of actividad_edit as a double


% --- Executes during object creation, after setting all properties.
function actividad_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to actividad_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function categoria_edit_Callback(hObject, eventdata, handles)
% hObject    handle to categoria_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of categoria_edit as text
%        str2double(get(hObject,'String')) returns contents of categoria_edit as a double


% --- Executes during object creation, after setting all properties.
function categoria_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to categoria_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
