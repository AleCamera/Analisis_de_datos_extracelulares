function varargout = plottingProperties(varargin)
% PLOTTINGPROPERTIES MATLAB code for plottingProperties.fig
%      PLOTTINGPROPERTIES, by itself, creates a new PLOTTINGPROPERTIES or raises the existing
%      singleton*.
%
%      H = PLOTTINGPROPERTIES returns the handle to a new PLOTTINGPROPERTIES or the handle to
%      the existing singleton*.
%
%      PLOTTINGPROPERTIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTTINGPROPERTIES.M with the given input arguments.
%
%      PLOTTINGPROPERTIES('Property','Value',...) creates a new PLOTTINGPROPERTIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plottingProperties_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plottingProperties_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plottingProperties

% Last Modified by GUIDE v2.5 16-Mar-2020 08:55:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plottingProperties_OpeningFcn, ...
                   'gui_OutputFcn',  @plottingProperties_OutputFcn, ...
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


% --- Executes just before plottingProperties is made visible.
function plottingProperties_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plottingProperties (see VARARGIN)

% Choose default command line output for plottingProperties
handles.output = hObject;
currentProperties = varargin{1};
handles.defaults = currentProperties.defaults;
handles.path = varargin{2};
%cargo los ejemplos 
exampleA = load([handles.path, '/Examples/GroupA.mat']);
exampleB = load([handles.path, '/Examples/GroupB.mat']);
handles.neurons = [exampleA.neurons, exampleB.neurons];
for i = 1:length(exampleA.neurons)
handles.gAList{i} = exampleA.neurons{i}.name;
end
for i = 1:length(exampleB.neurons)
handles.gBList{i} = exampleB.neurons{i}.name;
end
handles.neuronList = [handles.gAList, handles.gBList];
%atualizo el numero de filas y columnas por figura
set(handles.nRowsSPlot_edit, 'String', string(currentProperties.nRows))
set(handles.nColsSPlot_edit, 'String', string(currentProperties.nCols))

%%%%--- Rasters ---%%%%

%actualizo el ancho de linea
set(handles.lineWidth_edit, 'String', string(currentProperties.lineWidth))
%actualizo el tamaño relativo del raster
set(handles.relativeSize_edit, 'String', string(currentProperties.relativeSize))

%actializpo la posicion
switch currentProperties.position
    case 'bottom'
        set(handles.bottom_check, 'Value', true)
        set(handles.top_check, 'Value', false)
    case 'top'
        set(handles.top_check, 'Value', true)
        set(handles.bottom_check, 'Value', false)
end

%actualizo la forma de colorear los rasters en el caso de promedios
switch currentProperties.colorMethod
    case 'uniform'
        set(handles.uniformColorMethod_check, 'Value', true)
        set(handles.scaleColorMethod_check, 'Value', false)
        set(handles.randomColorMethod_check, 'Value', false)
    case 'scale'
        set(handles.uniformColorMethod_check, 'Value', false)
        set(handles.scaleColorMethod_check, 'Value', true)
        set(handles.randomColorMethod_check, 'Value', false)
    case 'random'
        set(handles.uniformColorMethod_check, 'Value', false)
        set(handles.scaleColorMethod_check, 'Value', false)
        set(handles.randomColorMethod_check, 'Value', true)
end

%actualizo los colores del raster
if currentProperties.defaultRasterColor
    color = currentProperties.defaults.raster;
    set(handles.rasterColorR_edit, 'enable', 'off', 'String', string(color(1)))
    set(handles.rasterColorG_edit, 'enable', 'off', 'String', string(color(2)))
    set(handles.rasterColorB_edit, 'enable', 'off', 'String', string(color(3)))
    set(handles.rasterColorSample, 'BackgroundColor', color)
    set(handles.defaultRasterColor_check, 'Value', 1)
else
    set(handles.rasterColorR_edit, 'String', string(currentProperties.raster(1)))
    set(handles.rasterColorG_edit, 'String', string(currentProperties.raster(2)))
    set(handles.rasterColorB_edit, 'String', string(currentProperties.raster(3)))
    set(handles.rasterColorSample, 'BackgroundColor', currentProperties.raster);
end

%%%%--- PSH general ---%%%%

%actualizo si quiero usar el smooteado
if currentProperties.smoothPSH
    set(handles.smoothPSH_check, 'Value', true)
end
%actualizo el smoothing span
set(handles.smoothingSpan_edit, 'String', string(currentProperties.smoothingSpan));

%actualizo si quiero plotear con lineas en ve de barras
if currentProperties.useLinePlot
    set(handles.linePSH_check, 'Value', true)
    if currentProperties.addStdError
        set(handles.addStdError_check, 'Value', true);
    else
        set(handles.addStdError_check, 'Value', false);
    end
else
    set(handles.addStdError_check, 'Value', false, 'enable', 'off');
end

if isempty(currentProperties.stimHeigth)
    set(handles.stimHeigth_edit, 'String', '0.1');
else
    set(handles.stimHeigth_edit, 'String', string(currentProperties.stimHeigth));
end

if currentProperties.fixPSHmaxFreq
    set(handles.fixYaxis_check, 'Value', true);
    set(handles.maxFreqPSH_edit, 'Enable', 'on', 'String', string(currentProperties.maxFreqPSH));
else
    set(handles.fixYaxis_check, 'Value', false);
    set(handles.maxFreqPSH_edit, 'Enable', 'off', 'String', '');
end

%seteo la posición de los estímulos
set(handles.PSHstimUnderPlot_check, 'Value', currentProperties.PSHstimUnderPlot);

%%%%--- PSH grupo A ---%%%%

%actualizo los colores de las barras
if currentProperties.defaultPSHgAfaceColor
    color = currentProperties.defaults.PSHgAface;
    set(handles.PSHgAfaceColorR_edit, 'enable', 'off', 'String', string(color(1)))
    set(handles.PSHgAfaceColorG_edit, 'enable', 'off', 'String', string(color(2)))
    set(handles.PSHgAfaceColorB_edit, 'enable', 'off', 'String', string(color(3)))
    set(handles.PSHgAfaceColorSample, 'BackgroundColor', color);
    set(handles.defaultPSHgAfaceColor_check, 'Value', 1)
