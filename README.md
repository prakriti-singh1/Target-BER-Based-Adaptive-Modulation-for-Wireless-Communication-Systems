# Target-BER based adaptive modulation for wireless communication systems

A MATLAB simulation of adaptive modulation. At each average Eb/N0, the link picks the highest-order scheme (BPSK, QPSK or 16-QAM) whose bit error rate still meets a chosen target. The code then compares that against fixed-modulation throughput and BER curves.

Everything here is Monte Carlo. There are no closed-form BER formulas in the code. The BER curves are measured by pushing random bits through the modulator, the channel and the demodulator, and then taking the observed error fraction.

## What main.m does

1. Measures BER against Eb/N0 for BPSK, QPSK and 16-QAM over AWGN and Rayleigh, from 0 to 20 dB in 1 dB steps, with 400,000 bits per point.
2. For target BERs of 10^-2, 10^-3 and 10^-4, picks the highest-rate scheme that meets the target at every SNR point, and records the SNR where QPSK and 16-QAM first become viable.
3. Compares the throughput of the three fixed schemes against the three adaptive schemes.
4. Saves plots, CSV tables and a results.mat file into the `Results/` folder.

## Running it

You need MATLAB. The code uses core functions only (`randi`, `randn`, `semilogy`, `saveas` and so on), so no toolboxes are required.

```matlab
main
```

The output folder is the relative path `Results`, so it is created in whatever your current folder is. `main.m` opens with `clear; clc; close all;`, so it wipes previous figures and workspace state first.

## Results

### BER against Eb/N0

| AWGN | Rayleigh |
|---|---|
| ![BER vs SNR, AWGN](Results/BER_vs_SNR_AWGN.svg) | ![BER vs SNR, Rayleigh](Results/BER_vs_SNR_Rayleigh.svg) |

### Switching SNRs

| AWGN | Rayleigh |
|---|---|
| ![Switching sensitivity, AWGN](Results/Switching_SNR_Sensitivity_AWGN.svg) | ![Switching sensitivity, Rayleigh](Results/Switching_SNR_Sensitivity_Rayleigh.svg) |

### Throughput, fixed against adaptive

| AWGN | Rayleigh |
|---|---|
| ![Throughput comparison, AWGN](Results/Throughput_Fixed_vs_Adaptive_AWGN.svg) | ![Throughput comparison, Rayleigh](Results/Throughput_Fixed_vs_Adaptive_Rayleigh.svg) |

## Folder layout

```text
.
├── main.m
├── run_ber_sweep.m
├── simulate_ber.m
├── modulate_signal.m
├── demodulate_signal.m
├── awgn_channel.m
├── rayleigh_channel.m
├── bits_per_symbol.m
├── adaptive_select.m
├── compute_throughput.m
└── Results/
    ├── BER_vs_SNR_AWGN.svg
    ├── BER_vs_SNR_Rayleigh.svg
    ├── Switching_SNR_Sensitivity_AWGN.svg
    ├── Switching_SNR_Sensitivity_Rayleigh.svg
    ├── Throughput_Fixed_vs_Adaptive_AWGN.svg
    ├── Throughput_Fixed_vs_Adaptive_Rayleigh.svg
    ├── ber_results.csv
    ├── switching_snr_table.csv
    └── results.mat
```
