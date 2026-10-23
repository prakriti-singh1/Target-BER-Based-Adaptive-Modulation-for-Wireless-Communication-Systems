# Target-BER based adaptive modulation for wireless communication systems

A MATLAB simulation of adaptive modulation. At each average Eb/N0, the link picks the highest-order scheme (BPSK, QPSK or 16-QAM) whose bit error rate still meets a chosen target. The code then compares that adaptive link with fixed modulation over two channels: AWGN and flat Rayleigh fading.

Everything here is Monte Carlo. There are no closed-form BER formulas in the code. The BER curves are measured by pushing random bits through the modulator, the channel and the demodulator, and the adaptive logic reads its switching thresholds straight off those measured curves.

## What main.m does

1. Measures BER against Eb/N0 for BPSK, QPSK and 16-QAM over AWGN and Rayleigh, from 0 to 20 dB in 1 dB steps, with 400,000 bits per point.
2. For target BERs of 10<sup>-2</sup>, 10<sup>-3</sup> and 10<sup>-4</sup>, picks the highest-rate scheme that meets the target at every SNR point, and records the SNR where QPSK and 16-QAM first qualify.
3. Compares the throughput of the three fixed schemes against the three adaptive schemes.
4. Saves six figures, two CSV tables and a `results.mat` file to `results/`.

## Running it

You need MATLAB. The code uses core functions only (`randi`, `randn`, `semilogy`, `saveas` and so on), so no toolboxes are required.

```matlab
cd matlab_code
main
```

Run it from inside `matlab_code`. The output folder is the relative path `results`, so it is created in whatever your current folder is. `main.m` opens with `clear; clc; close all;`, so it wipes your workspace. Figures are created with `'Visible','off'`, which means no windows pop up, you just get the PNGs.

The random generator is seeded with `rng(42)`. Exact numbers may still shift between MATLAB versions.

To change the experiment, edit the parameter block near the top of `main.m`:

| Variable | Default | Meaning |
|---|---|---|
| `snr_range` | `0:1:20` | Eb/N0 values in dB |
| `nbits` | `4e5` | Bits simulated per SNR point |
| `target_bers` | `[1e-2, 1e-3, 1e-4]` | Target BERs for adaptive selection |

If you raise `nbits`, the low-BER tails get smoother, and runtime grows linearly with it.

You can also call the pieces on their own:

```matlab
ber = simulate_ber('16QAM', 'Rayleigh', 12, 1e5);       % one BER point

results = run_ber_sweep(0:2:20, 2e5);                    % full sweep
[selected, sp] = adaptive_select(results, 'AWGN', 1e-3); % scheme per SNR + switching SNRs
[thr, se] = compute_throughput(selected, results, 'AWGN');
```

## Files

| File | Role |
|---|---|
| `main.m` | Driver script. Runs the sweep, the adaptive selection and the throughput comparison, then saves everything. |
| `run_ber_sweep.m` | Loops over schemes, channels and SNR points and collects the BER into one struct. |
| `simulate_ber.m` | One Monte Carlo run for a single scheme, channel and SNR. |
| `modulate_signal.m` | Bits to unit-energy complex symbols (BPSK, QPSK, Gray-coded 16-QAM). |
| `demodulate_signal.m` | Hard-decision detection back to bits. |
| `awgn_channel.m` | Adds complex Gaussian noise scaled to a given Eb/N0. |
| `rayleigh_channel.m` | Flat Rayleigh fading plus noise, then equalization with a known channel. |
| `bits_per_symbol.m` | Returns 1, 2 or 4 for BPSK, QPSK or 16-QAM. |
| `adaptive_select.m` | Chooses a scheme for each SNR point and finds the switching SNRs. |
| `compute_throughput.m` | Throughput for a fixed scheme or for an adaptive selection. |
| `results/` | Output from a run of `main.m` with the default settings (see below). |

## How the simulation works

Modulation. BPSK maps bits to -1 and +1. QPSK maps bit pairs to (+/-1 +/- 1j) divided by sqrt(2). 16-QAM uses Gray coding on each axis (levels -3, -1, +1, +3) divided by sqrt(10). All three have unit average symbol energy, so they can share the same noise calculation.

Noise. The noise level is set from Eb/N0, not Es/N0: `N0 = Es / (bits_per_symbol * Eb/N0)`, with complex Gaussian noise of variance N0/2 per dimension. Using Eb/N0 puts the three schemes on the same per-bit footing. Note that the variables called `snr` in the code, and the x-axes in the plots, are all Eb/N0 in dB.

Rayleigh fading. Each symbol gets its own unit-power complex Gaussian gain `h`, noise is added, and the receiver divides by `h`. That assumes perfect channel knowledge and fading that is independent from symbol to symbol, so there is no channel memory and no estimation error.

Detection. Hard decisions per axis. The 16-QAM demapper inverts the same Gray map the modulator uses.

Zero-error floor. If a point sees no errors at all, its BER is set to `0.5 / nbits` (1.25e-6 at the default `nbits`). That keeps the log plots and the threshold search from breaking. Treat anything at that value as "no errors observed", not as a measured BER.

Adaptive selection. For each SNR point, `adaptive_select` goes through BPSK, QPSK and 16-QAM in order of rate and keeps the last one whose measured BER is at or below the target. If none qualifies, it falls back to BPSK. The switching SNR for QPSK (or 16-QAM) is the first SNR in the sweep where that scheme meets the target, and NaN if it never does.

