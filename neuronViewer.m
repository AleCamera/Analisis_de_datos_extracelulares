function varargout = neuronViewer(varargin)
% NEURONVIEWER MATLAB code for neuronViewer.fig
%      NEURONVIEWER, by itself, creates a new NEURONVIEWER or raises the existing
%      singleton*.
%
%      H = NEURONVIEWER returns the handle to a new NEURONVIEWER or the handle to
%      the existing singleton*.
%
%      NEURONVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEURONVIEWER.M with the given input arguments.
%
%      NEURONVIEWER('Property','Value',...) creates a new NEURONVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before neuronViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to neuronViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help neuronViewer

% Last Modified by GUIDE v2.5 26-Oct-2019 20:00:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @neuronViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @neuronViewer_OutputFcn, ...
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


% --- Executes just before neuronViewer is made visible.
function neuronViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to neuronViewer (see VARARGIN)

% Choose default command line output for neuronViewer
handles.output = hObject;

%neuronViewer es una interfaz gráfica para visualizar y comparar la
%actividad de distintas neuronas. Las neuronas quedan guardadas en un
%vector de celdas (handles.neurons) y por lo tanto se puede llamar a cada
%neurona como handles.neurons{i} donde i es el indice que contiene a la
%neurona. 
%cada neurona consiste de un struct con 6 campos:

%neuron.data tiene los timestamps en segundos (es un vector)

%neuron.file tiene un string que corresponde al path del registro de esa neurona

%neuron.cluster es un vector con el numero de cluster (NO LO ESTOY USANDO
%POR AHORA, es informacion inutil. SACAR)

%neuron.Estimulos tiene una matriz con los estimulos. La matrix tiene 3
%columnas que tienen: 
%C1->codigo del estimulo, 
%C2->inicio del estimulo en segundos,
%C3-> final del estimulo en segundos

%neuron.Monitores = es un vector de caracteres que tiene la informacion de
%qué monitor vino cada estimulo. Tiene el mismo largo que Estimulos y dice:
%'D' si vino del monitor derecho
%'I' si vino del izquierdo
%'ID' si vino de ambos al mismo tiempo

%neuron.name tiene un string con el nombre de la neurona

%handles.neurons es la base de datos de la GUI. Además la GUI tiene dos
%listas de nueuronas:
%neuronList tiene los nombres de todas las neuronas de la base de datos


if isempty(varargin)
    %si no cargué ninguna neurona como argumento dejo vacía la base de
    %datos
    handles.neurons = {};
else
    %Si envie neuronas como argumento las cargo
    handles.neurons = varargin{1};
    
    %cargo los nombres de los archivos
    for i = 1:length(handles.neurons)
        if i == 1
            names{1} =handles.neurons{i}.name;
        else
            names{i} = handles.neurons{i}.name;
        end
    end
    %y los coloco en la lista
    set(handles.neuronList,'string',names);
    % actualizo la cantidad de neuronas en la lista
    set(handles.neuronListLength_Txt, 'String', num2str(length(names)));
end

%seteo por default que el primer item de la lista sea el seleccionado
%handles.leftIndex = 1;
%seteo que ambos monitores esten activados
set(handles.mDerecho_check, 'Value', 1);
set(handles.mIzquierdo_check, 'Value', 1);
%seteo que se pueda elegir varias neuronas a la vez de la lista completa
set(handles.neuronList, 'Max', 100, 'min', 0);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes neuronViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = neuronViewer_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on selection change in neuronList.
function neuronList_Callback(hObject, eventdata, handles)

%handles.leftIndex = get(hObject,'Value'); %creo que no se usa
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function neuronList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in compare.
function compare_Callback(hObject, eventdata, handles)
%Compare es una función que se ejecuta cuando se presiona el boton
%"Comparar". Va a generar un raster plot y un PSH promediando esos rasters
%para cada una de las neuronas en la lista de neuronas seleccionadas (lista
%de la derecha)

