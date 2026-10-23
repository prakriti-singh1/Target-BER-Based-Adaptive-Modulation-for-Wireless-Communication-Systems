function [thr, se] = compute_throughput(scheme_or_selected, results, channel)
% COMPUTE_THROUGHPUT Normalized throughput & spectral efficiency vs SNR
%   scheme_or_selected : either a fixed scheme name ('BPSK'/'QPSK'/'16QAM')
%                         or a 1xN cell array of per-SNR selected schemes
%                         (as returned by adaptive_select)
%   results : struct from run_ber_sweep
%   channel : 'AWGN' | 'Rayleigh'
%
%   thr = normalized throughput      = bits/symbol * (1 - BER)
%   se  = spectral efficiency (bits/s/Hz), numerically identical here since
%         symbol rate is normalized to 1 symbol/s/Hz (Nyquist signalling)

    n = numel(results.snr);
    thr = zeros(1, n);

    if ischar(scheme_or_selected)
        % Fixed scheme
        scheme = scheme_or_selected;
        bps = bits_per_symbol(scheme);
        ber = results.BER.(scheme).(channel);
        thr = bps * (1 - ber);
    else
        % Adaptive: per-SNR-point scheme selection
        selected = scheme_or_selected;
        for k = 1:n
            scheme = selected{k};
            bps = bits_per_symbol(scheme);
            ber = results.BER.(scheme).(channel)(k);
            thr(k) = bps * (1 - ber);
        end
    end

    se = thr;  % normalized bandwidth => spectral efficiency = throughput
end
