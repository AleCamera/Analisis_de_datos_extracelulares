function varargout = neuronViewer2_0(varargin)
% NEURONVIEWER2_0 MATLAB code for neuronViewer2_0.fig
%      NEURONVIEWER2_0, by itself, creates a new NEURONVIEWER2_0 or raises the existing
%      singleton*.
%
%      H = NEURONVIEWER2_0 returns the handle to a new NEURONVIEWER2_0 or the handle to
%      the existing singleton*.
%
%      NEURONVIEWER2_0('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEURONVIEWER2_0.M with the given input arguments.
%
%      NEURONVIEWER2_0('Property','Value',...) creates a new NEURONVIEWER2_0 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before neuronViewer2_0_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to neuronViewer2_0_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help neuronViewer2_0

% Last Modified by GUIDE v2.5 17-Feb-2020 05:28:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @neuronViewer2_0_OpeningFcn, ...
                   'gui_OutputFcn',  @neuronViewer2_0_OutputFcn, ...
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


% --- Executes just before neuronViewer2_0 is made visible.
function neuronViewer2_0_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for neuronViewer2_0
handles.output = hObject;

%neuronViewer2_0 es una interfaz gráfica para visualizar y comparar la
%actividad de distintas neuronas. Las neuronas quedan guardadas en un
%vector de celdas (handles.neurons) y por lo tanto se puede llamar a cada
%neurona como handles.neurons{i} donde i es el indice que contiene a la
%neurona. 
%cada neurona consiste de un struct con 6 campos:

%neuron.data tiene los timestamps en segundos (es un vector)

%neuron.file tiene un string que corresponde al path del registro de esa neurona

%neuron.cluster es un vector con el numero de cluster 

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
%seteo la estetica de los grupos
set(handles.groupATitle_Txt, 'BackgroundColor', getColor('A'));
set(handles.groupBTitle_Txt, 'BackgroundColor', getColor('B'));

handles.plottingFunct = @PlotRasters_oneColor;
%handles.plottingFunct = @PlotSync;

%settings tiene los parametros cargados para armar las figuras.
if isunix
handles.settingsPath = '/home/usuario/Scripts/Analisis_de_datos_extracelulares/plottingParameters';
handles.settings = load([handles.settingsPath, '/plotSettings']);
else
    handles.settingsPath = 'C:\Users\Alejandro\Documents\Ale\Scripts\Analisis_de_datos_extracelulares\plottingParameters';
    handles.settings = load([handles.settingsPath, '\plotSettings']);
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes neuronViewer2_0 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = neuronViewer2_0_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------- GRUPOS DE NEURONAS Y FUNCIONES QUE LOS ADMINISTRAN -----------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on selection change in neuronList.
function neuronList_Callback(hObject, eventdata, handles)

%handles.leftIndex = get(hObject,'Value'); %creo que no se usa
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function neuronList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in groupA.
function groupA_Callback(hObject, eventdata, handles)
%lista de neuronas seleccionadas
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function groupA_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function groupB_Callback(hObject, eventdata, handles)
%lista de neuronas seleccionadas
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function groupB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to groupB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddToA_button.
function AddToA_button_Callback(hObject, eventdata, handles)
%agrega a una neurona de la lista de todas las neuronas al grupo A

%si no hay neuronas cargadas en el programa no hago nada
if isempty(get(handles.neuronList, 'String'))
    return
end
%cargo la lista de nueuronas a la que quiero sumar las seleccionadas
groupList = get(handles.groupA, 'String');
%agrego las neuronas seleccionadas a la lista
groupList = addToList(handles, groupList);

set(handles.groupA, 'String', groupList)
nItems = length(groupList);
set(handles.groupA, 'Value', nItems)
set(handles.groupALength_Txt, 'String', num2str(nItems));
guidata(hObject, handles);


% --- Executes on button press in AddToB_push.
function AddToB_push_Callback(hObject, eventdata, handles)
%agrega a una neurona de la lista de todas las neuronas al grupo B

%si no hay neuronas cargadas en el programa no hago nada
if isempty(get(handles.neuronList, 'String'))
    return
end
%cargo la lista de nueuronas a la que quiero sumar las seleccionadas
groupList = get(handles.groupB, 'String');
%agrego las neuronas seleccionadas a la lista
groupList = addToList(handles, groupList);

set(handles.groupB, 'String', groupList)
nItems = length(groupList);
set(handles.groupB, 'Value', nItems)
set(handles.groupBLength_Txt, 'String', num2str(nItems));
guidata(hObject, handles);



% --- Executes on button press in RemoveA_edit.
function RemoveA_edit_Callback(hObject, eventdata, handles)
%Saca a una neurona de la lisata de neuronas seleccionadas
if isempty(get(handles.groupA, 'String'))
    return
else
    selectedList = get(handles.groupA, 'String');
    selectedList(get(handles.groupA, 'Value')) = [];
end
nItems = length(selectedList);
set(handles.groupA, 'Value', nItems)
set(handles.groupA, 'String', selectedList)
set(handles.groupALength_Txt, 'String', num2str(nItems));
guidata(hObject, handles);


% --- Executes on button press in removeB_push.
function removeB_push_Callback(hObject, eventdata, handles)
%Saca a una neurona de la lisata de neuronas seleccionadas
if isempty(get(handles.groupB, 'String'))
    return
else
    selectedList = get(handles.groupB, 'String');
    selectedList(get(handles.groupB, 'Value')) = [];
end
nItems = length(selectedList);
set(handles.groupB, 'Value', nItems)
set(handles.groupB, 'String', selectedList)
set(handles.groupBLength_Txt, 'String', num2str(nItems));
guidata(hObject, handles);


% --- Executes on button press in saveGroupA_push.
function saveGroupA_push_Callback(hObject, eventdata, handles)
%guarda la lista de neuronas seleccionadas como un archivo .mat

%cargo la lista de neuronas seleccionadas
selectedList = get(handles.groupA, 'String');
%si no hay neuronas en la lista salgo de la función
if isempty(selectedList)
    return
end
saveList(handles, selectedList)


% --- Executes on button press in saveGroupB_push.
function saveGroupB_push_Callback(hObject, eventdata, handles)
%guarda la lista de neuronas seleccionadas como un archivo .mat

%cargo la lista de neuronas seleccionadas
selectedList = get(handles.groupB, 'String');
%si no hay neuronas en la lista salgo de la función
if isempty(selectedList)
    return
end
saveList(handles, selectedList)


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

%cargo la lista de neuronas del grupo A
groupA = get(handles.groupA, 'String');
%busco el indice de la neurona a renombrar en la lista seleccionada
ALindex=[];
for i = 1:length(groupA)
    if sum(strcmp(groupA{i}, neuronList{NLindex}))
        ALindex = i;
    end
end

%cargo la lista de neuronas del grupo B
groupB = get(handles.groupB, 'String');
%busco el indice de la neurona a renombrar en la lista seleccionada
BLindex=[];
for i = 1:length(groupB)
    if sum(strcmp(groupB{i}, neuronList{NLindex}))
        BLindex = i;
    end
end

%cargo el nuevo nombre en la lista de todas las neuronas
neuronList{NLindex} = newName;
%lo cargo en la base de datos
handles.neurons{NLindex}.name = newName;

%checkeo si ALidex tiene un indice cargado (si no tiene entonces la neurona 
%no estaba en la lista de las neuronas seleccionadas y no hace falta
%modificarla)
if ~isempty(ALindex)
    %y cargo el nuevo nombre en la lista de neuronas seleccionadas
    groupA{ALindex} = newName;
end

%checkeo si BLidex tiene un indice cargado (si no tiene entonces la neurona 
%no estaba en la lista de las neuronas seleccionadas y no hace falta
%modificarla)
if ~isempty(BLindex)
    %y cargo el nuevo nombre en la lista de neuronas seleccionadas
    groupB{BLindex} = newName;
end

%ESTO ESTA CONSTRUIDO DE MANERA POBRE. SERIA MEJOR VINCULAR TODOS LOS
%NOMBRES DIRECTO A LA BASE DE DATOS EN VEZ DE MANEJAR MÚLTIPLES LISTAS.
%SE PUEDE HACER? NO SE, NO SOY PROGRAMADOR

%actualizo los datos de la GUI
set(handles.neuronList,'string',neuronList);
set(handles.groupA,'string',groupA);
set(handles.groupA, 'Value', 1);
set(handles.groupB,'string',groupB);
set(handles.groupB, 'Value', 1);
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

%si no estaba vacia cargo la lista de neuronas del grupo A
gAList = get(handles.groupA, 'String');
%busco los indices de las neuronas a eliminar que también estén en la lista
%de seleccionadas
neurons2delete = repmat({''},length(NLindex),1);
for i = 1:length(NLindex)
    neurons2delete{i} = neuronList{NLindex(i)};
end
%intersect me devuelve los indices en groupA de las neuronas a
%eliminar
[~, gALindex,~] = intersect(gAList,neurons2delete, 'stable');

%si no estaba vacia cargo la lista de neuronas del grupo B
gBList = get(handles.groupB, 'String');

%intersect me devuelve los indices en groupB de las neuronas a
%eliminar
[~, gBLindex,~] = intersect(gBList,neurons2delete, 'stable');

%ahora elimino las neuronas de la lista de todas las neuronas y de la base 
%de datos (de atras para adelante para no modificar los indices del resto 
%de las neuronas cuando elemino una)
for i = flip(NLindex)
    neuronList(i) = [];
    handles.neurons(i) = [];
end

%checkeo si gALidex tiene indices cargados (si no tiene entonces la neurona
%no estaba en la lista de las neuronas seleccionadas y no hace falta
%eliminarla)
if ~isempty(gALindex)
    %las elimino de la lista de neuronas seleccionadas
    for i = flip(gALindex)
        gAList(gALindex) = [];
    end
end

%checkeo si gALidex tiene indices cargados (si no tiene entonces la neurona
%no estaba en la lista de las neuronas seleccionadas y no hace falta
%eliminarla)
if ~isempty(gBLindex)
    %las elimino de la lista de neuronas seleccionadas
    for i = flip(gBLindex)
        gBList(gBLindex) = [];
    end
end

%actualizo la base de datos
set(handles.neuronList,'string',neuronList);
set(handles.groupA,'string',gAList);
set(handles.groupA, 'Value', 1);
set(handles.groupB,'string',gBList);
set(handles.groupB, 'Value', 1);
set(handles.neuronList, 'Value', 1);
set(handles.neuronListLength_Txt, 'String', num2str(length(neuronList)));
set(handles.groupALength_Txt, 'String', num2str(length(gAList)));
set(handles.groupBLength_Txt, 'String', num2str(length(gBList)));
guidata(hObject, handles);


% --- Executes on button press in clearGroupA_push.
function clearGroupA_push_Callback(hObject, eventdata, handles)
%Limpia la lista de neuronas seleccionadas
selectedList = {};
set(handles.groupA, 'Value', 0)
set(handles.groupA, 'String', selectedList)
set(handles.groupALength_Txt, 'String', '0');
guidata(hObject, handles);


% --- Executes on button press in clearGroupB_push.
function clearGroupB_push_Callback(hObject, eventdata, handles)
%Limpia la lista de neuronas seleccionadas
selectedList = {};
set(handles.groupB, 'Value', 0)
set(handles.groupB, 'String', selectedList)
set(handles.groupBLength_Txt, 'String', '0');
guidata(hObject, handles);


% --- Executes on button press in deleteGroupA_push.
function deleteGroupA_push_Callback(hObject, eventdata, handles)
%Elimina de las tres listas y la base de datos a todas las nueuronas de la 
%lista de neuronas seleccionadas 

%cargo la lista de neuronas seleccionadas
selectedList = get(handles.groupA, 'String');
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
%ahora checkeo si alguna de las neuronas seleccionadas está en la otra
%lista
otherList = get(handles.groupB, 'String');
%intersect me devuelve los indices en groupB de las neuronas a
%eliminar
[~, OLindex,~] = intersect(otherList, selectedList, 'stable');
for i = length(OLindex):-1:1
    otherList(OLindex(i)) = [];
end

%vacio la lista de neuronas selecionadas
selectedList = {};

%actualizo la base de datos
set(handles.neuronList,'string',neuronList);
set(handles.groupA,'string',selectedList);
set(handles.groupB, 'String', otherList);
set(handles.groupA, 'Value', 1);
set(handles.groupB, 'Value', 1);
set(handles.neuronList, 'Value', 1);
set(handles.neuronListLength_Txt, 'String', num2str(length(neuronList)));
set(handles.groupALength_Txt, 'String', '0');
set(handles.groupBLength_Txt, 'String', length(otherList));
guidata(hObject, handles);


% --- Executes on button press in deleteGroupB_push.
function deleteGroupB_push_Callback(hObject, eventdata, handles)
%Elimina de las tres listas y la base de datos a todas las nueuronas de la 
%lista de neuronas seleccionadas 

%cargo la lista de neuronas seleccionadas
selectedList = get(handles.groupB, 'String');
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
%ahora checkeo si alguna de las neuronas seleccionadas está en la otra
%lista
otherList = get(handles.groupA, 'String');
%intersect me devuelve los indices en groupB de las neuronas a
%eliminar
[~, OLindex,~] = intersect(otherList, selectedList, 'stable');
for i = length(OLindex):-1:1
    otherList(OLindex(i)) = [];
end

%vacio la lista de neuronas selecionadas
selectedList = {};

%actualizo la base de datos
set(handles.neuronList,'string',neuronList);
set(handles.groupB,'string',selectedList);
set(handles.groupA, 'String', otherList);
set(handles.groupA, 'Value', 1);
set(handles.groupB, 'Value', 1);
set(handles.neuronList, 'Value', 1);
set(handles.neuronListLength_Txt, 'String', num2str(length(neuronList)));
set(handles.groupBLength_Txt, 'String', '0');
set(handles.groupALength_Txt, 'String', length(otherList));
guidata(hObject, handles);


function text3_CreateFcn(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------- PARAMETROS DE LOS PLOTEOS ------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


% --- Executes on button press in separateStim_Check.
function separateStim_Check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.compareStim_check, 'Value', 0)
    set(handles.compareNeurons_check, 'Value', 0)
end


% --- Executes on button press in compareStim_check.
function compareStim_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.separateStim_Check, 'Value', 0)
    set(handles.compareNeurons_check, 'Value', 0)