else
    color = currentProperties.PSHgAface;
    set(handles.PSHgAfaceColorR_edit, 'String', string(color(1)))
    set(handles.PSHgAfaceColorG_edit, 'String', string(color(2)))
    set(handles.PSHgAfaceColorB_edit, 'String', string(color(3)))
    set(handles.PSHgAfaceColorSample, 'BackgroundColor', color);
end

%actualizo los colores de los bordes de barras
if currentProperties.defaultPSHgAedgeColor
    color = currentProperties.defaults.PSHgAedge;
    set(handles.PSHgAedgeColorR_edit, 'enable', 'off', 'String', string(color(1)))
    set(handles.PSHgAedgeColorG_edit, 'enable', 'off', 'String', string(color(2)))
    set(handles.PSHgAedgeColorB_edit, 'enable', 'off', 'String', string(color(3)))
    set(handles.PSHgAedgeColorSample, 'BackgroundColor', color);
    set(handles.defaultPSHgAedgeColor_check, 'Value', true)
else
    color = currentProperties.PSHgAedge;
    set(handles.PSHgAedgeColorR_edit, 'String', string(color(1)))
    set(handles.PSHgAedgeColorG_edit, 'String', string(color(2)))
    set(handles.PSHgAedgeColorB_edit, 'String', string(color(3)))
    set(handles.PSHgAedgeColorSample, 'BackgroundColor', color);
end

%%%%--- PSH grupo B ---%%%%

%actualizo los colores de las barras
if currentProperties.defaultPSHgBfaceColor
    color = currentProperties.defaults.PSHgBface;
    set(handles.PSHgBfaceColorR_edit, 'enable', 'off', 'String', string(color(1)))
    set(handles.PSHgBfaceColorG_edit, 'enable', 'off', 'String', string(color(2)))
    set(handles.PSHgBfaceColorB_edit, 'enable', 'off', 'String', string(color(3)))
    set(handles.PSHgBfaceColorSample, 'BackgroundColor', color);
    set(handles.defaultPSHgBfaceColor_check, 'Value', true)
else
    color = currentProperties.PSHgBface;
    set(handles.PSHgBfaceColorR_edit, 'String', string(color(1)))
    set(handles.PSHgBfaceColorG_edit, 'String', string(color(2)))
    set(handles.PSHgBfaceColorB_edit, 'String', string(color(3)))
    set(handles.PSHgBfaceColorSample, 'BackgroundColor', color);
end

%actualizo los colores de los bordes de barras
if currentProperties.defaultPSHgBedgeColor
    color = currentProperties.defaults.PSHgBedge;
    set(handles.PSHgBedgeColorR_edit, 'enable', 'off', 'String', string(color(1)))
    set(handles.PSHgBedgeColorG_edit, 'enable', 'off', 'String', string(color(2)))
    set(handles.PSHgBedgeColorB_edit, 'enable', 'off', 'String', string(color(3)))
    set(handles.PSHgBedgeColorSample, 'BackgroundColor', color);
    set(handles.defaultPSHgBedgeColor_check, 'Value', 1)
else
    color = currentProperties.PSHgBedge;
    set(handles.PSHgBedgeColorR_edit, 'String', string(color(1)))
    set(handles.PSHgBedgeColorG_edit, 'String', string(color(2)))
    set(handles.PSHgBedgeColorB_edit, 'String', string(color(3)))
    set(handles.PSHgBedgeColorSample, 'BackgroundColor', color);
end

%%%%--- Correlograms ---%%%%

%actualizo las opciones del tipo de correlograma
if currentProperties.useLoadedCorrelograms
    set(handles.loadedCorrelograms_check, 'Value', true);
    set(handles.useSpontaneousCorrelogram_check, 'Value', false, 'Enable', 'off');
    set(handles.useStimIntervals_check, 'Value', false, 'Enable', 'off');
else
    set(handles.loadedCorrelograms_check, 'Value', false);
    set(handles.useSpontaneousCorrelogram_check, 'Value', currentProperties.useSpontaneousCorrelograms, 'Enable', 'on');
    set(handles.useStimIntervals_check, 'Value', currentProperties.useStimCorrelograms, 'Enable', 'on');
end

%actualizo el color de las barras
if currentProperties.defaultCorrelBarColor
    color = currentProperties.defaults.correlBarColor;
    set(handles.correlBarColorR_edit, 'enable', 'off', 'String', string(color(1)))
    set(handles.correlBarColorG_edit, 'enable', 'off', 'String', string(color(2)))
    set(handles.correlBarColorB_edit, 'enable', 'off', 'String', string(color(3)))
    set(handles.CorrelBarSample, 'BackgroundColor', color);
    set(handles.defaultCorrelBarColor_check, 'Value', true)
else
    color = currentProperties.correlBarColor;
    set(handles.correlBarColorR_edit, 'String', string(color(1)))
    set(handles.correlBarColorG_edit, 'String', string(color(2)))
    set(handles.correlBarColorB_edit, 'String', string(color(3)))
    set(handles.CorrelBarSample, 'BackgroundColor', color);
end

%actualizo el color de las lineas
if currentProperties.defaultCorrelLineColor
    color = currentProperties.defaults.correlLineColor;
    set(handles.correlLineColorR_edit, 'enable', 'off', 'String', string(color(1)))
    set(handles.correlLineColorG_edit, 'enable', 'off', 'String', string(color(2)))
    set(handles.correlLineColorB_edit, 'enable', 'off', 'String', string(color(3)))
    set(handles.CorrelLineSample, 'BackgroundColor', color);
    set(handles.defaultCorrelLineColor_check, 'Value', true)
else
    color = currentProperties.correlLineColor;
    set(handles.correlLineColorR_edit, 'String', string(color(1)))
    set(handles.correlLineColorG_edit, 'String', string(color(2)))
    set(handles.correlLineColorB_edit, 'String', string(color(3)))
    set(handles.CorrelLineSample, 'BackgroundColor', color);
end

%actualizo si es probabilistico o por conteo
set(handles.probabilisticCorrelogram_check, 'Value', currentProperties.useProbabilisticCorrelograms)

set(handles.correlogramWidth_edit, 'String', string(currentProperties.correlogramWidth));
set(handles.correlogramBin_edit, 'String', string(currentProperties.correlogramBin));


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plottingProperties wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = plottingProperties_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes during object creation, after setting all properties.
function rasterColorR_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rasterColorR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function relativeSize_edit_Callback(hObject, eventdata, handles)
if isempty(get(hObject, 'String'))||...
        isnan(str2double(get(hObject, 'String'))) ||...
        1 < str2double(get(hObject, 'String')) ||...
        0 > str2double(get(hObject, 'String'))
    set(hObject, 'String', '0.3')
