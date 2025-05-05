function protocol = generarProtocoloCrabola(nStims, options)
    fprintf(' 0) Generar protocolo\n')
    for i = 1:length(options)
        fprintf(' %d) Completar con %s\n',i,options{i})
    end
    while 1
        response = input('Elija una opcion:');
        if response == 0
            msjOpt = [newline];
            for o = 1:length(options)
                opt{o} = char(options{o});
                msjOpt = [msjOpt num2str(o) ')'  opt{o} newline];
            end
            for s = 1:nStims
                msjStrt = 'Indique la condicion del estimulo numero: ';
                while(1)
                    rta = input([msjStrt, num2str(s), msjOpt '(ingrese el numero)' newline]);
                    if isempty(rta)
                        disp("Respuesta vacia");
                    elseif rta>=1 && rta<=length(options)
                        break
                    else
                        disp("Numero fuera de rango");
                    end
                end
                protocol{s} = options{rta};
            end
            break;
        elseif response > 0 && response <= length(options)
            protocol = cell(1,nStims);
            protocol(:) = options(response);
            break;
        else
            disp('Opcion inadecuada')
        end
    end
end