end


% --- Executes on button press in compareNeurons_check.
function compareNeurons_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.separateStim_Check, 'Value', 0)
    set(handles.compareStim_check, 'Value', 0)
end


function mDerecho_check_Callback(hObject, eventdata, handles)


function mIzquierdo_check_Callback(hObject, eventdata, handles)


function normalize_check_Callback(hObject, eventdata, handles)


function addRastersToCompareMeans_check_Callback(hObject, eventdata, handles)


function normalizeWaves_check_Callback(hObject, eventdata, handles)


function meanWaves_check_Callback(hObject, eventdata, handles)


function addIndividualCorrelogramsA_check_Callback(hObject, eventdata, handles)


function addIndividualCorrelogramsB_check_Callback(hObject, eventdata, handles)


function meanAutoCorr_check_Callback(hObject, eventdata, handles)


function normalizeAutoCorr_check_Callback(hObject, eventdata, handles)

% --- Executes on button press in settings_push.
function settings_push_Callback(hObject, eventdata, handles)
plottingProperties(handles.settings,handles.settingsPath);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------- BOTONES QUE GENERAN PLOTS ------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in responseIndex_push.
function responseIndex_push_Callback(hObject, eventdata, handles)
NLindex = get(handles.neuronList, 'Value');
nNeurons = length(NLindex);
listStr = get(handles.stimCode_edit, 'String');
%si no hay estímulos escrito o estoy analizando los spikes espontáneos no
%hago nada
if isempty(listStr) || strcmp(listStr, 'spont')
    return
end
listCell = strsplit(listStr,' ');
stimCodes = zeros(1, length(listCell));
for i = 1:length(listCell)
    stimCodes(i) = str2double(listCell{i});
end
%intervalo de tiempo donde voy a contar los spike previos al estímulo
preStimInterval = [-16, -6];
%duración de ese intervalo de tiempo (la voy a usar para calcular la
%frequencia de disparos)
preStimDuration = abs(preStimInterval(1) - preStimInterval(2));
data = cell(1, nNeurons);
for neuron = 1:nNeurons
    for stage = 1:2
        %levanto los monitores
        mDerecho = get(handles.mDerecho_check, 'Value');
        mIzquierdo = get(handles.mIzquierdo_check, 'Value');
        %cargo la lista de todos los estímulos de esta neurona
        Estimulos = handles.neurons{NLindex(neuron)}.Estimulos;
        %la lista de los monitores de cada estimulo
        Monitores = handles.neurons{NLindex(neuron)}.Monitores;
        %los spikes de la neurona
        spkTimes = handles.neurons{NLindex(neuron)}.data;
        %el nombre de la neurona
        name = handles.neurons{NLindex(neuron)}.name;
        %elijo los estímulos a plotearpreStimInterval
        stims = checkStimAndMonitors(Estimulos,Monitores, stimCodes, ...
            mDerecho, mIzquierdo);
        %obtengo los spikes del cluster seleccionado (index indica a que
        %estimulo corresponden)
        if ~isempty(stims)
            [nStims, ~] = size(stims);
            if stage == 1
                [raster,index] = Sync(spkTimes,stims(:,2),'durations',preStimInterval);
                %freqSpkPre va a contener la frequencia de disparos previa al
                %estimulo de cada trial
                freqSpkPre = zeros(1,nStims);
                for trial = 1:nStims
                    freqSpkPre(trial) = length(raster(index == trial))/preStimDuration;
                end
            else
                tFinalMedio = mean(stims(:,3)-stims(:,2));
                [raster,index] = Sync(spkTimes,stims(:,2),'durations',[0, tFinalMedio]);
                %freqSpkDuriong va a contener la frequencia de disparos durante
                %la presentacion del estimulo de cada trial
                freqSpkDuring = zeros(1,nStims);
                for trial = 1:nStims
                    freqSpkDuring(trial) = length(raster(index == trial))/(stims(trial,3) - stims(trial, 2));
                end
            end

        else
            freqSpkPre = [];
            freqSpkDuring = [];
        end
    end
    [data{neuron}.mean, data{neuron}.sterr] = calculateResponseIndex(freqSpkPre, freqSpkDuring);
end

limits = [-1,1];
maxPlotsPerFigure = 10;
bars = cell(nNeurons,1);
nFigs = ceil (nNeurons/maxPlotsPerFigure);
curntNeuron = 1;
for fig = 1:nFigs
    figure(fig); clf;
    if nNeurons - curntNeuron > maxPlotsPerFigure
        indexToPlot = NLindex(curntNeuron:(curntNeuron+maxPlotsPerFigure-1));
    else
        indexToPlot = NLindex(curntNeuron:end);
    end
    hold on;
    for ind = 1:length(indexToPlot)
        subplot(1,maxPlotsPerFigure, ind)
        if ~isempty(data{curntNeuron}.mean)
            bars{curntNeuron}.mean = bar(curntNeuron, data{curntNeuron}.mean);
            hold on
            bars{curntNeuron}.error = errorbar(curntNeuron,data{curntNeuron}.mean,data{curntNeuron}.sterr,data{curntNeuron}.sterr);
            bars{curntNeuron}.error.Color = [0 0 0];
            ylim(limits)
            if ind  > 1
                set(gca,'ytick',[])
            else
                ylabel('response index')
            end
            hold off
        end
        curntNeuron = curntNeuron+1;
    end
end
hold off


% --- Executes on button press in CombineA.
function CombineA_Callback(hObject, eventdata, handles)
%CombineA es una función que se ejecuta cuando se presiona el boton
%"Combinar". Va a generar un PSH para cada neurona de la lista de neuronas 
%seleccionadas y al final va a hacer un PSH promedio de todas esas neuronas 
%para los estímulos seleccionados

%checkeo que haya neuronas en la lista
selectedList = get(handles.groupA, 'String');
nNeurons = length(selectedList);

%si no hay neuronas cargadas en la lista no hago nada
if nNeurons == 0
    return
elseif isempty(get(handles.stimCode_edit, 'string')) || strcmp(get(handles.stimCode_edit, 'string'), 'spont')
    %si el usuario no escribio ningun estimulo para plotear no hago nada
    return
else
    vargs = {'PSHcolor', handles.settings.PSHgAface, ...
            'PSHedgeColor', handles.settings.PSHgAedge,... 
            'smooth', handles.settings.smoothPSH,...
            'useLinePlot', handles.settings.useLinePlot, ...
            'stimUnderPlot', handles.settings.PSHstimUnderPlot, ...
            'StimHeigth', handles.settings.stimHeigth};
    combine(handles, selectedList, 'A', vargs{:});
end


% --- Executes on button press in CombineB.
function CombineB_Callback(hObject, eventdata, handles)
%CombineB es una función que se ejecuta cuando se presiona el boton
%"Combinar". Va a generar un PSH para cada neurona de la lista de neuronas 
%seleccionadas y al final va a hacer un PSH promedio de todas esas neuronas 
%para los estímulos seleccionados

%checkeo que haya neuronas en la lista
selectedList = get(handles.groupB, 'String');
nNeurons = length(selectedList);
%si no hay neuronas cargadas en la lista no hago nada
%si no hay neuronas cargadas en la lista no hago nada
if nNeurons == 0
    return
elseif isempty(get(handles.stimCode_edit, 'string')) || strcmp(get(handles.stimCode_edit, 'string'), 'spont')
    %si el usuario no escribio ningun estimulo para plotear no hago nada
    return
else
     vargs = {'PSHcolor', handles.settings.PSHgBface, ...
            'PSHedgeColor', handles.settings.PSHgBedge,... 
            'smooth', handles.settings.smoothPSH,...
            'useLinePlot', handles.settings.useLinePlot, ...
            'stimUnderPlot', handles.settings.PSHstimUnderPlot, ...
            'StimHeigth', handles.settings.stimHeigth};
    combine(handles, selectedList, 'B', vargs{:});
end


% --- Executes on button press in plotA.
function plotA_Callback(hObject, eventdata, handles)
%plotA es una función que se ejecuta cuando se presiona el boton
%"Comparar". Va a generar un raster plot y un PSH promediando esos rasters
%para cada una de las neuronas en la lista de neuronas seleccionadas (lista
%de la derecha)

%checkeo que haya neuronas en la lista
groupList = get(handles.groupA, 'String');
nNeurons = length(groupList);
%si no hay neuronas cargadas en la lista no hago nada
if nNeurons == 0
    return
end
func = handles.plottingFunct;

colorList = {handles.settings.PSHgAface, handles.settings.PSHgBface};
if handles.settings.fixPSHmaxFreq
    maxFreq = handles.settings.maxFreqPSH;
else
    maxFreq = [];