%checkeo que haya neuronas en la lista
selectedList = get(handles.selectedList, 'String');
nNeurons = length(selectedList);
%si no hay neuronas cargadas en la lista no hago nada
if nNeurons == 0
    return
end

%levanto la lista de estimulos
listStr = get(handles.stimCode_edit, 'string');
listCell = strsplit(listStr,' ');
for i = 1:length(listCell)
    stimCodes(i) = str2double(listCell{i});
end

%levanto los monitores
mDerecho = get(handles.mDerecho_check, 'Value');
mIzquierdo = get(handles.mIzquierdo_check, 'Value');

%levanto los tiempos
tPre = str2double(get(handles.tPre_edit, 'string'));
tPost = str2double(get(handles.tPost_edit, 'string'));

%Tambien cargo el tamaño de bins calculo el número de bins que necesito 
binSize = str2double(get(handles.binSize_edit, 'string'));
nBins = round((tPre + tPost)*(1000/binSize));

%ahora veo que neuronas voy a plotear
neuronList = get(handles.neuronList,'String');
%neuronIndex va a guardar los indices de handles.neuron donde estan las
%neuronas seleccioadas
neuronIndex = zeros(1,length(selectedList));
found = 0;

for i = 1:length(neuronList)
    %recorro la neuronList y guardo los indices donde el nombre coincide
    %con el de selectedList
    if sum(strcmp(neuronList{i}, selectedList))
        found = found+1;
        neuronIndex(found) = i;
    end
end