end


% --- Executes during object creation, after setting all properties.
function relativeSize_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to relativeSize_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lineWidth_edit_Callback(hObject, eventdata, handles)
if isempty(get(hObject, 'String'))||...
        isnan(str2double(get(hObject, 'String'))) ||...
        0 > str2double(get(hObject, 'String'))
    set(hObject, 'String', '0.1')
end


% --- Executes during object creation, after setting all properties.
function lineWidth_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lineWidth_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function rasterColorR_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.rasterColorR_edit, 'String'));
G = str2double(get(handles.rasterColorG_edit, 'String'));
B = str2double(get(handles.rasterColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.rasterColorSample, 'BackgroundColor', sampleColor);


function rasterColorG_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.rasterColorR_edit, 'String'));
G = str2double(get(handles.rasterColorG_edit, 'String'));
B = str2double(get(handles.rasterColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.rasterColorSample, 'BackgroundColor', sampleColor);


% --- Executes during object creation, after setting all properties.
function rasterColorG_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rasterColorG_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rasterColorB_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.rasterColorR_edit, 'String'));
G = str2double(get(handles.rasterColorG_edit, 'String'));
B = str2double(get(handles.rasterColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.rasterColorSample, 'BackgroundColor', sampleColor);


% --- Executes during object creation, after setting all properties.
function rasterColorB_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rasterColorB_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PSHgAfaceColorR_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.PSHgAfaceColorR_edit, 'String'));
G = str2double(get(handles.PSHgAfaceColorG_edit, 'String'));
B = str2double(get(handles.PSHgAfaceColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.PSHgAfaceColorSample, 'BackgroundColor', sampleColor);


% --- Executes during object creation, after setting all properties.
function PSHgAfaceColorR_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSHgAfaceColorR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PSHgAfaceColorG_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.PSHgAfaceColorR_edit, 'String'));
G = str2double(get(handles.PSHgAfaceColorG_edit, 'String'));
B = str2double(get(handles.PSHgAfaceColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.PSHgAfaceColorSample, 'BackgroundColor', sampleColor);


% --- Executes during object creation, after setting all properties.
function PSHgAfaceColorG_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSHgAfaceColorG_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PSHgAfaceColorB_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.PSHgAfaceColorR_edit, 'String'));
G = str2double(get(handles.PSHgAfaceColorG_edit, 'String'));
B = str2double(get(handles.PSHgAfaceColorB_edit, 'String'));


sampleColor = [R G B];
set(handles.PSHgAfaceColorSample, 'BackgroundColor', sampleColor);


