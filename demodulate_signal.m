function bits = demodulate_signal(rx, scheme)
% DEMODULATE_SIGNAL Minimum-distance detection back to bits
%   rx     : received complex symbol vector
%   scheme : 'BPSK' | 'QPSK' | '16QAM'

    switch scheme
        case 'BPSK'
            bits = double(real(rx) > 0);

        case 'QPSK'
            I = double(real(rx) > 0);
            Q = double(imag(rx) > 0);
            bits = zeros(1, 2*length(rx));
            bits(1:2:end) = I;
            bits(2:2:end) = Q;

        case '16QAM'
            scale = sqrt(10);
            I = real(rx) * scale;
            Q = imag(rx) * scale;
            bI = demapLevel2(I);
            bQ = demapLevel2(Q);
            n = length(rx);
            bits = zeros(1, 4*n);
            bits(1:4:end) = bI(:,1);
            bits(2:4:end) = bI(:,2);
            bits(3:4:end) = bQ(:,1);
            bits(4:4:end) = bQ(:,2);

        otherwise
            error('Unknown modulation scheme: %s', scheme);
    end
end

function b = demapLevel2(x)
% Inverse Gray map: nearest of {-3,-1,1,3} -> 2 bits
    x = x(:);
    n = length(x);
    b = zeros(n,2);
    b(x < -2, :)          = repmat([0 0], sum(x < -2), 1);
    b(x >= -2 & x < 0, :) = repmat([0 1], sum(x >= -2 & x < 0), 1);
    b(x >= 0 & x < 2, :)  = repmat([1 1], sum(x >= 0 & x < 2), 1);
    b(x >= 2, :)          = repmat([1 0], sum(x >= 2), 1);
end
