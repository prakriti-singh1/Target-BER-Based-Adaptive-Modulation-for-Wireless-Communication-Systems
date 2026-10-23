function rx = rayleigh_channel(tx, snr_db, bps)
% RAYLEIGH_CHANNEL Flat Rayleigh fading + AWGN, with perfect-CSI equalization
%   tx     : unit-average-symbol-energy transmitted symbols
%   snr_db : Eb/N0 in dB
%   bps    : bits per symbol for the active modulation

    h = (randn(size(tx)) + 1i*randn(size(tx))) / sqrt(2);  % unit-power fading

    EbN0 = 10^(snr_db/10);
    Es = mean(abs(tx).^2);
    N0 = Es / (bps * EbN0);
    noise_std = sqrt(N0/2);
    noise = noise_std * (randn(size(tx)) + 1i*randn(size(tx)));

    faded = h .* tx + noise;
    rx = faded ./ h;   % coherent equalization assuming known channel
end
