%% Lista de LGs en registros en crabola
%MLG2
if isunix
    list = readtable('/home/usuario/Registros/recording_list.txt', 'delimiter', ',');
elseif ispc
    list = readtable('C:\Users\Alejandro\Documents\recuperados_disco_maquina_labo\Registros\recording_list_windows2.txt', 'delimiter', ',');
end

for f = 1:height(list)
    recs(f) = CrabolaEphysRec('file', char(list.folder(f)), 'SampleFreq', list.sampleFreq(f));
end

neu_dates_MLG2 = {'2021-09-15', 3;...
                  '2021-09-16', 2;...
                  '2021-09-17', 4;...
                  '2021-10-14', 5;...
                  '2021-10-19', 4;...
                  '2021-10-28', 3;...
                  %'2021-10-29', 6;...
                  '2021-11-03', 7;...
                  };
%                   '2021-11-09', 2;...
%                   '2021-11-12', 8};

neu_dates_BLG2 = {'2021-09-24', 7;...
                  '2021-10-19', 6;...
                  '2021-10-21', 5;...
                  '2021-10-28', 2;...
                  '2021-11-10', 9;...
                  '2021-11-11', 7;...
                  '2021-11-12', 7;...
                  '2021-11-30', 4};             
     
              
[MLG2_IDs, MLG2_clu, neu_MLG2] = getNeuronRecInfo(neu_dates_MLG2, recs); 
[BLG2_IDs, BLG2_clu, neu_BLG2] = getNeuronRecInfo(neu_dates_BLG2, recs); 
%%
M2_color = [0 158 115] / 255;
B2_color = [213 50 102] / 255;
            [raster, index, fRate, fRateSTD] = getPairSpontData('asd', [B2, M2]);
            [ccg, t, tau, C] = CCG(raster, index, 'BinSize', 0.001, 'Duration', 0.12, 'mode', 'ccg', 'alpha', 0.05);
            ccg = ccg / (length(find(raster(index == 1)))* 0.001);
            figure
            title(' - BLG2')
            bar(t*1000, ccg(:,1,1), 'FaceColor', B2_color, 'EdgeColor', B2_color, 'BarWidth', 1)
            figure
            title(' - MLG2')
            bar(t*1000, ccg(:,2,2), 'FaceColor', M2_color, 'EdgeColor', M2_color, 'BarWidth', 1)
            figure
            %title()
            bar(t*1000, ccg(:,1,2), 'FaceColor', [0 0 0], 'EdgeColor', [0 0 0], 'BarWidth', 1)
            xticks([-60 0 60])
            ylim([0 23])
            ylabel('frecuencia (Hz)')
            xlabel('dt(ms)')
            prettyAxes

%%
all_IDs = [];
all_clu = [];
for r = recs
    all_IDs(end+1) = str2double(r.crabID);
    all_clu(end+1) = 2;
    if exist('neu_all', 'var')
        neu_all(end+1) = r.neurons(2);
    else
        neu_all(1) = r.neurons(2);
    end
end
%%
makeEphysSpeedCorrelations(neu_MLG2, MLG2_IDs, recs)
%%
compareConditions(neu_BLG2([1 2 3 4 5 6 7]), BLG2_IDs([1 2 3 4 5 6 7]), recs)
%%
correlateWalkingAndEphys(neu_MLG2, MLG2_IDs, recs)
%%
plotFiringRateVsSpeed(neu_BLG2, BLG2_IDs, recs)
%%
mixData_all = getMixedData(neu_all,all_IDs, recs, 'condition', 'ball', 'durations', [2 10], 'binSize', 1, 'spanephys', 300, 'spanBall', 300, 'smoothball', true);

%%
mixData_MLG2 = getMixedData(neu_MLG2,MLG2_IDs, recs, 'condition', 'ball', 'durations', [2 10], 'binSize', 30, 'spanephys', 10, 'spanBall', 10, 'smoothball', true);
%mixData_MLG2_air = getMixedData(neu_MLG2,16MLG2_IDs, recs, 'condition', 'air', 'durations', [2 6], 'binSize', 1, 'spanephys', 300);
mixData_BLG2 = getMixedData(neu_BLG2,BLG2_IDs, recs, 'condition', 'ball', 'durations', [2 10], 'binSize', 1,'spanephys', 300, 'spanBall', 300, 'smoothball', true);
mixData_BLG2_air = getMixedData(neu_BLG2,BLG2_IDs, recs, 'condition', 'air', 'durations', [2 10], 'binSize', 1, 'spanephys', 300, 'spanBall', 300, 'smoothball', true);
mixData_MLG2_air = getMixedData(neu_MLG2,MLG2_IDs, recs, 'condition', 'air', 'durations', [2 10], 'binSize', 1, 'spanephys', 300, 'spanBall', 300, 'smoothball', true);
%%
[inm_run, frz_run, run, no_run, air] = loadBLG2trials(BLG2_IDs,mixData_BLG2, mixData_BLG2_air);
%%
[inm_run_M2, frz_run_M2, run_M2, no_run_M2, air_M2] = loadMLG2trials(mixData_MLG2, MLG2_IDs, mixData_MLG2_air);
%%  
fc = find_BLG2_interactions(neu_BLG2, BLG2_IDs, recs)
%%
compare_BLG2_behaviors(run, frz_run, no_run, inm_run, air)
%%

compare_MLG2_behaviors(frz_run_M2, no_run_M2, inm_run_M2, air_M2)
%%
intr_IDs = [15 19];
intr_clus = [6 4
             2 3];
mergedData = get_LG_interactions(recs, intr_IDs, intr_clus, 'condition', 'ball', 'stim', 2, 'durations', [4 10], 'binSize', 1, 'spanephys', 300, 'spanBall', 300, 'smoothball', true);
%%
[raster, index, fRate, fRateSTD] = getPairSpontData('asd', [rec1.neurons(clu1), rec2.neurons(clu2)]);
            [ccg, t, tau, C] = CCG(raster, index, 'BinSize', 0.001, 'Duration', 0.12, 'mode', 'ccg', 'alpha', 0.05);
ccg = ccg / (length(find(raster(index == 1)))* 0.001);
            figure
            hold on
            plot(t*1000, ccg(:,1,1)/max(ccg(:,1,1)), 'Color', B2_color,'LineWidth', 2)
            plot(t*1000, ccg(:,2,2)/max(ccg(:,2,2)), 'Color', B2_color/2,'LineWidth', 2)
            ylabel('frecuencia (Hz)')
            xlabel('dt(ms)')
            xticks([-60 0 60])
            prettyAxes
%%
P1MLG2=[];
P1BLG2=[];
for i = 1:2
    %figure('position', [0 0 280 420]); hold on
    set(gcf, 'renderer', 'painters')
    figure
    for tr = 1:length(mergedData{i,1}.runs)
        subplot(length(mergedData{i,1}.runs), 1, tr)
        %figure; hold on
        hold on
        plot(mergedData{i,1}.runs(tr).time, mergedData{i,1}.runs(tr).vTras, 'k', 'linewidth', 1.5)
        ylim([0 50])
        ylabel('velocidad (cm/s)')
        yyaxis right
        plot(mergedData{i,1}.t_ephys, mergedData{i,1}.fRates(:,tr), '-r', 'linewidth', 1.5)
        P1MLG2(end+1) = mean(mergedData{i,1}.fRates(mergedData{i,1}.t_ephys > 0 & mergedData{i,1}.t_ephys > 1,tr));
        plot(mergedData{i,2}.t_ephys, mergedData{i,2}.fRates(:,tr), '-b', 'linewidth', 1.5)
        P1BLG2(end+1) = mean(mergedData{i,2}.fRates(mergedData{i,2}.t_ephys > 0.3 & mergedData{i,1}.t_ephys > 1.3,tr));
        ylabel('fdisp (Hz)')
        ylim([0 100])
        xlim([-2 7])
        if tr == 4
            xlabel('tiempo (s)')
        end
        prettyAxes
    end
end
%%
figure; hold on;
M2_color = [0 158 115] / 255;
B2_color = [213 50 102] / 255;
t_M2 = [];
fRate_M2 = [];
t_B2 = [];
fRate_B2 = [];
t_M2_beh = [];
vTras_M2 = [];
t_B2_beh = [];
vTras_B2 = [];
for i = 1:length(frz_run_M2)
    ind = (frz_run_M2(i).t_ephys > -1.9999 & frz_run_M2(i).t_ephys < 7.00001);
    t_M2(:,i) = frz_run_M2(i).t_ephys(ind);
    fRate_M2(:,i) = frz_run_M2(i).fRate(ind);
    ind_beh = (frz_run_M2(i).t_behav > -1.9999999 & frz_run_M2(i).t_behav < 7.0000000);
    t_M2_beh(:,i) = frz_run_M2(i).t_behav(ind_beh);
    vTras_M2(:,i) = frz_run_M2(i).vTras(ind_beh);
end
t_M2_mean = mean(t_M2,2);
fRate_M2_mean = mean(fRate_M2,2);
t_M2_err = std(t_M2, [], 2) / sqrt(length(frz_run_M2));
fRate_M2_err = std(fRate_M2, [], 2) / sqrt(length(frz_run_M2));

t_M2_beh_mean = mean(t_M2_beh,2);
vTras_M2_mean = mean(vTras_M2,2);
vTras_M2_err = std(vTras_M2, [], 2) / sqrt(length(inm_run_M2));

for i = 1:length(frz_run)
    ind = (frz_run(i).t_ephys > -1.9999 & frz_run(i).t_ephys < 7.00001);
    t_B2(:,i) = frz_run(i).t_ephys(ind);
    fRate_B2(:,i) = frz_run(i).fRate(ind);
    ind_beh = (frz_run(i).t_behav > -1.9999 & frz_run(i).t_behav < 7.0000);
    t_B2_beh(:,i) = frz_run(i).t_behav(ind_beh);
    vTras_B2(:,i) = frz_run(i).vTras(ind_beh);
end
t_B2_mean = mean(t_B2,2);
fRate_B2_mean = mean(fRate_B2,2);
t_B2_err = std(t_B2, [], 2) / sqrt(length(frz_run));
fRate_B2_err = std(fRate_B2, [], 2) / sqrt(length(frz_run));

t_B2_beh_mean = mean(t_B2,2);
vTras_B2_mean = mean(vTras_B2,2);
vTras_B2_err = std(vTras_B2, [], 2) / sqrt(length(inm_run));

plot(t_M2_mean, fRate_M2_mean, 'color', M2_color, 'linewidth', 2)
addPSHerror(t_M2_mean, fRate_M2_mean, fRate_M2_err, M2_color)
hold on
plot(t_B2_mean, fRate_B2_mean, 'color', B2_color, 'linewidth', 2)
addPSHerror(t_B2_mean, fRate_B2_mean, fRate_B2_err, B2_color)
ylim([0 80])
xlabel('tiempo (s)')
ylabel('frecuencia de disparo (Hz)')
hold on
%addPSHDecorations(2, 3.4, 80, 'stimunderplot', true, 'heigth', 0.15)

xlim([-2 7])
prettyAxes
yticks([0 80])

figure; hold on

plot(t_M2_beh_mean, vTras_M2_mean, 'color', M2_color, 'linewidth', 2)
addPSHerror(t_M2_beh_mean, vTras_M2_mean, vTras_M2_err, M2_color)
hold on
plot(t_B2_beh_mean, vTras_B2_mean, 'color', B2_color, 'linewidth', 2)
addPSHerror(t_B2_beh_mean, vTras_B2_mean, vTras_B2_err, B2_color)
xlabel('tiempo (s)')
ylabel('velocidad (cm/s)')
ylim([0 40])
hold on
addPSHDecorations(2, 3.4, max(ylim), 'stimunderplot', true, 'heigth', 0.15)
xlim([-2 7])
prettyAxes
yticks([0 40])

figure; hold on
t_M2 = [];
fRate_M2 = [];
t_B2 = [];
fRate_B2 = [];
t_M2_beh = [];
vTras_M2 = [];
t_B2_beh = [];
vTras_B2 = [];
for i = 1:length(inm_run_M2)
    ind = (inm_run_M2(i).t_ephys > -1.9999 & inm_run_M2(i).t_ephys < 7.00001);
    t_M2(:,i) = inm_run_M2(i).t_ephys(ind);
    fRate_M2(:,i) = inm_run_M2(i).fRate(ind);
    ind_beh = (inm_run_M2(i).t_behav > -1.9999 & inm_run_M2(i).t_behav < 7.0000);
    t_M2_beh(:,i) = inm_run_M2(i).t_behav(ind_beh);
    vTras_M2(:,i) = inm_run_M2(i).vTras(ind_beh);
end
t_M2_mean = mean(t_M2,2);
fRate_M2_mean = mean(fRate_M2,2);
fRate_M2_err = std(fRate_M2, [], 2) / sqrt(length(inm_run_M2));

t_M2_beh_mean = mean(t_M2_beh,2);
vTras_M2_mean = mean(vTras_M2,2);
vTras_M2_err = std(vTras_M2, [], 2) / sqrt(length(inm_run_M2));

for i = 1:length(inm_run)
    ind = (inm_run(i).t_ephys > -1.9999 & inm_run(i).t_ephys < 7.00001);
    t_B2(:,i) = inm_run(i).t_ephys(ind);
    fRate_B2(:,i) = inm_run(i).fRate(ind);
    ind_beh = (inm_run(i).t_behav > -1.9999999 & inm_run(i).t_behav < 7.0000);
    t_B2_beh(:,i) = inm_run(i).t_behav(ind_beh);
    vTras_B2(:,i) = inm_run(i).vTras(ind_beh);
end
t_B2_mean = mean(t_B2,2);
fRate_B2_mean = mean(fRate_B2,2);
fRate_B2_err = std(fRate_B2, [], 2) / sqrt(length(inm_run));

t_B2_beh_mean = mean(t_B2,2);
vTras_B2_mean = mean(vTras_B2,2);
vTras_B2_err = std(vTras_B2, [], 2) / sqrt(length(inm_run));

plot(t_M2_mean, fRate_M2_mean, 'color', M2_color, 'linewidth', 2)
addPSHerror(t_M2_mean, fRate_M2_mean, fRate_M2_err, M2_color)
hold on
plot(t_B2_mean, fRate_B2_mean, 'color', B2_color, 'linewidth', 2)
addPSHerror(t_B2_mean, fRate_B2_mean, fRate_B2_err, B2_color)
ylim([0 80])
xlabel('tiempo (s)')
ylabel('frecuencia de disparo (Hz)')
hold on
%addPSHDecorations(2, 3.4, 80, 'stimunderplot', true, 'heigth', 0.15)

xlim([-2 7])
prettyAxes
yticks([0 80])

figure; hold on

plot(t_M2_beh_mean, vTras_M2_mean, 'color', M2_color, 'linewidth', 2)
addPSHerror(t_M2_beh_mean, vTras_M2_mean, vTras_M2_err, M2_color)
hold on
plot(t_B2_beh_mean, vTras_B2_mean, 'color', B2_color, 'linewidth', 2)
addPSHerror(t_B2_beh_mean, vTras_B2_mean, vTras_B2_err, B2_color)
xlabel('tiempo (s)')
ylabel('velocidad (cm/s)')
ylim([0 40])
hold on
addPSHDecorations(2, 3.4, max(ylim), 'stimunderplot', true, 'heigth', 0.15)

xlim([-2 7])
prettyAxes
yticks([0 40])

figure; hold on
t_M2 = [];
fRate_M2 = [];
t_B2 = [];
fRate_B2 = [];
t_M2_beh = [];
vTras_M2 = [];
t_B2_beh = [];
vTras_B2 = [];
for i = 1:length(no_run_M2)
    ind = (no_run_M2(i).t_ephys > -1.9999 & no_run_M2(i).t_ephys < 7.00001);
    t_M2(:,i) = no_run_M2(i).t_ephys(ind);
    fRate_M2(:,i) = no_run_M2(i).fRate(ind);
    ind_beh = (no_run_M2(i).t_behav > -1.9999 & no_run_M2(i).t_behav < 7.0000);
    t_M2_beh(:,i) = no_run_M2(i).t_behav(ind_beh);
    vTras_M2(:,i) = no_run_M2(i).vTras(ind_beh);
end
t_M2_mean = mean(t_M2,2);
fRate_M2_mean = mean(fRate_M2,2);
fRate_M2_err = std(fRate_M2, [], 2) / sqrt(length(no_run_M2));

t_M2_beh_mean = mean(t_M2_beh,2);
vTras_M2_mean = mean(vTras_M2,2);
vTras_M2_err = std(vTras_M2, [], 2) / sqrt(length(no_run_M2));

for i = 1:length(no_run)
    ind = (no_run(i).t_ephys > -1.9999 & no_run(i).t_ephys < 7.00001);
    t_B2(:,i) = no_run(i).t_ephys(ind);
    fRate_B2(:,i) = no_run(i).fRate(ind);
    ind_beh = (no_run(i).t_behav > -1.9999999 & no_run(i).t_behav < 7.0000);
    t_B2_beh(:,i) = no_run(i).t_behav(ind_beh);
    vTras_B2(:,i) = no_run(i).vTras(ind_beh);
end
t_B2_mean = mean(t_B2,2);
fRate_B2_mean = mean(fRate_B2,2);
fRate_B2_err = std(fRate_B2, [], 2) / sqrt(length(no_run));

t_B2_beh_mean = mean(t_B2,2);
vTras_B2_mean = mean(vTras_B2,2);
vTras_B2_err = std(vTras_B2, [], 2) / sqrt(length(no_run));

plot(t_M2_mean, fRate_M2_mean, 'color', M2_color, 'linewidth', 2)
addPSHerror(t_M2_mean, fRate_M2_mean, fRate_M2_err, M2_color)
hold on
plot(t_B2_mean, fRate_B2_mean, 'color', B2_color, 'linewidth', 2)
addPSHerror(t_B2_mean, fRate_B2_mean, fRate_B2_err, B2_color)
ylim([0 80])
xlabel('tiempo (s)')
ylabel('frecuencia de disparo (Hz)')
hold on
%addPSHDecorations(2, 3.4, 80, 'stimunderplot', true, 'heigth', 0.15)