end
%func = @PlotSync;
handles.settings = load([handles.settingsPath, '/plotSettings']);
%cargo los settings de ploteo
vargs = {'RasterColor', handles.settings.raster,...
    'Position', handles.settings.position,...
    'LineWidth', handles.settings.lineWidth, ...
    'RelativeSize', handles.settings.relativeSize, ...
    'PSHcolor', handles.settings.PSHgAface, ...
    'PSHedgeColor', handles.settings.PSHgAedge,... 
    'nCols', handles.settings.nCols,...
    'nRows', handles.settings.nRows, ...
    'smooth', handles.settings.smoothPSH,...
    'span', handles.settings.smoothingSpan, ...
    'useLinePlot', handles.settings.useLinePlot, ...
    'addStdError', handles.settings.addStdError, ...
    'StimHeigth', handles.settings.stimHeigth, ...
    'StimUnderPlot', handles.settings.PSHstimUnderPlot, ...
    'ColorList', colorList, ...
    'MaxFreq', maxFreq};

groupColor = 'A'; %color del PSH
listStr = get(handles.stimCode_edit, 'string');
%si no hay estímulos escrito o estoy analizando los spikes espontáneos no
%hago nada
if isempty(listStr) || strcmp(listStr, 'spont')
    return
end

listCell = strsplit(listStr,' ');
if length(listCell) > 1
    if get(handles.separateStim_Check, 'Value')
        stimMat = str2double(listCell);
        plotPSHwithRasters_separated(handles, groupList, stimMat, groupColor,vargs{:});
        %plotList_separated(handles, func, groupList, stimMat, groupColor, color, lineWidth);
    elseif get(handles.compareStim_check, 'Value')
        plotPSHwithRasters_compareStims(handles, groupList, groupColor, vargs{:});
    elseif get(handles.compareNeurons_check, 'Value')
        plotPSHwithRasters_compareNeurons(handles, groupList, groupColor, vargs{:});
    else
        plotPSHwithRasters(handles, groupList, groupColor, vargs{:});
        %plotList(handles,func, groupList, groupColor, color, lineWidth)
    end
elseif get(handles.compareNeurons_check, 'Value')
    plotPSHwithRasters_compareNeurons(handles, groupList, groupColor, vargs{:});
else
    plotPSHwithRasters(handles, groupList, groupColor,vargs{:});
    %plotList(handles,func, groupList, groupColor, color, lineWidth)
end
guidata(hObject, handles);



% --- Executes on button press in plotB.
function plotB_Callback(hObject, eventdata, handles)
%plotB es una función que se ejecuta cuando se presiona el boton
%"Comparar". Va a generar un raster plot y un PSH promediando esos rasters
%para cada una de las neuronas en la lista de neuronas seleccionadas (lista
%de la derecha)

%checkeo que haya neuronas en la lista
groupList = get(handles.groupB, 'String');
nNeurons = length(groupList);
%si no hay neuronas cargadas en la lista no hago nada
if nNeurons == 0
    return
end
func = handles.plottingFunct;
%func = @PlotSync;
colorList = {handles.settings.PSHgAface, handles.settings.PSHgBface};
if handles.settings.fixPSHmaxFreq
    maxFreq = handles.settings.maxFreqPSH;
else
    maxFreq = [];
end

handles.settings = load([handles.settingsPath, '/plotSettings']);
%cargo los settings de ploteo
vargs = {'RasterColor', handles.settings.raster,...
    'Position', handles.settings.position,...
    'LineWidth', handles.settings.lineWidth, ...
    'RelativeSize', handles.settings.relativeSize, ...
    'PSHcolor', handles.settings.PSHgBface, ...
    'PSHedgeColor', handles.settings.PSHgBedge,...
    'nRows', handles.settings.nRows, ...
    'nCols', handles.settings.nCols, ...
    'smooth', handles.settings.smoothPSH,...
    'span', handles.settings.smoothingSpan, ...
    'useLinePlot', handles.settings.useLinePlot, ...
    'addStdError', handles.settings.addStdError, ...
    'StimHeigth', handles.settings.stimHeigth, ...
    'StimUnderPlot', handles.settings.PSHstimUnderPlot, ...
    'ColorList', colorList, ...
    'MaxFreq', maxFreq};
groupColor = 'B'; %color del PSH

listStr = get(handles.stimCode_edit, 'string');
%si no hay estímulos escrito o estoy analizando los spikes espontáneos no
%hago nada
if isempty(listStr) || strcmp(listStr, 'spont')
    return
end
listCell = strsplit(listStr,' ');

if length(listCell) > 1
    if get(handles.separateStim_Check, 'Value')
        stimMat = str2double(listCell);
        plotPSHwithRasters_separated(handles, groupList, stimMat, groupColor,vargs{:});
        %plotList_separated(handles, func, groupList, stimMat, groupColor, color, lineWidth);
    elseif get(handles.compareStim_check, 'Value')
        plotPSHwithRasters_compareStims(handles, groupList, groupColor, vargs{:});
    elseif get(handles.compareNeurons_check, 'Value')
        plotPSHwithRasters_compareNeurons(handles, groupList, groupColor, vargs{:});
    else
        plotPSHwithRasters(handles, groupList, groupColor, vargs{:});
        %plotList(handles,func, groupList, groupColor, color, lineWidth)
    end
elseif get(handles.compareNeurons_check, 'Value')
    plotPSHwithRasters_compareNeurons(handles, groupList, groupColor, vargs{:});
else
    plotPSHwithRasters(handles, groupList, groupColor,vargs{:});
    %plotList(handles,func, groupList, groupColor, color, lineWidth)
end
guidata(hObject, handles);



% --- Executes on button press in plotWaveformsA.
function plotWaveformsA_Callback(hObject, eventdata, handles)
groupList = get(handles.groupA, 'String');
neuronList = get(handles.neuronList, 'String');
nNeurons = length(groupList);
%si no hay neuronas cargadas en la lista no hago nada
if nNeurons == 0
    return
end
figure(1);clf;
[~, indList,~] = intersect(neuronList, groupList,'stable');
plotWaveforms(handles, indList)

% --- Executes on button press in plotWaveformsB.
function plotWaveformsB_Callback(hObject, eventdata, handles)
groupList = get(handles.groupB, 'String');
neuronList = get(handles.neuronList, 'String');
nNeurons = length(groupList);
%si no hay neuronas cargadas en la lista no hago nada
if nNeurons == 0
    return
end
figure(1);clf;
[~, indList,~] = intersect(neuronList, groupList,'stable');
plotWaveforms(handles, indList)


% --- Executes on button press in compareWaves.
function compareWaves_Callback(hObject, eventdata, handles)
gAList = get(handles.groupA, 'String');
gBList = get(handles.groupB, 'String');
%si alguna de las listas está vacía no hago nada.
if isempty(gAList) || isempty(gBList)
    return
end
vargs = {'Normalize', get(handles.normalizeWaves_check, 'Value'), ...
        'Means', get(handles.meanWaves_check, 'Value')};
figure(1);clf;
compareWaves(handles, gAList, gBList, vargs{:})


% --- Executes on button press in compareMeans_push.
function compareMeans_push_Callback(hObject, eventdata, handles)
%CompareMeans es una función que se ejecuta cuando se presiona el boton
%"Compara medias". Va a generar un PSH promedio para el grupo A y otro para
%el grupo B y los va a plotear en el mismo grafico
%para los estimulos seleccionados


%si alguna de las listas esta vacia no hago nada
if isempty(get(handles.groupA, 'String')) || isempty(get(handles.groupB, 'String'))
    return
end
%cargo ambas listas
gAList = get(handles.groupA, 'String');
gBList = get(handles.groupB, 'String');

doubleAxis = false; %ESTA PROPIEDAD NO ESTÁ TERMINADA, NO ANDA BIEN.

handles.settings = load([handles.settingsPath, '/plotSettings']);

%levanto la lista de estimulos
listStr = get(handles.stimCode_edit, 'string');
%si no hay estímulos escrito o estoy analizando los spikes espontáneos no
%hago nada
if isempty(listStr) || strcmp(listStr, 'spont')
    return
end

listCell = strsplit(listStr,' ');
params.stimCodes = zeros(1, length(listCell));
for stim = 1:length(listCell)
    params.stimCodes(stim) = str2double(listCell{stim});
end

%levanto los monitores
params.mDerecho = get(handles.mDerecho_check, 'Value');
params.mIzquierdo = get(handles.mIzquierdo_check, 'Value');

%levanto los tiempos
params.tPre = str2double(get(handles.tPre_edit, 'string'));
params.tPost = str2double(get(handles.tPost_edit, 'string'));

%Tambien cargo el tamaño de bins calculo el número de bins que necesito
params.binSize = str2double(get(handles.binSize_edit, 'string'));
params.nBins = round((params.tPre + params.tPost)*(1000/params.binSize));

%checkeo si pedi agregar los rasters
addRasters = get(handles.addRastersToCompareMeans_check, 'Value');

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
freq = [gAfreq gBfreq];
if handles.settings.smoothPSH
    freq(:,1) = smooth(freq(:,1), handles.settings.smoothingSpan);
    freq(:,2) = smooth(freq(:,2), handles.settings.smoothingSpan);
end
%si esta activa la opcion de normalizar
if get(handles.normalize_check, 'Value')
    %busco el valor maximo entre ambos
    maxFreq = max(freq);
    %normalizo al máximo correspondiente
    freq(:,1) = freq(:,1)/maxFreq(1);
    freq(:,2) =  freq(:,2)/maxFreq(2);
end
%armo el vector de tiempos
t = -params.tPre:(params.tPre+params.tPost)/(params.nBins-1):params.tPost;
fig = figure(1);clf;

vargs = {'PlotLines', handles.settings.useLinePlot, ...
        'Color', {handles.settings.PSHgAface, handles.settings.PSHgBface}, ...
        'DoubleAxis', doubleAxis, ...
        'StimHeigth', handles.settings.stimHeigth, ...
        'StimUnderPlot', handles.settings.PSHstimUnderPlot};
if handles.settings.fixPSHmaxFreq
    vargs = [vargs, 'TopLimit', handles.settings.maxFreqPSH];
end
%ploteo los PSH    
hPlot = plotPSH(freq, t, stims, params.tPre, params.tPost, '', vargs{:});
if ~handles.settings.useLinePlot
    setAesthetics(hPlot(1), 'FaceColor', handles.settings.PSHgAface, ...
        'EdgeColor', handles.settings.PSHgAedge);
    setAesthetics(hPlot(2), 'FaceColor', handles.settings.PSHgBface, ...
        'EdgeColor', handles.settings.PSHgBedge);
end

%agrego el error
if handles.settings.addStdError
    IDgA = unique(gAmean.neuronID);
    %recorro el grupo A para obtener un PSH de cada neurona
    for i = 1:length(IDgA) 
        [gANeuronsFreq(:,i),~] = SyncHist(gAmean.raster(gAmean.neuronID == IDgA(i)),...
                gAmean.index(gAmean.neuronID == IDgA(i)),'mode',...
                'mean', 'durations',[-params.tPre; params.tPost], 'nBins', params.nBins);
        if handles.settings.smoothPSH
            gANeuronsFreq(:,i) =  smooth(gANeuronsFreq(:,i), handles.settings.smoothingSpan);
        end
    end
    %recorro el grupo B para obtener un PSH de cada neurona
    IDgB = unique(gBmean.neuronID);
    for i = 1:length(IDgB) 
        [gBNeuronsFreq(:,i),~] = SyncHist(gBmean.raster(gBmean.neuronID == IDgB(i)),...
                gBmean.index(gBmean.neuronID == IDgB(i)),'mode',...
                'mean', 'durations',[-params.tPre; params.tPost], 'nBins', params.nBins);
    end
    %smootheo
    if handles.settings.smoothPSH
        gBNeuronsFreq(:,i) =  smooth(gBNeuronsFreq(:,i), handles.settings.smoothingSpan);
    end
    stdErrgA = zeros(params.nBins, 1);
    stdErrgB = zeros(params.nBins, 1);
    %calculo el ERROR STANDARD
    for bin = 1:params.nBins
        stdErrgA(bin,1) = std(gANeuronsFreq(bin,:)) / sqrt(gAmean.nEffectiveNeurons);
        stdErrgB(bin,1) = std(gBNeuronsFreq(bin,:)) / sqrt(gBmean.nEffectiveNeurons);
    end
    %lo normalizo
    if get(handles.normalize_check, 'Value')
        stdErrgA = stdErrgA / maxFreq(1);
        stdErrgB = stdErrgB / maxFreq(2);
    end
    %lo ploteo
    [~, errgA] = addPSHerror(t, freq(:,1), stdErrgA, handles.settings.PSHgAface);
    [~, errgB] = addPSHerror(t, freq(:,2), stdErrgB, handles.settings.PSHgBface);
