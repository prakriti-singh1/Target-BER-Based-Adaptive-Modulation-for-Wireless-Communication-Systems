function ber = simulate_ber(scheme, channel_type, snr_db, nbits)
% SIMULATE_BER Monte-Carlo BER for one (scheme, channel, SNR) combination
%   scheme       : 'BPSK' | 'QPSK' | '16QAM'
%   channel_type : 'AWGN' | 'Rayleigh'
%   snr_db       : Eb/N0 in dB
%   nbits        : number of bits to simulate (rounded to a multiple of bps)

    bps = bits_per_symbol(scheme);
    nbits = nbits - mod(nbits, bps);
    if nbits < bps
        nbits = bps;
    end

    bits = randi([0 1], 1, nbits);
    tx = modulate_signal(bits, scheme);

    switch channel_type
        case 'AWGN'
            rx = awgn_channel(tx, snr_db, bps);
        case 'Rayleigh'
            rx = rayleigh_channel(tx, snr_db, bps);
        otherwise
            error('Unknown channel type: %s', channel_type);
    end

    rx_bits = demodulate_signal(rx, scheme);
    errors = sum(bits ~= rx_bits);
    ber = errors / nbits;
end
