function [spkTimes, name, stims] = getNeuronInfo(neuron, stimCodes, mDerecho, mIzquierdo)
%cargo la lista de todos los estímulos de esta neurona
Estimulos = neuron.Estimulos;
%la lista de los monitores de cada estimulo
Monitores = neuron.Monitores;
%los spikes de la neurona
spkTimes = neuron.data;
%el nombre de la neurona
name = neuron.name;
%elijo los estímulos a plotear
stims = checkStimAndMonitors(Estimulos,Monitores, stimCodes, ...
    mDerecho, mIzquierdo);
end