% --- Executes during object creation, after setting all properties.
function PSHgAfaceColorB_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSHgAfaceColorB_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PSHgAedgeColorR_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.PSHgAedgeColorR_edit, 'String'));
G = str2double(get(handles.PSHgAedgeColorG_edit, 'String'));
B = str2double(get(handles.PSHgAedgeColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.PSHgAedgeColorSample, 'BackgroundColor', sampleColor);


% --- Executes during object creation, after setting all properties.
function PSHgAedgeColorR_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSHgAedgeColorR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PSHgAedgeColorG_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.PSHgAedgeColorR_edit, 'String'));
G = str2double(get(handles.PSHgAedgeColorG_edit, 'String'));
B = str2double(get(handles.PSHgAedgeColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.PSHgAedgeColorSample, 'BackgroundColor', sampleColor);


% --- Executes during object creation, after setting all properties.
function PSHgAedgeColorG_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSHgAedgeColorG_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PSHgAedgeColorB_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.PSHgAedgeColorR_edit, 'String'));
G = str2double(get(handles.PSHgAedgeColorG_edit, 'String'));
B = str2double(get(handles.PSHgAedgeColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.PSHgAedgeColorSample, 'BackgroundColor', sampleColor);


% --- Executes during object creation, after setting all properties.
function PSHgAedgeColorB_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSHgAedgeColorB_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in defaultRasterColor_check.
function defaultRasterColor_check_Callback(hObject, eventdata, handles)
if get(handles.defaultRasterColor_check, 'Value')
    color = handles.defaults.raster;
    set(handles.rasterColorR_edit, 'enable', 'off', 'String', string(color(1)))
    set(handles.rasterColorG_edit, 'enable', 'off', 'String', string(color(2)))
    set(handles.rasterColorB_edit, 'enable', 'off', 'String', string(color(3)))
    set(handles.rasterColorSample, 'BackgroundColor', color)
else
    set(handles.rasterColorR_edit, 'enable', 'on')
    set(handles.rasterColorG_edit, 'enable', 'on')
    set(handles.rasterColorB_edit, 'enable', 'on')
end



% --- Executes on button press in defaultPSHgAfaceColor_check.
function defaultPSHgAfaceColor_check_Callback(hObject, eventdata, handles)
if get(handles.defaultPSHgAfaceColor_check, 'Value')
    color = handles.defaults.PSHgAface;
    set(handles.PSHgAfaceColorR_edit, 'enable', 'off', 'String', string(color(1)))
    set(handles.PSHgAfaceColorG_edit, 'enable', 'off', 'String', string(color(2)))
    set(handles.PSHgAfaceColorB_edit, 'enable', 'off', 'String', string(color(3)))
    set(handles.PSHgAfaceColorSample, 'BackgroundColor', color);
else
    set(handles.PSHgAfaceColorR_edit, 'enable', 'on')
    set(handles.PSHgAfaceColorG_edit, 'enable', 'on')
    set(handles.PSHgAfaceColorB_edit, 'enable', 'on')
end


% --- Executes on button press in defaultPSHgAedgeColor_check.
function defaultPSHgAedgeColor_check_Callback(hObject, eventdata, handles)
if get(handles.defaultPSHgAedgeColor_check, 'Value')
    color = handles.defaults.PSHgAedge;
    set(handles.PSHgAedgeColorR_edit, 'enable', 'off', 'String', string(color(1)))
    set(handles.PSHgAedgeColorG_edit, 'enable', 'off', 'String', string(color(2)))
    set(handles.PSHgAedgeColorB_edit, 'enable', 'off', 'String', string(color(3)))
    set(handles.PSHgAedgeColorSample, 'BackgroundColor', color);
else
    set(handles.PSHgAedgeColorR_edit, 'enable', 'on')
    set(handles.PSHgAedgeColorG_edit, 'enable', 'on')
    set(handles.PSHgAedgeColorB_edit, 'enable', 'on')
end


% --- Executes on button press in save_push.
function save_push_Callback(hObject, eventdata, handles)

if get(handles.top_check, 'Value')
    newSettings.position = 'top';
elseif get(handles.bottom_check, 'Value')
    newSettings.position = 'bottom';
else
    newSettings.position = 'default';
end

newSettings.defaultRasterColor = get(handles.defaultRasterColor_check, 'Value');
newSettings.raster = [str2double(get(handles.rasterColorR_edit, 'String')) ...
    str2double(get(handles.rasterColorG_edit, 'String')) ...
    str2double(get(handles.rasterColorB_edit, 'String'))];


newSettings.defaultPSHgAfaceColor = get(handles.defaultPSHgAfaceColor_check, 'Value');
newSettings.PSHgAface = [str2double(get(handles.PSHgAfaceColorR_edit, 'String')) ...
    str2double(get(handles.PSHgAfaceColorG_edit, 'String')) ...
	str2double(get(handles.PSHgAfaceColorB_edit, 'String'))];

newSettings.defaultPSHgAedgeColor = get(handles.defaultPSHgAedgeColor_check, 'Value');
newSettings.PSHgAedge = [str2double(get(handles.PSHgAedgeColorR_edit, 'String')) ...
	str2double(get(handles.PSHgAedgeColorG_edit, 'String')) ...
	str2double(get(handles.PSHgAedgeColorB_edit, 'String'))];

newSettings.defaultPSHgBfaceColor = get(handles.defaultPSHgBfaceColor_check, 'Value');
newSettings.PSHgBface = [str2double(get(handles.PSHgBfaceColorR_edit, 'String')) ...
    str2double(get(handles.PSHgBfaceColorG_edit, 'String')) ...
	str2double(get(handles.PSHgBfaceColorB_edit, 'String'))];

newSettings.defaultPSHgBedgeColor = get(handles.defaultPSHgBedgeColor_check, 'Value');
newSettings.PSHgBedge = [str2double(get(handles.PSHgBedgeColorR_edit, 'String')) ...
	str2double(get(handles.PSHgBedgeColorG_edit, 'String')) ...
	str2double(get(handles.PSHgBedgeColorB_edit, 'String'))];

newSettings.defaultCorrelBarColor = get(handles.defaultCorrelBarColor_check, 'Value');
newSettings.correlBarColor = [str2double(get(handles.correlBarColorR_edit, 'String')) ...
	str2double(get(handles.correlBarColorG_edit, 'String')) ...
	str2double(get(handles.correlBarColorB_edit, 'String'))];

newSettings.defaultCorrelLineColor = get(handles.defaultCorrelLineColor_check, 'Value');
newSettings.correlLineColor = [str2double(get(handles.correlLineColorR_edit, 'String')) ...
	str2double(get(handles.correlLineColorG_edit, 'String')) ...
	str2double(get(handles.correlLineColorB_edit, 'String'))];

newSettings.defaults = handles.defaults;

if get(handles.scaleColorMethod_check, 'Value')
    newSettings.colorMethod = 'scale';
elseif get(handles.randomColorMethod_check, 'Value')
    newSettings.colorMethod = 'random';
else
    newSettings.colorMethod = 'uniform';
end
newSettings.lineWidth = str2double(get(handles.lineWidth_edit, 'String'));
newSettings.relativeSize = str2double(get(handles.relativeSize_edit, 'String'));
newSettings.nCols = str2double(get(handles.nColsSPlot_edit, 'String'));
newSettings.nRows = str2double(get(handles.nRowsSPlot_edit, 'String'));
newSettings.smoothPSH = get(handles.smoothPSH_check, 'Value');
newSettings.smoothingSpan = str2double(get(handles.smoothingSpan_edit, 'String'));
newSettings.useLinePlot = get(handles.linePSH_check, 'Value');
newSettings.addStdError = get(handles.addStdError_check, 'Value');
newSettings.stimHeigth = str2double(get(handles.stimHeigth_edit, 'String'));
newSettings.fixPSHmaxFreq = get(handles.fixYaxis_check, 'Value');
newSettings.maxFreqPSH = str2double(get(handles.maxFreqPSH_edit, 'String'));
newSettings.useLoadedCorrelograms = get(handles.loadedCorrelograms_check, 'Value');
newSettings.useStimCorrelograms =  get(handles.useStimIntervals_check, 'Value');
newSettings.useSpontaneousCorrelograms =  get(handles.useSpontaneousCorrelogram_check, 'Value');
newSettings.smoothCorrelogram = get(handles.smoothCorrelogram_check, 'Value');
newSettings.spanCorrelogram  = str2double(get(handles.spanCorrelogram_edit, 'String'));
newSettings.useProbabilisticCorrelograms = get(handles.probabilisticCorrelogram_check, 'Value');
newSettings.correlogramWidth = str2double(get(handles.correlogramWidth_edit, 'String'));
newSettings.correlogramBin = str2double(get(handles.correlogramBin_edit, 'String'));
newSettings.PSHstimUnderPlot = get(handles.PSHstimUnderPlot_check, 'Value');

save([handles.path, '/plotSettings'], '-struct', 'newSettings');



% --- Executes on button press in top_check.
function top_check_Callback(hObject, eventdata, handles)
if get(handles.top_check, 'Value')
    set(handles.bottom_check, 'Value', 0)
end


% --- Executes on button press in bottom_check.
function bottom_check_Callback(hObject, eventdata, handles)
if get(handles.bottom_check, 'Value')
    set(handles.top_check, 'Value', 0)
end


% --- Executes on button press in gAexample_push.
function gAexample_push_Callback(hObject, eventdata, handles)
cla(handles.examplePlot)

groupList = handles.gAList;

if get(handles.top_check, 'Value')
    position = 'top';
elseif get(handles.bottom_check, 'Value')
    position = 'bottom';
else
    position = 'default';
end

rasterColor = [str2double(get(handles.rasterColorR_edit, 'String')) ...
    str2double(get(handles.rasterColorG_edit, 'String')) ...
    str2double(get(handles.rasterColorB_edit, 'String'))];

PSHgAface = [str2double(get(handles.PSHgAfaceColorR_edit, 'String')) ...
    str2double(get(handles.PSHgAfaceColorG_edit, 'String')) ...
	str2double(get(handles.PSHgAfaceColorB_edit, 'String'))];

PSHgAedge = [str2double(get(handles.PSHgAedgeColorR_edit, 'String')) ...
	str2double(get(handles.PSHgAedgeColorG_edit, 'String')) ...
	str2double(get(handles.PSHgAedgeColorB_edit, 'String'))];
%cargo los settings de ploteo
vargs = {'RasterColor', rasterColor,...
    'Position', position,...
    'LineWidth', str2double(get(handles.lineWidth_edit, 'String')), ...
    'RelativeSize', str2double(get(handles.relativeSize_edit, 'String')), ...
    'PSHcolor', PSHgAface, ...
    'PSHedgeColor', PSHgAedge,...
    'smooth', get(handles.smoothPSH_check,'Value'),...
    'useLinePlot', get(handles.linePSH_check, 'Value')};

groupColor = 'A'; %color del PSH


plotPSHwithRasters_forPlotttingProperties(handles, groupList{1}, groupColor, vargs{:})



% --- Executes on button press in gBexample_push.
function gBexample_push_Callback(hObject, eventdata, handles)
cla(handles.examplePlot)

groupList = handles.gBList;

if get(handles.top_check, 'Value')
    position = 'top';
elseif get(handles.bottom_check, 'Value')
    position = 'bottom';
else
    position = 'default';
end

rasterColor = [str2double(get(handles.rasterColorR_edit, 'String')) ...
    str2double(get(handles.rasterColorG_edit, 'String')) ...
    str2double(get(handles.rasterColorB_edit, 'String'))];

PSHgBface = [str2double(get(handles.PSHgBfaceColorR_edit, 'String')) ...
    str2double(get(handles.PSHgBfaceColorG_edit, 'String')) ...
	str2double(get(handles.PSHgBfaceColorB_edit, 'String'))];

PSHgBedge = [str2double(get(handles.PSHgBedgeColorR_edit, 'String')) ...
	str2double(get(handles.PSHgBedgeColorG_edit, 'String')) ...
	str2double(get(handles.PSHgBedgeColorB_edit, 'String'))];
%cargo los settings de ploteo
vargs = {'RasterColor', rasterColor,...
    'Position', position,...
    'LineWidth', str2double(get(handles.lineWidth_edit, 'String')), ...
    'RelativeSize', str2double(get(handles.relativeSize_edit, 'String')), ...
    'PSHcolor', PSHgBface, ...
    'PSHedgeColor', PSHgBedge,...
    'smooth', get(handles.smoothPSH_check,'Value'),...
    'useLinePlot', get(handles.linePSH_check, 'Value')};
groupColor = 'B'; %color del PSH


plotPSHwithRasters_forPlotttingProperties(handles, groupList{1}, groupColor, vargs{:})


% --- Executes on button press in compareExample_push.
function compareExample_push_Callback(hObject, eventdata, handles)
axis(handles.examplePlot);
cla;

%cargo ambas listas
gAList = handles.gAList;
gBList = handles.gBList;

%levanto la lista de estimulos
params.stimCodes = 2;

%levanto los monitores
params.mDerecho = true;
params.mIzquierdo = true;

%levanto los tiempos
params.tPre = 2;
params.tPost = 5;

%Tambien cargo el tamaño de bins calculo el número de bins que necesito

if get(handles.smoothPSH_check, 'Value')
    params.binSize = 25;
else
    params.binSize = 100;
end
params.nBins = round((params.tPre + params.tPost)*(1000/params.binSize));

%los del face color del PSH del grupo A 
PSHgAface = [str2double(get(handles.PSHgAfaceColorR_edit, 'String')) ...
    str2double(get(handles.PSHgAfaceColorG_edit, 'String')) ...
	str2double(get(handles.PSHgAfaceColorB_edit, 'String'))];
%los del edge color del PSH del grupo A 
PSHgAedge = [str2double(get(handles.PSHgAedgeColorR_edit, 'String')) ...
	str2double(get(handles.PSHgAedgeColorG_edit, 'String')) ...
	str2double(get(handles.PSHgAedgeColorB_edit, 'String'))];


%los del face color del PSH del grupo B
PSHgBface = [str2double(get(handles.PSHgBfaceColorR_edit, 'String')) ...
    str2double(get(handles.PSHgBfaceColorG_edit, 'String')) ...
	str2double(get(handles.PSHgBfaceColorB_edit, 'String'))];

%los del edge color del PSH del grupo B
PSHgBedge = [str2double(get(handles.PSHgBedgeColorR_edit, 'String')) ...
	str2double(get(handles.PSHgBedgeColorG_edit, 'String')) ...
	str2double(get(handles.PSHgBedgeColorB_edit, 'String'))];

%cargo la posicion
if get(handles.top_check, 'Value')
    position = 'top';
else
    position = 'bottom';
end

%checkeo si pedi agregar los rasters
addRasters = true;

gAmean = getMeanPSH(handles, gAList, params);
gBmean = getMeanPSH(handles, gBList, params);
stims = [gAmean.stims; gBmean.stims];
%calculo la frecuencia promedio de cada grupo para cada tiempo
[gAfreq,~] = SyncHist(gAmean.raster, gAmean.index,'mode', 'mean' ...
    ,'durations',[-params.tPre; params.tPost], 'nBins', params.nBins);
%gAfreq = gAfreq/gAmean.nEffectiveNeurons;
[gBfreq,~] = SyncHist(gBmean.raster, gBmean.index,'mode', 'mean' ...
    ,'durations',[-params.tPre; params.tPost], 'nBins', params.nBins);
%gBfreq = gBfreq/gBmean.nEffectiveNeurons;
freq = [gAfreq' ;gBfreq']';
if get(handles.smoothPSH_check, 'Value')
    freq(:,1) = smooth(freq(:,1), params.binSize/2);
    freq(:,2) = smooth(freq(:,2), params.binSize/2);
end
%normalizo las frecuencias
%busco el valor maximo entre ambos
maxFreq = max(freq);
%normalizo al máximo correspondiente
freq(:,1) = freq(:,1)/maxFreq(1);
freq(:,2) =  freq(:,2)/maxFreq(2);

%armo el vector de tiempos
t = -params.tPre:(params.tPre+params.tPost)/(params.nBins-1):params.tPost;
%plot(t, freq)
vargs = {'PlotLines', get(handles.linePSH_check, 'Value'), 'Color', {PSHgAface, PSHgBface}};
hPlot = plotPSH(freq, t, stims, params.tPre, params.tPost, '', vargs{:});
if ~get(handles.linePSH_check, 'Value')
    setAesthetics(hPlot(1), 'FaceColor', PSHgAface, ...
        'EdgeColor', PSHgAedge);
    setAesthetics(hPlot(2), 'FaceColor', PSHgBface, ...
        'EdgeColor', PSHgBedge);
end
ylabel('actividad normalizada')

%si elegi agregar los rasters
if addRasters
    nTrialsgA = max(gAmean.index);
    nTrialsgB = max(gBmean.index);
    gAcolorList = cell(1,nTrialsgA);
    gBcolorList  = cell(1,nTrialsgB);
    color = PSHgAface;
    for trial = 1:nTrialsgA
        gAcolorList{trial} = color;
    end
    color = PSHgBface;
    for trial = 1:nTrialsgB
        gBcolorList{trial} = color;
    end
    colorList = flip([gAcolorList, gBcolorList]);
    allRaster = [gAmean.raster ; gBmean.raster];
    allIndex = [gAmean.index ;  (gBmean.index + max(gAmean.index))];
    times = [-params.tPre, params.tPost];
    vargs = {'colorList', colorList,...
        'Position', position,...
        'LineWidth', str2double(get(handles.lineWidth_edit, 'String')), ...
        'RelativeSize',str2double(get(handles.relativeSize_edit, 'String'))};
    
    PlotRasters_oneColor(allRaster, allIndex, times,max(max(freq)), vargs{:})
end

legend('group A', 'group B')

% --- Executes on button press in defaultPSHgBedgeColor_check.
function defaultPSHgBedgeColor_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    color = handles.defaults.PSHgBedge;
    set(handles.PSHgBedgeColorR_edit, 'enable', 'off', 'String', string(color(1)))
    set(handles.PSHgBedgeColorG_edit, 'enable', 'off', 'String', string(color(2)))
    set(handles.PSHgBedgeColorB_edit, 'enable', 'off', 'String', string(color(3)))
    set(handles.PSHgBedgeColorSample, 'BackgroundColor', color);
else
    set(handles.PSHgBedgeColorR_edit, 'enable', 'on')
    set(handles.PSHgBedgeColorG_edit, 'enable', 'on')
    set(handles.PSHgBedgeColorB_edit, 'enable', 'on')
end


% --- Executes on button press in defaultPSHgBfaceColor_check.
function defaultPSHgBfaceColor_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')   
    color = handles.defaults.PSHgBface;
    set(handles.PSHgBfaceColorR_edit, 'enable', 'off', 'String', string(color(1)))
    set(handles.PSHgBfaceColorG_edit, 'enable', 'off', 'String', string(color(2)))
    set(handles.PSHgBfaceColorB_edit, 'enable', 'off', 'String', string(color(3)))
    set(handles.PSHgBfaceColorSample, 'BackgroundColor', color);
else
    set(handles.PSHgBfaceColorR_edit, 'enable', 'on')
    set(handles.PSHgBfaceColorG_edit, 'enable', 'on')
    set(handles.PSHgBfaceColorB_edit, 'enable', 'on')
end


function PSHgBedgeColorB_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.PSHgBedgeColorR_edit, 'String'));
G = str2double(get(handles.PSHgBedgeColorG_edit, 'String'));
B = str2double(get(handles.PSHgBedgeColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.PSHgBedgeColorSample, 'BackgroundColor', sampleColor);


% --- Executes during object creation, after setting all properties.
function PSHgBedgeColorB_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSHgBedgeColorB_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PSHgBedgeColorG_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.PSHgBedgeColorR_edit, 'String'));
G = str2double(get(handles.PSHgBedgeColorG_edit, 'String'));
B = str2double(get(handles.PSHgBedgeColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.PSHgBedgeColorSample, 'BackgroundColor', sampleColor);

% --- Executes during object creation, after setting all properties.
function PSHgBedgeColorG_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSHgBedgeColorG_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PSHgBedgeColorR_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.PSHgBedgeColorR_edit, 'String'));
G = str2double(get(handles.PSHgBedgeColorG_edit, 'String'));
B = str2double(get(handles.PSHgBedgeColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.PSHgBedgeColorSample, 'BackgroundColor', sampleColor);

% --- Executes during object creation, after setting all properties.
function PSHgBedgeColorR_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSHgBedgeColorR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PSHgBfaceColorB_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.PSHgBfaceColorR_edit, 'String'));
G = str2double(get(handles.PSHgBfaceColorG_edit, 'String'));
B = str2double(get(handles.PSHgBfaceColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.PSHgBfaceColorSample, 'BackgroundColor', sampleColor);

% --- Executes during object creation, after setting all properties.
function PSHgBfaceColorB_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSHgBfaceColorB_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PSHgBfaceColorG_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.PSHgBfaceColorR_edit, 'String'));
G = str2double(get(handles.PSHgBfaceColorG_edit, 'String'));
B = str2double(get(handles.PSHgBfaceColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.PSHgBfaceColorSample, 'BackgroundColor', sampleColor);


% --- Executes during object creation, after setting all properties.
function PSHgBfaceColorG_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSHgBfaceColorG_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PSHgBfaceColorR_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.PSHgBfaceColorR_edit, 'String'));
G = str2double(get(handles.PSHgBfaceColorG_edit, 'String'));
B = str2double(get(handles.PSHgBfaceColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.PSHgBfaceColorSample, 'BackgroundColor', sampleColor);


% --- Executes during object creation, after setting all properties.
function PSHgBfaceColorR_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSHgBfaceColorR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in uniformColorMethod_check.
function uniformColorMethod_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.scaleColorMethod_check, 'Value', 0)
    set(handles.randomColorMethod_check, 'Value', 0)
