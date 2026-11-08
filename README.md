# Active Power Filter with Predictive Current Control

A MATLAB/Simulink simulation of a three-phase shunt active power filter for compensating nonlinear-load current harmonics. This project develops a predictive current controller from direct finite-control-set switching to iterative voltage optimization with PWM, supported by source-voltage estimation, synchronous-reference-frame reference generation, and DC-link voltage regulation.

## Master's thesis research

Developed by **Syed Adeel Abdullah** for the MS in Electrical Engineering (Controls) thesis, *Harmonic Suppression using a Model Predictive Controlled Active Power Filter*, at **NUST, Pakistan Navy Engineering College**, supervised by **Capt. Dr. Sajjad Haider Zaidi**, July 2021.

The research investigates whether a gradient-descent-based voltage optimizer can reduce the computational burden of conventional finite-control-set model predictive control (FCS-MPC) while retaining effective harmonic compensation. A separate PWM stage addresses the variable switching frequency associated with direct switching-state selection.

The thesis contribution is the development and simulation evaluation of this predictive-control approach for a shunt active filter: adapting the optimization stage, integrating it with voltage estimation and modulation, and comparing harmonic performance, transient response, computation time, and parameter sensitivity against FCS-MPC. SRF reference generation, PLL synchronization, and DC-link regulation support the complete system.

## Thesis-reported simulation results

Chapter 4 evaluates a three-phase diode-bridge nonlinear load, with a 20 microsecond sampling interval and a load change at 0.3 seconds. The reported parameters are:

| Parameter | Value |
| --- | --- |
| Source voltage | 380 V |
| Supply frequency | 50 Hz |
| DC-link voltage | 1300 V |
| DC-link capacitance | 1000 microfarads |
| Filter resistance | 1 ohm |
| Filter inductance | 1 mH |

| Evaluation | Reported finding | Thesis location |
| --- | --- | --- |
| Current harmonic compensation | Approximately 28% uncompensated THD; section 4.4 reports 3.2% for the proposed controller versus 3.7% for FCS-MPC | Sections 4.2-4.4, pp. 19-23 |
| Transient response | Slightly slower response for the proposed controller, with smaller tracking error in the presented comparison | Section 4.4, pp. 22-23 |
| Optimizer computation time | Approximately 3.5x lower execution time at learning rate 800, with approximately two iterations per sampling instant | Section 4.4.1 and Figure 4.11, pp. 23-24 |
| Parameter uncertainty | Reported THD remains below 5% when resistance and inductance are varied individually from -30% to +30% of nominal values | Section 4.5 and Figure 4.12, p. 25 |

These are results reported in the thesis's MATLAB/Simulink study, rather than hardware measurements or independently reproduced results from this checkout. The compensated spectrum displays 3.28% THD, while the conclusion summarizes approximately 27.5% to 3.5%; the table above retains the explicit section 4.4 controller comparison. The uncertainty study concerns the tested parameter variations, rather than a general stability guarantee.

## Controller development and contributions

The main development work is in the control architecture, embedded MATLAB controller, reference-generation path, and optimizer comparison scripts. Simulink and Simscape Electrical supply the electrical components, transforms, and modulation blocks.

### From switching-state search to voltage optimization

The earlier controller predicts the next current for each of eight inverter voltage vectors and directly selects the switching state with the lowest tracking cost. The updated controller iteratively calculates a continuous alpha-beta voltage command, converts it into three phase commands using the inverse Clarke transform, and feeds a three-phase, two-level PWM generator.

| Aspect | Earlier controller | Updated controller |
| --- | --- | --- |
| Decision variable | One of eight discrete voltage vectors | Iteratively updated alpha-beta voltage |
| Optimization | Enumerate candidates and select minimum cost | Update voltage using current-prediction error |
| Output | Inverter switching states | Three phase voltage commands |
| Gate generation | Direct state selection | Separate PWM block |
| Previous-step memory | Selected vector index and measured current | Optimized voltage and measured current |

This redesign separates predictive voltage calculation from gate-pulse generation. The live controller is embedded in the MATLAB Function block inside the **Shunt active harmonic filter** subsystem of `models/power_active_filter_mpc.slx`.

Standalone implementations in [`work/sgd_opt.m`](work/sgd_opt.m) and [`work/fcs_opt.m`](work/fcs_opt.m) make the two approaches accessible for comparison. Despite its filename, `sgd_opt.m` performs deterministic gradient updates rather than stochastic sampling.

### Source-voltage estimation from controller history

The inner predictive controller takes reference and measured currents without a separate source-voltage input. It estimates source voltage using the previous voltage command and consecutive current samples:

```text
Vs_est(k) = (L/Ts - R)*i(k-1) + v(k-1) - (L/Ts)*i(k)
```

The current prediction is:

```text
K = Ts/L
i_pred(k+1) = K*v - K*Vs_est(k) + (1 - R*K)*i(k)
```

Complex numbers represent alpha-beta components. Persistent variables store the previous current and optimized voltage between controller calls. The wider simulation retains voltage measurements and a PLL; the estimator removes the direct voltage input from the inner predictive controller.

### Iterative predictive voltage calculation

At each call, the embedded controller initializes the voltage command to zero and applies:

```text
error = i_ref - i_pred
v = v - alpha*(-2*K*error)
```

The implementation uses `alpha = 800` and stops when the change in its coded squared-error expression no longer exceeds a threshold. The embedded threshold is `1e-2`; the standalone optimizer uses `1e-5`.

