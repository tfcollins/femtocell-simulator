function [requiredPRBs, unroundedPRB] = determineNeededPRBs( bits, modulation, coderate )


switch modulation
    case 'QPSK'
        bitsPerSymbol = 2;
    case 'QAM16'
        bitsPerSymbol = 4;
    case 'QAM64'
        bitsPerSymbol = 6;
end

subcarriersPerPRB = 12;
OFDMSymbolsPerPRB = 7;

bitsPerResourceElement = bitsPerSymbol*coderate;

ResourceElementsPerPRB = subcarriersPerPRB * OFDMSymbolsPerPRB;

bitsPRB = ResourceElementsPerPRB * bitsPerResourceElement;

requiredPRBs = ceil(bits/bitsPRB);

unroundedPRB = (bits/bitsPRB);


end