end


% --- Executes on button press in scaleColorMethod_check.
function scaleColorMethod_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.uniformColorMethod_check, 'Value', 0)
    set(handles.randomColorMethod_check, 'Value', 0)
end


% --- Executes on button press in randomColorMethod_check.
function randomColorMethod_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.scaleColorMethod_check, 'Value', 0)
    set(handles.uniformColorMethod_check, 'Value', 0)
end



function nRowsSPlot_edit_Callback(hObject, eventdata, handles)
n = str2double(get(hObject, 'String'));
if isnan(n) || 1 > n
    set(hObject, 'String', '1');
else
    set(hObject, 'String', string(round(n)))
end


% --- Executes during object creation, after setting all properties.
function nRowsSPlot_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nRowsSPlot_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nColsSPlot_edit_Callback(hObject, eventdata, handles)
n = str2double(get(hObject, 'String'));
if isnan(n) || 1 > n
    set(hObject, 'String', '1');
else
    set(hObject, 'String', string(round(n)))
end

% --- Executes during object creation, after setting all properties.
function nColsSPlot_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nColsSPlot_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in smoothPSH_check.
function smoothPSH_check_Callback(hObject, eventdata, handles)
% hObject    handle to smoothPSH_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of smoothPSH_check


% --- Executes on button press in linePSH_check.
function linePSH_check_Callback(hObject, eventdata, handles)
if ~get(hObject, 'Value')
    set(handles.addStdError_check, 'Value', false, 'enable', 'off') 