end
%si esta activa la opcion de normalizar
if get(handles.normalize_check, 'Value')
    ylabel('actividad normalizada')
end
%si elegi agregar los rasters
if handles.settings.fixPSHmaxFreq
    yLimits = ylim;
    ylim([min(yLimits) handles.settings.maxFreqPSH])
    yt = yticks;
    yticks(yt(yt>0));
end
if addRasters
    nTrialsgA = max(gAmean.index);
    nTrialsgB = max(gBmean.index);
    gAcolorList = cell(1,nTrialsgA);
    gBcolorList  = cell(1,nTrialsgB);
    color = handles.settings.PSHgAface;
    for trial = 1:nTrialsgA
        gAcolorList{trial} = color;
    end
    color = handles.settings.PSHgBface;
    for trial = 1:nTrialsgB
        gBcolorList{trial} = color;
    end
    
    colorList = [gAcolorList, gBcolorList];
    if strcmp(handles.settings.position, 'bottom')
        colorList = flip(colorList);
    end
    allRaster = [gAmean.raster ; gBmean.raster];
    allIndex = [gAmean.index ;  (gBmean.index + max(gAmean.index))];
    times = [-params.tPre, params.tPost];
    vargs = {'colorList', colorList,...
        'Position', handles.settings.position,...
        'LineWidth', handles.settings.lineWidth, ...
        'RelativeSize', handles.settings.relativeSize};
    if handles.settings.fixPSHmaxFreq
        maxFreq = handles.settings.maxFreqPSH;
    else
        maxFreq = max([errgA; errgB]);
    end

    PlotRasters_oneColor(allRaster, allIndex, times,maxFreq, vargs{:})
end

legend('group A', 'group B')
guidata(hObject, handles);



% --- Executes on button press in getWaveforms_push.
function getWaveforms_push_Callback(hObject, eventdata, handles)
% NO FUNCIONA. Ver porqué no se extraen bien las wavesforms correspondientes a cada cluster
NLindex = get(handles.neuronList, 'Value');
nNeurons = length(NLindex);
oldPath = pwd;
nWaves = 300;
for neuron = 1:nNeurons
    path = handles.neurons{neuron}.file;
    cd(path)
    channel = input(['Qué canal querés usar para la waveform del registro:\n'...
        ,  path, ' cluster: ', num2str(handles.neurons{neuron}.cluster), '\n']);
    [meanWave, stdWave] = getWaveForms(handles.neurons{neuron}.cluster, channel, nWaves);
    handles.neurons{neuron}.waveform.mean = meanWave;
    handles.neurons{neuron}.waveform.std = stdWave;
end
cd(oldPath)
guidata(hObject, handles);


function doPCA_push_Callback(hObject, eventdata, handles)
%levanto la lista de neuronas y los índices de las que quiero analizar
neuronList = get(handles.neuronList, 'String');
NLindex = get(handles.neuronList, 'Value');
nNeurons = length(NLindex);
listStr = get(handles.stimCode_edit, 'string');
listCell = strsplit(listStr,' ');
stimCell = cell(1,length(listCell));
for i = 1:length(stimCell)
    stimCell{i} = str2double(listCell{i});
end
%intervalo de tiempo donde voy a contar los spike previos al estímulo
preStimInterval = [-16, -6];
%duración de ese intervalo de tiempo (la voy a usar para calcular la
%frequencia de disparos)
preStimDuration = abs(preStimInterval(1) - preStimInterval(2));
%creo la matriz que va a contener todos los datos para el PCA
data= zeros(nNeurons, length(stimCell));
for s = 1:length(stimCell)
    stimCodes = stimCell{s};
    for neuron = 1:nNeurons
        for stage = 1:3
            %levanto los monitores
            mDerecho = get(handles.mDerecho_check, 'Value');
            mIzquierdo = get(handles.mIzquierdo_check, 'Value');
            %cargo la lista de todos los estímulos de esta neurona
            Estimulos = handles.neurons{NLindex(neuron)}.Estimulos;
            %la lista de los monitores de cada estimulo
            Monitores = handles.neurons{NLindex(neuron)}.Monitores;
            %los spikes de la neurona
            spkTimes = handles.neurons{NLindex(neuron)}.data;
            %el nombre de la neurona
            name = handles.neurons{NLindex(neuron)}.name;
            %elijo los estímulos a plotearpreStimInterval
            stims = checkStimAndMonitors(Estimulos,Monitores, stimCodes, ...
                mDerecho, mIzquierdo);
            %obtengo los spikes del cluster seleccionado (index indica a que
            %estimulo corresponden)
            if ~isempty(stims)
                [nStims, ~] = size(stims);
                if stage == 1
                    [raster,index] = Sync(spkTimes,stims(:,2),'durations',preStimInterval);
                    %freqSpkPre va a contener la frequencia de disparos previa al
                    %estimulo de cada trial
                    freqSpkPre = zeros(1,nStims);
                    for trial = 1:nStims
                        freqSpkPre(trial) = length(raster(index == trial))/preStimDuration;
                    end
                elseif stage == 2
                    tFinalMedio = mean(stims(:,3)-stims(:,2));	
                    [raster,index] = Sync(spkTimes,stims(:,2),'durations',[0, tFinalMedio]);
                    %freqSpkDuriong va a contener la frequencia de disparos durante
                    %la presentacion del estimulo de cada trial
                    freqSpkDuring = zeros(1,nStims);
                    for trial = 1:nStims
                        freqSpkDuring(trial) = length(raster(index == trial))/(stims(trial,3) - stims(trial, 2));
                    end
                else
                    [raster,index] = Sync(spkTimes,stims(:,2),'durations',[tFinalMedio, tFinalMedio+ 2]);
                    freqSpkPost = zeros(1,nStims);
                    for trial = 1:nStims
                        freqSpkPost(trial) = length(raster(index == trial))/(stims(trial,3) - stims(trial, 2));
                    end
                end
                
            else
                error('no todas las neuronas seleccionadas tienen los estimulos elegidos');
            end
        end
        [respIndexDuring, ~] = calculateResponseIndex(freqSpkPre, freqSpkDuring);
        
        [respIndexPost, ~] = calculateResponseIndex(freqSpkPre, freqSpkPost);

        data(neuron,s) = respIndexDuring / respIndexPost;
    end
    
end
data = data - (mean(data));
[coeff,score,~,~,explained] = pca(data);
figure(1);clf;hold on

for i = 1:nNeurons
    plot(score(i,1), score(i, 2), 'o', 'Color', [1,(i/nNeurons), 0])
end
hold off


% --- Executes on button press in getCCorrelogram_push.
function getCCorrelogram_push_Callback(hObject, eventdata, handles)
NLindex = get(handles.neuronList, 'Value');
nNeurons = length(NLindex);
if nNeurons ~= 2 && nNeurons ~= 1
    error('Se necesitan dos neuronas seleccionadas solamente')
end
handles.settings = load([handles.settingsPath, '/plotSettings']);

binMS = handles.settings.correlogramBin;
histogramSizeMS = handles.settings.correlogramWidth;
if nNeurons == 1
    names = {handles.neurons{NLindex(1)}.name};
    type = 'auto';
else
    names{1} = handles.neurons{NLindex(1)}.name;
    names{2} = handles.neurons{NLindex(2)}.name;
    type = 'cross';
end
vargs = {'Probabilistic', handles.settings.useProbabilisticCorrelograms, 'Names', names, 'Type', type};
listStr = get(handles.stimCode_edit, 'string');
if isempty(listStr)
    %si el usuario no escribio ningun estimulo para plotear hago el CC de
    %todo el registro
    if nNeurons == 1
        getCrossCorrelogram(handles.neurons{NLindex(1)}.data, handles.neurons{NLindex(1)}.data,...
        binMS, histogramSizeMS, vargs{:});
    else
        getCrossCorrelogram(handles.neurons{NLindex(1)}.data, handles.neurons{NLindex(2)}.data,...
        binMS, histogramSizeMS, vargs{:});
    end
        
elseif strcmp(listStr, 'spont')
    for neuron = 1:nNeurons
        raster{neuron} = getSpontSpks(handles.neurons{NLindex(neuron)}, 8, 5.5);
    end
    if nNeurons == 1
        getCrossCorrelogram(raster{1}, raster{1}, binMS, histogramSizeMS, vargs{:});
    else
        getCrossCorrelogram(raster{1}, raster{2}, binMS, histogramSizeMS, vargs{:});
    end
    
else
    %extraigo los estimulos
    listCell = strsplit(listStr,' ');
    for i = 1:length(listCell)
        stimCodes(i) = str2double(listCell{i});
    end
    mDerecho = get(handles.mDerecho_check, 'Value');
    mIzquierdo = get(handles.mIzquierdo_check, 'Value');
    for neuron = 1:length(NLindex)
        [spkTimes, ~, stims] = getNeuronInfo(handles.neurons{NLindex(neuron)}, stimCodes, mDerecho, mIzquierdo);
        [raster{neuron},index{neuron}] = Sync(spkTimes,stims(:,2),'durations',[-0.4; 3.4]);
        for trial = 2:max(index{neuron})
            raster{neuron}(index{neuron} == trial)  = raster{neuron}(index{neuron} == trial) + stims(trial,2);
        end
    end
    if nNeurons == 1
        getCrossCorrelogram(raster{1}, raster{1}, binMS, histogramSizeMS, vargs{:});
    else
        getCrossCorrelogram(raster{1}, raster{2}, binMS, histogramSizeMS, vargs{:});
    end
end
guidata(hObject, handles);



% --- Executes on button press in groupCorrelogramsA_push.
function groupCorrelogramsA_push_Callback(hObject, eventdata, handles)

groupList = get(handles.groupA, 'String');
if isempty(groupList)
    return
end
addIndCorrelograms = get(handles.addIndividualCorrelogramsA_check, 'Value');
handles.settings = load([handles.settingsPath, '/plotSettings']);

vargs = {'probabilistic', true, ...
         'addIndividual', addIndCorrelograms,...
         'Smooth', handles.settings.smoothCorrelogram, ...
         'SmoothSpan', handles.settings.spanCorrelogram, ...
         'LineColor', handles.settings.correlLineColor, ...
         'BarColor', handles.settings.correlBarColor, ...
         'Width', handles.settings.correlogramWidth, ...
         'Bin', handles.settings.correlogramBin};

figure(1);clf;
plotGroupCorrelograms(handles, groupList, vargs{:});



% --- Executes on button press in groupCorrelogramsB_push.
function groupCorrelogramsB_push_Callback(hObject, eventdata, handles)

groupList = get(handles.groupB, 'String');
if isempty(groupList)
    return
