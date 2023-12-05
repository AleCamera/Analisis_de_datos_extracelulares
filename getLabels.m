function Etiquetas = getLabels(Estimulos)
Etiquetas = strings(10,1);
for i = 1:length(Estimulos)
    switch Estimulos(i,1)
        case Estimulo.Estimulo0
            Etiquetas(i,1) = 'Estimulo0';
        case Estimulo.Looming1
            Etiquetas(i,1) = 'Looming1';
        case Estimulo.Looming2
            Etiquetas(i,1) = 'Looming2';
        case Estimulo.Looming3
            Etiquetas(i,1) = 'Looming3';
        case Estimulo.Looming4
            Etiquetas(i,1) = 'Looming4';
        case Estimulo.Looming5
            Etiquetas(i,1) = 'Looming5';
        case Estimulo.Looming6
            Etiquetas(i,1) = 'Looming6';
        case Estimulo.Looming7
            Etiquetas(i,1) = 'Looming7';
        case Estimulo.Looming8
            Etiquetas(i,1) = 'Looming8';
        case Estimulo.Estimulo9
            Etiquetas(i,1) = 'Estímulo9';
        case Estimulo.Estimulo10
            Etiquetas(i,1) = 'Estímulo10';
        case Estimulo.LoomingCirc1
            Etiquetas(i,1) = 'LoomingCirc1';
        case Estimulo.LoomingCirc2
            Etiquetas(i,1) = 'LoomingCirc2';
        case Estimulo.LoomingCirc3
            Etiquetas(i,1) = 'LoomingCirc3';
        case Estimulo.LoomingCirc4
            Etiquetas(i,1) = 'LoomingCirc4';
        case Estimulo.LoomingCirc5
            Etiquetas(i,1) = 'LoomingCirc5';
        case Estimulo.LoomingCirc6
            Etiquetas(i,1) = 'LoomingCirc6';
        case Estimulo.LoomingCirc7
            Etiquetas(i,1) = 'LoomingCirc7';
        case Estimulo.LoomingCirc8
            Etiquetas(i,1) = 'LoomingCirc8';
        case Estimulo.Estimulo19
            Etiquetas(i,1) = 'Estímulo19';
        case Estimulo.Estimulo20
            Etiquetas(i,1) = 'Estímulo20';
        case Estimulo.BarraDI
            Etiquetas(i,1) = 'BarraDI';
        case Estimulo.BarraID
            Etiquetas(i,1) = 'BarraID';
        case Estimulo.BarraArribaAbajo
            Etiquetas(i,1) = 'BarraArribaAbajo';
        case Estimulo.BarraAbajArriba
            Etiquetas(i,1) = 'BarraAbajArriba';
        case Estimulo.FlujoDI
            Etiquetas(i,1) = 'FlujoDI';
        case Estimulo.FlujoID
            Etiquetas(i,1) = 'FlujoID';
        case Estimulo.FlujoArribaAbajo
            Etiquetas(i,1) = 'FlujoArribaAbajo';
        case Estimulo.FlujoAbajoArriba
            Etiquetas(i,1) = 'FlujoAbajoArriba';
        otherwise
            Etiquetas(i,1) = 'Código incorrecto';
    end
end
end