xlim([-2 7])
prettyAxes
yticks([0 80])

%%
mixData_MLG2_walk = getMixedData(neu_MLG2,MLG2_IDs, recs, 'condition', 'ball', 'durations', [0 600], 'binSize', 2000, 'spanephys', 5, 'spanBall', 5, 'smoothball', true, 'stim', 150);

%%
mixData = mixData_MLG2;
%mixData_air = mixData_MLG2_air;
vThresh = 10;
t_start = 0;
t_stop = 3.4;
delay_stop = 0.1;
t_early = 1;
t_post = 4.5;
delay_post = 0.1;
nPeaks = 0;
vTras_post_stacked = [];
fRate_post_stacked = [];
vTras_dur_stacked = [];
fRate_dur_stacked = [];
vTras_run = [];
vTras_freeze = [];
fRate_run = [];
fRate_freeze = [];
t_ephys_run = [];
t_ephys_freeze = [];
t_behav_run = [];
t_behav_freeze = [];
fRate_tEscs = [];
t_ephys_escs = [];
fRates_pre_esc = [];

neuIND_post_stacked = [];
neuIND = [];
vTras_post_separated = {};
fRate_post_separated = {};
neuIND_post_separated = [];
for i = 1:length(mixData)
    runs = mixData(i).runs;
    fRates = mixData(i).fRates;
    t_ephys = mixData(i).t_ephys;
    sponts = mixData(i).spontFreq.freqs;
    spontFreq_neu(i) = mixData(i).spontFreq.general.mean;
    spontFreq_neu_air(i) = mean(mixData(i).spontFreq.general.freqs(mixData(i).airIND));
    spontFreq_neu_ball(i) = mean(mixData(i).spontFreq.general.freqs(mixData(i).ballIND));
    nEscapes = 0;
    for tr = 1:length(runs)
        t_behav = mixData(i).runs(tr).time;    
        vTras_peak = max(runs(tr).vTras(t_behav > 3 & t_behav < t_stop+0.2));
        vTras_mean = mean(runs(tr).vTras(t_behav > 3 & t_behav < t_stop+0.2));
        accelPost_mean = (mean(runs(tr).vTras(t_behav > 4 & t_behav < 4.1)) - mean(runs(tr).vTras(t_behav > 3.6 & t_behav < 3.7)))/(4.05-3.65);
        fRateEarly_peak = max(fRates(t_ephys > t_start & t_ephys < t_early,tr));
        fRateEarly_mean = mean(fRates(t_ephys > t_start & t_ephys < t_early,tr));
        fRateMid_mean = mean(fRates(t_ephys > 1.8 & t_ephys < 2, tr));
        fRate_peak = max(fRates(t_ephys > 3 & t_ephys < t_stop+delay_stop,tr));
        fRate_mean = mean(fRates(t_ephys > 3 & t_ephys < t_stop+delay_stop,tr));
        vTras_esc = runs(tr).vTras(t_behav > 1.5 & t_behav < 3.5);
        vTras_dur = runs(tr).vTras(t_behav > 2 & t_behav < 3.4);
        fRate_dur = fRates(t_ephys > 2 & t_ephys < 3.4, tr);
        t_esc = t_behav(t_behav > 1.5 & t_behav < 3.5);
        
        vTras_post = runs(tr).vTras(t_behav > t_stop+delay_post & t_behav < t_post);
        fRate_post = fRates(t_ephys > t_stop+delay_post & t_ephys < t_post,tr);
        if length(vTras_post) > length(fRate_post)
            vTras_post = vTras_post(1:length(fRate_post));
        elseif length(vTras_post) < length(fRate_post)
            fRate_post = fRate_post(1:length(vTras_post));
        end
        if length(vTras_dur) > length(fRate_dur)
            vTras_dur = vTras_dur(1:length(fRate_dur));
        elseif length(vTras_dur) < length(fRate_dur)
            fRate_dur = fRate_dur(1:length(vTras_dur));
        end
        %length(fRate_dur) == length(vTras_dur)
        for bin = 1:length(vTras_esc)
            if vTras_esc(bin) > vThresh*1/10
                escStart = t_esc(bin);
                fRate_until_esc = mean(fRates(t_ephys > t_start & t_ephys < escStart));
                break
            elseif bin == length(vTras_esc)
                escStart = 0;
                fRate_until_esc = mean(fRates(t_ephys > t_start & t_ephys < escStart));
            end
        end
        
        if vTras_peak > vThresh
            nPeaks = nPeaks + 1;
            vTras_peaks(nPeaks) = vTras_peak;
            vTras_means(nPeaks) = vTras_mean;
            fRateEarly_peaks(nPeaks) = fRateEarly_peak;
            fRateEarly_means(nPeaks) = fRateEarly_mean;
            fRateMid_means(nPeaks) = fRateMid_mean;
            accelPost_means(nPeaks) = accelPost_mean;
            fRate_peaks(nPeaks) = fRate_peak;
            fRate_means(nPeaks) = fRate_mean;
            spontFreqs(nPeaks) = sponts(tr);
            t_escapes(nPeaks) = escStart;
            vTras_post_stacked = [vTras_post_stacked vTras_post'];
            fRate_post_stacked = [fRate_post_stacked fRate_post'];
            fRate_post_separated{nPeaks} = fRate_post';
            vTras_post_separated{nPeaks} = vTras_post;
            vTras_post_means(nPeaks) = mean(vTras_post);
            fRate_post_means(nPeaks) = mean(fRate_post);
            vTras_dur_stacked = [vTras_dur_stacked vTras_dur'];
            fRate_dur_stacked = [fRate_dur_stacked fRate_dur'];
            neuIND_post_separated(nPeaks) = i;
            neuIND_post_stacked = [neuIND_post_stacked ones(size(vTras_post'))*i];
            neuIND(nPeaks) = i;
            vTras_run(:,end+1) = runs(tr).vTras(t_behav >= -9.9999 & t_behav <= 10.0001);
            fRate_run(:,end+1) = fRates(:,tr);
            t_ephys_run(:,end+1) = t_ephys;
            t_behav_run(:,end+1) = t_behav(t_behav >= -9.9999 & t_behav <= 10.0001)';
            t_ephys_escs(:,end+1) = t_ephys(t_ephys > escStart - 0.5 & t_ephys < escStart + 0.5);
            fRate_tEscs(:,end+1) = fRates(t_ephys > escStart - 0.5 & t_ephys < escStart + 0.5);
            fRates_pre_esc(:,end+1) = fRate_until_esc;
            nEscapes = nEscapes+1;
        else
            vTras_freeze(:,end+1) = runs(tr).vTras(t_behav >= -9.9999 & t_behav <= 10.0001);
            fRate_freeze(:,end+1) = fRates(:,tr);
            t_ephys_freeze(:,end+1) = t_ephys;
            t_behav_freeze(:,end+1) = t_behav(t_behav >= -9.9999 & t_behav <= 10.0001)';
        end
    end
    escapes(i) = nEscapes;
    spontFreqs_general(i) = mixData(i).spontFreq.general.mean;
end
%%
x = fRate_peaks';
y = accelPost_means';
figure(20)
hold on
[R,PValue] = corrplot([x, y]);
hold off
close(20)
figure
hold on
for i = 1:length(neuIND)
%     if neuIND(i) == 7
%         continue
%     end
        plot(x(i), y(i), '.', 'linestyle', 'none', 'color', getAnimalColor(neuIND(i)), 'markersize', 20)
end
p = polyfit(x, y,1);
yfit = polyval(p,x);
plot(x,yfit, 'k') 
xlabel('peak firing rate after stimuli expansion (Hz)')
ylabel('acceleration after peak (cm/s2)')
xlimit = xlim;
ylimit = ylim;
text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 10))])

%%

t_escapes(8) = 2.319
t_escapes(17) = 1.325

for n = 1:length(t_escapes)
indx = t_ephys_run(:,n) > t_escapes(n) - 0.300001 & t_ephys_run(:,n) < t_escapes(n) + 0.30000001;
centered_fRate(:,n) = fRate_run(indx,n);
end

figure(1);clf;hold on
for n = 1:length(t_escapes)
plot(-300:299, centered_fRate(:,n), 'linewidth', 1, 'color', getAnimalColor(neuIND(n)));
end
plot(-300:299, mean(centered_fRate, 2),'linewidth', 2.5, 'color', [0 0 0], 'linestyle', '--');
xlabel('time to escape initiation (ms)')
ylabel('firing rate (Hz)')
prettyAxes()
%%
figure
hold on
nNeu = 0;
x = [];
y = [];
for an = unique(neuIND)
    if an == 8
        continue
    end
    n_neu = 0;
    n = 0;
    escVel = [];
    for i = 1:length(neuIND) 
        if neuIND(i) == an
            n = n+1;
            escVel(n) = vTras_means(i);
            %fRateEarly_tmp(n) = fRateEarly_means(i);
        end
    end
    if ~isempty(escVel)
        nNeu = nNeu+1;
        x(nNeu) = spontFreq_neu_air(an);
        %x(nNeu) = mean(fRateEarly_tmp);
        y(nNeu) = mean(escVel);
        plot(spontFreq_neu_air(an), mean(escVel), '.', 'color', getAnimalColor(an), 'markersize', 25)
        %plot(mean(fRateEarly_tmp), mean(escVel), '.', 'color', getAnimalColor(an), 'markersize', 25)
    end
    %for k = 1:length(escVel)
    %    plot(spontFreq_neu_air(an), escVel(k), 'o', 'color', getAnimalColor(an), 'markersize', 5)
    %end
        
end
x=x';
y=y';
[R, PValue] = corrcoef([x y]);
p = polyfit(x, y,1);
yfit = polyval(p,x);
plot(x,yfit, 'k') 
xlabel('spontaneous frequency in air trials (Hz)')
ylabel('mean escape velocity (cm/s)')
ylim([0, max(ylim)])
xlimit = xlim;
ylimit = ylim;
text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 10))])
%%
figure
hold on
nNeu = 0;
x = [];
y = [];
for an = unique(neuIND)
    if an == 3
        continue
    end
    n_neu = 0;
    n = 0;
    escVel = [];
    for i = 1:length(neuIND) 
        if neuIND(i) == an
            n = n+1;
            %escVel(n) = vTras_means(i);
            escVel(n) = t_escapes(i);
            %escVel(n) = fRate_means(i);
            fRateEarly_tmp(n) = fRateEarly_means(i);
        end
    end
    if ~isempty(escVel)
        nNeu = nNeu+1;
        %x(nNeu) = spontFreq_neu_air(an);
        x(nNeu) = mean(fRateEarly_tmp);
        y(nNeu) = mean(escVel);
        %plot(spontFreq_neu_air(an), mean(escVel), '.', 'color', getAnimalColor(an), 'markersize', 25)
        plot(mean(fRateEarly_tmp), mean(escVel), '.', 'color', getAnimalColor(an), 'markersize', 30)
    end
    %for k = 1:length(escVel)
    %    plot(spontFreq_neu_air(an), escVel(k), 'o', 'color', getAnimalColor(an), 'markersize', 5)
    %end
        
end
x=x';
y=y';
[R, PValue] = corrcoef([x y]);
p = polyfit(x, y,1);
yfit = polyval(p,x);
plot(x,yfit, 'k', 'linewidth', 2) 
xlabel('mean firing rate in P1 (Hz)')
%ylabel('mean escape velocity (cm/s)')
ylabel('time of escape (s)')
ylim([0, max(ylim)])
xlimit = xlim;
ylimit = ylim;
%prettyAxes;
text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 10))])
%% plot animal speed and MLG2 firerate
figure
hold on
nNeu = 0;
x = [];
y = [];
for an = unique(neuIND)
%     if an == 3
%         continue
%     end
    n_neu = 0;
    n = 0;
    vTrasSingleRuns = [];
    fRateSingleRuns = [];
    vTras_animals = [];
    vTras_animals_sterr = [];
    fRate_animals = [];
    fRate_animals_sterr = [];
    for i = 1:length(neuIND) 
        if neuIND(i) == an
            n = n+1;
            vTrasSingleRuns(:,n) = vTras_run(:,i);
            fRateSingleRuns(:,n) = fRate_run(:,i);
        end
    end
    if n > 1
        nNeu = nNeu+1;
        %x(nNeu) = spontFreq_neu_air(an);
        vTras_animals(:,nNeu) = mean(vTrasSingleRuns, 2);
        vTras_animals_sterr(:,nNeu) = std(vTrasSingleRuns,[],2)/sqrt(n);
        fRate_animals(:,nNeu) = mean(fRateSingleRuns, 2);
        fRate_animals_sterr(:,nNeu) = std(fRateSingleRuns,[],2)/sqrt(n);
        subplot(2,7,an)
        hold on
        plot(mean(t_behav_run, 2), vTras_animals(:,nNeu), 'color', getAnimalColor(an), 'LineWidth', 2)
        addPSHerror(mean(t_behav_run, 2), vTras_animals(:,nNeu),vTras_animals_sterr, getAnimalColor(an));
        xlim([-2 8])
        ylim([0 45])
        prettyAxes
        subplot(2, 7, an + max(unique(neuIND)))
        hold on
        plot(mean(t_ephys_run, 2), fRate_animals(:,nNeu), 'color', getAnimalColor(an), 'LineWidth', 2)
        addPSHerror(mean(t_ephys_run, 2), fRate_animals(:,nNeu), fRate_animals_sterr, getAnimalColor(an));
        xlim([-2 8])
        ylim([0 100])
        prettyAxes
    end
    
    %for k = 1:length(escVel)
    %    plot(spontFreq_neu_air(an), escVel(k), 'o', 'color', getAnimalColor(an), 'markersize', 5)
    %end
        
end
% x=x';
% y=y';
% [R, PValue] = corrcoef([x y]);
% p = polyfit(x, y,1);
% yfit = polyval(p,x);
% plot(x,yfit, 'k', 'linewidth', 2)
subplot(2,7,1)
ylabel('animal velocity (cm/s)')
xlim([-2 8])
%ylabel('mean escape velocity (cm/s)')
subplot(2,7,max(unique(neuIND))+1)

ylabel('MLG2 firing rate (Hz)')
xlim([-2 8])
%ylim([0, max(ylim)])
%xlimit = xlim;
%ylimit = ylim;
subplot(2, 7, 11)
xlabel('time (s)')
%text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 10))])
%%
figure
hold on
nNeu = 0;
x = [];
y = [];
for an = unique(neuIND)
    if an == 3
        continue
    end
    n_neu = 0;
    n = 0;
    escVel = [];
    for i = 1:length(neuIND) 
        if neuIND(i) == an
            n = n+1;
            escVel(n) = vTras_post_means(i);
            fRateEarly_tmp(n) = fRate_post_means(i);
        end
    end
    if ~isempty(escVel)
        nNeu = nNeu+1;
        %x(nNeu) = spontFreq_neu_air(an);
        x(nNeu) = mean(escVel);
        y(nNeu) = mean(fRateEarly_tmp);
        %plot(spontFreq_neu_air(an), mean(escVel), '.', 'color', getAnimalColor(an), 'markersize', 25)
        plot(mean(escVel), mean(fRateEarly_tmp), '.', 'color', getAnimalColor(an), 'markersize', 25)
    end
    %for k = 1:length(escVel)
    %    plot(spontFreq_neu_air(an), escVel(k), 'o', 'color', getAnimalColor(an), 'markersize', 5)
    %end
        
end
x=x';
y=y';
[R, PValue] = corrcoef([x y]);
p = polyfit(x, y,1);
yfit = polyval(p,x);
plot(x,yfit, 'k') 
xlabel('mean escape velocity in P3(cm/s)')
ylabel('mean firing rate in P3 (Hz)')
ylim([0, max(ylim)])
prettyAxes()
xlimit = xlim;
ylimit = ylim;
text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 10))])

%%
figure
hold on
nNeu = 0;
x = [];
y = [];
for an = 1:length(spontFreq_neu_air)
        nNeu = nNeu+1;
        x(an) = spontFreq_neu_air(an);
        y(an) = escapes(an)*100/4;
        plot(spontFreq_neu_air(an), escapes(an)*100/4, '.', 'color', getAnimalColor(an), 'markersize', 25)

    %for k = 1:length(escVel)
    %    plot(spontFreq_neu_air(an), escVel(k), 'o', 'color', getAnimalColor(an), 'markersize', 5)
    %end
        
end
x=x';
y=y';
[R, PValue] = corrcoef([x y]);
p = polyfit(x, y,1);
yfit = polyval(p,x);
plot(x,yfit, 'k') 
xlabel('spontaneous frequency in air trials (Hz)')
ylabel('escapes (%)')
ylim([min(ylim)-5, max(ylim)+5])
xlimit = xlim;
ylimit = ylim;
yticks([0 25 50 75 100])
text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 10))])


%%
figure
hold on
nNeu = 0;
x_air = [];
y_air = [];
for an = unique(neuIND)
    n_neu = 0;
    n = 0;
    escVel = [];
    for i = 1:length(neuIND) 
        if neuIND(i) == an
            n = n+1;
            escVel(n) = vTras_means(i);
        end
    end
    if ~isempty(escVel)
        nNeu = nNeu+1;
        x_air(nNeu) = spontFreq_neu_air(an);
        y_air(nNeu) = mean(escVel);
        x_ball(nNeu) = spontFreq_neu_ball(an);
        y_ball(nNeu) = mean(escVel);
        plot(spontFreq_neu_air(an), mean(escVel), '.', 'color', getAnimalColor(an), 'markersize', 25)
        %plot(spontFreq_neu_ball(an), mean(escVel), 'x', 'color', getAnimalColor(an), 'markersize', 25)
    end
    %for k = 1:length(escVel)
    %    plot(spontFreq_neu_air(an), escVel(k), 'o', 'color', getAnimalColor(an), 'markersize', 5)
    %end
        