end
addIndCorrelograms = get(handles.addIndividualCorrelogramsB_check, 'Value');
handles.settings = load([handles.settingsPath, '/plotSettings']);

vargs = {'probabilistic', true, ...
         'addIndividual', addIndCorrelograms,...
         'Smooth', handles.settings.smoothCorrelogram, ...
         'SmoothSpan', handles.settings.spanCorrelogram, ...
         'LineColor', handles.settings.correlLineColor, ...
         'BarColor', handles.settings.correlBarColor, ...
         'Width', handles.settings.correlogramWidth, ...
         'Bin', handles.settings.correlogramBin};

figure(1);clf;
plotGroupCorrelograms(handles, groupList, vargs{:});


% --- Executes on button press in CompareAutoCorr_push.
function CompareAutoCorr_push_Callback(hObject, eventdata, handles)
gAList = get(handles.groupA, 'String');
gBList = get(handles.groupB, 'String');

%si alguna lista esta vacia no hago nada
if isempty(gAList) || isempty(gBList)
    return;
end

%levanto las opciones que haya elegido el usuario
useMeans = get(handles.meanAutoCorr_check, 'Value');
normalize = get(handles.normalizeAutoCorr_check, 'Value');
handles.settings = load([handles.settingsPath, '/plotSettings']);

darkening = 0.4;

figure(1);clf;
if useMeans
    vargs = {'Probabilistic', true, 'addIndividual', false, 'Normalize', normalize, 'SingleColor', handles.settings.PSHgAface, 'UseMean', useMeans};
    err = plotGroupCorrelograms(handles, gAList, vargs{:});
    top = max(err);
    bottom = min(err);
    vargs = {'Probabilistic', true, 'addIndividual', false, 'Normalize', normalize, 'SingleColor', handles.settings.PSHgBface, 'UseMean', useMeans};
    err = plotGroupCorrelograms(handles, gBList, vargs{:});
    if top < max(err)
        top = max(err);
    end
    if bottom > min(err)
        bottom = min(err);
    end
    ylim([0, top])
else
    %genero la escala de colores del grupo A
    colorList = cell(1,length(gAList));
    startColor = handles.settings.PSHgAface;
    scale = linspace(1, 1-darkening, length(gAList));
    for n = 1:length(gAList)
        colorList{n} = startColor * scale(n);
    end
    vargs = {'Probabilistic', true, 'addIndividual', false, 'Normalize', normalize, 'ColorList', colorList};
    %ploteo el grupo A
    plotGroupCorrelograms(handles, gAList, vargs{:})
    
    %genero la escala de colores del grupo B
    colorList = cell(1,length(gBList));
    startColor = handles.settings.PSHgBface;
    scale = linspace(1, 1-darkening, length(gBList));
    for n = 1:length(gBList)
        colorList{n} = startColor * scale(n);
    end
    vargs = {'Probabilistic', true, 'addIndividual', false, 'Normalize', normalize, 'ColorList', colorList};
    %ploteo el grupo B  
    plotGroupCorrelograms(handles, gBList, vargs{:})
end



% --- Executes on button press in meanAndRastersA_push.
function meanAndRastersA_push_Callback(hObject, eventdata, handles)
%me da un PSH promedio del grupo con todos los rasters apilados

%checkeo que haya neuronas en la lista
selectedList = get(handles.groupA, 'String');
nNeurons = length(selectedList);
listStr = get(handles.stimCode_edit, 'string');
%si no hay neuronas cargadas en la lista no hago nada
if nNeurons == 0
    return
%si no hay estímulos escrito o estoy analizando los spikes espontáneos no
%hago nada
elseif isempty(listStr) || strcmp(listStr, 'spont')
    return
else
    handles.settings = load([handles.settingsPath, '/plotSettings']);
    vargs = {'RasterColor', handles.settings.raster,...
        'Position', handles.settings.position,...
        'LineWidth', handles.settings.lineWidth, ...
        'RelativeSize', handles.settings.relativeSize, ...
        'PSHcolor', handles.settings.PSHgAface, ...
        'PSHedgeColor', handles.settings.PSHgAedge,...
        'ColorMethod', handles.settings.colorMethod, ...
        'smooth', handles.settings.smoothPSH, ...
        'span', handles.settings.smoothingSpan, ...
        'useLinePlot', handles.settings.useLinePlot, ...
        'addStdError', handles.settings.addStdError, ...
        'StimHeigth', handles.settings.stimHeigth, ...
        'StimUnderPlot', handles.settings.PSHstimUnderPlot};
    
    groupMeanPSHAndRasters(handles, selectedList, 'A', vargs{:})
end
guidata(hObject, handles);


% --- Executes on button press in meanAndRastersB_push.
function meanAndRastersB_push_Callback(hObject, eventdata, handles)
%me da un PSH promedio del grupo con todos los rasters apilados

%checkeo que haya neuronas en la lista
selectedList = get(handles.groupB, 'String');
nNeurons = length(selectedList);
listStr = get(handles.stimCode_edit, 'string');
%si no hay neuronas cargadas en la lista no hago nada
if nNeurons == 0
    return
%si no hay estímulos escrito o estoy analizando los spikes espontáneos no
%hago nada
elseif isempty(listStr) || strcmp(listStr, 'spont')
    return
else
    handles.settings = load([handles.settingsPath, '/plotSettings']);
    vargs = {'RasterColor', handles.settings.raster,...
        'Position', handles.settings.position,...
        'LineWidth', handles.settings.lineWidth, ...
        'RelativeSize', handles.settings.relativeSize, ...
        'PSHcolor', handles.settings.PSHgBface, ...
        'PSHedgeColor', handles.settings.PSHgBedge,...
        'ColorMethod', handles.settings.colorMethod, ...
        'smooth', handles.settings.smoothPSH, ...
        'span', handles.settings.smoothingSpan, ...
        'useLinePlot', handles.settings.useLinePlot, ...
        'addStdError', handles.settings.addStdError, ...
        'StimHeigth', handles.settings.stimHeigth, ...
        'StimUnderPlot', handles.settings.PSHstimUnderPlot};
    
    groupMeanPSHAndRasters(handles, selectedList, 'B', vargs{:})
end
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------------- FUNCIONES DE PLOTEO ---------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotPSHwithRasters(handles, list, group, varargin)
nNeurons = length(list);
%levanto la lista de estimulos
listStr = get(handles.stimCode_edit, 'string');
listCell = strsplit(listStr,' ');
for i = 1:length(listCell)
    stimCodes(i) = str2double(listCell{i});
end
%Default arguments
rasterColor = [0 0 0];
lineWidth = 0.1;
position = 'bottom';
relativeSize = 0.4;
PSHface = 'default';
PSHedge = 'default';
nRows = 3;
nCols = 2;
smoothPSH = false;
span =  5;
useLinePlot = false;
addStdError =  false;
stimHeigth = 0.5;
maxFreq = [];
fixMaxFreq = false;
stimUnderPlot = false;
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
        case 'nrows'
            nRows = varargin{arg+1};
        case 'ncols' 
            nCols = varargin{arg+1};
        case 'smooth'
            smoothPSH = varargin{arg+1};
        case 'span'
            span = varargin{arg+1};
        case 'uselineplot'
            useLinePlot = varargin{arg+1};
        case 'addstderror'
            addStdError = varargin{arg+1};
        case 'stimheigth'
            stimHeigth = varargin{arg+1};
        case 'maxfreq'
            maxFreq = varargin{arg+1};
            if ~isempty(maxFreq)
                fixMaxFreq = true;
            end
        case 'stimunderplot'
            stimUnderPlot = varargin{arg+1};
    end
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
neuronIndex = zeros(1,length(list));
found = 0;

for i = 1:length(neuronList)
    %recorro la neuronList y guardo los indices donde el nombre coincide
    %con el de groupA
    if sum(strcmp(neuronList{i}, list))
        found = found+1;
        neuronIndex(found) = i;
    end
end

%ahora genero una figura y la voy cargando con los rasters y PSH
neuron = 1;
maxPlotsPerFigure = nRows*nCols;
if nNeurons == 1
    nRows = 1;
    nCols = 1;
    plotsPerFigure = 1;
elseif nNeurons < maxPlotsPerFigure
    plotsPerFigure = length(list);
    nRows = ceil(nNeurons/nCols);
else
    plotsPerFigure = maxPlotsPerFigure;
end
nFigure = 1;
%doy vueltas en el loop mientas que haya neuronas sin plotear
while neuron <= nNeurons
    figure(nFigure);clf;
    if nNeurons - (neuron-1) > plotsPerFigure
        plotsToDo = plotsPerFigure;
    else
        plotsToDo = nNeurons - (neuron-1);
    end
    %recorro el subplot
    for nPlot = 1:plotsToDo
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
        subplot(nRows, nCols, nPlot)
        hold on
        %armo el vector de frecuencias de disparo (Hz)
        [freq,~] = SyncHist(raster, index,'mode', 'mean' ,'durations',...
            [-tPre; tPost], 'nBins', nBins);
        if smoothPSH
            freq = smooth(freq, span);
        end
        
        vargs = {'PlotLines', useLinePlot, 'Color', PSHface, 'StimHeigth', stimHeigth, 'StimUnderPlot', stimUnderPlot, 'TopLimit', maxFreq};
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
        if ~fixMaxFreq
            maxFreq = max(freq);
        end
        %si quiero agregar los errores
        if addStdError
            stdErr = getPSHstdErr(raster, index, nBins, tPre, tPost, ...
                'smooth', smoothPSH, 'span', span);
            [hFill] = addPSHerror (t, freq, stdErr, PSHface);
            if ~fixMaxFreq
                maxFreq = max(hFill.YData);
            end
        end
        
        
        
        if nPlot < plotsToDo - (nCols-1)
            set(gca,'xtick',[])
            xlabel({})
            ylabel ('')
        else
            xlabel('time (s)')
            ylabel ('freq (Hz)')
        end
        
        PlotRasters_oneColor(raster, index, [-tPre, tPost],maxFreq, ...
            'Color', rasterColor, 'Linewidth', lineWidth, 'Position', position, 'relativeSize', relativeSize);
        
        if nPlot < plotsToDo-(nCols-1)
            set(gca,'xtick',[])
            xlabel({})
        else
            xlabel('time (s)')
        end
        hold off
        neuron = neuron+1;
    end
    nFigure = nFigure+1;
end



function plotPSHwithRasters_separated(handles, list, stimMat, group, varargin)

%Default arguments
rasterColor = [0 0 0];
lineWidth = 0.1;
position = 'bottom';
relativeSize = 0.4;
PSHface = 'default';
PSHedge = 'default';
nCols = 2;
smoothPSH = false;
span = 5;
useLinePlot = false;
addStdError = false;
stimHeigth = 0.5;
stimUnderPlot = false;
for arg = 1:2:length(varargin)
    switch lower(varargin{arg})
        case 'rastercolor'
            rasterColor = varargin{arg+1};
        case 'linewidth'
            lineWidth = varargin{arg+1};
        case 'position'
            position = varargin{arg+1};
            if ~strcmp(position, 'bottom') && ~strcmp(position, 'top')
                error('la posicion solo puede ser "top" o "bottom"')
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
        case 'ncols' 
            nCols = varargin{arg+1};
        case 'smooth'
            smoothPSH = varargin{arg+1};
        case 'span'
            span = varargin{arg+1};
        case 'uselineplot'
            useLinePlot = varargin{arg+1};
        case 'addstderror'
            addStdError = varargin{arg+1};
        case 'stimheigth'
            stimHeigth = varargin{arg+1};
        case 'stimunderplot'
            stimUnderPlot = varargin{arg+1};
    end
