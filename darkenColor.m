function colorList = darkenColor(startColor, darkening, nShades)
% toma startColor (color inicial como un vector RGB), darkening como una
% fraccion (0-1) de oscurecimiento y nShades (cuantos colores quiero
% generar) y me devuelve colorList (un cell array con los nuevos RGBs). Los
% colores dentro de colorList van a estar entre el color inicial y su
% versión oscurecida por la fracción darkening.

scale = linspace(1, 1-darkening, nShades);
colorList = cell(nShades, 1);
for n = 1:nShades
    colorList{n} = startColor * scale(n);
end
end