end
x_air=x_air';
y_air=y_air';
[R_air, PValue_air] = corrcoef([x_air y_air]);
p = polyfit(x_air, y_air,1);
yfit = polyval(p,x_air);
l_air = plot(x_air,yfit, 'r');
% x_ball=x_ball';
% y_ball=y_ball';
% [R_ball, PValue_ball] = corrcoef([x_ball y_ball]);
% p = polyfit(x_ball, y_ball,1);
% yfit = polyval(p,x_ball);
% l_ball = plot(x_ball,yfit, 'b');
xlabel('spontaneous frequency (Hz)')
ylabel('mean escape velocity (cm/s)')
ylim([0, max(ylim)])
xlimit = xlim;
ylimit = ylim;
text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R_air(2), 2)) '   p=' num2str(round(PValue_air(2), 10))])
%%
figure(4)
hold on
for n = 1:length(data)
    if n == 77 || n == 137
        continue
    end
    runs = data(n).runs;
    runTr = 0;
    escapeStart = [];
    vtms = [];
    for tr = 1:length(runs)
        t_behav = data(n).runs(tr).time;
        plot(t_behav, data(n).runs(tr).vTras);
        
        vtms(tr) = mean(runs(tr).vTras(t_behav > 3 & t_behav < 3.4+0.2));
        vTras_esc = runs(tr).vTras(t_behav > 1 & t_behav < 3.5);
        t_esc = t_behav(t_behav > 1 & t_behav < 3.5);
        for bin = 1:length(vTras_esc)
            if vTras_esc(bin) > 3
                escapeStart(tr) = t_esc(bin);
                break
            elseif bin == length(vTras_esc)
                escapeStart(tr) = 0;
            end
        end
        if max(vtms(tr)) > 10
            runTr = runTr+1;
        end
    end
    if runTr > 1
        vtm(n) = mean(vtms(vtms>0));
        escStrt(n) = mean(escapeStart(escapeStart> 0));
        sf(n) = mean(data(n).spontFreq.general.freqs(data(n).airIND));
    end
end
xlim([-2 8])
figure(1)
hold on
%plot(sf, vtm, '.', 'markersize', 20, 'color', [0.4 0.4 0.4])
plot(sf(vtm>0), vtm(vtm>0), '.', 'markersize', 20, 'color', [0.4 0.4 0.4])
ylim([10 max(ylim)])
xlabel('spontaneous frequency air trials (Hz)')
ylabel('mean escape velocity (cm/s)')
figure(2)
hold on
plot(sf(vtm>0), escStrt(vtm>0), '.', 'markersize', 20, 'color', [0.4 0.4 0.4])
xlabel('spontaneous frequency air trials (Hz)')
ylabel('mean time of escape (cm/s)')
%%
figure(1)
hold on
nNeu = 0;
x_air = [];
y_air = [];
for an = unique(neuIND)
    n_neu = 0;
    n = 0;
    escVel = [];
    if an == 3
        continue;
    end
    for i = 1:length(neuIND) 
        if neuIND(i) == an
            n = n+1;
            escVel(n) = vTras_means(i);
        end
    end
    if ~isempty(escVel)
        nNeu = nNeu+1;
        x_air(nNeu) = spontFreq_neu_air(an);
        y_air(nNeu) = mean(escVel);
        x_ball(nNeu) = spontFreq_neu_ball(an);
        y_ball(nNeu) = mean(escVel);
        plot(spontFreq_neu_air(an), mean(escVel), '.', 'color', getAnimalColor(an), 'markersize', 35)
        %plot(spontFreq_neu_ball(an), mean(escVel), 'x', 'color', getAnimalColor(an), 'markersize', 25)
    end
    %for k = 1:length(escVel)
    %    plot(spontFreq_neu_air(an), escVel(k), 'o', 'color', getAnimalColor(an), 'markersize', 5)
    %end
        
end
x_air=x_air';
y_air=y_air';
[R_air, PValue_air] = corrcoef([x_air y_air]);
p = polyfit(x_air, y_air,1);
yfit = polyval(p,x_air);
l_air = plot(x_air,yfit, 'k', 'linewidth', 2);
% x_ball=x_ball';
% y_ball=y_ball';
% [R_ball, PValue_ball] = corrcoef([x_ball y_ball]);
% p = polyfit(x_ball, y_ball,1);
% yfit = polyval(p,x_ball);
% l_ball = plot(x_ball,yfit, 'b');
xlabel('spontaneous frequency air trials (Hz)')
ylabel('mean escape velocity (cm/s)')
ylim([0, max(ylim)])
xlimit = xlim;
ylimit = ylim;
text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R_air(2), 2)) '   p=' num2str(round(PValue_air(2), 10))])


%%
figure(2)
hold on
nNeu = 0;
x_air = [];
y_air = [];
for an = unique(neuIND)
    n_neu = 0;
    n = 0;
    escTime = [];
    if an == 3
        continue;
    end
    for i = 1:length(neuIND) 
        if neuIND(i) == an
            n = n+1;
            escTime(n) = t_escapes(i);
        end
    end
    if ~isempty(escTime)
        nNeu = nNeu+1;
        x_air(nNeu) = spontFreq_neu_air(an);
        y_air(nNeu) = mean(escTime);
        x_ball(nNeu) = spontFreq_neu_ball(an);
        y_ball(nNeu) = mean(escTime);
        plot(spontFreq_neu_air(an), mean(escTime), '.', 'color', getAnimalColor(an), 'markersize', 35)
        %plot(spontFreq_neu_ball(an), mean(escTime), 'x', 'color', getAnimalColor(an), 'markersize', 25)
    end
    %for k = 1:length(escVel)
    %    plot(spontFreq_neu_air(an), escVel(k), 'o', 'color', getAnimalColor(an), 'markersize', 5)
    %end
        
end
x_air=x_air';
y_air=y_air';
[R_air, PValue_air] = corrcoef([x_air y_air]);
p = polyfit(x_air, y_air,1);
yfit = polyval(p,x_air);
l_air = plot(x_air,yfit, 'k', 'linewidth', 2);
% x_ball=x_ball';
% y_ball=y_ball';
% [R_ball, PValue_ball] = corrcoef([x_ball y_ball]);
% p = polyfit(x_ball, y_ball,1);
% yfit = polyval(p,x_ball);
% l_ball = plot(x_ball,yfit, 'b');
xlabel('spontaneous frequency (Hz)')
ylabel('mean time of escape start (cm/s)')
ylim([1, max(ylim)])
xlimit = xlim;
ylimit = ylim;
text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R_air(2), 2)) '   p=' num2str(round(PValue_air(2), 10))])


%%

x = fRateEarly_means';
%y = t_escapes';
y = fRate_means';
figure(20)
hold on
[R,PValue] = corrplot([x, y]);
hold off
close(20)
figure
hold on
for i = 1:length(neuIND)
%     if neuIND(i) == 7
%         continue
%     end
        plot(x(i), y(i), '.', 'linestyle', 'none', 'color', getAnimalColor(neuIND(i)), 'markersize', 30)

end
p = polyfit(x, y,1);
yfit = polyval(p,x);
plot(x,yfit, 'k')
xlabel('firing rate on the first second (Hz)')
ylabel('time of escape (s)')
xlimit = xlim;
ylimit = ylim;
ax = gca;
ax.LineWidth = 2;
text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 10))])
%%
x = fRateEarly_means';
%y = vTras_means';
y = fRate_means';
figure(20)
hold on
[R,PValue] = corrplot([x, y]);
hold off
close(20)
figure
hold on
for i = 1:length(neuIND)
%     if neuIND(i) == 7
%         continue
%     end
        plot(x(i), y(i), '.', 'linestyle', 'none', 'color', getAnimalColor(neuIND(i)), 'markersize', 20)

end
p = polyfit(x, y,1);
yfit = polyval(p,x);
plot(x,yfit, 'k') 
xlabel('firing rate on the first second (Hz)')
ylabel('mean escape velocity (cm/s)')
xlimit = xlim;
ylimit = ylim;
text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 10))])
%%
x = fRate_means';
y = vTras_means';
figure(20)
hold on
[R,PValue] = corrplot([x, y]);
hold off
close(20)
figure
hold on
for i = 1:length(neuIND)
%     if neuIND(i) == 7
%         continue
%     end
        plot(x(i), y(i), '.', 'linestyle', 'none', 'color', getAnimalColor(neuIND(i)), 'markersize', 20)

end
p = polyfit(x, y,1);
yfit = polyval(p,x);
plot(x,yfit, 'k') 
xlabel('mean firing rate (Hz)')
ylabel('mean escape velocity (cm/s)')
xlimit = xlim;
ylimit = ylim;
text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 10))])

x = fRateEarly_means';
y = fRate_means';
figure(20)
hold on
[R,PValue] = corrplot([x, y]);
hold off
close(20)
figure
hold on
for i = 1:length(neuIND)
%     if neuIND(i) == 7
%         continue
%     end
        plot(x(i), y(i), '.', 'linestyle', 'none', 'color', getAnimalColor(neuIND(i)), 'markersize', 20)

end
p = polyfit(x, y,1);
yfit = polyval(p,x);
plot(x,yfit, 'k') 
xlabel('peak firing rate on the first second (Hz)')
ylabel('peak firing rate (cm/s)')
xlimit = xlim;
ylimit = ylim;
text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 10))])
%%
x = vTras_post_means';
y = fRate_post_means';
figure(20)
hold on
[R,PValue] = corrplot([x, y]);
hold off
close(20)
figure
hold on
for i = 1:length(neuIND)
%     if neuIND(i) == 3
%         continue
%     end
        plot(x(i), y(i), '.', 'linestyle', 'none', 'color', getAnimalColor(neuIND(i)), 'markersize', 30)

end
p = polyfit(x, y,1);
yfit = polyval(p,x);
plot(x,yfit, 'k', 'linewidth', 1.5) 
xlabel('running speed on P3 (cm/s)')
ylabel('firing rate on P3 (Hz)')
ax = gca;
ax.LineWidth = 2;
ax.FontSize = 11;
xlimit = xlim;
ylimit = ylim;
xticks([0 10 20 30 40]);
yticks([0 10 20 30 40]);
text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 10))])

%%
x = vTras_means';
y = fRate_post_means';

figure(20)
hold on
[R,PValue] = corrplot([x, y]);
hold off
close(20)
figure
hold on
for i = 1:length(neuIND)
%     if neuIND(i) == 7
%         continue
%     end
        plot(x(i), y(i), '.', 'linestyle', 'none', 'color', getAnimalColor(neuIND(i)), 'markersize', 20)

end
p = polyfit(x, y,1);
yfit = polyval(p,x);
plot(x,yfit, 'k') 
xlabel('mean escape velocity (cm/s)')
ylabel('mean firing rate post expansion (Hz)')
xlimit = xlim;
ylimit = ylim;
text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 10))])
%%
x = fRateMid_means';
y = t_escapes';
figure(20)
hold on
[R,PValue] = corrplot([x, y]);
hold off
close(20)
figure
hold on

for i = 1:length(neuIND)
%     if neuIND(i) == 7
%         continue
%     end
        plot(x(i), y(i), '.', 'linestyle', 'none', 'color', getAnimalColor(neuIND(i)), 'markersize', 20)

end
p = polyfit(x, y,1);
yfit = polyval(p,x);
plot(x,yfit, 'k')
xlabel('firing rate on the middle peak (Hz)')
ylabel('time of escape (s)')
xlimit = xlim;
ylimit = ylim;
text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 10))])
%%
%%
x = spontFreqs';
y = vTras_means';
figure(20)
hold on
[R,PValue] = corrplot([x, y]);
hold off
close(20)
figure
hold on
for i = 1:length(neuIND)
%     if neuIND(i) == 7
%         continue
%     end
        plot(x(i), y(i), '.', 'linestyle', 'none', 'color', getAnimalColor(neuIND(i)), 'markersize', 20)

end
p = polyfit(x, y,1);
yfit = polyval(p,x);
plot(x,yfit, 'k') 
xlabel('firing rate before the stimuli appeared (Hz)')
ylabel('mean escape velocity (cm/s)')
xlimit = xlim;
ylimit = ylim;
text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 10))])


%%
fRate_post_stacked(fRate_post_stacked < 0) = 0;
y = fRate_post_stacked';
x = vTras_post_stacked';

neuIND_stkd = neuIND_post_stacked;
neuIND_stkd(x <1) = [];
y(x <1) = [];
x(x <1) = [];
figure(20)
hold on
[R,PValue] = corrplot([x, y]);
hold off
close(20)
figure
hold on
for i = 1:25:length(neuIND_stkd)
%     if neuIND_post_stacked(i) == 7
%         continue
%     end
%    plot(x(i), y(i), '.', 'linestyle', 'none', 'color', getAnimalColor(neuIND_stkd(i)), 'markersize', 10)
   plot(x(i), y(i), '.', 'linestyle', 'none', 'color', [0.4 0.4 0.4], 'markersize', 15)
end
p = polyfit(x, y,1);
yfit = polyval(p,x);
plot(x,yfit, 'k', 'linewidth', 2) 
ylabel('firing rate after expansion (Hz)')
xlabel('escape velocity after expansion (cm/s)')
xlimit = xlim;
ylimit = ylim;
xticks([0 25 50])
yticks([0 30 60])
ax = gca;
ax.LineWidth = 2;
ax.FontSize = 11;
text(max(xlim)*0.8, ylimit(2)-(ylimit(2)*0.8), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 15))], 'FontSize', 11)


%%
tic
delay_bins = -300:1:300;
vTras_delayed_stacked = cell(size(delay_bins));
fRate_delayed_stacked = cell(size(delay_bins));
neuIND_delayed_stacked = cell(size(delay_bins));
n_delays = 0;
R = {};
PValue  ={};
for db = delay_bins
    n_delays = n_delays + 1;
    for i = 1:length(neuIND_post_separated)
        if db > 0
            delayed_fRate = fRate_post_separated{i}(1+db:end);
            delayed_vTras = vTras_post_separated{i}(1:end-db);
        elseif db < 0
            delayed_fRate = fRate_post_separated{i}(1:end+db);
            delayed_vTras = vTras_post_separated{i}(1-db:end);
        else
            delayed_fRate = fRate_post_separated{i}(1:end);
            delayed_vTras = vTras_post_separated{i}(1:end);
        end
        %delayed_fRate(delayed_vTras < 1) = [];
        %delayed_vTras(delayed_vTras < 1) = [];
        vTras_delayed_stacked{n_delays} = [vTras_delayed_stacked{n_delays} delayed_vTras'];
        fRate_delayed_stacked{n_delays} = [fRate_delayed_stacked{n_delays} delayed_fRate];
        neuIND_delayed_stacked{n_delays} = [neuIND_delayed_stacked{n_delays} ones(size(delayed_vTras))'*neuIND_post_separated(i)];
    end
    
    y = fRate_delayed_stacked{n_delays}';
    x = vTras_delayed_stacked{n_delays}';

    [R{n_delays},PValue{n_delays}] = corrcoef([x, y]);

end
toc
%%
clear x
clear y

for i = 1:length(R)
    y(i) = R{i}(1,2);
    x(i) = delay_bins(i);
end
figure
plot(x,y, 'linewidth', 2, 'color', [0.8 0.2 0.2])
hold on
%ylim([0.58 0.69])
line([0 0], ylim, 'color', [0 0 0], 'linestyle', '--', 'linewidth', 1.5)
xlim([-300 300])
xticks([-300 -150 0 150 300])
ax = gca;
ax.LineWidth = 2;
ax.FontSize = 11;
hold off




%%

for nt = 1:length(fRate_post_separated)
    if nt == 1
        currSp = 1;
    elseif neuIND_post_separated(nt) == neuIND_post_separated(nt-1)
        currSp = currSp + 1;
    else
        currSp = 1;
    end
    x = fRate_post_separated{nt}';
    y = vTras_post_separated{nt};
    x(y < 1.5) = [];
    y(y < 1.5) = [];
    figure(20)
    hold on
    [R,PValue] = corrplot([x, y]);
    hold off
    close(20)
    figure(neuIND_post_separated(nt))
    subplot(2, 2, currSp)
    hold on
    plot(x(1:20:end), y(1:20:end), '.k', 'markersize', 10)
    p = polyfit(x, y,1);
    yfit = polyval(p,x);
    if PValue(1,2) < 0.05
        style = '-';
    else
        style = '--';
    end
    plot(x,yfit, 'color', getAnimalColor(neuIND_post_separated(nt)),'linestyle', style)
    ylabel('escape velocity (cm/s)')
    xlabel('firing rate (Hz)')
    xlimit = xlim;
    ylimit = ylim;
    text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 15))])
    figure(19)
    hold on
    
    plot(x,yfit, 'color', getAnimalColor(neuIND_post_separated(nt)), 'linestyle', style, 'linewidth', 1.3)
end
%%
%%

