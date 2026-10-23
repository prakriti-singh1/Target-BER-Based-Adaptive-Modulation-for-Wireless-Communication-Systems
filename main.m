%% ========================================================================
%  Target-BER Based Adaptive Modulation for Wireless Communication Systems
%  Main driver script
%  ------------------------------------------------------------------------
%  Runs:
%   1. BER-vs-SNR simulation for BPSK / QPSK / 16-QAM over AWGN & Rayleigh
%   2. Target-BER adaptive modulation selection (10^-2, 10^-3, 10^-4)
%   3. Switching-SNR sensitivity study across target BER values
%   4. Throughput & spectral efficiency: fixed vs adaptive comparison
%   5. Saves all figures as PNG and a results table as CSV
%  ========================================================================

clear; clc; close all;
rng(42);   % fixed seed for reproducibility

outdir = 'results';
if ~exist(outdir, 'dir'); mkdir(outdir); end

%% ---- Simulation parameters ----
snr_range   = 0:1:20;      % Eb/N0 in dB
nbits       = 4e5;         % bits per SNR point (increase for smoother tails)
target_bers = [1e-2, 1e-3, 1e-4];
channels    = {'AWGN','Rayleigh'};

fprintf('=== Step 1: Running BER-vs-SNR sweep (this may take a moment) ===\n');
results = run_ber_sweep(snr_range, nbits);

%% ---- Step 1 output: BER vs SNR curves ----
for ci = 1:numel(channels)
    ch = channels{ci};
    figure('Visible','off');
    semilogy(snr_range, results.BER.BPSK.(ch),  '-o', 'LineWidth',1.5); hold on;
    semilogy(snr_range, results.BER.QPSK.(ch),  '-s', 'LineWidth',1.5);
    semilogy(snr_range, results.BER.('16QAM').(ch), '-^', 'LineWidth',1.5);
    grid on;
    xlabel('E_b/N_0 (dB)'); ylabel('Bit Error Rate');
    title(['BER vs SNR - ', ch, ' Channel']);
    legend('BPSK','QPSK','16-QAM','Location','southwest');
    ylim([1e-5 1]);
    saveas(gcf, fullfile(outdir, ['BER_vs_SNR_' ch '.png']));
end

%% ---- Step 2 & 3: Adaptive selection + switching-SNR sensitivity ----
fprintf('=== Step 2: Target-BER adaptive modulation selection ===\n');

switch_table = {}; % rows: channel, target_ber, BPSK->QPSK, QPSK->16QAM
row = 1;
adaptive_selected = struct();

for ci = 1:numel(channels)
    ch = channels{ci};
    for ti = 1:numel(target_bers)
        tb = target_bers(ti);
        [selected, sp] = adaptive_select(results, ch, tb);
        key = sprintf('t%d', ti);
        adaptive_selected.(ch).(key) = selected;

        switch_table(row,:) = {ch, tb, sp.BPSK_to_QPSK, sp.QPSK_to_16QAM};
        row = row + 1;
    end
end

% Display switching-SNR table
fprintf('\nSwitching-SNR sensitivity table:\n');
fprintf('%-10s %-12s %-16s %-16s\n','Channel','TargetBER','BPSK->QPSK(dB)','QPSK->16QAM(dB)');
for r = 1:size(switch_table,1)
    fprintf('%-10s %-12g %-16g %-16g\n', switch_table{r,1}, switch_table{r,2}, switch_table{r,3}, switch_table{r,4});
end

% Save switching table as CSV
fid = fopen(fullfile(outdir,'switching_snr_table.csv'), 'w');
fprintf(fid, 'Channel,TargetBER,BPSK_to_QPSK_dB,QPSK_to_16QAM_dB\n');
for r = 1:size(switch_table,1)
    fprintf(fid, '%s,%g,%g,%g\n', switch_table{r,1}, switch_table{r,2}, switch_table{r,3}, switch_table{r,4});
end
fclose(fid);

%% ---- Threshold sensitivity plot: switching SNR vs target BER ----
for ci = 1:numel(channels)
    ch = channels{ci};
    idxs = find(strcmp(switch_table(:,1), ch));
    tb_vals = cell2mat(switch_table(idxs,2));
    bq = cell2mat(switch_table(idxs,3));
    qm = cell2mat(switch_table(idxs,4));

    figure('Visible','off');
    semilogx(tb_vals, bq, '-o', 'LineWidth',1.5); hold on;
    semilogx(tb_vals, qm, '-s', 'LineWidth',1.5);
    grid on; set(gca,'XDir','reverse');
    xlabel('Target BER'); ylabel('Switching SNR (dB)');
    title(['Switching-SNR Sensitivity - ', ch]);
    legend('BPSK \rightarrow QPSK','QPSK \rightarrow 16-QAM','Location','best');
    saveas(gcf, fullfile(outdir, ['Switching_Sensitivity_' ch '.png']));
end

%% ---- Step 4: Throughput & spectral efficiency, fixed vs adaptive ----
fprintf('\n=== Step 3: Throughput / spectral efficiency comparison ===\n');

for ci = 1:numel(channels)
    ch = channels{ci};
    [thr_bpsk, ~]  = compute_throughput('BPSK', results, ch);
    [thr_qpsk, ~]  = compute_throughput('QPSK', results, ch);
    [thr_qam, ~]   = compute_throughput('16QAM', results, ch);

    figure('Visible','off');
    plot(snr_range, thr_bpsk, '-o', 'LineWidth',1.5); hold on;
    plot(snr_range, thr_qpsk, '-s', 'LineWidth',1.5);
    plot(snr_range, thr_qam,  '-^', 'LineWidth',1.5);

    styles = {'-d','-x','-p'};
    for ti = 1:numel(target_bers)
        key = sprintf('t%d', ti);
        selected = adaptive_selected.(ch).(key);
        [thr_adapt, ~] = compute_throughput(selected, results, ch);
        plot(snr_range, thr_adapt, styles{ti}, 'LineWidth',1.8);
    end

    grid on;
    xlabel('E_b/N_0 (dB)'); ylabel('Normalized Throughput (bits/symbol)');
    title(['Throughput: Fixed vs Adaptive - ', ch]);
    legend('Fixed BPSK','Fixed QPSK','Fixed 16-QAM', ...
           'Adaptive (target 10^{-2})','Adaptive (target 10^{-3})','Adaptive (target 10^{-4})', ...
           'Location','northwest');
    saveas(gcf, fullfile(outdir, ['Throughput_Comparison_' ch '.png']));
end

%% ---- Save raw BER results to CSV for the report/appendix ----
fid = fopen(fullfile(outdir,'ber_results.csv'), 'w');
fprintf(fid, 'SNR_dB,Scheme,Channel,BER\n');
for si = 1:numel(results.schemes)
    scheme = results.schemes{si};
    for ci = 1:numel(channels)
        ch = channels{ci};
        ber_vec = results.BER.(scheme).(ch);
        for k = 1:numel(snr_range)
            fprintf(fid, '%g,%s,%s,%g\n', snr_range(k), scheme, ch, ber_vec(k));
        end
    end
end
fclose(fid);

save(fullfile(outdir,'results.mat'), 'results', 'adaptive_selected', 'switch_table', 'snr_range', 'target_bers');

fprintf('\nAll done. Figures, CSVs and results.mat saved in the "results" folder.\n');
