function rx = awgn_channel(tx, snr_db, bps)
% AWGN_CHANNEL Adds complex AWGN calibrated to a given Eb/N0 (dB)
%   tx     : unit-average-symbol-energy transmitted symbols
%   snr_db : Eb/N0 in dB
%   bps    : bits per symbol for the active modulation

    EbN0 = 10^(snr_db/10);
    Es = mean(abs(tx).^2);         % ~1 for our normalized constellations
    N0 = Es / (bps * EbN0);
    noise_std = sqrt(N0/2);
    noise = noise_std * (randn(size(tx)) + 1i*randn(size(tx)));
    rx = tx + noise;
end