%ahora genero una figura y la voy cargando con los rasters y PSH
neuron = 1;
plotsPerFigure = 2;
nFigure = 1;
%doy vueltas en el loop mientas que haya neuronas sin plotear
while neuron <= nNeurons
    figure(nFigure);clf;
    if nNeurons - (neuron-1) > plotsPerFigure
        plotsToDo = plotsPerFigure;
    else
        plotsToDo = nNeurons - (neuron-1);
    end
    %recorro el subplot. Con dos columnas tiene:
    %filas:1,3,5,...,n para la primer columna y
    %filas:2,4,6,...,n+1 para la segunda columna
    for nPlot = 1:2:(plotsToDo*2)-1
        %cargo la lista de todos los estímulos de esta neurona
        Estimulos = handles.neurons{neuronIndex(neuron)}.Estimulos;
        %la lista de los monitores de cada estimulo
        Monitores = handles.neurons{neuronIndex(neuron)}.Monitores;
        %los spikes de la neurona
        spkTimes = handles.neurons{neuronIndex(neuron)}.data;
        %el nombre de la neurona
        name = handles.neurons{neuronIndex(neuron)}.name;
        %elijo los estímulos a plotear
        stims = checkStimAndMonitors(Estimulos,Monitores, stimCodes, ...
            mDerecho, mIzquierdo);
        %obtengo los spikes del cluster seleccionado (index indica a que 
        %estimulo corresponden)
        [raster,index] = Sync(spkTimes,stims(:,2),'durations',[-tPre; tPost]);
        %creo el titulo de la figura
        titulo = ['Neurona: ', name, '  Estimulos: ', num2str(unique(stims(:,1))')];
        %Ploteo los rasters
        subplot(plotsPerFigure, 2, nPlot)
        hold on
        plotRasters(raster, index, tPre, tPost, stims)
        subplot(plotsPerFigure, 2, nPlot+1)
        plotPSH(raster, index, tPre, tPost, stims, nBins, titulo)
        hold off
        neuron = neuron+1;
    end
    nFigure = nFigure+1;
end




% --- Executes on button press in Combine.
function Combine_Callback(hObject, eventdata, handles)
%Combine es una función que se ejecuta cuando se presiona el boton
%"Combinar". Va a generar un PSH para cada neurona de la lista de neuronas 
%seleccionadas y al final va a hacer un PSH promedio de todas esas neuronas 
%para los estímulos seleccionados

%checkeo que haya neuronas en la lista
selectedList = get(handles.selectedList, 'String');
nNeurons = length(selectedList);
%si no hay neuronas cargadas en la lista no hago nada
if nNeurons == 0
    return
end

%levanto la lista de estimulos
listStr = get(handles.stimCode_edit, 'string');
listCell = strsplit(listStr,' ');
for neuron = 1:length(listCell)
    stimCodes(neuron) = str2double(listCell{neuron});
end

%levanto los monitores
mDerecho = get(handles.mDerecho_check, 'Value');
mIzquierdo = get(handles.mIzquierdo_check, 'Value');

%levanto los tiempos
tPre = str2double(get(handles.tPre_edit, 'string'));
tPost = str2double(get(handles.tPost_edit, 'string'));

%Tambien cargo el tamaño de bins calculo el número de bins que necesito
binSize = str2double(get(handles.binSize_edit, 'string'));
nBins = round((tPre + tPost)*(1000/binSize));

%ahora veo que neuronas voy a plotear
neuronList = get(handles.neuronList,'String');
%neuronIndex va a guardar los indices de handles.neuron donde estan las
%neuronas seleccioadas
neuronIndex = zeros(1,length(selectedList));
found = 0;
for i = 1:length(neuronList)
    %recorro la neuronList y guardo los indices donde el nombre coincide
    %con el de selectedList
    if sum(strcmp(neuronList{i}, selectedList))
        found = found+1;
        neuronIndex(found) = i;
    end
end

%armo un cell array con los spikes
data = cell(1,nNeurons);
totalLength = 0;
allStims = [];
for neuron=1:nNeurons
    %cargo la lista de todos los estímulos de esta neurona
    Estimulos = handles.neurons{neuronIndex(neuron)}.Estimulos;
    %la lista de los monitores de cada estimulo
    Monitores = handles.neurons{neuronIndex(neuron)}.Monitores;
    %los spikes de la neurona
    spkTimes = handles.neurons{neuronIndex(neuron)}.data;
    %el nombre de la neurona
    data{neuron}.name = handles.neurons{neuronIndex(neuron)}.name;
    %elijo los estímulos a plotear
    data{neuron}.stims = checkStimAndMonitors(Estimulos,Monitores, stimCodes, ...
        mDerecho, mIzquierdo);

    %obtengo los spikes del cluster seleccionado (index indica a que
    %estimulo corresponden)
    [data{neuron}.raster,data{neuron}.index] = Sync(spkTimes,data{neuron}.stims(:,2),'durations',[-tPre; tPost]);
    data{neuron}.nData = length(data {neuron}.raster);
    totalLength = totalLength + data{neuron}.nData;
    allStims = [allStims; data{neuron}.stims];
end

%los ploteo por separado
figure(1);clf;
for neuron = 1:nNeurons
    subplot(nNeurons+1, 1, neuron)
    hold on
    titulo = ['Neurona: ', data{neuron}.name, '  Estimulos: ', num2str(unique(data{neuron}.stims(:,1))')];
    plotPSH(data{neuron}.raster, data{neuron}.index, tPre, tPost, data{neuron}.stims, nBins, titulo)
    hold off
end
%ahora genero un vector con todos los spikes juntos
combined.raster = zeros(totalLength,1);
combined.index = zeros(totalLength,1);
currentPoint = 1;
for neuron = 1:nNeurons
    combined.raster(currentPoint:(currentPoint+data{neuron}.nData-1),1) = data{neuron}.raster;
    combined.index(currentPoint:(currentPoint+data{neuron}.nData-1), 1) = data{neuron}.index;
    currentPoint = currentPoint+data{neuron}.nData;
end
subplot(nNeurons+1, 1, nNeurons+1)
hold on
titulo = 'Combined';
plotPSH(combined.raster, combined.index, tPre, tPost, allStims, nBins, titulo)
hold off



% --- Executes on selection change in selectedList.
function selectedList_Callback(hObject, eventdata, handles)
%lista de neuronas seleccionadas
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function selectedList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Add_button.
function Add_button_Callback(hObject, eventdata, handles)
%agrega a una neurona de la lista de todas las neuronas a la lista de de
%neuronas seleccionadas

%cargo la lista de todas las neuronas
neuronList = get(handles.neuronList, 'String');
%si no hay neuronas cargadas en el programa no hago nada
if isempty(neuronList)
    return
end

%levanto los indices de las neuronas seleccionadas
NLindex = get(handles.neuronList, 'Value');

%si la lista de neuronas seleccionadas esta� vacia le asigno la neurona que
%esta seleccionada en ese momento
if isempty(get(handles.selectedList, 'String'))
    selectedList = repmat({''},length(NLindex),1);
    for i = 1:length(NLindex)
        selectedList{i} = neuronList{NLindex(i)};
    end
else
    %si no estaba vacia cargo la lista de neuronas seleccionadas
    selectedList = get(handles.selectedList, 'String');
    for index = NLindex
        %checkeo si la neurona ya esta en la lista
        if sum(strcmp(selectedList, neuronList{index}))
            %si está en la lista la ignoro
            continue
        end
        %si no esta la agrego a la lista
        selectedList{length(selectedList)+1} = neuronList{index};
    end
end
set(handles.selectedList, 'String', selectedList)
nItems = length(selectedList);
set(handles.selectedList, 'Value', nItems)
set(handles.selectedListLength_Txt, 'String', num2str(nItems));
guidata(hObject, handles);

% --- Executes on button press in Clear_button.
function Clear_button_Callback(hObject, eventdata, handles)
%Limpia la lista de neuronas seleccionadas
selectedList = {};
set(handles.selectedList, 'Value', 0)
set(handles.selectedList, 'String', selectedList)
set(handles.selectedListLength_Txt, 'String', '0');
guidata(hObject, handles);



% --- Executes on button press in Remove_edit.
function Remove_edit_Callback(hObject, eventdata, handles)
%Saca a una neurona de la lisata de neuronas seleccionadas
if isempty(get(handles.selectedList, 'String'))
    return
else
    selectedList = get(handles.selectedList, 'String');
    selectedList(get(handles.selectedList, 'Value')) = [];
end
nItems = length(selectedList);
set(handles.selectedList, 'Value', nItems)
set(handles.selectedList, 'String', selectedList)
set(handles.selectedListLength_Txt, 'String', num2str(nItems));
guidata(hObject, handles);



function tPost_edit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function tPost_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tPre_edit_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function tPre_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function binSize_edit_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function binSize_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stimCode_edit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function stimCode_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in mDerecho_check.
function mDerecho_check_Callback(hObject, eventdata, handles)


% --- Executes on button press in mIzquierdo_check.
function mIzquierdo_check_Callback(hObject, eventdata, handles)


% --- Executes on button press in saveSelection_push.
function saveSelection_push_Callback(hObject, eventdata, handles)
%guarda la lista de neuronas seleccionadas como un archivo .mat

%cargo la lista de neuronas seleccionadas
selectedList = get(handles.selectedList, 'String');
%si no hay neuronas en la lista salgo de la función
if isempty(selectedList)
    return
end
[file,path] = uiputfile('*.mat', 'Guardar la lista', 'ClusterType.mat');
if path == 0
    return
end
%cargo la lista de neuronas
neuronList = get(handles.neuronList, 'String');
%neurons es un cell array que va a contener a todas las neuronas a guardar
neurons =cell(1,length(selectedList));
found = 0;
%recorro la lista de todas las neuronas
for i = 1:length(neuronList)
    if sum(strcmp(neuronList{i}, selectedList))
        %si la neurona esta en la lista de las seleccionadas la guardo
        found = found+1;
        neurons{found} = handles.neurons{i};
    end
end
%guardo las neuronas
save([path, '/', file], 'neurons')

% --- Executes on button press in loadList_push.
function loadList_push_Callback(hObject, eventdata, handles)
%carga una lista de neuronas ya armada a partir de un archivo .mat

%cargo el una lista de neuronas. Si las guardé con el programa el nombre de
%la lista va a ser "neurons"
[file,path] = uigetfile('*mat');
if file == 0
    return
end
cd(path)
loaded = load(file);
neurons = handles.neurons;
if isempty(neurons)
    %si no hay datos cargados creo la lista de neuronas
    handles.neurons = loaded.neurons;
    %genero la lista de nombres
    for i = 1:length(handles.neurons)
        if i == 1
            names{1} =handles.neurons{i}.name;
        else
            names{i} = handles.neurons{i}.name;
        end
    end
    %y los coloco en la lista
    set(handles.neuronList,'string',names);
        %y el numero de neuronas cargadas
    set(handles.neuronListLength_Txt, 'String', num2str(length(names)));
else
    %si ya hay datos cargados en la lista
    neuronList = get(handles.neuronList,'string');
    for i = 1:length(loaded.neurons)
        if ~strcmp(neuronList,loaded.neurons{i}.name)
            %si el nombre de la neurona no esta en la lista de nombres lo agrego
            neuronList{length(neuronList)+1} = loaded.neurons{i}.name;
            %ahora agrego los datos de la neurona
            handles.neurons = [handles.neurons, loaded.neurons{i}];
        end
    end
    %actualizo la lista de nombres
    set(handles.neuronList,'string',neuronList);
    %y el numero de neuronas cargadas
    set(handles.neuronListLength_Txt, 'String', num2str(length(neuronList)));
end

guidata(hObject, handles);


% --- Executes on button press in rename_push.
function rename_push_Callback(hObject, eventdata, handles)
%cambia el nombre de una neurona

%cargo la lista de neuronas y salgo de la función si está vacía
neuronList = get(handles.neuronList, 'String');
if isempty(neuronList)
    return
end
%veo los indices de las neuronas seleccionadas para renombrar y salgo de la 
%función si seleccioné mas de una
NLindex = get(handles.neuronList, 'Value');
if length(NLindex) > 1
    warning('seleccione una sola neurona para renombrar')
    return
end
%genero el nuevo nombre
newName = clusterNameGUI;
if isempty(newName)
    return
end

%cargo la lista de neuronas seleccionadas
selectedList = get(handles.selectedList, 'String');
%busco el indice de la neurona a renombrar en la lista seleccionada
SLindex=[];
for i = 1:length(selectedList)
    if sum(strcmp(selectedList{i}, neuronList{NLindex}))
        SLindex = i;
    end
end
%cargo el nuevo nombre en la lista de todas las neuronas
neuronList{NLindex} = newName;
%lo cargo en la base de datos
handles.neurons{NLindex}.name = newName;
%checkeo si SLidex tiene un indice cargado (si no tiene entonces la neurona 
%no estaba en la lista de las neuronas seleccionadas y no hace falta
%modificarla)
if ~isempty(SLindex)
    %y cargo el nuevo nombre en la lista de neuronas seleccionadas
    selectedList{SLindex} = newName;
end

%ESTO ESTA CONSTRUIDO DE MANERA POBRE. SERIA MEJOR VINCULAR TODOS LOS
%NOMBRES DIRECTO A LA BASE DE DATOS EN VEZ DE MANEJAR MÚLTIPLES LISTAS.
%SE PUEDE HACER? NO SE, NO SOY PROGRAMADOR

%actualizo los datos de la GUI
set(handles.neuronList,'string',neuronList);
set(handles.selectedList,'string',selectedList);
set(handles.selectedList, 'Value', 1);
set(handles.neuronList, 'Value', 1);
guidata(hObject, handles);


% --- Executes on button press in delete_push.
function delete_push_Callback(hObject, eventdata, handles)
%elimina una neurona de la lista (la neurona se elije de la lista de todas
%las neuronas y se elimina de todas las listas y la base de datos)

%cargo la lista de neuronas
neuronList = get(handles.neuronList, 'String');
if isempty(neuronList)
    return
end
%levanto los indices de las neuronas seleccionadas
NLindex = get(handles.neuronList, 'Value');

%si no estaba vacia cargo la lista de neuronas seleccionadas
selectedList = get(handles.selectedList, 'String');
%busco los indices de las neuronas a eliminar que también estén en la lista
%de seleccionadas
neurons2delete = repmat({''},length(NLindex),1);
for i = 1:length(NLindex)
    neurons2delete{i} = neuronList{NLindex(i)};
end
%intersect me devuelve los indices en selectedList de las neuronas a
%eliminar
[~, SLindex,~] = intersect(selectedList,neurons2delete, 'stable');

%ahora elimino las neuronas de la lista de todas las neuronas y de la base 
%de datos (de atras para adelante para no modificar los indices del resto 
%de las neuronas cuando elemino una)
for i = flip(NLindex)
    neuronList(i) = [];
    handles.neurons(i) = [];
end
%checkeo si SLidex tiene indices cargados (si no tiene entonces la neurona
%no estaba en la lista de las neuronas seleccionadas y no hace falta
%eliminarla)
if ~isempty(SLindex)
    %las elimino de la lista de neuronas seleccionadas
    for i = flip(SLindex)
        selectedList(SLindex) = [];
    end
end

%actualizo la base de datos
set(handles.neuronList,'string',neuronList);
set(handles.selectedList,'string',selectedList);
set(handles.selectedList, 'Value', 1);
set(handles.neuronList, 'Value', 1);
set(handles.neuronListLength_Txt, 'String', num2str(length(neuronList)));
set(handles.selectedListLength_Txt, 'String', num2str(length(selectedList)));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function text3_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in deleteSelection_push.
function deleteSelection_push_Callback(hObject, eventdata, handles)
%Elimina de ambas listas y la base de datos a todas las nueuronas de la 
%lista de neuronas seleccionadas 

%cargo la lista de neuronas seleccionadas
selectedList = get(handles.selectedList, 'String');
%si no hay neuronas en la lista salgo de la funcion
if isempty(selectedList)
    return
end

%cargo la lista completa de neuronas
neuronList = get(handles.neuronList, 'String');

%NLindex va a contener a todos los indices de las neuronas a eliminar
NLindex = zeros(1, length(selectedList));
nFound = 0;
%recorro la lista de todas las neuronas
for i = 1:length(neuronList)
    if sum(strcmp(neuronList{i}, selectedList))
        %si la neurona esta en la lista de las seleccionadas guardo el
        %indice
        nFound = nFound+1;
        NLindex(nFound) = i;
    end
end
%elimino las neuronas de la lista completa y de la base de datos (recorro
%el vector de mayor a menor para no modificar los indices de las neuronas a
%eleiminar a medida que los borro
for i = length(NLindex):-1:1
    neuronList(NLindex(i)) = [];
    handles.neurons(NLindex(i)) = [];
end
%vacio la lista de neuronas selecionadas
selectedList = {};

%actualizo la base de datos
set(handles.neuronList,'string',neuronList);
set(handles.selectedList,'string',selectedList);
set(handles.selectedList, 'Value', 1);
set(handles.neuronList, 'Value', 1);
set(handles.neuronListLength_Txt, 'String', num2str(length(neuronList)));
set(handles.selectedListLength_Txt, 'String', '0');
guidata(hObject, handles);


% --- Executes on button press in test_push.
function test_push_Callback(hObject, eventdata, handles)

neuronList = get(handles.neuronList, 'String')
assignin('base', 'neuronList', neuronList)
neuronValues = get(handles.neuronList, 'Value')
assignin('base', 'neuronValues', neuronValues)