else
    set(handles.addStdError_check, 'enable', 'on')
end


function plotPSHwithRasters_forPlotttingProperties(handles, list, group, varargin)
%levanto la lista de estimulos
stimCodes = 2;
%Default arguments
rasterColor = [0 0 0];
lineWidth = 0.1;
position = 'bottom';
relativeSize = 0.4;
PSHface = 'default';
PSHedge = 'default';
smoothPSh = false;
useLinePlot = false;
for arg = 1:2:length(varargin)
    switch lower(varargin{arg})
        case 'rastercolor'
            rasterColor = varargin{arg+1};
        case 'linewidth'
            lineWidth = varargin{arg+1};
        case 'position'
            if strcmp(varargin{arg+1}, 'default')
                continue
            end
            position = varargin{arg+1};
            if ~strcmp(position, 'bottom') && ~strcmp(position, 'top')
                error('la posicion solo puede ser "top", "bottom" o "default"')
            end
        case 'relativesize'
            relativeSize = varargin{arg+1};
            if relativeSize >= 1 || relativeSize <= 0
                error('relativeSize sólo puede tomar valores entre 0 y 1')
            end
        case 'pshcolor'
            PSHface = varargin{arg+1};
        case 'pshedgecolor'
            PSHedge = varargin{arg+1};
        case 'smooth'
            smoothPSH = varargin{arg+1};
        case 'uselineplot'
            useLinePlot = varargin{arg+1};
    end