for nt = 1:length(fRate_post_separated)
    if nt == 1
        currSp = 1;
        x = fRate_post_separated{nt}';
        y = vTras_post_separated{nt};
        continue
    elseif neuIND_post_separated(nt) == neuIND_post_separated(nt-1) 
        currSp = currSp + 1;
        x = [x ; fRate_post_separated{nt}'];
        y = [y; vTras_post_separated{nt}];
        if nt ~= length(neuIND_post_separated)
            continue
        end
    else 
         x = fRate_post_separated{nt}';
        y = vTras_post_separated{nt};
        currSp = 1;
    end
    nt
    x(y < 1.5) = [];
    y(y < 1.5) = [];
    figure(20)
    hold on
    [R,PValue] = corrplot([x, y]);
    hold off
    close(20)
    
    p = polyfit(x, y,1);
    yfit = polyval(p,x);
    if PValue(1,2) < 0.05
        style = '-';
    else
        style = '--';
    end

    
    figure(19)
    hold on
    
    plot(x,yfit, 'color', getAnimalColor(neuIND_post_separated(nt)), 'linestyle', style, 'linewidth', 1.3)
    

end
%%
y = fRate_post_stacked';
x = vTras_post_stacked';
y(x < 1) = [];
x(x < 1) = [];

figure(20)
hold on
[R,PValue] = corrplot([x, y]);
hold off
close(20)
figure(19)
hold on
p = polyfit(x, y,1);
yfit = polyval(p,x);
if PValue(1,2) < 0.05
    style = '-';
else
    style = '--';
end
plot(x,yfit, 'color', [0 0 0],'linestyle', style, 'linewidth', 2)
plot(x,y, 'color', [0.3 0.3 0.3],'linestyle', 'none', 'marker', '.', 'markersize', 20)
xlabel('escape velocity (cm/s)')
ylabel('firing rate (Hz)')
xlimit = xlim;
ylimit = ylim;
text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2(round(R(2), 2)) '   p=' num2str(round(PValue(2), 15))])
%% 
for n = 1:length(data)
if n == 77 || n == 137
continue
end
runs = data(n).runs;
runTr = 0;
for tr = 1:length(runs)
t_behav = data(n).runs(tr).time;
vtms(tr) = mean(runs(tr).vTras(t_behav > 3 & t_behav < 3.4+0.2));
t_esc = t_behav(t_behav > 1.5 & t_behav < 3.5);
vTras_esc = runs(tr).vTras(t_behav > 1.5 & t_behav < 3.5);
for bin = 1:length(vTras_esc)
    if vTras_esc(bin) > 1
        escStart(tr) = t_esc(bin);
        break
    elseif bin == length(vTras_esc)
        escStart(tr) = 0;
    end
end
if max(vtms(tr)) > 10
runTr = runTr+1;
end
end
if runTr > 1
vtm(n) = mean(vtms);
sf(n) = mean(data(n).spontFreq.general.freqs(data(n).airIND));
tesc(n) = mean(escStart(escStart>0));
end
end
figure (1)
clf
plot(sf(vtm>0), vtm(vtm>0), '.', 'markersize', 25, 'color', [0.3 0.3 0.3])
plot(sf(vtm>0), tesc(vtm>0), '.', 'markersize', 25, 'color', [0.3 0.3 0.3])
%%
c = jet;
fMax = max(fRate_means);
fMin = min(fRate_means);
figure
hold on
title('colored by P2 firing rate')
for tr = 1:length(fRate_means)

color = findColorGradient(c, fMax, fMin, fRate_means(tr));
plot(t_behav_run(:,tr), vTras_run(:,tr), 'color', color, 'linewidth', 1.5)
end
ylabel(' velocity (cm/s)')
xlabel('time (s)')
xlim ([-2 10])


fMax = max(fRateEarly_means);
fMin = min(fRateEarly_means);
figure
hold on
title('colored by P1 firing rate')
for tr = 1:length(fRateEarly_means)

color = findColorGradient(c, fMax, fMin, fRateEarly_means(tr));
plot(t_behav_run(:,tr), vTras_run(:,tr), 'color', color, 'linewidth', 1.5)
end
ylabel(' velocity (cm/s)')
xlabel('time (s)')
xlim ([-2 10])
%%
c = parula;
fMax = max(fRate_means);
fMin = min(fRate_means);

fRates_neuMeans = [0];
vTras_anMeans = {};

n = 0;
for tr = 1:length(fRate_means)
    if (tr > 1 && neuIND(tr) ~= neuIND(tr-1)) || tr == length(fRate_means)
        fRates_neuMeans(neuIND(tr-1)) = fRates_neuMeans(neuIND(tr-1)) / n;
        vTras_anMeans{:,neuIND(tr-1)} = vTras_anMeans{:,neuIND(tr-1)} / n;
        n = 1;
        fRates_neuMeans(neuIND(tr)) = fRate_means(tr);
        vTras_anMeans{:,neuIND(tr)} = vTras_run(:,tr);
    else
        n = n+1;
        fRates_neuMeans(neuIND(tr)) = fRates_neuMeans(neuIND(tr)) + fRate_means(tr);
        if n == 1
            vTras_anMeans{neuIND(tr)} = vTras_run(:,tr);
        else
            vTras_anMeans{neuIND(tr)} = vTras_anMeans{neuIND(tr)} + vTras_run(:,tr);
        end
    end
    
end
fMax = max(fRates_neuMeans);
fMin = min(fRates_neuMeans);
figure
hold on
title('colored by P2 firing rate')
for neu = 1:length(fRates_neuMeans)
    if ~isempty(vTras_anMeans{neu})
        color = findColorGradient(c, fMax, fMin, fRates_neuMeans(neu));
        plot(t_behav_run(:,1), vTras_anMeans{neu}, 'color', color, 'linewidth', 1.5)
    end
end

ylabel(' velocity (cm/s)')
xlabel('time (s)')
xlim ([-2 10])
%%
%c = cc;
c = jet;
fRatesEarly_neuMeans = [0];
vTras_anMeans = {};

n = 0;
for tr = 1:length(fRateEarly_means)
    if (tr > 1 && neuIND(tr) ~= neuIND(tr-1)) || tr == length(fRateEarly_means)
        fRatesEarly_neuMeans(neuIND(tr-1)) = fRatesEarly_neuMeans(neuIND(tr-1)) / n;
        vTras_anMeans{:,neuIND(tr-1)} = vTras_anMeans{:,neuIND(tr-1)} / n;
        n = 1;
        fRatesEarly_neuMeans(neuIND(tr)) = fRateEarly_means(tr);
        vTras_anMeans{:,neuIND(tr)} = vTras_run(:,tr);
    else
        n = n+1;
        fRatesEarly_neuMeans(neuIND(tr)) = fRatesEarly_neuMeans(neuIND(tr)) + fRateEarly_means(tr);
        if n == 1
            vTras_anMeans{neuIND(tr)} = vTras_run(:,tr);
        else
            vTras_anMeans{neuIND(tr)} = vTras_anMeans{neuIND(tr)} + vTras_run(:,tr);
        end
    end
    
end

fMax = max(fRatesEarly_neuMeans);
fMin = min(fRatesEarly_neuMeans);
figure
hold on
title('colored by P1 firing rate')
for neu = 1:length(fRatesEarly_neuMeans)
    if ~isempty(vTras_anMeans{neu})
        color = findColorGradient(c, fMax, fMin, fRatesEarly_neuMeans(neu));
        plot(t_behav_run(:,1), vTras_anMeans{neu}, 'color', color, 'linewidth', 2.5)
    end
end

ylabel(' velocity (cm/s)')
xlabel('time (s)')
xlim ([-2 10])
%% Busco graficar las corridas con un codigo de colores que corresponda a la cantidad de spikes disparados.
%c = cc;
c = jet;
fRatesEarly_neuMeans = [0];
vTras_anMeans = {};

n = 0;
for tr = 1:length(fRateEarly_means)
    if (tr > 1 && neuIND(tr) ~= neuIND(tr-1)) || tr == length(fRateEarly_means)
        fRatesEarly_neuMeans(neuIND(tr-1)) = fRatesEarly_neuMeans(neuIND(tr-1)) / n;
        vTras_anMeans{:,neuIND(tr-1)} = vTras_anMeans{:,neuIND(tr-1)} / n;
        n = 1;
        fRatesEarly_neuMeans(neuIND(tr)) = fRateEarly_means(tr);
        vTras_anMeans{:,neuIND(tr)} = vTras_run(:,tr);
    else
        n = n+1;
        fRatesEarly_neuMeans(neuIND(tr)) = fRatesEarly_neuMeans(neuIND(tr)) + fRateEarly_means(tr);
        if n == 1
            vTras_anMeans{neuIND(tr)} = vTras_run(:,tr);
        else
            vTras_anMeans{neuIND(tr)} = vTras_anMeans{neuIND(tr)} + vTras_run(:,tr);
        end
    end
    
end

fMax = max(fRatesEarly_neuMeans);
fMin = min(fRatesEarly_neuMeans);
figure
hold on
title('colored by P1 firing rate')
for neu = 1:length(fRatesEarly_neuMeans)
    if ~isempty(vTras_anMeans{neu})
        color = findColorGradient(c, fMax, fMin, fRatesEarly_neuMeans(neu));
        plot(t_behav_run(:,1), vTras_anMeans{neu}, 'color', color, 'linewidth', 2.5)
    end
end

ylabel(' velocity (cm/s)')
xlabel('time (s)')
xlim ([-2 10])

