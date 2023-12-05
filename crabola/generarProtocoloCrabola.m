function protocol = generarProtocoloCrabola(nStims, options)

msjOpt = [newline];
for o = 1:length(options)
    opt{o} = char(options{o});
    msjOpt = [msjOpt num2str(o) ')'  opt{o} newline];
end
msjStrt = 'indique la condicion del estimulo numero: ';

for s = 1:nStims
    while(1)
        rta = str2num(input([msjStrt, num2str(s), newline msjOpt '(ingrese el numero)' newline], 's'));
        if rta>=1 && rta<=length(options)
            break
        else
            disp("Numero fuera de rango");
        end
    end
    protocol{s} = options{rta};
end