Throughput. `bits_per_symbol * (1 - BER)`. The symbol rate is normalized to one symbol per second per hertz, so spectral efficiency comes out numerically identical to throughput.

## Results

These come from the files in `results/`, produced with the default settings.

### BER against Eb/N0

| AWGN | Rayleigh |
|---|---|
| ![BER vs SNR, AWGN](results/BER_vs_SNR_AWGN.png) | ![BER vs SNR, Rayleigh](results/BER_vs_SNR_Rayleigh.png) |

BPSK and QPSK sit on top of each other in both channels. That is expected: with Gray mapping and Eb/N0 normalization, QPSK is two independent BPSK streams. The small gaps you can see, for example around 7 to 9 dB in AWGN, are sampling noise. 16-QAM needs roughly 3 to 4 dB more Eb/N0 than QPSK in AWGN for the same BER.

### Switching SNRs

From `results/switching_snr_table.csv`, on a 1 dB grid:

| Channel | Target BER | BPSK to QPSK (dB) | QPSK to 16-QAM (dB) |
|---|---|---|---|
| AWGN | 10<sup>-2</sup> | 5 | 8 |
| AWGN | 10<sup>-3</sup> | 7 | 11 |
| AWGN | 10<sup>-4</sup> | 9 | 13 |
| Rayleigh | 10<sup>-2</sup> | 14 | 17 |
| Rayleigh | 10<sup>-3</sup> | never (NaN) | never (NaN) |
| Rayleigh | 10<sup>-4</sup> | never (NaN) | never (NaN) |

| AWGN | Rayleigh |
|---|---|
| ![Switching sensitivity, AWGN](results/Switching_Sensitivity_AWGN.png) | ![Switching sensitivity, Rayleigh](results/Switching_Sensitivity_Rayleigh.png) |

In AWGN, each tenfold tightening of the target pushes the switching points up by about 2 to 3 dB. Rayleigh is far more expensive. Even at 20 dB, BPSK only reaches a BER of about 2.5e-3, so no scheme can meet 10<sup>-3</sup> or 10<sup>-4</sup> inside the 0 to 20 dB range. The usual high-SNR approximation for BPSK in Rayleigh fading, BER of about 1/(4 Eb/N0), puts those targets near 24 dB and 34 dB. This is also why the Rayleigh sensitivity plot shows a single point per curve: the NaN entries are simply not drawn.

### Throughput, fixed against adaptive

| AWGN | Rayleigh |
|---|---|
| ![Throughput comparison, AWGN](results/Throughput_Comparison_AWGN.png) | ![Throughput comparison, Rayleigh](results/Throughput_Comparison_Rayleigh.png) |

In AWGN the adaptive curves step from 1 to 2 to 4 bits per symbol at the switching SNRs in the table above, and the tighter the target, the later the steps. In Rayleigh, the 10<sup>-3</sup> and 10<sup>-4</sup> adaptive curves never leave BPSK and lie on top of the fixed BPSK line.

### Output files

| File | Contents |
|---|---|
| `ber_results.csv` | Raw BER data: `SNR_dB,Scheme,Channel,BER`, one row per point (126 rows). |
| `switching_snr_table.csv` | The switching-SNR table above. |
| `results.mat` | `results`, `adaptive_selected`, `switch_table`, `snr_range`, `target_bers`. |
| `BER_vs_SNR_*.png` | BER curves, one per channel. |
| `Switching_Sensitivity_*.png` | Switching SNR against target BER. |
| `Throughput_Comparison_*.png` | Fixed and adaptive throughput. |

## Limitations and reading notes

- Fixed 16-QAM is never beaten on the throughput plots. The metric is `bits_per_symbol * (1 - BER)`, which charges almost nothing for errors, so it rewards the highest rate everywhere. The adaptive curves climb onto the 16-QAM curve once 16-QAM meets the target and stay below it before that. What adaptive modulation buys you is the BER guarantee, and these plots don't show it. A metric that penalizes errors harder, such as packet error rate, would show the trade-off more fairly.
- The guarantee only holds above the first switching point. Below it the code falls back to BPSK even when BPSK misses the target, because there is no "do not transmit" state. For example, in AWGN with a 10<sup>-2</sup> target, BPSK is still at about 1.2e-2 at 4 dB.
- Selection is based on average Eb/N0 and on the measured BER curves used as a lookup table. There is no channel estimator, no feedback delay, and no adaptation to the instantaneous fade in the Rayleigh case.
- No channel coding, no packets, no pulse shaping.
- At 4e5 bits per point, a BER of 10<sup>-4</sup> is only about 40 errors, so the 10<sup>-4</sup> thresholds carry visible sampling error, and anything near 1e-5 or below is not reliable. Raise `nbits` if you need cleaner tails.

## Folder layout

```
matlab_code/
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
└── results/
    ├── ber_results.csv
    ├── switching_snr_table.csv
    ├── results.mat
    ├── BER_vs_SNR_AWGN.png
    ├── BER_vs_SNR_Rayleigh.png
    ├── Switching_Sensitivity_AWGN.png
    ├── Switching_Sensitivity_Rayleigh.png
    ├── Throughput_Comparison_AWGN.png
    └── Throughput_Comparison_Rayleigh.png
```
