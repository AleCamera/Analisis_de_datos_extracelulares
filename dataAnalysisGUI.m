function varargout = dataAnalysisGUI(varargin)
% DATAANALYSISGUI MATLAB code for dataAnalysisGUI.fig
%      DATAANALYSISGUI, by itself, creates a new DATAANALYSISGUI or raises the existing
%      singleton*.
%
%      H = DATAANALYSISGUI returns the handle to a new DATAANALYSISGUI or the handle to
%      the existing singleton*.
%
%      DATAANALYSISGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATAANALYSISGUI.M with the given input arguments.
%
%      DATAANALYSISGUI('Property','Value',...) creates a new DATAANALYSISGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dataAnalysisGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dataAnalysisGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dataAnalysisGUI

% Last Modified by GUIDE v2.5 25-Oct-2019 14:45:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dataAnalysisGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @dataAnalysisGUI_OutputFcn, ...
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


% --- Executes just before dataAnalysisGUI is made visible.
function dataAnalysisGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dataAnalysisGUI (see VARARGIN)

% Choose default command line output for dataAnalysisGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dataAnalysisGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dataAnalysisGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadData.
function loadData_Callback(hObject, eventdata, handles)
% hObject    handle to loadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Seteo el path al que voy a ir a buscar los archivos
path = uigetdir('D://Labo//registros');
handles.path = path;
loadingDataStr = 'Loading Data...';
set(handles.pathTxt, 'String', loadingDataStr);
guidata(hObject, handles);

%Cargo los datos: 
%"data" tiene los tiempos de cada spike. Cada celda corresponde a un
% cluster distinto. Las dimensiones de data son 1 x #de clusters: 
handles.data = loadData(path);
%cargo los estimulos
load('Estimulos.mat');
%Cargo las etiquetas de cada uno (algo falla ac�, arreglar)
labels = getLabels(Estimulos);
%cargo los monitores
load('Monitores.mat');


handles.Estimulos = Estimulos;
handles.stimLabels = labels;
handles.Monitores = Monitores(:,1);
%assignin('base', 'HANDLES', handles);
propertyList = {'String', 'ForegroundColor'};
propertyValues = {path, [0.1,0.9,0.1]};
set(handles.pathTxt, propertyList, propertyValues);
set(handles.monitorDerecho, 'Value', 1);
set(handles.monitorIzquierdo, 'Value', 1);
guidata(hObject, handles);