%%
tic
for n = 3:7
    fRate = mixData_MLG2_walk(n).fRates;
    t_ephys  = mixData_MLG2_walk(n).t_ephys;
    t_ball = mixData_MLG2_walk(n).runs.time(mixData_MLG2_walk(n).runs.time >= 0 & mixData_MLG2_walk(n).runs.time < 600);
    vTras = mixData_MLG2_walk(n).runs.vTras(mixData_MLG2_walk(n).runs.time >= 0 & mixData_MLG2_walk(n).runs.time < 600);
    delay_bins = -500:1:500;
    vTras_delayed= cell(size(delay_bins));
    fRate_delayed= cell(size(delay_bins));
    n_delays = 0;
    R = {};
    PValue  ={};
    for db = delay_bins
        n_delays = n_delays + 1;
        if db > 0
            delayed_fRate = fRate(1+db:end);
            delayed_vTras = vTras(1:end-db);
        elseif db < 0
            delayed_fRate = fRate(1:end+db);
            delayed_vTras = vTras(1-db:end);
        else
            delayed_fRate = fRate(1:end);
            delayed_vTras = vTras(1:end);
        end
        delayed_fRate = delayed_fRate(delayed_vTras > 0.5 & delayed_vTras < 10);
        delayed_vTras = delayed_vTras(delayed_vTras > 0.5 & delayed_vTras < 10);
        
        vTras_delayed{n_delays} = [vTras_delayed{n_delays} delayed_vTras'];
        fRate_delayed{n_delays} = [fRate_delayed{n_delays} delayed_fRate];
        x = fRate_delayed{n_delays};
        y = vTras_delayed{n_delays}';
        [R{n_delays},PValue{n_delays}] = corrcoef([x, y]);
    end
    toc
    for i = 1:length(R)
        r(i) = R{i}(1,2);
        dt(i) = delay_bins(i);
    end
    figure(n)
    subplot(1, 2, 2)
    plot(dt,r, 'linewidth', 2)
    disp(['neuron ' num2str(n) ' peak delay = ' num2str(dt(r == max(r)))])
    subplot(1,2, 1)
    hold on
    yyaxis left
    plot(t_ball, vTras, 'linewidth', 1)
    ylim([0, max(ylim)])
    ylabel('vTras (cm/s)')
    yyaxis right
    plot(t_ephys, fRate, 'linewidth', 1)
    ylabel('frate (Hz)')
    ylim([0, max(ylim)])
end
%%
for n = 1:length(neu_MLG2)
    stim = 2;
    for r = recs
        if str2double(r.crabID) == MLG2_IDs(n)
            rec = r;
            break
        end
    end
    neu =  neu_MLG2(n);
    stimIND = rec.getStimIndex(stim);
    if isempty(stimIND)
        continue
    end
    titleTxt = ['ID: ' num2str(r.crabID) ' - cluster: ' num2str(neu.cluster)];
    r.makeMixedPlots(stim, neu.cluster, 'xlim', [-5 10], 'binsize', 50, 'condition', 'ball', 'title', titleTxt, 'addTitle', true)
    hold on
    title(['ID: ' num2str(r.crabID) ' - cluster: ' num2str(neu.cluster)])
end
%% grafico de barras para el primer pico de la BLG2 en los distitnos comportamientos
bar(1, mean([inm_run.fRateP1]), 'facecolor', [0.1 0.1 0.9], 'edgecolor', [0.1 0.1 0.9])
hold on
errorbar(1, mean([inm_run.fRateP1]), std([inm_run.fRateP1])/sqrt(length([inm_run.fRateP1])), 'linewidth', 2, 'color', [0 0 0])
bar(2, mean([frz_run.fRateP1]), 'facecolor', [0.9 0.1 0.1], 'edgecolor', [0.9 0.1 0.1])
errorbar(2, mean([frz_run.fRateP1]), std([frz_run.fRateP1])/sqrt(length([frz_run.fRateP1])), 'linewidth', 2, 'color', [0 0 0])
hold on
bar(3, mean([run.fRateP1]),'facecolor', [0.2 0.2 0.2], 'edgecolor', [0.2 0.2 0.2])
errorbar(3, mean([run.fRateP1]), std([run.fRateP1])/sqrt(length([run.fRateP1])), 'linewidth', 2, 'color', [0 0 0])
hold on
bar(4, mean([no_run.fRateP1]),'facecolor', [0.1 0.8 0.1], 'edgecolor', [0.1 0.8 0.1])
errorbar(4, mean([no_run.fRateP1]), std([no_run.fRateP1])/sqrt(length([no_run.fRateP1])), 'linewidth', 2, 'color', [0 0 0])
xlim([0 5])
prettyAxes
xticks([1 2 3 4])
xticklabels({'inm -> run', 'walk -> frz -> run', 'walk -> run', 'no escape'})
xtickangle(60)
ylabel('firing rate of the first peak (Hz)')
%%

function [IDs, clu, neu] = getNeuronRecInfo(neu_dates, recs)

IDs = [];
clu = [];
neu = [];
for n = 1:length(neu_dates)
    clu(end+1) = neu_dates{n,2};
    date = neu_dates{n,1};
    nFound = 0;
    currIDs = [];
    for r = recs
        if strcmp(r.date, date)
            nFound = nFound+1;
            currIDs(end+1) = str2num(r.crabID);
        end
    end
    if nFound == 0
        error('missing neuron')
    elseif nFound == 1
        IDs(end+1) = currIDs;
    elseif nFound > 1
        disp(currIDs)
        currIDs = str2num(input('Pick an ID:      ', 's'));
        IDs(end+1) = currIDs;
    end
    for r = recs
        if str2num(r.crabID) == IDs(end)
            if isempty(neu)
                neu = r.neurons(clu(end));
            else
                neu(end+1) = r.neurons(clu(end));
            end
%             fullName{n} = [neu_dates{n,1} ' - ID:' r.crabID, ' - clu:' num2str(clu(end))];
%             r.makeMixedPlots(2, clu(end))
%             hold on
%             suptitle(fullName{n})
%             hold off
        end
    end
end
end

function compareConditions(neurons,IDs, recs)
fRateBall_all = [];
vTrasBall_all = [];
figure
hold on
stim = 2;
n_run = 0;
n_fr = 0;
n_air = 0;
fRateFr = cell(length(neurons), 1);
fRateRun = cell(length(neurons), 1);
for n = 1:length(neurons)
    for r = recs
        if str2double(r.crabID) == IDs(n)
            rec = r;
            break
        end
    end
    neu =  neurons(n);
    stimIND_air = rec.getStimIndex(2, 'condition', 'air');
    stimIND_ball = rec.getStimIndex(2, 'condition', 'ball');
    data_air = rec.getRunAndFireRate(neu.cluster, stim, ...
        'durations', [5.5 10], 'binSize', 1 , 'condition', 'air', ...
        'spanephys', 250, 'smoothmethod', 'lowess');
    data_ball = rec.getRunAndFireRate(neu.cluster, stim, ...
        'durations', [5.5 10], 'binSize', 1 , 'condition', 'ball', ...
        'spanephys', 250, 'smoothmethod', 'lowess');
    t = data_ball.t_ephys;
    n_esc = 0;
    n_noEsc = 0;
    for i = 1:length(stimIND_air)
%         [raster, index, stimList] = neu.getRasters(2, 'stimindex', stimIND_air(i), 'durations', [5 10]);
%         [freq, t] = neu.getPSH(raster, index, [-5 10], 300);
%         fRateAir{n}(i) = mean(freq(t > 3.5 & t < 4));
%         freqsAir{n}(:,i) = freq;
        n_air = n_air + 1;
        fRateAir{n}(i) = mean(data_air.fRates(data_air.t_ephys > 3.5 & data_air.t_ephys < 4,i));
        freqsAir{n}(:,i) = data_air.fRates(:,i);
        freqsAir_all(:,n_air) = data_air.fRates(:,i);
    end
    
    for i = 1:length(stimIND_ball)
%         [raster, index, stimList] = neu.getRasters(2, 'stimindex', stimIND_ball(i), 'durations', [5 10]);
%         [freq, t] = neu.getPSH(raster, index, [-5 10], 300);
%         fRateBall{n}(i) = mean(freq(t > 3.5 & t < 4));
%         run = rec.ball.interpolateRuns(stimIND_ball(i), 0.050);
%         run.time = run.time-10;
%         vTrasBall{n}(i) = mean(run.vTras(run.time > 3.5 & run.time < 4));
%         freqsBall{n}(:,i) = freq;
        fRateBall{n}(i) = mean(data_ball.fRates(data_ball.t_ephys > 3.5 & data_ball.t_ephys < 4,i));
        freqsBall{n}(:,i) = data_ball.fRates(:,i);
        run = data_ball.runs(i);
        vTrasBall{n}(i) = mean(run.vTras(run.time > 3.5 & run.time < 4));
        if max(run.vTras(run.time > 3.3 & run.time < 4)) >= 10
            n_run = n_run+1;
            n_esc = n_esc + 1;
            freqsBall_run(:,n_run) = data_ball.fRates(:,i);
            fRateRun{n}(n_esc) = fRateBall{n}(i);
        else
            n_fr = n_fr + 1;
            n_noEsc = n_noEsc + 1;
            freqsBall_fr(:,n_fr) = data_ball.fRates(:,i);
            fRateFr{n}(n_noEsc) = fRateBall{n}(i);
        end
    end
    fRateBall_mean(n) = mean(fRateBall{n});
    fRateAir_mean(n) = mean(fRateAir{n});
    fRateRun_mean(n) = mean(fRateRun{n});
    fRateFr_mean(n)  = mean(fRateFr{n});
    freqsMeanBall(:,n) = mean(freqsBall{n},2);
    freqsMeanAir(:,n) = mean(freqsAir{n},2);
    % %     %
    %      figure
    plot(vTrasBall{n}, fRateBall{n}, 'o', 'linestyle', 'none', 'markersize', 8, 'color', 'k')
    %      input('as')
    %plot(vTrasBall{n}, fRateBall{n}, 'o', 'linestyle', 'none', 'markersize', 8)
    fRateBall_all = [fRateBall_all fRateBall{n}];
    vTrasBall_all = [vTrasBall_all vTrasBall{n}];
end
freqsBall_all = [freqsBall_run freqsBall_fr];
fRates.air = freqsAir_all;
fRates.run = freqsBall_run;
fRates.fr = freqsBall_fr;
fRates.n_run  = n_run;
fRates.n_fr = n_fr;
fRates.n_air = n_air;
fRates.t = t;
assignin('base', 'fRates_comp', fRates)
% xlabel('velocity (cm/s)')
% ylabel('firing rate (Hz)')
% figure(7)
% [R,PValue] = corrplot([vTrasBall_all', fRateBall_all']);
% close 7
% fRateDiff = fRateBall_mean - fRateAir_mean;
% figure;hold on
% x = vTrasBall_all;
% y = fRateBall_all;
% p = polyfit(x, y,1);
% yfit = polyval(p,x);
% plot(x,yfit)
% plot(vTrasBall_all, fRateBall_all, 'o', 'linestyle', 'none', 'markersize', 8, 'color', 'k')
% text(5, 38, ['r = ' num2str(R(2)) ', p = ' num2str(PValue(2))])
% xlabel('velocity (cm/s)')
% ylabel('firing rate (Hz)')
% hold off
% figure
% plot(1:length(fRateDiff), fRateDiff, 'o', 'linestyle', 'none')
c_run = [30 136 229]/255;
c_air = [255 193 7]/255;
c_fr = [0 77 54]/255;
c_ball = c_run/2 + c_fr/2;
figure
hold on
plot(t, mean(freqsMeanBall,2), 'color', c_ball)
plot(t, mean(freqsMeanAir,2), 'color', c_air)
stdBall = (std(freqsMeanBall'))';
errBall = stdBall / sqrt(length(neurons));
[hFill, err] = addPSHerror(t, mean(freqsMeanBall,2), errBall, c_ball);
stdAir = (std(freqsMeanAir'))';
errAir = stdAir / sqrt(length(neurons));
[hFill, err] = addPSHerror(t, mean(freqsMeanAir,2), errAir, c_air);
xlabel('time (s)')
ylabel('firing rate (Hz)')
legend({'crabola', 'aire'})
hold off


figure
hold on
c_run = [30 136 229]/255;
c_air = [255 193 7]/255;
c_fr = [0 77 54]/255;
c_ball = c_run/2 + c_fr/2;
plot(t, mean(freqsBall_all,2),'color', c_ball, 'linewidth', 2)
plot(t, mean(freqsAir_all,2),'color', c_air, 'linewidth', 2)
stdBall_all = (std(freqsBall_all'))';
errBall_all = stdBall_all / sqrt(n_run);
[hFill, err] = addPSHerror(t, mean(freqsBall_all,2), errBall_all, c_ball);
stdAir = (std(freqsAir_all'))';
errAir = stdAir / sqrt(n_air);
[hFill, err] = addPSHerror(t, mean(freqsAir_all,2), errAir, c_air);

xlabel('time (s)')
ylabel('firing rate (Hz)')
legend({'ball', 'air'}, 'AutoUpdate', 'off')
hold on
addPSHDecorations(2, 3.35, max(ylim), 'StimUnderPlot', true, 'heigth', 0.15)
set(gcf, 'Renderer', 'painters')
xlim([-2 8])


hold off
figure
hold on
c_run = [30 136 229]/255;
c_air = [255 193 7]/255;
c_fr = [0 77 54]/255;
plot(t, mean(freqsBall_run,2),'color', c_run, 'linewidth', 2)
plot(t, mean(freqsAir_all,2),'color', c_air, 'linewidth', 2)
plot(t, mean(freqsBall_fr,2),'color', c_fr, 'linewidth', 2)
stdBall_run = (std(freqsBall_run'))';
errBall_run = stdBall_run / sqrt(n_run);
[hFill, err] = addPSHerror(t, mean(freqsBall_run,2), errBall_run, c_run);
stdAir = (std(freqsAir_all'))';
errAir = stdAir / sqrt(n_air);
[hFill, err] = addPSHerror(t, mean(freqsAir_all,2), errAir, c_air);
stdBall_fr = (std(freqsBall_fr'))';
errBall_fr = stdBall_fr / sqrt(n_fr);
[hFill, err] = addPSHerror(t, mean(freqsBall_fr,2), errBall_fr, c_fr);
xlabel('time (s)')
ylabel('firing rate (Hz)')
legend({'run', 'air', 'no run'}, 'AutoUpdate', 'off')
hold on
addPSHDecorations(2, 3.35, max(ylim), 'StimUnderPlot', true, 'heigth', 0.15)
set(gcf, 'Renderer', 'painters')
xlim([-2 8])


hold off

figure;
hold on;
plot(ones(size(fRateFr_mean))*1, fRateFr_mean, 'marker', '.', 'markersize', 25, 'linestyle', 'none', 'color', c_fr)
plot(ones(size(fRateAir_mean))*2, fRateAir_mean, 'marker', '.', 'markersize', 25, 'linestyle', 'none', 'color', c_air)
plot(ones(size(fRateRun_mean))*3, fRateRun_mean, 'marker', '.', 'markersize', 25, 'linestyle', 'none', 'color', c_run)

for l = 1:length(fRateAir_mean)
    if ~isempty(fRateFr_mean)
        line([1 2], [fRateFr_mean(l), fRateAir_mean(l)], 'linewidth', 2, 'color', 'k')
    end
end
for l = 1:length(fRateAir_mean)
    if ~isempty(fRateRun_mean)
        line([2 3], [fRateAir_mean(l), fRateRun_mean(l)], 'linewidth', 2, 'color', 'k')
    end
end

xlim([0 4])
xticks([1,2,3])
xticklabels({'no run', 'air', 'run'})
xlabel('Condition')
ylabel('firing rate (Hz)')
hold off

figure
hold on
bar([1], mean(fRateFr_mean(~isnan(fRateFr_mean))), 'facecolor', c_fr, 'edgecolor', c_fr*0.7)
hold on
bar([2], mean(fRateAir_mean(~isnan(fRateAir_mean))), 'facecolor', c_air, 'edgecolor', c_air*0.7)
hold on
bar([3], mean(fRateRun_mean(~isnan(fRateRun_mean))), 'facecolor', c_run, 'edgecolor', c_run*0.7)
hold on
stdFr = std(fRateFr_mean(~isnan(fRateFr_mean)));
errFr = stdFr / sqrt(sum(~isnan(fRateFr_mean)));
stdAir = std(fRateAir_mean(~isnan(fRateAir_mean)));
errAir = stdAir / sqrt(sum(~isnan(fRateAir_mean)));
stdRun = std(fRateRun_mean(~isnan(fRateRun_mean)));
errRun = stdRun / sqrt(sum(~isnan(fRateRun_mean)));
errorbar(1, mean(fRateFr_mean(~isnan(fRateFr_mean))), errFr, 'linewidth', 2, 'color', 'k')
errorbar(2, mean(fRateAir_mean(~isnan(fRateAir_mean))), errAir, 'linewidth', 2, 'color', 'k')
errorbar(3, mean(fRateRun_mean(~isnan(fRateRun_mean))), errRun, 'linewidth', 2, 'color', 'k')
xlim([0 4])
xticks([1 2 3])
xticklabels({'no run', 'air', 'run'})

figure;
hold on;
plot(ones(size(fRateAir_mean)), fRateAir_mean, 'marker', 'o', 'markersize', 8, 'linestyle', 'none', 'color', 'r')
plot(ones(size(fRateBall_mean))*2, fRateBall_mean, 'marker', 'o', 'markersize', 8, 'linestyle', 'none', 'color', 'b')
for l = 1:length(fRateAir_mean)
    line([1 2], [fRateAir_mean(l), fRateBall_mean(l)], 'linewidth', 1.5, 'color', 'k')
end
xlim([0 3])
xticks([1,2])
xticklabels({'Aire', 'Crabola'})
xlabel('Condition')
ylabel('firing rate (Hz)')
hold off

figure
hold on
plot(t, freqsMeanBall, 'b', t, mean(freqsMeanAir,2), 'r')
stdBall = (std(freqsMeanBall'))';
errBall = stdBall / sqrt(length(neurons));
[hFill, err] = addPSHerror(t, mean(freqsMeanBall,2), errBall, [0 0 1]);
stdAir = (std(freqsMeanAir'))';
errAir = stdAir / sqrt(length(neurons));
[hFill, err] = addPSHerror(t, mean(freqsMeanAir,2), errAir, [1 0 0]);
xlabel('time (s)')
ylabel('firing rate (Hz)')
legend({'crabola', 'aire'})
hold off
end

function makeEphysSpeedCorrelations(neurons, IDs, recs)
stacked_vTras = [];
stacked_fRate = [];
stim = 2;
for n = 1:length(neurons)
%     if n == 1
%         color = [rand, rand, rand];
%     else
%         color = getDifferentRGB(color);
%     end
    for r = recs
        if str2double(r.crabID) == IDs(n)
            rec = r;
            break
        end
    end
%     if n == 7
%         continue
%     end
    color = getAnimalColor(n)
    neu =  neurons(n);
    stimIND_ball = rec.getStimIndex(stim, 'condition', 'ball');
    data_ball = rec.getRunAndFireRate(neu.cluster, stim, ...
        'durations', [2 7], 'binSize', 10 , 'condition', 'ball', ...
        'spanephys', 25, 'smoothmethod', 'lowess', 'spanBall', 15, 'smoothball', true);
    for i = 1:length(stimIND_ball)
        [raster, index, stimList] = neu.getRasters(stim, 'stimindex', stimIND_ball(i), 'durations', [5 10]);
        [freq, t] = neu.getPSH(raster, index, [-5 10], 300);
        %fRatesBall{n}(:,i) = freq(t > 3.5 & t < 6.5);
        run = rec.ball.interpolateRuns(stimIND_ball(i), 0.050);
        run.time = run.time-10.00001;
        t = data_ball.t_ephys;
        %vTrasBall{n}(:,i) = run.vTras(run.time > 3.5 & run.time < 6.5);
        vTras = data_ball.runs(i).vTras(data_ball.runs(i).time > 3.5 & data_ball.runs(i).time <= 6.5);
        if length(vTras) > 300
            vTras = vTras(1:300);
        end
        vTrasBall{n}(:,i) = vTras;
        fRatesBall{n}(:,i) = data_ball.fRates(t > 3.5 & t < 6.5,i);
    end
    % descarto los trials con baja rta
    figure(n)
    subplot(2,2,1)
    suptitle([rec.date, ' ID:', rec.crabID ' Clu:' num2str(IDs(n))])
    for i = 1:length(stimIND_ball)
        
        if mean(vTrasBall{n}(:,i)) < 4
            continue
        end
        figure(n+1)
        hold on
        [R,PValue] = corrplot([vTrasBall{n}(:,i), fRatesBall{n}(:,i)]);
        hold off
        close(n+1)
        figure(n)
        hold on
        subplot(2,2,i)
        hold on
        plot(fRatesBall{n}(1:4:end,i),vTrasBall{n}(1:4:end,i), 'ok');
        y = vTrasBall{n}(:,i);
        x = fRatesBall{n}(:,i);
        p = polyfit(x, y,1);
        yfit = polyval(p,x);
        plot(x,yfit, 'color', color)
        xlimit = xlim;
        ylimit = ylim;
        text(0, ylimit(2)-(ylimit(2)*0.05), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 6))])
        
        ylabel('speed (cm/s)')
        xlabel('firing rate (Hz)')
        hold off
        figure(length(neurons)+2); hold on;
        if PValue(2) < 0.05
            lw = 1;
            ls = '-';
        else
            lw = 1;
            ls = '--';
        end
        indMin = find(yfit == min(yfit));
        if length(indMin > 1) 
            indMin = indMin(1);
        end
        indMax = find(yfit == max(yfit));
        if length(indMax > 1)
            indMax = indMax(1);
        end
        plot([x(indMin) x(indMax)], [yfit(indMin) yfit(indMax)], 'color', color, 'linewidth', lw, 'linestyle', ls)
        ylabel('speed (cm/s)')
        xlabel('firing rate (Hz)')
        hold off
        stacked_vTras = [stacked_vTras; vTrasBall{n}(:,i)];
        stacked_fRate = [stacked_fRate; fRatesBall{n}(:,i)];

    end
    hold off
end
figure(length(neurons)+3); hold on;
[R,PValue] = corrplot( [stacked_fRate, stacked_vTras]);
close(length(neurons)+3)
figure(length(neurons)+2); hold on;

%pDots = plot(stacked_vTras, stacked_fRate, 'ok', 'markerSize', 2);
p = polyfit(stacked_vTras, stacked_fRate,1);
yfit = polyval(p,stacked_fRate);
plot(stacked_fRate, yfit, 'k', 'linewidth', 2)
%uistack(pDots, 'bottom')
text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 6))])
hold off
end

function correlateWalkingAndEphys(neurons, IDs, recs)
stacked_vTras = [];
stacked_fRate = [];
stim = 150;
for n = 1:length(neurons)
%     if n == 1
%         color = [rand, rand, rand];
%     else
%         color = getDifferentRGB(color);
%     end
    for r = recs
        if str2double(r.crabID) == IDs(n)
            rec = r;
            break
        end
    end
    if n == 7
        continue
    end
    color = getAnimalColor(n);
    neu =  neurons(n);
    stimIND = rec.getStimIndex(stim);
    if isempty(stimIND)
        continue
    end
    
    [raster, index, stimList] = neu.getRasters(stim, 'stimindex', stimIND, 'durations', [0 600]);
    [freq, t] = neu.getPSH(raster, index, [0 600], 600);
    fRatesBall = freq;
    run = rec.ball.interpolateRuns(stimIND, 1);
    run.time = run.time-10.00001;
    vTrasBall = (run.vTras(run.time >= 0 & run.time <= 600))';
    % descarto los trials con baja rta
    figure(n)
    suptitle([rec.date, ' ID:', rec.crabID ' Clu:' num2str(IDs(n))])
    figure(n+1)
    hold on
    [R,PValue] = corrplot([vTrasBall, fRatesBall]);
    hold off
    close(n+1)
    figure(n)
    hold on
    plot(vTrasBall, fRatesBall, 'ok');
    x = vTrasBall;
    y = fRatesBall;
    p = polyfit(x, y,1);
    yfit = polyval(p,x);
    plot(x,yfit)
    xlimit = xlim;
    ylimit = ylim;
    text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 10))])
    
    xlabel('speed (cm/s)')
    ylabel('firing rate (Hz)')
    hold off
    figure(length(neurons)+2); hold on;
    if PValue(2) < 0.05
        lw = 1;
        ls = '-';
    else
        lw = 1;
        ls = '--';
    end
    indMin = find(yfit == min(yfit));
    if length(indMin > 1)
        indMin = indMin(1);
    end
    indMax = find(yfit == max(yfit));
    if length(indMax > 1)
        indMax = indMax(1);
    end
    plot([x(indMin) x(indMax)], [yfit(indMin) yfit(indMax)], 'color', color, 'linewidth', lw, 'linestyle', ls)
    xlabel('speed (cm/s)')
    ylabel('firing rate (Hz)')
    hold off
    stacked_vTras = [stacked_vTras; vTrasBall];
    stacked_fRate = [stacked_fRate; fRatesBall];
    
end
hold off

figure(length(neurons)+3); hold on;
[R,PValue] = corrplot([stacked_vTras,  stacked_fRate]);
close(length(neurons)+3)
figure(length(neurons)+2); hold on;

%pDots = plot(stacked_vTras, stacked_fRate, 'ok', 'markerSize', 2);
p = polyfit(stacked_vTras, stacked_fRate,1);
yfit = polyval(p,stacked_vTras);
plot(stacked_vTras, yfit, 'k', 'linewidth', 2)
%uistack(pDots, 'bottom')
text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(PValue(2))])
hold off
end

function plotFiringRateVsSpeed(neurons,IDs, recs)
fRateStrt_all = [];
vTrasBall_all = [];
vTrasFreez_all = [];
vTrasPeak_all = [];
fRatePeak_all = [];
escStart_all = [];
vThreshold = 10;
stim = 2;
for n = 1:length(neurons)
    for r = recs
        if str2double(r.crabID) == IDs(n)
            rec = r;
            break
        end
    end
    neu =  neurons(n);
    stimIND_air = rec.getStimIndex(stim, 'condition', 'all');
    stimIND_ball = rec.getStimIndex(stim, 'condition', 'ball');
    data_air = rec.getRunAndFireRate(neu.cluster, stim, ...
        'durations', [5.5 10], 'binSize', 1 , 'condition', 'air', ...
        'spanephys', 250, 'smoothmethod', 'lowess');
    data_ball = rec.getRunAndFireRate(neu.cluster, stim, ...
        'durations', [2 7], 'binSize', 1 , 'condition', 'ball', ...
        'spanephys', 250, 'smoothmethod', 'lowess', 'spanBall', 150, 'smoothball', true);
    for i = 1:length(stimIND_air)
        [raster, index, stimList] = neu.getRasters(stim, 'stimindex', stimIND_air(i), 'durations', [2 6]);
        [freq, t] = neu.getPSH(raster, index, [-2 6], 300);
        %fRateAir{n}(i) = mean(freq(t > 3.5 & t < 4));
        freqsAir{n}(:,i) = freq;
        
    end
    for i = 1:length(stimIND_ball)
        [raster, index, stimList] = neu.getRasters(2, 'stimindex', stimIND_ball(i), 'durations', [2 7]);
        [freq, t] = neu.getPSH(raster, index, [-2 7], 300);
        fRateStrt{n}(i) = mean(freq(t > 0 & t < 1));
        run = rec.ball.interpolateRuns(stimIND_ball(i), 0.050);
        run.time = run.time-10;
        vTrasBall{n}(i) = mean(run.vTras(run.time > 2 & run.time < 3.6));
        vTrasFreez{n}(i) = mean(run.vTras(run.time > 1.15 & run.time < 1.65));
        vTrasPeak{n}(i) = max(run.vTras(run.time > 2 & run.time < 3.7));
        fRatePeak{n}(i) = max(freq(t > 3.1 & t < 3.5));
        freqsBall{n}(:,i) = data_ball.fRates(:,i);
        t = data_ball.t_ephys;
        vTras = data_ball.runs(i).vTras(data_ball.runs(i).time >= -2 & data_ball.runs(i).time <= 7);
        t_ball = data_ball.runs(i).time(data_ball.runs(i).time >= -2 & data_ball.runs(i).time <= 7);
        %busco el inicio del escape
        vTras_esc = run.vTras(run.time > 1.5 & run.time < 3.5);
        time_esc = run.time(run.time > 1.5 & run.time < 3.5);
        for bin = 1:length(vTras_esc)
            if vTras_esc(bin) > vThreshold/2
                escStart{n}(:,i) = time_esc(bin);
                break
            elseif bin == length(vTras_esc)
                escStart{n}(:,i) = 0;
            end
        end
        if length(run.vTras > 468)
            run.vTras = run.vTras(1:468);
            run.time = run.time(1:468);
        end
        speedBall{n}(:,i) = vTras';
    end
    
    %fRateBall_mean(n) = mean(fRateBall{n});
    fRateStrt_mean(n) = mean(fRateStrt{n});
    %fRateAir_mean(n) = mean(fRateAir{n});
    vTrasBall_mean(n) = mean(vTrasBall{n});
    vTrasFreez_mean(n) = mean(vTrasFreez{n});
    vTrasPeak_mean(n) = mean(vTrasPeak{n});
    freqsMeanBall(:,n) = mean(freqsBall{n},2);
    freqsMeanAir(:,n) = mean(freqsAir{n},2);
    speedMeanBall(:,n) = mean(speedBall{n},2);
    % %     %
    %      figure
    %plot(vTrasBall{n}, fRateBall{n}, 'o', 'linestyle', 'none', 'markersize', 8, 'color', 'k')
    %      input('as')
    %plot(vTrasBall{n}, fRateBall{n}, 'o', 'linestyle', 'none', 'markersize', 8)
    %fRateBall_all = [fRateBall_all fRateBall{n}];
    fRateStrt_all = [fRateStrt_all fRateStrt{n}];
    vTrasBall_all = [vTrasBall_all vTrasBall{n}];
    vTrasFreez_all = [vTrasFreez_all vTrasFreez{n}];
    vTrasPeak_all = [vTrasPeak_all vTrasPeak{n}];
    fRatePeak_all = [fRatePeak_all fRatePeak{n}];
    escStart_all = [escStart_all escStart{n}];
end
figure
hold on
yyaxis right
plot(t, mean(freqsMeanBall,2), 'color',[0.8500 0.3250 0.0980]);
ylabel('firing rate (Hz)');
stdBall = (std(freqsMeanBall'))';
errBall = stdBall / sqrt(length(neurons));
[hFill, err] = addPSHerror(t, mean(freqsMeanBall,2), errBall, [0.8500 0.3250 0.0980]);
%ylim([min(ylim) max(err)*1.2]);

xlabel('time (s)')
xlim([-2 6])
yyaxis left
speedMeanBall_all = (mean(speedMeanBall, 2))';
plot(t_ball, speedMeanBall_all,'color',[0 0.4470 0.7410]);
stdSpeed = (std(speedMeanBall'))';
errSpeed = stdSpeed / sqrt(length(neurons));
[hFill, err] = addPSHerror(t_ball, speedMeanBall_all, errSpeed, [0 0.4470 0.7410]);
ylabel('velocity (cm/s)')
hold off

figure
figure
hold on
plot(t, mean(freqsMeanBall,2), 'color',[0.8500 0.3250 0.0980]);
ylabel('firing rate (Hz)');
stdBall = (std(freqsMeanBall'))';
errBall = stdBall / sqrt(length(neurons));
[hFill, err] = addPSHerror(t, mean(freqsMeanBall,2), errBall, [0.8500 0.3250 0.0980]);
xlim([-2 7])
hold off

figure
xlabel('time (s)')
ax =gca;
ax.YAxisLocation = 'right';
speedMeanBall_all = (mean(speedMeanBall, 2))';
plot(t_ball, speedMeanBall_all,'color',[0 0.4470 0.7410]);
stdSpeed = (std(speedMeanBall'))';
errSpeed = stdSpeed / sqrt(length(neurons));
[hFill, err] = addPSHerror(t_ball, speedMeanBall_all, errSpeed, [0 0.4470 0.7410]);
ylabel('velocity (cm/s)')
xlim([-2 7])
hold off
% 
% x = vTrasBall_all';
% y = fRateStrt_all';
% figure(20)
% hold on
% [R,PValue] = corrplot([x, y]);
% hold off
% close(20)
% figure
% hold on
% plot(vTrasBall_all, fRateStrt_all, 'ok', 'linestyle', 'none')
% p = polyfit(x, y,1);
% yfit = polyval(p,x);
% plot(x,yfit)
% xlimit = xlim;
% ylimit = ylim;
% text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 10))])
% xlabel('escape velocity during expansion (cm/s)')
% ylabel('firing rate previus to expansion (Hz) ')
% hold off
% 
% x = vTrasFreez_all';
% y = fRateStrt_all';
% figure(20)
% hold on
% [R,PValue] = corrplot([x, y]);
% hold off
% close(20)
% figure
% hold on
% plot(vTrasFreez_all, fRateStrt_all, 'ok', 'linestyle', 'none')
% p = polyfit(x, y,1);
% yfit = polyval(p,x);
% plot(x,yfit)
% xlimit = xlim;
% ylimit = ylim;
% text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 10))])
% xlabel('speed during freezing period (cm/s)')
% ylabel('firing rate previus to expansion (Hz) ')
% hold off
% 
% x = vTrasPeak_all';
% y = fRateStrt_all';
% figure(20)
% hold on
% [R,PValue] = corrplot([x, y]);
% hold off
% close(20)
% figure
% hold on
% plot(vTrasPeak_all, fRateStrt_all, 'ok', 'linestyle', 'none')
% p = polyfit(x, y,1);
% yfit = polyval(p,x);
% plot(x,yfit)
% xlimit = xlim;
% ylimit = ylim;
% text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 10))])
% xlabel('Peak speed (cm/s)')
% ylabel('firing rate previus to expansion (Hz) ')
% hold off
% 
% %verifico si el animal corrió
% y = vTrasPeak_all';
% x = fRatePeak_all';
% for i = length(y):-1:1
%     if y(i) < vThreshold
%         y(i) = [];
%         x(i) = [];
%     end
% end
% figure(20)
% hold on
% [R,PValue] = corrplot([x, y]);
% hold off
% close(20)
% figure
% hold on
% plot(x, y, 'ok', 'linestyle', 'none')
% p = polyfit(x, y,1);
% yfit = polyval(p,x);
% plot(x,yfit)
% xlimit = xlim;
% ylimit = ylim;
% text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 5))])
% xlabel('Peak firing rate (Hz) ')
% ylabel('Peak speed (cm/s)')
% hold off
% 
% %verifico si el animal corrió
% y = escStart_all';
% x = fRateStrt_all';
% for i = length(y):-1:1
%     if y(i) < 1
%         y(i) = [];
%         x(i) = [];
%     elseif vTrasPeak_all(i) < vThreshold
%         y(i) = [];
%         x(i) = [];
%     end
% end
% 
% size(x)
% size(y)
% figure(20)
% hold on
% [R,PValue] = corrplot([x, y]);
% hold off
% close(20)
% figure
% hold on
% plot(x, y, 'ok', 'linestyle', 'none')
% p = polyfit(x, y,1);
% yfit = polyval(p,x);
% plot(x,yfit)
% xlimit = xlim;
% ylimit = ylim;
% text(0, ylimit(2)-(ylimit(2)*0.5), ['r=' num2str(round(R(2), 2)) '   p=' num2str(round(PValue(2), 10))])
% xlabel('Peak firing rate before expansion (Hz) ')
% ylabel('escape start (s)')
% hold off