end

nNeurons = length(list);
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
neuronIndex = zeros(1,length(list));
found = 0;

for i = 1:length(neuronList)
    %recorro la neuronList y guardo los indices donde el nombre coincide
    %con el de groupA
    if sum(strcmp(neuronList{i}, list))
        found = found+1;
        neuronIndex(found) = i;
    end
end

plotsPerFigure = length(stimMat);
%creo una figura por neurona. Cada figura va a tener los rasters y PSH de
%cada estimulo por separado
for neuron = 1:nNeurons
    figure(neuron);clf;
    %cargo la lista de todos los estímulos de esta neurona
    Estimulos = handles.neurons{neuronIndex(neuron)}.Estimulos;
    %la lista de los monitores de cada estimulo
    Monitores = handles.neurons{neuronIndex(neuron)}.Monitores;
    %los spikes de la neurona
    spkTimes = handles.neurons{neuronIndex(neuron)}.data;
    %el nombre de la neurona
    name = handles.neurons{neuronIndex(neuron)}.name;
    %empiezo un contador de estimulos
    nStim = 1;
    for nsPlot = 1:plotsPerFigure
        %elijo los estímulos a plotear
        stims = checkStimAndMonitors(Estimulos,Monitores, stimMat(nStim), ...
            mDerecho, mIzquierdo);
        if isempty(stims)
            continue;
        end
        %obtengo los spikes del cluster seleccionado (index indica a que
        %estimulo corresponden)
        [raster,index] = Sync(spkTimes,stims(:,2),'durations',[-tPre; tPost]);
        %creo el titulo de la figura
        if nsPlot == 1
            titulo = ['Neurona: ', name, '  Estimulos: ', string(stimMat(nStim))];
        else
            titulo = string(stimMat(nStim));
        end
        %Ploteo los rasters
        subplot(ceil(plotsPerFigure/nCols), nCols, nsPlot)
        hold on
        %armo el vector de frecuencias de disparo (Hz)
        [freq,~] = SyncHist(raster, index,'mode', 'mean' ,'durations',...
            [-tPre; tPost], 'nBins', nBins);
         if smoothPSH
            freq = smooth(freq, span);
        end
        
        vargs = {'PlotLines', useLinePlot, 'Color', PSHface, ...
                 'StimHeigth', stimHeigth, 'StimUnderPlot', stimUnderPlot};
        %armo el vector de tiempos
        t = -tPre:(tPre+tPost)/(nBins-1):tPost;
        %polteo el PSH
        hBar = plotPSH(freq, t, stims,tPre, tPost, titulo, vargs{:});
        %seteo los detalles visuales del PSH
        if ~useLinePlot
            if strcmp(PSHface, 'default')
                setAesthetics(hBar, group);
            elseif strcmp(PSHedge, 'default')
                setAesthetics(hBar, 'FaceColor', PSHface)
            else
                setAesthetics(hBar, ...
                    'FaceColor', PSHface,...
                    'EdgeColor', PSHedge)
            end
        end
        maxFreq = max(freq);
        %si quiero agregar los errores
        if addStdError
            stdErr = getPSHstdErr(raster, index, nBins, tPre, tPost, ...
                'smooth', smoothPSH, 'span', span);
            hFill = addPSHerror (t, freq, stdErr, PSHface);
            maxFreq = max(hFill.YData);
        end
        
        %si el grafico no esta en la ultima fila saco las marcas de de
        %tiempo del eje X y el frecuencia del eje Y
        if (nsPlot) < (plotsPerFigure-1)
            set(gca,'xtick',[])
            xlabel({})
            ylabel ('')
        else
            xlabel('time (s)')
            ylabel ('freq (Hz)')
        end
        %grafico los rasters sobre el PSH
        PlotRasters_oneColor(raster, index, [-tPre, tPost],maxFreq, ...
            'Color', rasterColor, 'Linewidth', lineWidth, 'Position', position, ...
            'relativeSize', relativeSize);
        
        if (nsPlot) < (plotsPerFigure-1)
            set(gca,'xtick',[])
            xlabel({})
        else
            xlabel('time (s)')
        end
        hold off
        nStim = nStim+1;
    end
end


function plotPSHwithRasters_compareStims(handles, list, group, varargin)
nNeurons = length(list);
%levanto la lista de estimulos
listStr = get(handles.stimCode_edit, 'string');
listCell = strsplit(listStr,' ');
for i = 1:length(listCell)
    stimCodes(i) = str2double(listCell{i});
end
%Default arguments
rasterColor = [0 0 0];
lineWidth = 0.1;
position = 'bottom';
relativeSize = 0.4;
PSHface = 'default';
PSHedge = 'default';
nRows = 3;
nCols = 2;
smoothPSH = false;
span = 5;
useLinePlot = false;
addStdError = false;
stimHeigth = 0.5;
useDefaultColors = true;
maxFreq = [];
fixMaxFreq = false;
stimUnderPlot = false;
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
        case 'nrows'
            nRows = varargin{arg+1};
        case 'ncols' 
            nCols = varargin{arg+1};
        case 'smooth'
            smoothPSH = varargin{arg+1};
        case 'span'
            span = varargin{arg+1};
        case 'uselineplot'
            useLinePlot = varargin{arg+1};
        case 'addstderror'
            addStdError = varargin{arg+1};
        case 'stimheigth'
            stimHeigth = varargin{arg+1};
        case 'colorlist'
            if length(varargin{arg+1}) ~= length(stimCodes)
                warning('El numero de colores no coincide con el de estimulos, uso colores predeterminados')
            else
                stimColor = varargin{arg+1};
                useDefaultColors = false;
            end
        case 'maxfreq'
            maxFreq = varargin{arg+1};
            if ~isempty(maxFreq)
                fixMaxFreq = true;
            end
        case 'stimunderplot'
            stimUnderPlot = varargin{arg+1};
    end
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
neuronIndex = zeros(1,length(list));
found = 0;

for i = 1:length(neuronList)
    %recorro la neuronList y guardo los indices donde el nombre coincide
    %con el de groupA
    if sum(strcmp(neuronList{i}, list))
        found = found+1;
        neuronIndex(found) = i;
    end
end

%ahora genero una figura y la voy cargando con los rasters y PSH
neuron = 1;
maxPlotsPerFigure = nRows*nCols;
if nNeurons == 1
    nRows = 1;
    nCols = 1;
    plotsPerFigure = 1;
elseif nNeurons < maxPlotsPerFigure
    plotsPerFigure = length(list);
    nRows = ceil(nNeurons/nCols);
else
    plotsPerFigure = maxPlotsPerFigure;
end
nFigure = 1;
%doy vueltas en el loop mientas que haya neuronas sin plotear
while neuron <= nNeurons
    figure(nFigure);clf;
    if nNeurons - (neuron-1) > plotsPerFigure
        plotsToDo = plotsPerFigure;
    else
        plotsToDo = nNeurons - (neuron-1);
    end
    %recorro el subplot
    for nPlot = 1:plotsToDo
        subplot(nRows, nCols, nPlot)
        allRasters = [];
        allIndex = [];
        colorList = {};
        if ~fixMaxFreq
            maxFreq = [];
        end
        hold on
        %en cada subplot voy a graficar la rta de una neurona a todos los
        %estímulos seleccionados
        for stim = 1:length(stimCodes)
            %levanto los spikes de mi neurona para los estimulos
            %seleccionados
            [spkTimes, name, stims] = getNeuronInfo(handles.neurons{neuronIndex(neuron)}, stimCodes(stim), mDerecho, mIzquierdo);
            %obtengo los spikes del cluster seleccionado (index indica a que
            %estimulo corresponden)
            [raster,index] = Sync(spkTimes,stims(:,2),'durations',[-tPre; tPost]);
            %creo el titulo de la figura
            titulo = ['Neurona: ', name];
            
            %armo el vector de frecuencias de disparo (Hz)
            [freq,~] = SyncHist(raster, index,'mode', 'mean' ,'durations',...
                [-tPre; tPost], 'nBins', nBins);
            if smoothPSH
                freq = smooth(freq, span);
            end
            %armo el vector de tiempos
            t = -tPre:(tPre+tPost)/(nBins-1):tPost;
            
            %guardo la frequencia maxima para saber donde poner los raster
            if isempty(maxFreq)
                maxFreq = max(freq);
            elseif ~fixMaxFreq && maxFreq < max(freq)
                maxFreq = max(freq);
            end
            
            %cargo los argumentos optativos de plotPSH
            vargs = {'plotLines', true, 'decorations', false, 'StimUnderPlot', stimUnderPlot};
            if ~useDefaultColors || neuron > 1
                vargs = [vargs, 'Color', stimColor{stim}];
            end
            
            %grafico el PSH
            hPlot = plotPSH(freq, t, stims,tPre, tPost, titulo, vargs{:});
            hPlots(stim) =hPlot;
            
            if useDefaultColors && neuron == 1
                stimColor{stim} = hPlot.Color;
            end
            %guardo el color del PSH en la lista de colores
            if isempty(colorList)
                colorList{1} = stimColor{stim};
                for i = 2:max(index)
                    colorList = [colorList, stimColor{stim}];
                end
            else
                for i = 1:max(index)
                    colorList = [colorList, stimColor{stim}];
                end
            end
            %si quiero agregar los errores
            if addStdError
                stdErr = getPSHstdErr(raster, index, nBins, tPre, tPost, ...
                    'smooth', smoothPSH, 'span', span);
                hFill = addPSHerror (t, freq, stdErr, stimColor{stim});
                if ~fixMaxFreq && maxFreq < max(hFill.YData)
                    maxFreq = max(hFill.YData);
                end
            end
            %guardo los Rasters a plotear
            if isempty(allRasters)
                allRasters = raster;
                allIndex = index;
            else
                index = index + max(allIndex);
                allRasters = [allRasters', raster' ]';
                allIndex = [allIndex', index']';
            end
            meanStimDuration(stim) = mean(stims(:,3) - stims(:,2));
        end
        
        %ploteo los rasters con los colores correspondientes a cada
        %estimulo.
        PlotRasters_oneColor(allRasters, allIndex, [-tPre, tPost],maxFreq, ...
            'ColorList', colorList, 'Linewidth', lineWidth, 'Position', position, ...
            'relativeSize', relativeSize);
        
        if nPlot < (plotsToDo)-(nCols-1)
            set(gca,'xtick',[])
            xlabel({})
            ylabel ('freq (Hz)')
        else
            xlabel('time (s)')
            ylabel ('freq (Hz)')
        end
        hold on
        for stim = 1:length(stimCodes)
            addPSHDecorations(stimCodes(stim), meanStimDuration(stim), maxFreq, ...
                'Color', stimColor{stim}, 'Transparency', 0.3, ...
                'Heigth', stimHeigth, 'StimUnderPlot', stimUnderPlot)
        end
        legend(hPlots,listCell)
        hold off
        neuron = neuron+1;
    end
    nFigure = nFigure+1;
end


function plotPSHwithRasters_compareNeurons(handles, list, group, varargin)
nNeurons = length(list);
%levanto la lista de estimulos
listStr = get(handles.stimCode_edit, 'string');
listCell = strsplit(listStr,' ');
for i = 1:length(listCell)
    stimCodes(i) = str2double(listCell{i});
