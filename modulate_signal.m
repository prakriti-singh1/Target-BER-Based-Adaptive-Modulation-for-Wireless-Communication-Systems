function symbols = modulate_signal(bits, scheme)
% MODULATE_SIGNAL Maps a bit stream to unit-average-energy complex symbols
%   bits   : row vector of 0/1 values
%   scheme : 'BPSK' | 'QPSK' | '16QAM'

    switch scheme
        case 'BPSK'
            % 0 -> -1, 1 -> +1
            symbols = 2*double(bits) - 1;

        case 'QPSK'
            b = reshape(bits, 2, []).';
            I = 2*double(b(:,1)) - 1;
            Q = 2*double(b(:,2)) - 1;
            symbols = (I + 1i*Q) / sqrt(2);
            symbols = symbols.';

        case '16QAM'
            b = reshape(bits, 4, []).';
            I = grayMap2(b(:,1), b(:,2));
            Q = grayMap2(b(:,3), b(:,4));
            symbols = (I + 1i*Q) / sqrt(10);
            symbols = symbols.';

        otherwise
            error('Unknown modulation scheme: %s', scheme);
    end
end

function levels = grayMap2(b1, b2)
% Gray-coded mapping of 2 bits to PAM levels {-3,-1,1,3}
%   00 -> -3 , 01 -> -1 , 11 -> +1 , 10 -> +3
    levels = zeros(size(b1));
    levels(b1==0 & b2==0) = -3;
    levels(b1==0 & b2==1) = -1;
    levels(b1==1 & b2==1) =  1;
    levels(b1==1 & b2==0) =  3;
end