end

function mixData = getMixedData(neurons,IDs, recs, varargin)

dur = [2 6];
binSize = 50; % ms
condition = 'ball';
spanEphys = 5;
spanBall = 5;
method = 'lowess';
stim = 2;
smoothBall = true;
for arg = 1:2:length(varargin)
    switch lower(varargin{arg})
        case 'durations'
            dur = varargin{arg+1};
        case 'binsize'
            binSize = varargin{arg+1};
        case 'condition'
            condition  = varargin{arg+1};
        case 'spanephys'
            spanEphys = varargin{arg+1};
        case 'spanball'
            spanBall = varargin{arg+1};
        case 'smoothmethod'
            method = varargin{arg+1};
        case 'smoothball'
            smoothBall = varargin{arg+1};
        case 'stim'
            stim = varargin{arg+1};
        otherwise
            error(['invalid optional argument: ' varargin{arg}])
    end
end



for n = 1:length(neurons)
    for r = recs
        if str2double(r.crabID) == IDs(n)
            rec = r;
            break
        end
    end
    mixData(n) = rec.getRunAndFireRate(neurons(n).cluster, 2, ...
        'durations', dur, 'binSize', binSize, 'condition', condition, ...
        'spanephys', spanEphys,'spanball', spanBall, 'smoothmethod', method, 'smoothball', smoothBall);
end
end

function color = getAnimalColor(nAnimal)
switch nAnimal
    case 1
        color = [0 0.4470 0.7410];
    case 2
        color = [0.8500 0.3250 0.0980];
    case 3
        color = [0.9290 0.6940 0.1250];
    case 4
        color = [0.4940 0.1840 0.5560];
    case 5
        color = [0.4660 0.6740 0.1880];
    case 6
        color = [0.3010 0.7450 0.9330];
    case 7
        color = [0.6350 0.0780 0.1840];
    case 8
        color = [0.6 0.6 0.6];
    otherwise
        color = [0 0 0];
end

end


function color = findColorGradient(colors, yMax, yMin, y)
% fMax = (y - yMin) / (yMax - yMin);
% fMin = (yMax - y) / (yMax - yMin);
% color = (colorMax * fMax) + (colorMin *fMin );
frecs = linspace(yMin, yMax, length(colors));
for i = 1:length(frecs)
    if y <= frecs(i)
        break
    end
end
color = colors(i,:);

end

function [inm_run, frz_run, wlk_run, no_run, air] = loadBLG2trials(IDs, mixData, mixData_air)

frz_list = ["28-7-2",...
            "28-7-4",...
            "27-7-1",...
            "27-7-2",...
            "19-2-1",...
            "19-2-4",...
            "19-2-3"];

frz_times = [1.151, 1.998;...
             1.378, 2.095;...
             1.1149, 1.790;...
             1.350, 1.508;...
             0.745, 1.476;...
             1.324, 1.827;...
             1.120, 1.385];
        
run_list = ["30-4-2",...
           "30-4-3",...
           "30-4-4",...
           "27-7-3",...
           "16-5-2"];
       
inm_list = ["28-7-1",...
            "28-7-3",...
            "30-4-1",...
            "26-9-3",...
            "26-9-4",...
            "16-5-1",...
            "16-5-3",...
            "9-7-4",...
            "9-7-3",...
            "26-9-1",...
            "26-9-2"];
        
nrn_list = ["27-7-4",...
            "19-2-2",...
            "16-5-4",...
            "15-6-1",...
            "15-6-2",...
            "15-6-3",...
            "15-6-4",...
            "9-7-1",...
            "9-7-2"];

           
frz_run = getTrialsData(IDs, mixData, frz_list);
wlk_run = getTrialsData(IDs, mixData, run_list);
inm_run = getTrialsData(IDs, mixData, inm_list);
no_run = getTrialsData(IDs, mixData, nrn_list);

for n = 1:length(mixData_air)
    for tr = 1:length(mixData_air(n).runs)
        if tr == 1 && n == 1
            air(1).ID = mixData_air(n).ID;
            air(1).clu = mixData_air(n).clu;
            air(1).tr = tr;
            air(1).vTras = mixData_air(n).runs(tr).vTras;
            air(1).t_behav = mixData_air(n).runs(tr).time;
            air(1).fRate = mixData_air(n).fRates(:,tr);
            air(1).t_ephys = mixData_air(n).t_ephys;
            air(1).fRateP1 = mean(air(1).fRate(air(1).t_ephys > 0.29999999 &  air(1).t_ephys < 1.300001));
            air(1).vEsc = mean(air(1).vTras(air(1).t_behav > 3 &  air(1).t_behav < 3.6));
            air(1).vTrasP1 = mean(air(1).vTras(air(1).t_behav > 0.29999999 &  air(1).t_behav < 1.300001));
        else
            air(end+1).ID = mixData_air(n).ID;
            air(end).clu = mixData_air(n).clu;
            air(end).tr = tr;
            air(end).vTras = mixData_air(n).runs(tr).vTras;
            air(end).t_behav = mixData_air(n).runs(tr).time;
            air(end).fRate = mixData_air(n).fRates(:,tr);
            air(end).t_ephys = mixData_air(n).t_ephys;
            air(end).fRateP1 = mean(air(end).fRate(air(end).t_ephys > 0.29999999 &  air(end).t_ephys < 1.300001));
            air(end).vEsc = mean(air(end).vTras(air(end).t_behav > 3 &  air(end).t_behav < 3.6));
            air(end).vTrasP1 = mean(air(end).vTras(air(end).t_behav > 0.29999999 &  air(end).t_behav < 1.300001));

        end
    end
end
for i = 1:length(frz_run)
    frz_run(i).frz_start = frz_times(i,1);
    frz_run(i).frz_stop = frz_times(i,2);
    
end

end


function compare_BLG2_behaviors(run, frz_run, no_run, inm_run, air)
for n = 1:length(frz_run)
vTras_frz(:,n) =  frz_run(n).vTras( frz_run(n).t_behav > -1.99999 & frz_run(n).t_behav < 8.0000001);
t_behav_frz(:,n) =  frz_run(n).t_behav( frz_run(n).t_behav > -1.99999 & frz_run(n).t_behav < 8.0000001);
fRate_frz(:,n) = frz_run(n).fRate( frz_run(n).t_ephys > -1.99999 & frz_run(n).t_ephys < 8.0000001);
t_ephys_frz(:,n) = frz_run(n).t_ephys( frz_run(n).t_ephys > -1.99999 & frz_run(n).t_ephys < 8.0000001);
end
for n = 1:length(run)
vTras_run(:,n) =  run(n).vTras( run(n).t_behav > -1.99999 & run(n).t_behav < 8.0000001);
t_behav_run(:,n) =  run(n).t_behav( run(n).t_behav > -1.99999 & run(n).t_behav < 8.0000001);
fRate_run(:,n) = run(n).fRate( run(n).t_ephys > -1.99999 & run(n).t_ephys < 8.0000001);
t_ephys_run(:,n) = run(n).t_ephys( run(n).t_ephys > -1.99999 & run(n).t_ephys < 8.0000001);
end
for n = 1:length(no_run)
vTras_nrn(:,n) =  no_run(n).vTras( no_run(n).t_behav > -1.99999 & no_run(n).t_behav < 8.0000001);
t_behav_nrn(:,n) =  no_run(n).t_behav( no_run(n).t_behav > -1.99999 & no_run(n).t_behav < 8.0000001);
fRate_nrn(:,n) = no_run(n).fRate( no_run(n).t_ephys > -1.99999 & no_run(n).t_ephys < 8.0000001);
t_ephys_nrn(:,n) = no_run(n).t_ephys( no_run(n).t_ephys > -1.99999 & no_run(n).t_ephys < 8.0000001);
end
for n = 1:length(inm_run)
vTras_irn(:,n) =  inm_run(n).vTras( inm_run(n).t_behav > -1.99999 & inm_run(n).t_behav < 8.0000001);
t_behav_irn(:,n) =  inm_run(n).t_behav( inm_run(n).t_behav > -1.99999 & inm_run(n).t_behav < 8.0000001);
fRate_irn(:,n) = inm_run(n).fRate( inm_run(n).t_ephys > -1.99999 & inm_run(n).t_ephys < 8.0000001);
t_ephys_irn(:,n) = inm_run(n).t_ephys( inm_run(n).t_ephys > -1.99999 & inm_run(n).t_ephys < 8.0000001);
end

for n = 1:length(air)
vTras_air(:,n) =  air(n).vTras( air(n).t_behav > -1.99999 & air(n).t_behav < 8.0000001);
t_behav_air(:,n) =  air(n).t_behav( air(n).t_behav > -1.99999 & air(n).t_behav < 8.0000001);
fRate_air(:,n) = air(n).fRate( air(n).t_ephys > -1.99999 & air(n).t_ephys < 8.0000001);
t_ephys_air(:,n) = air(n).t_ephys( air(n).t_ephys > -1.99999 & air(n).t_ephys < 8.0000001);
end

if isempty(run)
    vTras_run =  [];
    t_behav_run = [];
    fRate_run = [];
    t_ephys_run = [];
end


figure
subplot(2,2,1)
hold on

plot(mean(t_behav_frz,2), mean(vTras_frz,2), 'r', 'linewidth', 2)
plot(mean(t_behav_run,2), mean(vTras_run,2), 'k', 'linewidth', 2)
ylabel('velocity (cm/s)')
xlabel('time (s)')
hold on
plot(mean(t_behav_irn,2), mean(vTras_irn,2), 'b', 'linewidth', 2)
plot(mean(t_behav_nrn,2), mean(vTras_nrn,2), 'color', [0.2 0.8 0.2], 'linewidth', 2)
plot(mean(t_behav_air,2), mean(vTras_air,2), 'color', [0.4 0.4 0.4], 'linewidth', 2, 'linestyle', ':')
if isempty(run)
    legend({'walk->frz->run', 'inmobile-> run', 'no escape', 'air'}, 'AutoUpdate', 'off')
