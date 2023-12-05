function setAesthetics(hBar, varargin)

%default arguments
barWidth = 0.9;
customFaceColor = false;
customEdgeColor = false;
groupColor = '';
if nargin == 2
    %si hay un solo argumento es entonces es la letra del grupo
    groupColor = varargin{1};
else
    for arg = 1:2:length(varargin)
        switch lower(varargin{arg})
            case 'facecolor'
                if strcmp(varargin{arg+1}, 'default')
                    continue;
                else
                    faceColor = varargin{arg+1};
                    customFaceColor = true;
                end
            case 'edgecolor'
                if strcmp(varargin{arg+1}, 'default')
                    continue;
                else
                    edgeColor = varargin{arg+1};
                    customEdgeColor = true;
                end
            case 'barwidth'
                barWidth = varargin{arg+1};
        end
    end
end

hBar.BarWidth = barWidth;
if customFaceColor
    hBar.FaceColor = faceColor;
else
    hBar.FaceColor = getColor(groupColor);
end
set(gca, 'TitleFontSizeMultiplier', 0.8)

if customEdgeColor
    %uso los colores cargados
    hBar.EdgeColor = edgeColor;
else
    %uso los colores default del grupo
    if groupColor == 'A'
        hBar.EdgeColor = [0.00, 0.45, 0.74];
    elseif groupColor == 'B'
        hBar.EdgeColor = [0.85, 0.33, 0.10];
    elseif groupColor == 'M'
        hBar.EdgeColor = [0.39, 0.54, 0.18];
    else
        hBar.EdgeColor =[0, 0, 0];
    end
end