end
nStims = length(stimCodes);
%Default arguments
rasterColor = [0 0 0];
lineWidth = 0.1;
position = 'bottom';
relativeSize = 0.4;
PSHface = 'default';
PSHedge = 'default';
nRows = 3;
nCols = 2;
smoothPSH = false;
span = 5;
useLinePlot = false;
addStdError = false;
stimHeigth = 0.5;
useDefaultColors = true;
maxFreq = [];
fixMaxFreq = false;
stimUnderPlot = false;
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
        case 'nrows'
            nRows = varargin{arg+1};
        case 'ncols' 
            nCols = varargin{arg+1};
        case 'smooth'
            smoothPSH = varargin{arg+1};
        case 'span'
            span = varargin{arg+1};
        case 'uselineplot'
            useLinePlot = varargin{arg+1};
        case 'addstderror'
            addStdError = varargin{arg+1};
        case 'stimheigth'
            stimHeigth = varargin{arg+1};
        case 'colorlist'
            if length(varargin{arg+1}) ~= length(list)
                warning('El numero de colores no coincide con el de neuronas, uso colores predeterminados')
            else
                neuronColor = varargin{arg+1};
                useDefaultColors = false;
            end
        case 'maxfreq'
            maxFreq = varargin{arg+1};
            if ~isempty(maxFreq)
                fixMaxFreq = true;
            end
        case 'stimunderplot'
            stimUnderPlot = varargin{arg+1};
    end
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
neuronIndex = zeros(1,length(list));
found = 0;

for i = 1:length(neuronList)
    %recorro la neuronList y guardo los indices donde el nombre coincide
    %con el de groupA
    if sum(strcmp(neuronList{i}, list))
        found = found+1;
        neuronIndex(found) = i;
    end
end

%ahora genero una figura y la voy cargando con los rasters y PSH
stim = 1;
maxPlotsPerFigure = nRows*nCols;
if nStims == 1
    nRows = 1;
    nCols = 1;
    plotsPerFigure = 1;
elseif nStims < maxPlotsPerFigure
    plotsPerFigure = nStims;
    nRows = ceil(nStims/nCols);
else
    plotsPerFigure = maxPlotsPerFigure;
end
nFigure = 1;

%doy vueltas en el loop mientas que haya estimulos sin plotear
while stim <= nStims
    figure(nFigure);clf;
    if nStims - (stim-1) > plotsPerFigure
        plotsToDo = plotsPerFigure;
    else
        plotsToDo = nStims - (stim-1);
    end
    %recorro el subplot
    for nPlot = 1:plotsToDo
        subplot(nRows, nCols, nPlot)
        allRasters = [];
        allIndex = [];
        colorList = {};
        if ~fixMaxFreq
            maxFreq = [];
        end
        hold on
        %reccoro la lista de nueuronas. En cada subplot voy a mostrar la
        %rta de cada neurona a un mismo estimulo.
        for neuron = 1:nNeurons
            %levanto los spikes de mi neurona para los estimulos
            %seleccionados
            [spkTimes, name, stims] = getNeuronInfo(handles.neurons{neuronIndex(neuron)}, stimCodes(stim), mDerecho, mIzquierdo);
            %obtengo los spikes del cluster seleccionado (index indica a que
            %estimulo corresponden)
            [raster,index] = Sync(spkTimes,stims(:,2),'durations',[-tPre; tPost]);
            %creo el titulo de la figura
            titulo = ['Estimulo: ', string(stimCodes(stim))];
            
            %armo el vector de frecuencias de disparo (Hz)
            [freq,~] = SyncHist(raster, index,'mode', 'mean' ,'durations',...
                [-tPre; tPost], 'nBins', nBins);
            if smoothPSH
                freq = smooth(freq, span);
                f{neuron} = freq;
            end
            
            %guardo la frequencia maxima para saber donde poner los raster
            if isempty(maxFreq)
                maxFreq = max(freq);
            elseif ~fixMaxFreq && maxFreq < max(freq)
                maxFreq = max(freq);
            end
            %armo el vector de tiempos
            t = -tPre:(tPre+tPost)/(nBins-1):tPost;
            
            %cargo los argumentos optativos de plotPSH
            vargs = {'plotLines', true, 'stimHeigth', stimHeigth, ...
                     'StimUnderPlot', stimUnderPlot};
            if ~useDefaultColors || stim > 1
                vargs = [vargs, 'Color', neuronColor{neuron}];
            end
            if neuron > 1
                vargs = [vargs, 'decorations', false];
            end
            
            %grafico el PSH
             hPlot = plotPSH(freq, t, stims, tPre, tPost, titulo, vargs{:});
                
            hPlots(neuron) = hPlot;
            
            %si se trata del subplot con el primer estimulo entonces guardo
            %los colores correspondientes a cada neurona. En el siguiente 
            %subplot voy a forzar que los colores que se usen para cada
            %neurona coincidan con los del primer subplot.
            if useDefaultColors && stim == 1
                neuronColor{neuron} = hPlot.Color;
            end
            %guardo el color del PSH en la lista de colores
            if isempty(colorList)
                colorList{1} = neuronColor{neuron};
                for i = 2:max(index)
                    colorList = [colorList, neuronColor{neuron}];
                end
            else
                for i = 1:max(index)
                    colorList = [colorList, neuronColor{neuron}];
                end
            end
            %si quiero agregar el error
            if addStdError
                stdErr = getPSHstdErr(raster, index, nBins, tPre, tPost, ...
                    'smooth', smoothPSH, 'span', span);
                hFill = addPSHerror (t, freq, stdErr, neuronColor{neuron});
                if ~fixMaxFreq && maxFreq < max(hFill.YData)
                    maxFreq = max(hFill.YData);
                end
            end
            
            %guardo los Rasters a plotear
            if isempty(allRasters)
                allRasters = raster;
                allIndex = index;
            else
                index = index + max(allIndex);
                allRasters = [allRasters', raster' ]';
                allIndex = [allIndex', index']';
            end
        end
        %plote los rasters con los colores correspondientes a cada neurona
        PlotRasters_oneColor(allRasters, allIndex, [-tPre, tPost],maxFreq, ...
            'ColorList', colorList, 'Linewidth', lineWidth, 'Position', position, 'relativeSize', relativeSize);
        
        if nPlot < (plotsToDo)-(nCols-1)
            set(gca,'xtick',[])
            xlabel({})
            ylabel ('freq (Hz)')
        else
            xlabel('time (s)')
            ylabel ('freq (Hz)')
        end
        
        legend(hPlots,list, 'Location', 'northwest')
        hold off
        stim = stim+1;
    end
    nFigure = nFigure+1;
    if nNeurons == 2
        figure
        plot(f{1}, f{2}, 'o')
    end
end


function groupMeanPSHAndRasters(handles, list, group, varargin)
%grafica el PSH promedio de la lista dada de neuronas y apila los rasters
%de todos los trials de cada neurona.

lineWidth = 0.1;
rasterColor = [0.8 0.1 0.1];
position = 'bottom';
relativeSize =  0.4;
useColorList = false;
showSections = false;
PSHface = 'default';
PSHedge = 'default';
smoothPSH =  false;
span = 5;
useLinePlot = false;
addStdError = false;
stimHeigth = 0.5;
stimUnderPlot = false;
for arg = 1:2:length(varargin)
    switch lower(varargin{arg})
        case 'rastercolor'
            rasterColor = varargin{arg+1};
        case 'linewidth'
            lineWidth = varargin{arg+1};
        case 'position'
            position = varargin{arg+1};
        case 'relativesize'
            relativeSize = varargin{arg+1};
        case 'colormethod'
            if strcmp(varargin{arg+1}, 'random')
                colorMethod = 'random';
                useColorList = true;
            elseif strcmp(varargin{arg+1}, 'scale')
                colorMethod = 'scale';
                useColorList = true;
            elseif strcmp(varargin{arg+1}, 'uniform')
                colorMethod = 'uniform';
            else
                error('el colormethod es desconocido, argumento incorrecto');
            end
        case 'pshcolor'
            PSHface = varargin{arg+1};
        case 'pshedgecolor'
            PSHedge = varargin{arg+1};
        case 'showsections'
            showSections = varargin{arg+1};
        case 'smooth'
            smoothPSH = varargin{arg+1};
        case 'span'
            span = varargin{arg+1};
        case 'uselineplot'
            useLinePlot = varargin{arg+1};
        case 'addstderror'
            addStdError = varargin{arg+1};
        case 'stimheigth'
            stimHeigth = varargin{arg+1};
        case 'stimunderplot'
            stimUnderPlot = varargin{arg+1};
    end
end

nNeurons = length(list);
%levanto la lista de estimulos
listStr = get(handles.stimCode_edit, 'string');
listCell = strsplit(listStr,' ');
stimCodes = zeros(1, length(listCell));
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
neuronIndex = zeros(1,length(list));
found = 0;
for i = 1:length(neuronList)
    %recorro la neuronList y guardo los indices donde el nombre coincide
    %con el de grupo
    if sum(strcmp(neuronList{i}, list))
        found = found+1;
        neuronIndex(found) = i;
    end
end

%allRasters va a contener los timestamps de cada uno de los spikes de todas
%las neuronas (alineados al estimulo)
allRasters = [];
%allIndex va a contener el numero de trial de cada neurona
allIndex = [];
nameListPerTrial = {};
t = -tPre:(tPre+tPost)/(nBins-1):tPost;
if addStdError
    freqPerNeuron = zeros(nBins, nNeurons);
end
for neuron=1:nNeurons
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
    [raster, index] = Sync(spkTimes, stims(:,2),'durations',[-tPre; tPost]);
    if addStdError
        [freqPerNeuron(:,neuron), ~] = SyncHist(raster, index, 'mode', ...
            'mean' ,'durations', [-tPre; tPost], 'nBins', nBins);
        if smoothPSH
            freqPerNeuron(:,neuron) = smooth(freqPerNeuron(:,neuron), span);
        end
    end
    allRasters = [allRasters ; raster];
    
    %si ya hay datos cargados en allIndex modifico el indice que viene para
    %que se apile sobre el anterior
    if ~isempty(allIndex)
        %cargo los nombres de las neuronas para cada trial
        for trial = (max(allIndex)+1):(max(allIndex) + max(index))
            nameListPerTrial{trial} = name;
        end
        index = index + max(allIndex);
    else
        for trial = 1:max(index)
            nameListPerTrial{trial} = name;
        end
    end
    allIndex = [allIndex; index];
end
%nameListPerTrial = flip(nameListPerTrial);
if useColorList
    colorList = cell(1, length(nameListPerTrial));
    if showSections
        section = 1;
    end
    switch colorMethod
        case 'random'
            for trial = 1:length(colorList)
                if trial == 1
                    colorList{trial} = getDifferentRGB([0.5, 0.5, 0.5]);
                    if showSections
                        sections(section) = trial;
                        section = section + 1;
                    end
                else
                    if strcmp(nameListPerTrial{trial}, nameListPerTrial{trial-1})
                        colorList{trial} = colorList{trial-1};
                    else
                        colorList{trial} = getDifferentRGB (colorList{trial-1});
                        if showSections
                            sections(section) = trial-1;
                            section = section +1;
                        end
                    end
                    
                end
            end
            if showSections
                sections(end+1) = trial;
            end
        case 'scale'
            neuron = 1;
            if rasterColor(1) == 0
                Rscale = flip(0:(1/nNeurons):1);
            else
                Rscale = flip(0:(rasterColor(1)/nNeurons):rasterColor(1));
            end
            if rasterColor(2) == 0
                Gscale = flip(0:(1/nNeurons):1);
            else
                Gscale = flip(0:(rasterColor(2)/nNeurons):rasterColor(2));
            end
            if rasterColor(3) == 0
                Bscale = flip(0:(1/nNeurons):1);
            else
                Bscale = flip(0:(rasterColor(3)/nNeurons):rasterColor(3));
            end
            for trial = 1:length(colorList)
                if trial == 1
                    colorList{trial} = rasterColor;
                else
                    if strcmp(nameListPerTrial{trial}, nameListPerTrial{trial-1})
                        colorList{trial} = colorList{trial-1};
                    else
                        neuron = neuron +1;
                        colorList{trial} = [Rscale(neuron), Gscale(neuron), Bscale(neuron)];
                        if showSections
                            sections(section) = trial-1;
                            sections(section+1) = trial;
                            section = section +2;
                        end
                    end
                end
            end
            if showSections
                sections(end+1) = trial;
            end
    end
