function [selected, switch_points] = adaptive_select(results, channel, target_ber)
% ADAPTIVE_SELECT Chooses the highest-rate modulation meeting a target BER
%   results    : struct from run_ber_sweep
%   channel    : 'AWGN' | 'Rayleigh'
%   target_ber : e.g. 1e-2, 1e-3, 1e-4
%
%   selected      : cell array, one scheme name per SNR point
%   switch_points : struct with fields
%       .BPSK_to_QPSK   : SNR (dB) at which QPSK first becomes valid (NaN if never)
%       .QPSK_to_16QAM  : SNR (dB) at which 16-QAM first becomes valid (NaN if never)

    schemes = results.schemes;           % ordered low-rate -> high-rate
    snr = results.snr;
    n = numel(snr);
    selected = cell(1, n);

    for k = 1:n
        best = schemes{1};   % fallback: most robust scheme (BPSK)
        for si = 1:numel(schemes)
            scheme = schemes{si};
            ber_k = results.BER.(scheme).(channel)(k);
            if ber_k <= target_ber
                best = scheme;   % keep upgrading while target is still met
            end
        end
        selected{k} = best;
    end

    % --- Determine switching SNRs (first SNR where a higher scheme qualifies) ---
    qpsk_ber = results.BER.QPSK.(channel);
    qam_ber  = results.BER.('16QAM').(channel);

    idx_q = find(qpsk_ber <= target_ber, 1, 'first');
    idx_m = find(qam_ber  <= target_ber, 1, 'first');

    switch_points.BPSK_to_QPSK  = ternary_nan(idx_q, snr);
    switch_points.QPSK_to_16QAM = ternary_nan(idx_m, snr);
end

function val = ternary_nan(idx, snr)
    if isempty(idx)
        val = NaN;
    else
        val = snr(idx);
    end
end