else
    legend({'walk->frz->run', 'walk->run', 'inmobile-> run', 'no escape', 'air'}, 'AutoUpdate', 'off')
end
stdErr_run = std(vTras_run, [], 2)/sqrt(length(run));
stdErr_frz = std(vTras_frz, [], 2)/sqrt(length(frz_run));
stdErr_irn = std(vTras_irn, [], 2)/sqrt(length(inm_run));
stdErr_nrn = std(vTras_nrn, [], 2)/sqrt(length(no_run));
stdErr_air = std(vTras_air, [], 2)/sqrt(length(air));
addPSHerror(mean(t_behav_run,2), mean(vTras_run,2), stdErr_run, [0 0 0])
hold on
addPSHerror(mean(t_behav_frz,2), mean(vTras_frz,2), stdErr_frz, [1 0 0])
hold on
addPSHerror(mean(t_behav_irn,2), mean(vTras_irn,2), stdErr_irn, [0 0 1])
hold on
addPSHerror(mean(t_behav_nrn,2), mean(vTras_nrn,2), stdErr_nrn, [0.2 0.8 0.2])
hold on
addPSHerror(mean(t_behav_air,2), mean(vTras_air,2), stdErr_air, [0.2 0.8 0.2])
hold on
addPSHDecorations(2, 3.4, 60, 'stimunderplot', true, 'heigth', 0.15)

xlim([-2 8])
prettyAxes

subplot(2,2,3)
hold on
plot(mean(t_ephys_frz,2), mean(fRate_frz,2), 'r', 'linewidth', 2)
plot(mean(t_ephys_run,2), mean(fRate_run,2), 'k', 'linewidth', 2)

ylabel(' firing rate (Hz)')
xlabel('time (s)')
hold on
plot(mean(t_ephys_irn,2), mean(fRate_irn,2), 'b', 'linewidth', 2)
plot(mean(t_ephys_nrn,2), mean(fRate_nrn,2), 'color', [0.2 0.8 0.2], 'linewidth', 2)
plot(mean(t_ephys_air,2), mean(fRate_air,2), 'color', [0.4 0.4 0.4], 'linewidth', 2, 'linestyle', ':')
legend({'walk->frz->run', 'walk->run', 'inmobile-> run', 'no escape', 'air'}, 'AutoUpdate', 'off')
stdErr_run = std(fRate_run, [], 2)/sqrt(length(run));
stdErr_frz = std(fRate_frz, [], 2)/sqrt(length(frz_run));
stdErr_irn = std(fRate_irn, [], 2)/sqrt(length(inm_run));
stdErr_nrn = std(fRate_nrn, [], 2)/sqrt(length(no_run));
stdErr_air = std(fRate_air, [], 2)/sqrt(length(air));
addPSHerror(mean(t_ephys_run,2), mean(fRate_run,2), stdErr_run, [0 0 0])
hold on
addPSHerror(mean(t_ephys_frz,2), mean(fRate_frz,2), stdErr_frz, [1 0 0])
hold on
addPSHerror(mean(t_ephys_irn,2), mean(fRate_irn,2), stdErr_irn, [0 0 1])
hold on
addPSHerror(mean(t_ephys_nrn,2), mean(fRate_nrn,2), stdErr_nrn, [0.2 0.8 0.2])
hold on
addPSHerror(mean(t_ephys_air,2), mean(fRate_air,2), stdErr_air, [0.4 0.4 0.4])
hold on
addPSHDecorations(2, 3.4, 60, 'stimunderplot', true, 'heigth', 0.15)
xlim([-2 8])
prettyAxes

subplot(2,2,2)
hold on
bar(3, mean([inm_run.vTrasP1]), 'facecolor', [0.1 0.1 0.9], 'edgecolor', [0.1 0.1 0.9])
errorbar(3, mean([inm_run.vTrasP1]), std([inm_run.vTrasP1])/sqrt(length([inm_run.vTrasP1])), 'linewidth', 2, 'color', [0 0 0])
bar(1, mean([frz_run.vTrasP1]), 'facecolor', [0.9 0.1 0.1], 'edgecolor', [0.9 0.1 0.1])
errorbar(1, mean([frz_run.vTrasP1]), std([frz_run.vTrasP1])/sqrt(length([frz_run.vTrasP1])), 'linewidth', 2, 'color', [0 0 0])
bar(2, mean([run.vTrasP1]),'facecolor', [0.2 0.2 0.2], 'edgecolor', [0.2 0.2 0.2])
errorbar(2, mean([run.vTrasP1]), std([run.vTrasP1])/sqrt(length([run.vTrasP1])), 'linewidth', 2, 'color', [0 0 0])
bar(4, mean([no_run.vTrasP1]),'facecolor', [0.1 0.8 0.1], 'edgecolor', [0.1 0.8 0.1])
errorbar(4, mean([no_run.vTrasP1]), std([no_run.vTrasP1])/sqrt(length([no_run.vTrasP1])), 'linewidth', 2, 'color', [0 0 0])
bar(5, mean([air.vTrasP1]),'facecolor', [0.4 0.4 0.4], 'edgecolor', [0.4 0.4 0.4])
errorbar(5, mean([air.vTrasP1]), std([air.vTrasP1])/sqrt(length([air.vTrasP1])), 'linewidth', 2, 'color', [0 0 0])
xlim([0 6])
prettyAxes
xticks([1 2 3 4 5])
xticklabels({ 'walk -> frz -> run', 'walk -> run', 'inm -> run','no escape', 'air'})
xtickangle(30)
ylabel('velocity during the first peak (cm/s)')

subplot(2,2,4)
hold on
bar(3, mean([inm_run.fRateP1]), 'facecolor', [0.1 0.1 0.9], 'edgecolor', [0.1 0.1 0.9])
errorbar(3, mean([inm_run.fRateP1]), std([inm_run.fRateP1])/sqrt(length([inm_run.fRateP1])), 'linewidth', 2, 'color', [0 0 0])
bar(1, mean([frz_run.fRateP1]), 'facecolor', [0.9 0.1 0.1], 'edgecolor', [0.9 0.1 0.1])
errorbar(1, mean([frz_run.fRateP1]), std([frz_run.fRateP1])/sqrt(length([frz_run.fRateP1])), 'linewidth', 2, 'color', [0 0 0])
bar(2, mean([run.fRateP1]),'facecolor', [0.2 0.2 0.2], 'edgecolor', [0.2 0.2 0.2])
errorbar(2, mean([run.fRateP1]), std([run.fRateP1])/sqrt(length([run.fRateP1])), 'linewidth', 2, 'color', [0 0 0])
bar(4, mean([no_run.fRateP1]),'facecolor', [0.1 0.8 0.1], 'edgecolor', [0.1 0.8 0.1])
errorbar(4, mean([no_run.fRateP1]), std([no_run.fRateP1])/sqrt(length([no_run.fRateP1])), 'linewidth', 2, 'color', [0 0 0])
bar(5, mean([air.fRateP1]),'facecolor', [0.4 0.4 0.4], 'edgecolor', [0.4 0.4 0.4])
errorbar(5, mean([air.fRateP1]), std([air.fRateP1])/sqrt(length([air.fRateP1])), 'linewidth', 2, 'color', [0 0 0])
xlim([0 6])
prettyAxes
xticks([1 2 3 4 5])
xticklabels({ 'walk -> frz -> run', 'walk -> run', 'inm -> run','no escape', 'air'})
xtickangle(30)
ylabel('firing rate of the first peak (Hz)')

data = table
data.ID = [[frz_run.ID]';[inm_run.ID]';  [run.ID]'; [no_run.ID]']
data.vEsc = [ [frz_run.vEsc]';[inm_run.vEsc]'; [run.vEsc]'; [no_run.vEsc]']
data.behavior =  [ones(size([frz_run.vEsc]'))*1;ones(size([inm_run.vEsc]'))*2; ones(size([run.vEsc]'))*3; ones(size([no_run.vEsc]'))*4]
writetable(data,'G:\My Drive\Tesis\seccion registros crabola\B2\BLG2_vEsc_data.csv')

end

function compare_MLG2_behaviors(frz_run, no_run, inm_run, air)
for n = 1:length(frz_run)
vTras_frz(:,n) =  frz_run(n).vTras( frz_run(n).t_behav > -1.99999 & frz_run(n).t_behav < 8.0000001);
t_behav_frz(:,n) =  frz_run(n).t_behav( frz_run(n).t_behav > -1.99999 & frz_run(n).t_behav < 8.0000001);
fRate_frz(:,n) = frz_run(n).fRate( frz_run(n).t_ephys > -1.99999 & frz_run(n).t_ephys < 8.0000001);
t_ephys_frz(:,n) = frz_run(n).t_ephys( frz_run(n).t_ephys > -1.99999 & frz_run(n).t_ephys < 8.0000001);
vTras_peak_frz(n) = mean(frz_run(n).vTras( frz_run(n).t_behav > 3 & frz_run(n).t_behav < 3.6));
fRate_P2_frz(n) = mean(frz_run(n).fRate( frz_run(n).t_ephys > 3 & frz_run(n).t_ephys < 3.4));
fRate_P1_frz(n) = mean(frz_run(n).fRate( frz_run(n).t_ephys > 0 & frz_run(n).t_ephys < 1));
end

for n = 1:length(no_run)
vTras_nrn(:,n) =  no_run(n).vTras( no_run(n).t_behav > -1.99999 & no_run(n).t_behav < 8.0000001);
t_behav_nrn(:,n) =  no_run(n).t_behav( no_run(n).t_behav > -1.99999 & no_run(n).t_behav < 8.0000001);
fRate_nrn(:,n) = no_run(n).fRate( no_run(n).t_ephys > -1.99999 & no_run(n).t_ephys < 8.0000001);
t_ephys_nrn(:,n) = no_run(n).t_ephys( no_run(n).t_ephys > -1.99999 & no_run(n).t_ephys < 8.0000001);
end
for n = 1:length(inm_run)
vTras_irn(:,n) =  inm_run(n).vTras( inm_run(n).t_behav > -1.99999 & inm_run(n).t_behav < 8.0000001);
t_behav_irn(:,n) =  inm_run(n).t_behav( inm_run(n).t_behav > -1.99999 & inm_run(n).t_behav < 8.0000001);
fRate_irn(:,n) = inm_run(n).fRate( inm_run(n).t_ephys > -1.99999 & inm_run(n).t_ephys < 8.0000001);
t_ephys_irn(:,n) = inm_run(n).t_ephys( inm_run(n).t_ephys > -1.99999 & inm_run(n).t_ephys < 8.0000001);
vTras_peak_irn(n) = mean(inm_run(n).vTras( inm_run(n).t_behav > 3 & inm_run(n).t_behav < 3.6));
fRate_P2_irn(n) = mean(inm_run(n).fRate( inm_run(n).t_ephys > 3 & inm_run(n).t_ephys < 3.4));
fRate_P1_irn(n) = mean(inm_run(n).fRate( inm_run(n).t_ephys > 0 & inm_run(n).t_ephys < 1));
end

for n = 1:length(air)
vTras_air(:,n) =  air(n).vTras( air(n).t_behav > -1.99999 & air(n).t_behav < 8.0000001);
t_behav_air(:,n) =  air(n).t_behav( air(n).t_behav > -1.99999 & air(n).t_behav < 8.0000001);
fRate_air(:,n) = air(n).fRate( air(n).t_ephys > -1.99999 & air(n).t_ephys < 8.0000001);
t_ephys_air(:,n) = air(n).t_ephys( air(n).t_ephys > -1.99999 & air(n).t_ephys < 8.0000001);
end


figure
subplot(2,2,1)
hold on

plot(mean(t_behav_frz,2), mean(vTras_frz,2), 'r', 'linewidth', 2)
ylabel('velocity (cm/s)')
xlabel('time (s)')
hold on
plot(mean(t_behav_irn,2), mean(vTras_irn,2), 'b', 'linewidth', 2)
plot(mean(t_behav_nrn,2), mean(vTras_nrn,2), 'color', [0.2 0.8 0.2], 'linewidth', 2)
plot(mean(t_behav_air,2), mean(vTras_air,2), 'color', [0.4 0.4 0.4], 'linewidth', 2, 'linestyle', ':')
legend({'walk->frz->run', 'inmobile-> run', 'no escape', 'air'}, 'AutoUpdate', 'off')

stdErr_frz = std(vTras_frz, [], 2)/sqrt(length(frz_run));
stdErr_irn = std(vTras_irn, [], 2)/sqrt(length(inm_run));
stdErr_nrn = std(vTras_nrn, [], 2)/sqrt(length(no_run));
stdErr_air = std(vTras_air, [], 2)/sqrt(length(air));
hold on
addPSHerror(mean(t_behav_frz,2), mean(vTras_frz,2), stdErr_frz, [1 0 0])
hold on
addPSHerror(mean(t_behav_irn,2), mean(vTras_irn,2), stdErr_irn, [0 0 1])
hold on
addPSHerror(mean(t_behav_nrn,2), mean(vTras_nrn,2), stdErr_nrn, [0.2 0.8 0.2])
hold on
addPSHerror(mean(t_behav_air,2), mean(vTras_air,2), stdErr_air, [0.2 0.8 0.2])
hold on
addPSHDecorations(2, 3.4, 60, 'stimunderplot', true, 'heigth', 0.15)

xlim([-2 8])
prettyAxes

subplot(2,2,3)
hold on
plot(mean(t_ephys_frz,2), mean(fRate_frz,2), 'r', 'linewidth', 2)

ylabel(' firing rate (Hz)')
xlabel('time (s)')
hold on
plot(mean(t_ephys_irn,2), mean(fRate_irn,2), 'b', 'linewidth', 2)
plot(mean(t_ephys_nrn,2), mean(fRate_nrn,2), 'color', [0.2 0.8 0.2], 'linewidth', 2)
plot(mean(t_ephys_air,2), mean(fRate_air,2), 'color', [0.4 0.4 0.4], 'linewidth', 2, 'linestyle', ':')
legend({'walk->frz->run', 'inmobile-> run', 'no escape', 'air'}, 'AutoUpdate', 'off')
stdErr_frz = std(fRate_frz, [], 2)/sqrt(length(frz_run));
stdErr_irn = std(fRate_irn, [], 2)/sqrt(length(inm_run));
stdErr_nrn = std(fRate_nrn, [], 2)/sqrt(length(no_run));
stdErr_air = std(fRate_air, [], 2)/sqrt(length(air));
hold on
addPSHerror(mean(t_ephys_frz,2), mean(fRate_frz,2), stdErr_frz, [1 0 0])
hold on
addPSHerror(mean(t_ephys_irn,2), mean(fRate_irn,2), stdErr_irn, [0 0 1])
hold on
addPSHerror(mean(t_ephys_nrn,2), mean(fRate_nrn,2), stdErr_nrn, [0.2 0.8 0.2])
hold on
addPSHerror(mean(t_ephys_air,2), mean(fRate_air,2), stdErr_air, [0.4 0.4 0.4])
hold on
addPSHDecorations(2, 3.4, 60, 'stimunderplot', true, 'heigth', 0.15)
xlim([-2 8])
prettyAxes

subplot(2,2,2)
hold on
bar(2, mean([inm_run.vTrasP1]), 'facecolor', [0.1 0.1 0.9], 'edgecolor', [0.1 0.1 0.9])
errorbar(2, mean([inm_run.vTrasP1]), std([inm_run.vTrasP1])/sqrt(length([inm_run.vTrasP1])), 'linewidth', 2, 'color', [0 0 0])
bar(1, mean([frz_run.vTrasP1]), 'facecolor', [0.9 0.1 0.1], 'edgecolor', [0.9 0.1 0.1])
errorbar(1, mean([frz_run.vTrasP1]), std([frz_run.vTrasP1])/sqrt(length([frz_run.vTrasP1])), 'linewidth', 2, 'color', [0 0 0])
bar(3, mean([no_run.vTrasP1]),'facecolor', [0.1 0.8 0.1], 'edgecolor', [0.1 0.8 0.1])
errorbar(3, mean([no_run.vTrasP1]), std([no_run.vTrasP1])/sqrt(length([no_run.vTrasP1])), 'linewidth', 2, 'color', [0 0 0])
bar(4, mean([air.vTrasP1]),'facecolor', [0.4 0.4 0.4], 'edgecolor', [0.4 0.4 0.4])
errorbar(4, mean([air.vTrasP1]), std([air.vTrasP1])/sqrt(length([air.vTrasP1])), 'linewidth', 2, 'color', [0 0 0])
xlim([0 5])
prettyAxes
xticks([1 2 3 4])
xticklabels({ 'walk -> frz -> run', 'inm -> run','no escape', 'air'})
xtickangle(30)
ylabel('velocity during the first peak (cm/s)')

subplot(2,2,4)
hold on
bar(2, mean([inm_run.fRateP1]), 'facecolor', [0.1 0.1 0.9], 'edgecolor', [0.1 0.1 0.9])
errorbar(2, mean([inm_run.fRateP1]), std([inm_run.fRateP1])/sqrt(length([inm_run.fRateP1])), 'linewidth', 2, 'color', [0 0 0])
bar(1, mean([frz_run.fRateP1]), 'facecolor', [0.9 0.1 0.1], 'edgecolor', [0.9 0.1 0.1])
errorbar(1, mean([frz_run.fRateP1]), std([frz_run.fRateP1])/sqrt(length([frz_run.fRateP1])), 'linewidth', 2, 'color', [0 0 0])
bar(3, mean([no_run.fRateP1]),'facecolor', [0.1 0.8 0.1], 'edgecolor', [0.1 0.8 0.1])
errorbar(3, mean([no_run.fRateP1]), std([no_run.fRateP1])/sqrt(length([no_run.fRateP1])), 'linewidth', 2, 'color', [0 0 0])
bar(4, mean([air.fRateP1]),'facecolor', [0.4 0.4 0.4], 'edgecolor', [0.4 0.4 0.4])
errorbar(4, mean([air.fRateP1]), std([air.fRateP1])/sqrt(length([air.fRateP1])), 'linewidth', 2, 'color', [0 0 0])
xlim([0 5])
prettyAxes
xticks([1 2 3 4])
xticklabels({ 'walk -> frz -> run', 'inm -> run','no escape', 'air'})
xtickangle(30)
ylabel('firing rate of the first peak (Hz)')


