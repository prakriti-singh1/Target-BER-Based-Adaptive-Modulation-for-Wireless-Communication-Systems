function bps = bits_per_symbol(scheme)
% BITS_PER_SYMBOL Returns number of bits carried per symbol for a scheme
    switch scheme
        case 'BPSK'
            bps = 1;
        case 'QPSK'
            bps = 2;
        case '16QAM'
            bps = 4;
        otherwise
            error('Unknown modulation scheme: %s', scheme);
    end
end
