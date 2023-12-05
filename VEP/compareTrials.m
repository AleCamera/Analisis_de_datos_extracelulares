lw = 1;
regList = [14 17 18 19 20 24 27 1];
baseColors = [0 0 1;...
              1 0 0];
darken = 0.6;
stims = [25 26];
for r = regList
figure
subplot(2,1,1)
hold on
title({num2str(r)})
[time, VEP] = regs(r).getVEP2plot(stims(1), 'mean', true);
plot(time, VEP, 'Color', baseColors(1,:), 'LineWidth', lw*2)
[time, VEP] = regs(r).getVEP2plot(stims(2), 'mean', true);
plot(time, VEP, 'Color', baseColors(2,:), 'LineWidth', lw*2)
legend({num2str(stims(1)), num2str(stims(2))})
hold off
subplot(2,1,2)
hold on
[time, VEP] = regs(r).getVEP2plot(stims(1), 'mean', false);
plotVEPtrials(time, VEP, baseColors(1,:), darken, lw)

[time, VEP] = regs(r).getVEP2plot(stims(2), 'mean', false);
plotVEPtrials(time, VEP, baseColors(2,:), darken, lw)

hold off
end


function plotVEPtrials(time, VEP, color, darken, lw)
[~, nTrials] = size(VEP);
colorList = darkenColor(color, darken, nTrials);
for tr = 1:nTrials
    plot(time, VEP(:,tr), 'color', colorList{tr}, 'linewidth', lw)
end

end