figure
subplot(1,2,1)
hold on
plot(fRate_P1_frz, vTras_peak_frz, '.r', 'markersize', 30)
plot(fRate_P1_irn, vTras_peak_irn, '.b', 'markersize', 30)
xlabel('escape velocity (cm/s)')
ylabel('firing rate on P1 (Hz)')
legend({'frz', 'inm'})
subplot(1,2,2)
hold on
plot(fRate_P2_frz, vTras_peak_frz, '.r', 'markersize', 30)
plot(fRate_P2_irn, vTras_peak_irn, '.b', 'markersize', 30)
xlabel('escape velocity (cm/s)')
ylabel('firing rate on P2 (Hz)')
legend({'frz', 'inm'})

end


function run = getTrialsData(ID_list, mixData, codeList)

[ID, cluster, trial] = getCrabTrialData(codeList);

for i = 1:length(ID)
    ind = find(ID_list == ID(i));
    run(i).ID = ID(i);
    run(i).clu = cluster(i);
    run(i).tr = trial(i);
    tr = trial(i);
    run(i).vTras = mixData(ind).runs(tr).vTras;
    run(i).t_behav = mixData(ind).runs(tr).time;
    run(i).fRate = mixData(ind).fRates(:,tr);
    run(i).t_ephys = mixData(ind).t_ephys;
    run(i).fRateP1 = mean(run(i).fRate(run(i).t_ephys > 0.29999999 &  run(i).t_ephys < 1.300001));
    run(i).vEsc = mean(run(i).vTras(run(i).t_behav > 3 & run(i).t_behav < 3.6));
    run(i).vTrasP1 = mean(run(i).vTras(run(i).t_behav > 0.29999999 &  run(i).t_behav < 1.300001));
end
end

function final_criteria = find_BLG2_interactions(neu, IDs, recs)

iterations = 1000;
binSize = 0.001;
duration = 0.06;
for i = 1:length(IDs)
    %busco el registro al que pertenece mi neurona
    id = IDs(i);
    clu = neu(i).cluster;
    for r = recs
        if str2double(r.crabID) == id
            break
        elseif strcmp(r.crabID, recs(end).crabID)
            error(['ID: ' num2str(id) ' not found'])
        end
    end
    %encuentro todos los clusters asociados al mio dentro del registro
    clus = [];
    for nClu = 2:length(r.neurons)
        if nClu ~= clu
            clus(end+1) = nClu;
        end
    end
    
    %hago el jittering y calculo los desvios
    pair = 0;
    for c = clus
        pair = pair+1;
        names = {num2str(clu), num2str(c)};
        neurons = [neu(i), r.neurons(c)];
        [raster, index, fRate, fRateSTD] = getPairSpontData(names, neurons);
        nSpks1 = sum(index == 1);
        nSpks2 = sum(index == 2);
        tic
        jittered = zeros(nSpks1 + nSpks2,iterations);
        index = [ones(nSpks1,1) ; 2*ones(nSpks2,1)];
        for nJit = 1:iterations
            jittered(1:nSpks1,nJit) = jitterSpikes(raster(index == 1), 5);
            jittered(nSpks1+1:end,nJit) = jitterSpikes(raster(index == 2), 5);
            [ccg, t, tau, C] = CCG(jittered(:,nJit), index, 'BinSize', binSize, 'Duration', duration, 'mode', 'ccg', 'alpha', 0.05);
            jitteredCCGs(:,nJit) = ccg(:,1,2);
        end
        jit{pair}.mean = mean(jitteredCCGs, 2);
        jit{pair}.std = std(jitteredCCGs,0,2);
        toc
        figure
        hold on
        [ccg, t, tau, C] = CCG(raster, index, 'BinSize', binSize, 'Duration', duration, 'mode', 'ccg', 'alpha', 0.05);
        bar(t*1000, ccg(:,1,2), 'FaceColor', [0 0 0], 'EdgeColor', [0 0 0], 'BarWidth', 1)
        line([10 10], [0 max(ylim)], 'LineStyle', '-', 'Color', [0 0 0.8], 'LineWidth', 1.5)
        line([-10 -10], [0 max(ylim)], 'LineStyle', '-', 'Color', [0 0 0.8], 'LineWidth', 1.5)
        xlim([min(t*1000) max(t*1000)]);
        ylabel('count')
        xlabel('time (ms) ')
        ytic = yticks;
        yticks([0, max(ytic)/2, max(ytic)]);
        line( [0 0], [0 max(ytic)])
        xticks([min(t*1000) 0 max(t*1000)]);
        plot(t*1000, jit{pair}.mean+2*jit{pair}.std, 'Color', [0.8 0 0], 'LineStyle', '--', 'LineWidth', 1.5)
        plot(t*1000, jit{pair}.mean-2*jit{pair}.std, 'Color', [0.8 0 0], 'LineStyle', '--', 'LineWidth', 1.5)
        plot(t*1000, jit{pair}.mean+3*jit{pair}.std, 'Color', [0 0.8 0.8], 'LineStyle', '--', 'LineWidth', 1.5)
        plot(t*1000, jit{pair}.mean-3*jit{pair}.std, 'Color', [0 0.8 0.8], 'LineStyle', '--', 'LineWidth', 1.5)
        sgtitle(['crab ID = ' num2str(id) ' - cluster: ' num2str(c)])
        hold off
        
        final_criteria(pair) = str2double(input(' 1 o 0?', 's'));
        close all
        
    end
end

end

function jitteredSpks = jitterSpikes(spks, halfWidthMS)
%halfWidth is in miliseconds
%spks is in seconds
halfWidth = halfWidthMS / 1000;
jitteredSpks = zeros(size(spks));
for s = 1:length(spks)
    jitteredSpks(s) = randNegPos(halfWidth) + spks(s);
end

end

function [raster, index, fRate, fRateStd] = getPairSpontData(names, neurons)
tPre = 0.5;
tPost = 5;

refSpks = getSpontSpks(neurons(1), tPost, tPre);
evalSpks = getSpontSpks(neurons(2), tPost, tPre);
raster = [refSpks;evalSpks];
index = [ones(length(refSpks),1); 2*ones(length(evalSpks),1)];
[fRate, fRateStd] = getSpontFreq(neurons(2), tPost, tPre);
end

function raster = getSpontSpks(neuron, tPost, tPre)
for s = 1:length(neuron.stims)
    if s == 1
        raster = neuron.data(neuron.data < (neuron.stims(s).start - tPre));
    else
        raster = [raster; neuron.data(neuron.data < (neuron.stims(s).start - tPre)...
                                        & neuron.data > (neuron.stims(s-1).finish + tPost))];
    end
end
end

function [fMean, fDev] = getSpontFreq(neuron, tPost, tPre, varargin)

conditon = 'all';
for arg = 1:2:length(varargin)
    switch lower(varargin{arg})
        case 'condition'
            condition = varargin{arg+1};
    end
end


nBlocks = length(neuron.stims)-1;
blocks.start = [neuron.stims(1:end-1).finish] + tPost;
blocks.stop  = [neuron.stims(2:end).start] + tPre;

for b = 1:nBlocks
    blocks.nSpks(b) = sum(neuron.data > blocks.start(b) & neuron.data < blocks.stop(b));
    blocks.freq(b)  = blocks.nSpks(b) / (blocks.stop(b) - blocks.start(b));
end

fMean = mean(blocks.freq);
fDev = std(blocks.freq);

end
    
function r = randNegPos(halfWidth)
r = (-1+2*rand(1,1)) * halfWidth;
end


function [ID, cluster, trial] = getCrabTrialData(codeList)
for i = 1:length(codeList)
    code = codeList(i).split('-');
    ID(i) = str2double(code(1));
    cluster(i) = str2double(code(2));
    trial(i) = str2double(code(3));
end
end


function mergedData = get_LG_interactions(recs, IDs, clusters, varargin)

dur = [2 6];
binSize = 50; % ms
condition = 'ball';
spanEphys = 5;
spanBall = 5;
method = 'lowess';
stim = 2;
smoothBall = true;
for arg = 1:2:length(varargin)
    switch lower(varargin{arg})
        case 'durations'
            dur = varargin{arg+1};
        case 'binsize'
            binSize = varargin{arg+1};
        case 'condition'
            condition  = varargin{arg+1};
        case 'spanephys'
            spanEphys = varargin{arg+1};
        case 'spanball'
            spanBall = varargin{arg+1};
        case 'smoothmethod'
            method = varargin{arg+1};
        case 'smoothball'
            smoothBall = varargin{arg+1};
        case 'stim'
            stim = varargin{arg+1};
        otherwise
            error(['invalid optional argument: ' varargin{arg}])
    end
end

M2_color = [0 158 115] / 255;
B2_color = [213 50 102] / 255;
mergedData = {};
for r = recs
    for i = 1:length(IDs)
        id = IDs(i);
        BLG2_clu = clusters(i, 1);
        MLG2_clu = clusters(i, 2);
        if str2double(r.crabID) == id
            [raster, index, fRate, fRateSTD] = getPairSpontData('asd', [r.neurons(BLG2_clu), r.neurons(MLG2_clu)]);
            [ccg, t, tau, C] = CCG(raster, index, 'BinSize', 0.001, 'Duration', 0.12, 'mode', 'ccg', 'alpha', 0.05);
            ccg = ccg / (length(find(raster(index == 1)))* 0.001);
            figure
            title([num2str(id) ' - BLG2'])
            bar(t*1000, ccg(:,1,1), 'FaceColor', B2_color, 'EdgeColor', B2_color, 'BarWidth', 1)
            figure
            title([num2str(id) ' - MLG2'])
            bar(t*1000, ccg(:,2,2), 'FaceColor', M2_color, 'EdgeColor', M2_color, 'BarWidth', 1)

            figure
            title(num2str(id))
            bar(t*1000, ccg(:,1,2), 'FaceColor', [0 0 0], 'EdgeColor', [0 0 0], 'BarWidth', 1)
            xticks([-60 0 60])
            ylim([0 23])
            ylabel('frecuencia (Hz)')
            xlabel('dt(ms)')
            prettyAxes
            figure
            [ccg, t, tau, C] = CCG(raster, index, 'BinSize', 0.01, 'Duration', 1.2, 'mode', 'ccg', 'alpha', 0.05);
            ccg = ccg / (length(find(raster(index == 1)))* 0.01);
            bar(t*1000, ccg(:,1,2), 'FaceColor', [0 0 0], 'EdgeColor', [0 0 0], 'BarWidth', 1)
            xticks([-600 0 600])
            ylim([0 23])
            ylabel('frecuencia (Hz)')
            xlabel('dt(ms)')
            prettyAxes
            mixData_B2 = r.getRunAndFireRate(r.neurons(BLG2_clu).cluster, stim, ...
            'durations', dur, 'binSize', binSize, 'condition', condition, ...
            'spanephys', spanEphys,'spanball', spanBall, 'smoothmethod', method, 'smoothball', smoothBall);
            mixData_M2 = r.getRunAndFireRate(r.neurons(MLG2_clu).cluster, stim, ...
            'durations', dur, 'binSize', binSize, 'condition', condition, ...
            'spanephys', spanEphys,'spanball', spanBall, 'smoothmethod', method, 'smoothball', smoothBall);
            mergedData{end+1, 1} = mixData_M2;
            mergedData{end, 2} = mixData_B2;
        end
    end
end
end

function [inm_run, frz_run, run, no_run, air] = loadMLG2trials(mixData, ID_list, mixData_air)
load('C:\Users\Alejandro\Documents\recuperados_disco_maquina_labo\Registros\MLG2_trial_class.mat')
for i = 1:length(MLG2_trial_class.inm_run)
    inm_run(i).ID = MLG2_trial_class.inm_run(i).ID;
    ind = find(ID_list == inm_run(i).ID);
    inm_run(i).clu = MLG2_trial_class.inm_run(i).clu;
    inm_run(i).tr = MLG2_trial_class.inm_run(i).tr;
    tr = MLG2_trial_class.inm_run(i).tr;
    inm_run(i).vTras = mixData(ind).runs(tr).vTras;
    inm_run(i).t_behav = mixData(ind).runs(tr).time;
    inm_run(i).fRate = mixData(ind).fRates(:,tr);
    inm_run(i).t_ephys = mixData(ind).t_ephys;
    inm_run(i).fRateP1 = mean(inm_run(i).fRate(inm_run(i).t_ephys > 0.00001 &  inm_run(i).t_ephys < 1.000001));
    inm_run(i).vEsc = mean(inm_run(i).vTras(inm_run(i).t_behav > 3 & inm_run(i).t_behav < 3.6));
    inm_run(i).vTrasP1 = mean(inm_run(i).vTras(inm_run(i).t_behav > 0.00001 &  inm_run(i).t_behav < 1.000001));
end

for i = 1:length(MLG2_trial_class.frz_run)
    frz_run(i).ID = MLG2_trial_class.frz_run(i).ID;
    ind = find(ID_list == frz_run(i).ID);
    frz_run(i).clu = MLG2_trial_class.frz_run(i).clu;
    frz_run(i).tr = MLG2_trial_class.frz_run(i).tr;
    tr = MLG2_trial_class.frz_run(i).tr;
    frz_run(i).vTras = mixData(ind).runs(tr).vTras;
    frz_run(i).t_behav = mixData(ind).runs(tr).time;
    frz_run(i).fRate = mixData(ind).fRates(:,tr);
    frz_run(i).t_ephys = mixData(ind).t_ephys;
    frz_run(i).fRateP1 = mean(frz_run(i).fRate(frz_run(i).t_ephys > 0.00001 &  frz_run(i).t_ephys < 1.000001));
    frz_run(i).vEsc = mean(frz_run(i).vTras(frz_run(i).t_behav > 3 & frz_run(i).t_behav < 3.6));
    frz_run(i).vTrasP1 = mean(frz_run(i).vTras(frz_run(i).t_behav > 0.00001 &  frz_run(i).t_behav < 1.000001));
end
if isempty(MLG2_trial_class.run)
    run = [];
end
for i = 1:length(MLG2_trial_class.run)
    run(i).ID = MLG2_trial_class.run(i).ID;
    ind = find(ID_list == run(i).ID);
    run(i).clu = MLG2_trial_class.run(i).clu;
    run(i).tr = MLG2_trial_class.run(i).tr;
    tr = MLG2_trial_class.run(i).tr;
    run(i).vTras = mixData(ind).runs(tr).vTras;
    run(i).t_behav = mixData(ind).runs(tr).time;
    run(i).fRate = mixData(ind).fRates(:,tr);
    run(i).t_ephys = mixData(ind).t_ephys;
    run(i).fRateP1 = mean(run(i).fRate(run(i).t_ephys > 0.00001 &  run(i).t_ephys < 1.000001));
    run(i).vEsc = mean(run(i).vTras(run(i).t_behav > 3 & run(i).t_behav < 3.6));
    run(i).vTrasP1 = mean(run(i).vTras(run(i).t_behav > 0.00001 &  run(i).t_behav < 1.000001));
end

for i = 1:length(MLG2_trial_class.no_run)
    no_run(i).ID = MLG2_trial_class.no_run(i).ID;
    ind = find(ID_list == no_run(i).ID);
    no_run(i).clu = MLG2_trial_class.no_run(i).clu;
    no_run(i).tr = MLG2_trial_class.no_run(i).tr;
    tr = MLG2_trial_class.no_run(i).tr;
    no_run(i).vTras = mixData(ind).runs(tr).vTras;
    no_run(i).t_behav = mixData(ind).runs(tr).time;
    no_run(i).fRate = mixData(ind).fRates(:,tr);
    no_run(i).t_ephys = mixData(ind).t_ephys;
    no_run(i).fRateP1 = mean(no_run(i).fRate(no_run(i).t_ephys > 0.00001 &  no_run(i).t_ephys < 1.000001));
    no_run(i).vEsc = mean(no_run(i).vTras(no_run(i).t_behav > 3 & no_run(i).t_behav < 3.6));
    no_run(i).vTrasP1 = mean(no_run(i).vTras(no_run(i).t_behav > 0.00001 &  no_run(i).t_behav < 1.000001));
end

for n = 1:length(mixData_air)
    for tr = 1:length(mixData_air(n).runs)
        if tr == 1 && n == 1
            air(1).ID = mixData_air(n).ID;
            air(1).clu = mixData_air(n).clu;
            air(1).tr = tr;
            air(1).vTras = mixData_air(n).runs(tr).vTras;
            air(1).t_behav = mixData_air(n).runs(tr).time;
            air(1).fRate = mixData_air(n).fRates(:,tr);
            air(1).t_ephys = mixData_air(n).t_ephys;
            air(1).fRateP1 = mean(air(1).fRate(air(1).t_ephys > 0.29999999 &  air(1).t_ephys < 1.300001));
            air(1).vEsc = mean(air(1).vTras(air(1).t_behav > 3 &  air(1).t_behav < 3.6));
            air(1).vTrasP1 = mean(air(1).vTras(air(1).t_behav > 0.29999999 &  air(1).t_behav < 1.300001));
        else
            air(end+1).ID = mixData_air(n).ID;
            air(end).clu = mixData_air(n).clu;
            air(end).tr = tr;
            air(end).vTras = mixData_air(n).runs(tr).vTras;
            air(end).t_behav = mixData_air(n).runs(tr).time;
            air(end).fRate = mixData_air(n).fRates(:,tr);
            air(end).t_ephys = mixData_air(n).t_ephys;
            air(end).fRateP1 = mean(air(end).fRate(air(end).t_ephys > 0.29999999 &  air(end).t_ephys < 1.300001));
            air(end).vEsc = mean(air(end).vTras(air(end).t_behav > 3 &  air(end).t_behav < 3.6));
            air(end).vTrasP1 = mean(air(end).vTras(air(end).t_behav > 0.29999999 &  air(end).t_behav < 1.300001));

        end
    end
end

end