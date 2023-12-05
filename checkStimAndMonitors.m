function stims = checkStimAndMonitors(Estimulos, Monitores, stims2plot, mDerecho, mIzquierdo)

%Busco todos los indices que correspondan con el los códigos ingresados
indices = ismember(Estimulos(:,1), stims2plot);
%si no hay monitores seleccionados no ploteo nada
if mDerecho == 0 && mIzquierdo == 0
    stims = [];
    return

%si sólo se seleccionó el monitor derecho elimino los estímulos del lado
%izquierdo
elseif mDerecho == 1 && mIzquierdo == 0
    for i = 1:length(indices)
        if indices(i) == 1 && Monitores(i) ~= 'D'
            indices(i) = 0;
        end
    end
%si sólo se seleccionó el monitor izquierdo elimino los estímulos del lado
%derecho
elseif mDerecho == 0 && mIzquierdo == 1
    for i = 1:length(indices)
        if indices(i) == 1 && Monitores(i) ~= 'I'
            indices(i) = 0;
        end
    end
end

lista = find(indices);
    stims = zeros(length(lista),3);
for i = 1:length(lista)
    stims (i,:) = Estimulos (lista(i),:);
end
end