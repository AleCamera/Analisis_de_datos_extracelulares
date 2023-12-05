%comparo flujos en un monitor contra dos monitores.

load('/home/usuario/Registros/Neuronas/M2.mat')
MLG2 = neurons;
load('/home/usuario/Registros/Neuronas/Direcionales.mat')
LCDC = neurons;
load('/home/usuario/Registros/Neuronas/B2.mat')
BLG2 = neurons;
load('/home/usuario/Registros/Neuronas/ExitacionPostEstimulo.mat')
EPE = neurons;
load('/home/usuario/Registros/Neuronas/posiblesLGs.mat')
posiblesLGs = neurons;
load('/home/usuario/Registros/Neuronas/M1.mat')
MLG1 = neurons;
load('/home/usuario/Registros/Neuronas/NR.mat')
NR = neurons;
load('/home/usuario/Registros/Neuronas/Raras.mat')
raras = neurons;
clear neurons
neurons = [raras, NR, posiblesLGs, MLG1, MLG2, BLG2, EPE, LCDC];


neu(1:length(neurons), 1) = Neuron;
nDual = 0;
for n = 1:length(neurons)
    neu(n) = Neuron(neurons{n});
    if neu(n).hasScreens(25, 'ID')
        nDual = nDual+1;
        dualNeu(nDual) = neu(n);
    end
        
end

compareVEPs(neu, dualNeu, 26, 'legend', {'una pantalla', 'dos pantallas'},...
            'smooth', true, 'span', 10, 'xlim', [-3, 18])