end



%levanto los monitores
mDerecho = true;
mIzquierdo = true;

%levanto los tiempos
tPre = 2;
tPost = 5;

%Tambien cargo el tamaño de bins calculo el número de bins que necesito
binSize = 100;
if smoothPSH
    binSize = 25;
end
nBins = round((tPre + tPost)*(1000/binSize));

%ahora veo que neuronas voy a plotear
neuronList = handles.neuronList;
%neuronIndex va a guardar los indices de handles.neuron donde estan las
%neuronas seleccioadas

neuronIndex = find(strcmp(neuronList, list));

%doy vueltas en el loop mientas que haya neuronas sin plotear
%cargo la lista de todos los estímulos de esta neurona
Estimulos = handles.neurons{neuronIndex}.Estimulos;
%la lista de los monitores de cada estimulo
Monitores = handles.neurons{neuronIndex}.Monitores;
%los spikes de la neurona
spkTimes = handles.neurons{neuronIndex}.data;
%el nombre de la neurona
name = handles.neurons{neuronIndex}.name;
%elijo los estímulos a plotear
stims = checkStimAndMonitors(Estimulos,Monitores, stimCodes, ...
    mDerecho, mIzquierdo);
%obtengo los spikes del cluster seleccionado (index indica a que
%estimulo corresponden)
[raster,index] = Sync(spkTimes,stims(:,2),'durations',[-tPre; tPost]);
%creo el titulo de la figura
titulo = ['Neurona: ', name, '  Estimulos: ', num2str(unique(stims(:,1))')];
%armo el vector de frecuencias de disparo (Hz)
[freq,~] = SyncHist(raster, index,'mode', 'mean' ,'durations',...
    [-tPre; tPost], 'nBins', nBins);
if smoothPSH
    freq = smooth(freq, binSize/2);
end
vargs = {'PlotLines', useLinePlot, 'Color', PSHface};
%armo el vector de tiempos
t = -tPre:(tPre+tPost)/(nBins-1):tPost;
%grafico el PSH
hPlot = plotPSH(freq, t, stims,tPre, tPost, titulo, vargs{:});
if ~useLinePlot
    if strcmp(PSHface, 'default')
        setAesthetics(hPlot, group);
    elseif strcmp(PSHedge, 'default')
        setAesthetics(hPlot, 'FaceColor', PSHface)
    else
        setAesthetics(hPlot, ...
            'FaceColor', PSHface,...
            'EdgeColor', PSHedge)
    end
end
xlabel('tiempo (s)')
ylabel ('freq (Hz)')


PlotRasters_oneColor(raster, index, [-tPre, tPost],max(freq), ...
    'Color', rasterColor, 'Linewidth', lineWidth, 'Position', position, 'relativeSize', relativeSize);
legend(['Group ', group]);
hold off



function smoothingSpan_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 > val
    set(hObject, 'String', '5')
end


% --- Executes during object creation, after setting all properties.
function smoothingSpan_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smoothingSpan_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addStdError_check.
function addStdError_check_Callback(hObject, eventdata, handles)
% hObject    handle to addStdError_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of addStdError_check



function stimHeigth_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
val
if isempty(val) || val < 0
    set(hObject,'String', '0.1')
elseif val > 1
    set(hObject, 'String', '1')
end


% --- Executes during object creation, after setting all properties.
function stimHeigth_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stimHeigth_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fixYaxis_check.
function fixYaxis_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.maxFreqPSH_edit, 'Enable', 'on', 'String', '100');
else
    set(handles.maxFreqPSH_edit, 'Enable', 'off', 'String', '');
end



function maxFreqPSH_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isempty(val) || val <= 0
    set(hObject, 'String', '100');
end


% --- Executes during object creation, after setting all properties.
function maxFreqPSH_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxFreqPSH_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spanCorrelogram_edit_Callback(hObject, eventdata, handles)
val = round(str2double(get(hObject, 'String')));
if isempty(val) || val < 1
    set(hObject, 'String', '1');
else
    set(hObject, 'String', string(val));
end


% --- Executes during object creation, after setting all properties.
function spanCorrelogram_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spanCorrelogram_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in smoothCorrelogram_check.
function smoothCorrelogram_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.spanCorrelogram_edit, 'String', '3', 'Enable', 'on');
else
    set(handles.spanCorrelogram_edit, 'String', '', 'Enable', 'off');
