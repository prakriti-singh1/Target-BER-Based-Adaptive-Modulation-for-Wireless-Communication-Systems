function results = run_ber_sweep(snr_range, nbits)
% RUN_BER_SWEEP Simulates BER vs SNR for BPSK/QPSK/16-QAM over AWGN & Rayleigh
%   snr_range : vector of Eb/N0 values in dB, e.g. 0:1:20
%   nbits     : bits simulated per point (higher = smoother low-BER curves)
%
%   results is a struct:
%     results.schemes  = {'BPSK','QPSK','16QAM'}
%     results.channels = {'AWGN','Rayleigh'}
%     results.snr      = snr_range
%     results.BER.(scheme).(channel) = vector of BER, same length as snr_range

    schemes  = {'BPSK','QPSK','16QAM'};
    channels = {'AWGN','Rayleigh'};

    results.schemes  = schemes;
    results.channels = channels;
    results.snr      = snr_range;

    for si = 1:numel(schemes)
        scheme = schemes{si};
        for ci = 1:numel(channels)
            channel = channels{ci};
            ber_vec = zeros(1, numel(snr_range));
            for k = 1:numel(snr_range)
                ber_vec(k) = simulate_ber(scheme, channel, snr_range(k), nbits);
                % Avoid exact-zero BER (log-plot / threshold-search friendliness)
                if ber_vec(k) == 0
                    ber_vec(k) = 0.5 / nbits;
                end
            end
            results.BER.(scheme).(channel) = ber_vec;
            fprintf('Completed sweep: %-6s over %-8s\n', scheme, channel);
        end
    end
end