end

titulo = 'mean PSH';
%genero la figura
figure(1);clf;

hold on
%armo el vector de frecuencias de disparo (Hz)
[freq,~] = SyncHist(allRasters, allIndex,'mode', 'mean' ,'durations',...
    [-tPre; tPost], 'nBins', nBins);
%armo el vector de tiempos
t = -tPre:(tPre+tPost)/(nBins-1):tPost;

if smoothPSH
    freq = smooth(freq, span);
end
vargs = {'PlotLines', useLinePlot, 'Color', PSHface, 'StimHeigth', stimHeigth, 'StimUnderPlot', stimUnderPlot};

%grafico el PSH
hPlot = plotPSH(freq, t, stims,tPre, tPost, titulo, vargs{:});
if ~useLinePlot
    setAesthetics(hPlot, 'FaceColor', PSHface, 'EdgeColor', PSHedge);
end
maxFreq = max(freq);
%si quiero agregar los errores
if addStdError
    stdErr = zeros(nBins, 1);
    for bin = 1:nBins
        stdErr(bin) = std(freqPerNeuron(bin, :))/sqrt(nNeurons);
    end
    hFill = addPSHerror (t, freq, stdErr, PSHface);
    maxFreq = max(hFill.YData);
end

xlabel('time (s)')
ylabel ('freq (Hz)')
args = {allRasters, allIndex, [-tPre, tPost],maxFreq, ...
    'LineWidth', lineWidth, 'Position', position, 'relativeSize', relativeSize};

if useColorList
    args = [args, 'colorList', {colorList}];
else
    args = [args, 'Color', rasterColor];
end

if showSections
    args = [args, 'showSections', sections];
end

assignin('base', 'freq', freq)
assignin('base', 't', t)

PlotRasters_oneColor(args{:})
hold off

function plotWaveforms(handles, indexList, varargin)

useColorList = false;
useLegend = true;
normalize = false;
if ~isempty(varargin)
    for arg = 1:2:length(varargin)
        switch lower(varargin{arg})
            case 'colorlist'
                colorList = varargin{arg+1};
                useColorList = true;
            case 'uselegend'
                useLegend = varargin{arg+1};
            case 'normalize'
                normalize = varargin{arg+1};
        end
    end
end

nNeurons = length(indexList);
neuronList = get(handles.neuronList, 'String');



hold on
leg = cell(1,nNeurons);
nLeg = 1;
for neuron = indexList'
    wave = handles.neurons{neuron}.waveform;
    if normalize
        wave = wave / max(abs(wave));
    end
    leg{nLeg} = handles.neurons{neuron}.name;
    vargs = {'LineWidth', 2};
    if useColorList
        vargs = [vargs, 'Color', colorList{nLeg}];
    end
    nLeg = nLeg +1;
    plot(wave, vargs{:})
end
if useLegend
    legend(leg)
end
hold off

function compareWaves (handles, gAList, gBList, varargin)

normalize = false;
useMeans =  false;
for arg = 1:2:length(varargin)
    switch lower(varargin{arg})
        case 'normalize'
            normalize = varargin{arg+1};
        case 'means'
            useMeans = varargin{arg+1};
    end
end

neuronList = get(handles.neuronList, 'String');
darkening = 0.4;

nAneurons = length(gAList);
nBneurons = length(gBList);
[~, AindList,~] = intersect(neuronList, gAList,'stable');
[~, BindList,~] = intersect(neuronList, gBList,'stable');
if useMeans
    hold on
    nWavePoints =  length(handles.neurons{AindList(1)}.waveform);
    waves = zeros(length(gAList),nWavePoints);
    for neuron = 1:length(gAList)
        waves(neuron,:) = handles.neurons{AindList(neuron)}.waveform;
        if normalize
            waves(neuron,:) = waves(neuron,:)/abs(min(waves(neuron,:)));
        end
    end
    media = mean(waves,1);
    plot(media, 'Color', handles.settings.PSHgAface, 'LineWidth', 2);
    if length(gAList) > 1
        stderr = std(waves) / sqrt(length(gAList));
        addPSHerror (1:nWavePoints, media, stderr, handles.settings.PSHgAface);
    end
    waves = zeros(length(gBList),nWavePoints);
    for neuron = 1:length(gBList)
        waves(neuron,:) = handles.neurons{BindList(neuron)}.waveform;
        if normalize
            waves(neuron,:) = waves(neuron,:)/abs(min(waves(neuron,:)));
        end
    end
    media = mean(waves,1);
    hold on
    plot(media, 'Color', handles.settings.PSHgBface, 'LineWidth', 2);
    if length(gBList) > 1
    stderr = std(waves) / sqrt(length(gBList));
    addPSHerror (1:nWavePoints, media, stderr, handles.settings.PSHgBface);
    end
    hold off
else
    colorList = cell(1,nAneurons);
    startColor = handles.settings.PSHgAface;
    scale = linspace(1, 1-darkening, nAneurons);
    for n = 1:nAneurons
        colorList{n} = startColor * scale(n);
    end
    
    plotWaveforms(handles, AindList, 'ColorList', colorList, 'UseLegend', false, 'Normalize', normalize);
    
    colorList = cell(1,nBneurons);
    startColor = handles.settings.PSHgBface;
    scale = linspace(1, 1-darkening, nBneurons);
    for n = 1:nBneurons
        colorList{n} = startColor * scale(n);
    end
    
    plotWaveforms(handles, BindList, 'ColorList', colorList, 'UseLegend', false, 'Normalize', normalize);
    
end
if normalize
    ylim([-1 1]);
end


function err = plotGroupCorrelograms(handles, list, varargin)

addIndividual = false;
probabilistic = true;
normalize = true;
colorList = {};
color = handles.settings.correlLineColor;
useMean = false;
useSingleColor = false;
smooth = true;
smoothSpan = 3;
barColor = handles.settings.defaults.correlBarColor;
lineColor = handles.settings.defaults.correlLineColor;
widthMS = 61;
binMS = 1;
for arg = 1:2:length(varargin)
    switch lower(varargin{arg})
        case 'addindividual'
            addIndividual = varargin{arg+1};
        case 'probabilistic' 
            probabilistic = varargin{arg+1};
        case 'normalize'
            normalize = varargin{arg+1};
        case 'colorlist'
            colorList = varargin{arg+1};
        case 'usemean'
            useMean = varargin{arg+1};
        case 'singlecolor'
            color = varargin{arg+1};
            useSingleColor = true;
        case 'smooth'
            smooth = varargin{arg+1};
        case 'smoothspan'
            smoothSpan = varargin{arg+1};
        case 'barcolor'
            barColor = varargin{arg+1};
        case 'linecolor'
            lineColor = varargin{arg+1};
        case 'width'
            widthMS = varargin{arg+1};
        case 'bin'
            binMS = varargin{arg+1};
    end
end

if useSingleColor
    colorList = {};
end

%levanto la lista de nueronas
neuronList = get(handles.neuronList, 'String');
%miro los índices de las que me interesan
[~,NLindex, ~] = intersect(neuronList, list,'stable');

%seteo MakePlot y Probabilistic como falsos para estos argumentos por que
%los luego voy a calcular las probabilidades y hacer los gráficos (si
%corresponde)
vargs = {'Probabilistic', false, ...
         'MakePlot', false, ...
         'Smooth', smooth, ...
         'SmoothSpan', smoothSpan, ...
         'LineColor', lineColor, ...
         'BarColor', barColor};
%genero los vectores que van a contener los datos de los AC
trends = cell (1, length(NLindex));
binCenters = cell (1, length(NLindex));
counts = cell (1, length(NLindex));
for n = 1:length(NLindex)
    %si la neurona tiene cargados los datos
    if sum(isfield(handles.neurons{NLindex(n)},{'ACtrend', 'ACcount', 'ACbins'})) == 3 && widthMS == 61;
        trends{n} = handles.neurons{NLindex(n)}.ACtrend;
        binCenters{n} = handles.neurons{NLindex(n)}.ACbins;
        counts{n}  = handles.neurons{NLindex(n)}.ACcount;
        continue;
    else
        %sino doy una advertencia y los calculo
        warning([handles.neurons{NLindex(n)}.name ' no tiene cargados los datos del autocorrelograma, los calculo'])
        [trends{n}, binCenters{n}, ~, counts{n}] = getCrossCorrelogram(handles.neurons{NLindex(n)}.data, ...
            handles.neurons{NLindex(n)}.data, binMS, widthMS, 'names', {handles.neurons{NLindex(n)}.name}, vargs{:});
    end
end

if useMean
    hold on
    for n = 1:length(NLindex)
        if normalize
            trendData(:,n) = trends{n} / max(trends{n});
            yleg = '';
        else
            trendData(:,n) = trends{n};
            yleg = 'count';
        end
    end
    media = mean(trendData, 2);
    stdev = std(trendData, 0, 2);
    plot(binCenters{n}, media, 'Color', color, 'LineWidth', 2);
    [~, err] = addPSHerror(binCenters{n}, media, stdev, color);
    xlim([min(binCenters{n}) max(binCenters{n})]);
    ylabel(yleg)
    xlabel('time (ms) ')
else
    %ahora ploteo todos superpuestos
    hold on
    for n = 1:length(NLindex)
        if normalize
            trend = trends{n} / max(trends{n});
            yleg = '';
        else
            trend = trends{n};
            yleg = 'count';
        end
        if isempty(colorList)
            plot(binCenters{n}, trend, 'LineWidth', 2)
        else
            plot(binCenters{n}, trend, 'LineWidth', 2, 'Color', colorList{n})
        end
        xlim([min(binCenters{n}) max(binCenters{n})]);
        ylabel(yleg)
        xlabel('time (ms) ')
    end
    hold off
end

%si quiero los AC individuales
if  addIndividual
    for n = 1:length(NLindex)
        figure
        hold on
        if probabilistic
            nSpikes = sum(~isnan(handles.neurons{n}.data));
            bar(binCenters{n}, counts{n}/nSpikes, 'FaceColor', barColor, 'EdgeColor', barColor, 'BarWidth', 1)
            plot(binCenters{n}, trends{n}/nSpikes, 'Color', lineColor, 'LineWidth', 2, 'LineStyle', '-')
            yleg = 'probability';
        else
            bar(binCenters{n}, counts{n}, 'FaceColor', barColor, 'EdgeColor', barColor, 'BarWidth', 1)
            plot(binCenters{n}, trends{n}, 'Color', lineColor, 'LineWidth', 2, 'LineStyle', '-')
            yleg = 'count';
        end        
        xlim([min(binCenters{n}) max(binCenters{n})]);
        ylabel(yleg)
        xlabel('time (ms) ')
        hold off
    end
end



function raster = getSpontSpks(neuron, tPost, tPre)
for s = 1:length(neuron.Estimulos)
    if s == 1
        raster = neuron.data(neuron.data < (neuron.Estimulos(s, 2) - tPre));
    else
        raster = [raster; neuron.data(neuron.data < (neuron.Estimulos(s, 2) - tPre)...
                                        & neuron.data > (neuron.Estimulos(s-1, 2) + tPost))];
    end
end
                                      
    