end


function correlBarColorR_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.correlBarColorR_edit, 'String'));
G = str2double(get(handles.correlBarColorG_edit, 'String'));
B = str2double(get(handles.correlBarColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.CorrelBarSample, 'BackgroundColor', sampleColor);


% --- Executes during object creation, after setting all properties.
function correlBarColorR_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to correlBarColorR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function correlBarColorG_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.correlBarColorR_edit, 'String'));
G = str2double(get(handles.correlBarColorG_edit, 'String'));
B = str2double(get(handles.correlBarColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.CorrelBarSample, 'BackgroundColor', sampleColor);

% --- Executes during object creation, after setting all properties.
function correlBarColorG_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to correlBarColorG_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function correlBarColorB_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.correlBarColorR_edit, 'String'));
G = str2double(get(handles.correlBarColorG_edit, 'String'));
B = str2double(get(handles.correlBarColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.CorrelBarSample, 'BackgroundColor', sampleColor);


% --- Executes during object creation, after setting all properties.
function correlBarColorB_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to correlBarColorB_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function correlLineColorR_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.correlLineColorR_edit, 'String'));
G = str2double(get(handles.correlLineColorG_edit, 'String'));
B = str2double(get(handles.correlLineColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.CorrelLineSample, 'BackgroundColor', sampleColor);



% --- Executes during object creation, after setting all properties.
function correlLineColorR_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to correlLineColorR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function correlLineColorG_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.correlLineColorR_edit, 'String'));
G = str2double(get(handles.correlLineColorG_edit, 'String'));
B = str2double(get(handles.correlLineColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.CorrelLineSample, 'BackgroundColor', sampleColor);



% --- Executes during object creation, after setting all properties.
function correlLineColorG_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to correlLineColorG_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function correlLineColorB_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val) || 1 < val || 0 > val
    set(hObject, 'String', '0')
end
R = str2double(get(handles.correlLineColorR_edit, 'String'));
G = str2double(get(handles.correlLineColorG_edit, 'String'));
B = str2double(get(handles.correlLineColorB_edit, 'String'));

sampleColor = [R G B];
set(handles.CorrelLineSample, 'BackgroundColor', sampleColor);


% --- Executes during object creation, after setting all properties.
function correlLineColorB_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to correlLineColorB_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in defaultCorrelBarColor_check.
function defaultCorrelBarColor_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    color = handles.defaults.correlBarColor;
    set(handles.correlBarColorR_edit, 'Enable', 'off', 'String', string(color(1)))
    set(handles.correlBarColorG_edit, 'Enable', 'off', 'String', string(color(2)))
    set(handles.correlBarColorB_edit, 'Enable', 'off', 'String', string(color(3)))
    set(handles.CorrelBarSample, 'BackgroundColor', color);
else
    set(handles.correlBarColorR_edit, 'Enable', 'on')
    set(handles.correlBarColorG_edit, 'Enable', 'on')
    set(handles.correlBarColorB_edit, 'Enable', 'on')
end


% --- Executes on button press in defaultCorrelLineColor_check.
function defaultCorrelLineColor_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    color = handles.defaults.correlLineColor;
    set(handles.correlLineColorR_edit, 'Enable', 'off', 'String', string(color(1)))
    set(handles.correlLineColorG_edit, 'Enable', 'off', 'String', string(color(2)))
    set(handles.correlLineColorB_edit, 'Enable', 'off', 'String', string(color(3)))
    set(handles.CorrelLineSample, 'BackgroundColor', color);
else
    set(handles.correlLineColorR_edit, 'Enable', 'on')
    set(handles.correlLineColorG_edit, 'Enable', 'on')
    set(handles.correlLineColorB_edit, 'Enable', 'on')
end



% --- Executes on button press in loadedCorrelograms_check.
function loadedCorrelograms_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.useSpontaneousCorrelogram_check, 'Value', false, 'Enable', 'off')
    set(handles.useStimIntervals_check, 'Value', false, 'Enable', 'off')
else
    
    set(handles.useSpontaneousCorrelogram_check, 'Value', false, 'Enable', 'on')
    set(handles.useStimIntervals_check, 'Value', true, 'Enable', 'on')
end

% --- Executes on button press in useStimIntervals_check.
function useStimIntervals_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.useSpontaneousCorrelogram_check, 'Value', false)
else
    set(handles.useSpontaneousCorrelogram_check, 'Value', true)
end

% --- Executes on button press in useSpontaneousCorrelogram_check.
function useSpontaneousCorrelogram_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.useStimIntervals_check, 'Value', false)
else
    set(handles.useStimIntervals_check, 'Value', true)
end


% --- Executes on button press in probabilisticCorrelogram_check.
function probabilisticCorrelogram_check_Callback(hObject, eventdata, handles)
% hObject    handle to probabilisticCorrelogram_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of probabilisticCorrelogram_check



function correlogramBin_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isempty(val) || val <= 0
    set(hObject, 'String', '1')
end


% --- Executes during object creation, after setting all properties.
function correlogramBin_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to correlogramBin_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function correlogramWidth_edit_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isempty(val) || val <= 0
    set(hObject, 'String', '60')
end

% --- Executes during object creation, after setting all properties.
function correlogramWidth_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to correlogramWidth_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PSHstimUnderPlot_check.
function PSHstimUnderPlot_check_Callback(hObject, eventdata, handles)
% hObject    handle to PSHstimUnderPlot_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PSHstimUnderPlot_check
