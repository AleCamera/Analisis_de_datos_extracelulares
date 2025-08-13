% NO USAR con vectores que despues se van promediar!! (ver Ej al final)
function angsCorr = angTo360(angulos)
[nFilas, nCol]= size(angulos); %Calculo #filas y #col
angsCorr = zeros(nFilas,nCol); %Crea una matris vacia de igual tamaño

for i = 1:nFilas
    for j = 1:nCol
        angulo = angulos(i,j); 
        if angulo>=0 && angulo<360          % (-inf:0)   -> +360
            angsCorr(i,j) = angulo;
        elseif angulo<0                     % [0:360)    ->  =
            angsCorr(i,j) = angulo+360;
        else                                % [360:+inf) -> -360
            angsCorr(i,j) = angulo-360;
        end
    end
end
end


% si promedias 350 y 10 te va a dar 180, hay que cambiar la forma de
% calcular la direccion

% Ejemplo:
% prom(330y250)=290° <=> +100 <=> prom(430y350)=390°(que es = 290+100) 
% que despues de PROMEDIAR 390° se CORRIGE a 30° 
% pero al CORREGIR el ultimo de (430y350) a (70y350) y despues PROMEDIAR: 
% prom(70y350)=210° que ~=30°