The iterative implementation evaluates `(i_ref - i_pred)^2` on complex values. The FCS comparison script evaluates `real(error)^2 + imag(error)^2`. These cost expressions differ, so their reported costs are not interchangeable. The iterative implementation has no explicit iteration cap or voltage constraint.

### SRF reference generation and DC-link regulation

The reference-generation design evolved from peak-based detection to a synchronous-reference-frame (SRF) approach. The model includes a three-phase PLL, coordinate transforms, filtering, and a PID path for capacitor/DC-link voltage regulation. These stages generate the reference feeding the predictive current controller.

### Comparison and analysis tools

- [`work/data_test.m`](work/data_test.m) replays logged source-voltage, reference-current, and measured-current samples through both optimizers. It stores voltage outputs, costs, and iterative counts for inspection.
- [`work/profile_tester.m`](work/profile_tester.m) repeatedly calls both optimizers for profiling. Each loop contains ten million calls; reduce the count for an initial check.
- The simulation includes current/error measurements, THD measurement blocks, and spectrum analysis for examining tracking and harmonic compensation.

The thesis presents comparative results from these investigations. The repository supplies logged-data and profiling workloads; it does not yet provide a single script that regenerates all thesis figures and metrics. Reproducing the comparisons requires matched plant parameters, sampling intervals, references, and timing conditions.

## Simulation workflow

```text
Load and filter measurements
          |
          v
PLL / SRF reference generation + DC-link regulation
          |
          v
Reference current + measured filter current
          |
          v
Source-voltage estimate -> predictive voltage optimization
          |
          v
Inverse Clarke transform -> three-phase PWM -> filter inverter
```

The electrical model includes a three-phase source, rectifier loads, transformers, and the shunt filter. Its saved simulation stop time is 0.5 seconds.

## Running the project

The model was saved with **MATLAB R2019a**. Its blocks reference **Simulink**, **Simscape Electrical**, including Specialized Power Systems, and **DSP System Toolbox**.

From the repository root in MATLAB:

```matlab
project = openProject('Activefiltermpc.prj');
open_system('power_active_filter_mpc');
sim('power_active_filter_mpc');
```

Opening the project runs `models/parameters.m`, which loads the saved workspace from `work/matlab.mat` and initializes the controller parameters. The startup folder is `work`, and `models` is on the project path. Closing the project runs `models/shutdown.m`, which clears the workspace.

The initialization sets `Ts = 20e-6`, obtains `L` from `AF.activefilter.Laf`, and sets `R = 1`. The standalone optimizers instead use `Ts = 25e-6` and `L = 1e-3`; align these values when comparing their behavior with the simulation.

To replay the supplied samples from the project startup folder:

```matlab
data_test
```

Inspect `v` for voltage outputs, `g` for the respective coded costs, and `c` for the iterative optimizer's iteration counts.

## Repository map

| Path | Contents |
| --- | --- |
| `Activefiltermpc.prj` | MATLAB project entry point |
| `models/power_active_filter_mpc.slx` | Electrical simulation, embedded controller, reference generation, and PWM |
| `models/parameters.m` | Workspace loading and controller initialization |
| `models/shutdown.m` | Project shutdown cleanup |
| `work/sgd_opt.m` | Standalone iterative voltage optimizer |
| `work/fcs_opt.m` | Eight-vector FCS comparison implementation |
| `work/inv_clarke.m` | Alpha-beta-zero to three-phase conversion |
| `work/data_test.m` | Logged-data optimizer comparison |
| `work/profile_tester.m` | Repeated-call profiling workload |
| `work/matlab.mat` | Saved model workspace and plant parameters |
| `work/test_data_log.mat` | Logged samples for the comparison script |
| `resources/project/` | MATLAB project configuration |

## Implementation and reproduction notes

- **Objective function:** The thesis writes a squared complex tracking error in equation 3.0.7, matching the iterative code. It does not explicitly distinguish that expression from squared magnitude. Review the objective and stopping condition before extending the optimizer.
- **Equation consistency:** Thesis equations 3.0.5, 3.0.8, and 3.0.9 contain sign or indexing discrepancies relative to the stated plant equation or implemented update. The equations shown in this README describe the implemented predictor and estimator.
- **Timing comparison:** Section 4.4.1 reports the learning-rate study and acknowledges possible oscillation or divergence at excessive step sizes. Reproducing its speed comparison also requires the original timing environment and measurement procedure; it is not a worst-case hardware execution guarantee.
- **Evaluation scope:** The thesis includes load-change and parameter-uncertainty studies. Hardware validation, measurement-noise sensitivity, explicit voltage constraints, and comparison with a closed-form unconstrained voltage solution are not established by the supplied evaluation.

## Development milestones

The commit history records the evolution of the controller:

| Commit | Change |
| --- | --- |
| `2cb2fd1` | Source-voltage estimator added |
| `d407110`, `ca72ff4` | Transition to SRF reference generation |
| `f04bc3e` | Tuned PID and capacitor-voltage control |
| `c955f9a` | Controller restructuring, described in the commit as delay compensation |
| `fa3bad6` | Iterative optimizer, PWM integration, and comparison scripts |
| `dc689ce` | Spectrum analyzer added |
| `128813e` | Filter-response tuning |

The current controller uses a one-step prediction and previous-step memory, without an explicit separate two-step delay-compensated prediction horizon. The remote branch named `FCS-MPC` also contains an iterative controller; revision `c955f9a` provides the historical direct-switching implementation used for the comparison above.