function clusterEdit_Callback(hObject, eventdata, handles)
% hObject    handle to clusterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of clusterEdit as text
%        str2double(get(hObject,'String')) returns contents of clusterEdit as a double
handles.cluster = str2double(get(hObject, 'string'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function clusterEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clusterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stimByCodeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to stimByCodeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
listStr = get(hObject, 'string');
listCell = strsplit(listStr,' ');
handles.stimMethod = "Code";
for i = 1:length(listCell)
    stimList(i) = str2double(listCell{i});
end
handles.stims2plot = stimList;
set(handles.stimByListEdit, 'String', '');
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of stimByCodeEdit as text
%        str2double(get(hObject,'String')) returns contents of stimByCodeEdit as a double


% --- Executes during object creation, after setting all properties.
function stimByCodeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stimByCodeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plotRasters.
function plotRasters_Callback(hObject, eventdata, handles)

%primero veo si pedi estimulos por lista o codigo
if handles.stimMethod == "Code"
    stims = checkStimAndMonitors(handles.Estimulos, handles.Monitores, ...
        handles.stims2plot, handles.monitorDerecho.Value, handles.monitorIzquierdo.Value);
elseif handles.stimMethod == "List"
    stims = zeros(length(handles.stims2plot),3);
    for i = 1:length(handles.stims2plot)
        stims(i,:) = handles.Estimulos(handles.stims2plot(i),:);
    end
end

%cargo los tiempos a graficar antes y después del onset del estimulo.
%Tambien cargo el tamaño de bins calculo el número de bins que necesito 
tPre = str2double(get(handles.tPreStimEdit, 'string'));
tPost = str2double(get(handles.tPostStimEdit, 'string'));
binSize = str2double(get(handles.binSize, 'string'));
nBins = round((tPre + tPost)*(1000/binSize));

%obtengo los spikes del cluster seleccionado (index indica a que estimulo
%corresponden)
[raster,index] = Sync(handles.data{handles.cluster},stims(:,2),'durations',[-tPre; tPost]);     % compute spike raster data

%armo los datos para el histograma (junta todos los trials)
[m,~] = SyncHist(raster, index,'mode', 'mean','durations',[-tPre; tPost], 'nBins', nBins);
t = -tPre:(tPre+tPost)/(nBins-1):tPost;

%creo la figura
figure (1);clf;
subplot(2,1,2);
%ploteo el histograma
bar(t,m);
% y la adorno (acá hay que agregar detalles para los gráficos)
hold on
topLimit = max(m) * 1.2;
tFinalMedio = mean(stims(:,3)-stims(:,2));
[nStims, ~]=size(stims);
if stimsAreUnique(96, stims(:,1))
    %fondo gris durante los periodos oscuros del estimulo 96
    R1 = rectangle('position', [-2,0, 2,topLimit]', 'FaceColor', [0.6 0.6 0.6], 'LineStyle', 'none');
    R2 = rectangle('position', [2,0, 2,topLimit]', 'FaceColor', [0.6 0.6 0.6], 'LineStyle', 'none');
    uistack(R1, 'bottom');
    uistack(R2, 'bottom');
elseif stimsAreUnique(2, stims(:,1))
    %dibujo un looming si el estímulo es el 2
    sizeCM = 17;
    t = 0:(tFinalMedio/1000):tFinalMedio;
    y = zeros(1,length(t));
    for i = 1:length(t)
        y(i) = 2*((20*sizeCM)/(500 - (142.5*t(i))));
    end
    y = y - y(1);
    y = y*topLimit/max(y);
    y2 = zeros(1,length(y));
    L1 = line(t,y,'Color', 'k');
    A1 = fill([t,fliplr(t)],[y, fliplr(y2)], [0.6, 0.6, 0.6]);
    uistack(L1, 'bottom');
    uistack(A1, 'bottom');
elseif length(handles.stims2plot) == 1 || stimsAreUnique([25, 26], stims(:,1))...
        || stimsAreUnique([33 34 37 38 39 40 41 42 43 44 45 46 47 48], stims(:,1))
    %sino pongo un fondo gris durante la duracion del estimulo si hay un
    %sólo tipo de estimulo o son los dos flujos o los cuadrados
    R1 = rectangle('position', [0,0, tFinalMedio,topLimit]', 'FaceColor', [0.6 0.6 0.6], 'LineStyle', 'none');
    uistack(R1, 'bottom');
end
ylim([0,topLimit])
xlim([-tPre tPost])
subplot(2,1,1);
%%%%%------Mi propio raster plot----%%%%%
% figure
% for i = 1:length(raster)
% line([raster(i), raster(i)], [index(i)-0.5, index(i) + 0.5], 'Color', 'k')
% end
%%%%%-------------------------------%%%%%
%Grafico los rasters
PlotSync(raster,index, 'durations', [-tPre; tPost]);             % plot spike raster
for nStim = 1:nStims
    %pongo una flechita negra al final del estimulo
    tFinal = stims(nStim, 3) - stims(nStim, 2);
    quiver ( tFinal, nStim-0.5, 0, -0.1, 'LineStyle', 'none','Color', 'k', 'Marker', 'v', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
end
if stimsAreUnique(96, stims(:,1))
    %fondo gris durante los periodos oscuros del estimulo 96
    R1 = rectangle('position', [-2,-0.5, 2,length(stims)]', 'FaceColor', [0.6 0.6 0.6], 'LineStyle', 'none');
    R2 = rectangle('position', [2,-0.5, 2,length(stims)]', 'FaceColor', [0.6 0.6 0.6], 'LineStyle', 'none');
    uistack(R1, 'bottom');
    uistack(R2, 'bottom');
else
    for nStim = 1:nStims
        tFinal = stims(nStim, 3) - stims(nStim, 2);
        quiver ( tFinal, nStim-0.5, 0, -0.1, 'LineStyle', 'none','Color', 'k', 'Marker', 'v', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
    end
end
ylim([-0.5, nStims-0.5]);
%creo el titulo de la figura
titulo = ['Cluster: ', num2str(handles.cluster), '   Estimulos: '];
for i = 1:length(handles.stims2plot)
    titulo = [titulo, num2str(handles.stims2plot(i)), ' '];
end
title(titulo);
hold off


% --- Executes on button press in plotPSH.
function plotPSH_Callback(hObject, eventdata, handles)
% hObject    handle to plotPSH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function tPreStimEdit_Callback(hObject, eventdata, handles)
% hObject    handle to tPreStimEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tPreStimEdit as text
%        str2double(get(hObject,'String')) returns contents of tPreStimEdit as a double


% --- Executes during object creation, after setting all properties.
function tPreStimEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tPreStimEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function tPostStimEdit_Callback(hObject, eventdata, handles)
% hObject    handle to tPostStimEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tPostStimEdit as text
%        str2double(get(hObject,'String')) returns contents of tPostStimEdit as a double


% --- Executes during object creation, after setting all properties.
function tPostStimEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tPostStimEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stimByListEdit_Callback(hObject, eventdata, handles)
% hObject    handle to stimByListEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stimByListEdit as text
%        str2double(get(hObject,'String')) returns contents of stimByListEdit as a double
listStr = get(hObject, 'string');
listCell = strsplit(listStr,' ');
handles.stimMethod = "List";
for i = 1:length(listCell)
    stimList(i) = str2double(listCell{i});
end
handles.stims2plot = stimList;
set(handles.stimByCodeEdit, 'String', '');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stimByListEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stimByListEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in monitorDerecho.
function monitorDerecho_Callback(hObject, eventdata, handles)
% hObject    handle to monitorDerecho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of monitorDerecho


% --- Executes on button press in monitorIzquierdo.
function monitorIzquierdo_Callback(hObject, eventdata, handles)
% hObject    handle to monitorIzquierdo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of monitorIzquierdo



function binSize_Callback(hObject, eventdata, handles)
% hObject    handle to binSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of binSize as text
%        str2double(get(hObject,'String')) returns contents of binSize as a double




% --- Executes during object creation, after setting all properties.
function binSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveCluster.
function saveCluster_Callback(hObject, eventdata, handles)
% hObject    handle to saveCluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%obtengo el nombre de la neurona con la GUI clusterNameGUI
neuron.name = clusterNameGUI;
%si me devuelve un vector vacío es que se canceló y salgo de la función
if isempty(neuron.name)
    return;
end
%cargo los datos de la neurona
neuron.data = handles.data{handles.cluster};
neuron.file = handles.pathTxt.String;
neuron.cluster = handles.cluster;
neuron.Estimulos = handles.Estimulos;
neuron.Monitores = handles.Monitores;

if isfield(handles, 'neurons')
    %si hay neuronas guardadas agrego la nueva neurona a la lista
    nNeurons = length(handles.neurons);    
    handles.neurons{nNeurons+1} = neuron;
else
    %si no asigno como la primer neurona
    handles.neurons{1} = neuron;
end
%actualizo los datos
set(handles.clustersSaved, 'String', ['Clusters Saved: ', num2str(length(handles.neurons))]);
guidata(hObject, handles);


% --- Executes on button press in openNeuronViewer.
function openNeuronViewer_Callback(hObject, eventdata, handles)
% hObject    handle to openNeuronViewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%si hay neuronas cargadas abro el neuronViewer con las neuronas cargadas
if isfield(handles, 'neurons') && ~isempty(handles.neurons) 
    neuronViewer(handles.neurons)   
else
    %si no lo habro vacío
    neuronViewer;
end

% --- Executes on button press in add2List_push.
function add2List_push_Callback(hObject, eventdata, handles)
% hObject    handle to add2List_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile('*mat');
cd(path)
%cargo la lista de neuronas a la que quiero sumar mi neurona
loaded = load(file);
%obtengo el nombre de la neurona con la GUI clusterNameGUI
neuron.name = clusterNameGUI;
%si me devuelve un vector vacío es que se canceló y salgo de la función
if isempty(neuron.name)
    return;
end
%cargo los datos de la neurona
neuron.data = handles.data{handles.cluster};
neuron.file = handles.pathTxt.String;
neuron.cluster = handles.cluster;
neuron.Estimulos = handles.Estimulos;
neuron.Monitores = handles.Monitores;

%checkeo que no haya una neurona en la lista con el mismo nombre
for i = 1:length(loaded.neurons)
    if strcmp(neuron.name, loaded.neurons{i}.name)
        error('Ya hay una neurona con ese nombre en la lista')
    end
end

%neurons es un cell array que va a contener a todas las neuronas a guardar
neurons =loaded.neurons;
%y le agrego mi nueva neurona
neurons = [neurons, neuron];
%guardo las neuronas
save([path, '/', file], 'neurons')
fprintf('\nNeurona agregada!\n\n')