
newInd = zeros(length(stims),1);
count = 0;
stimTypes = unique(stims);
for  type = 1:length(stimTypes)
    stimCode = stimTypes(type);
    %stimCodes toma los valores de cada TIPO de estimulo que haya
    %presentado ordenados de codigo menor a mayor
    typeIndex = find(stims == stimCode);
    for j = 1:length(typeIndex)
        trialIndex = typeIndex(j);
        %trialIndex toma el valor de cada indice para el trial
        %correspondiente
        count = count +1;
        newInd(trialIndex) = count;
    end
    
end
%ahora tengo vector que me dice la posicion que tienen que tomar los
%indices viejos

orderedIndex = zeros(length(index),1);
for trial = 1:length(newInd)
    ind = newInd(trial);
    orderedIndex(index == ind) = trial;
end
