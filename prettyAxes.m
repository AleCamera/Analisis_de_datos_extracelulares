function prettyAxes(varargin)
%% Ale Camera 28-03-23
% prettyAxes(varargin) es una funcion que modifica los parametros esteticos 
% de el ultimo grafico seleccionado. No devuelve ninguna variable y no tiene
% argumentos obligatorios. Acepta una serie de argumentos optativos
% expresados como pares de string, valor. Estos son:

% nticksy   ---> modifica la cantidad de ticks del eje vertical, el valor
%                dado tiene que ser un entero. Def: 3

% nticksx   ---> modifica la cantidad de ticks del eje horizontal, el valor
%                dado tiene que ser un entero. Def: 3

% linewidth ---> modifica el espesor de linea de los ejes y ticks, el valor
%                dado tiene que ser un numero postivo. Def: 2

% fontsize  ---> modifica el tamaño del texto en los ejes, el valor dado
%                tieneque ser un entero. Def: 11

% roundingx ---> redondea los limites del eje horizontal a un múltiplo del 
%                valor dado, el valor dado tiene que ser un numero. Def: -1  

% roundingy ---> redondea los limites del ejes vertical a un múltiplo del
%                valor dado, el valor dado tiene que ser un numero. Def: -1

% renderer  ---> modifica el tipo de renderer utilizado para el grafico, el
%                el valor dado tiene que ser un string con el tipo de
%                renderer como: 'painters' (def), 'OpenGL Software', 'OpenGL Hardware'

% ADVERTENCIA: Esta funcion no cuenta con ningun tipo de inputcheck salvo
% por el nombre de los argumentos optativos, utilizar los tipos de valores
% especificados en la documentacion.


%ejemplo donde dejo todos los parametros como default salvo el tamaño de
%letra (10) y el numero de ticks de los dos ejes (5):

% prettyAxes('fontsize', 10, 'nticksx', 4, 'nticksy', 5)
nTicksY = 3;
nTicksX = 3;
linewidth = 2;
fontSize = 11;
roundingX = -1;
roundingY = -1;
renderer = 'painters';
for arg = 1:2:length(varargin)
    switch lower(varargin{arg})
        case 'nticksy'
            nTicksY = varargin{arg+1};
        case 'nticksx'
            nTicksX = varargin{arg+1};
        case 'linewidth'
            linewidth = varargin{arg+1};
        case 'fontsize'
            fontSize = varargin{arg+1};
        case 'roundingx'
            roundingX = varargin{arg+1};
        case 'roundingy'
            roundingY = varargin{arg+1};
        case 'renderer'
            renderer = varargin{arg+1};
        otherwise
            warning(['ignoring "' varargin{arg} '" argument. This is not a valid argument'])
    end
end
ax = gca;
ax.LineWidth = linewidth;
ax.FontSize = fontSize;
horLim = round(xlim, roundingX);
verLim = round(ylim, roundingY);
if horLim(1) < horLim(2)
    xticks( linspace(horLim(1), horLim(2), nTicksX));
end

if verLim(1) < verLim(2)
    yticks( linspace(verLim(1), verLim(2), nTicksY));
end
set(gcf, 'renderer', renderer)
end

