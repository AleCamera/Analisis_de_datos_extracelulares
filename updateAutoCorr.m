for n = 1:length(neurons)
        [neurons{n}.ACtrend, neurons{n}.ACbins, ~, neurons{n}.ACcount] = getCrossCorrelogram(neurons{n}.data, ...
            neurons{n}.data, 1, 61, 'names', {neurons{n}.name}, 'Probabilistic', false, 'makePlot', false);
        neurons{n}.data = neurons{n}.data(~isnan(neurons{n}.data));
end
%%
figure
hold on
for n = 1:length(neurons)
    plot(neurons{n}.ACbins, neurons{n}.ACtrend/sum(~isnan(neurons{n}.data)))
end
hold off
%%