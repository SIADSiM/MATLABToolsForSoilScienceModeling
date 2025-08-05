# MATLAB Tools For Soil Science Modeling

This repository provides a collection of MATLAB functions for simulating and analyzing key soil processes. It integrates models for soil physics, hydrology, biogeochemistry, and erosion, with a focus on research reproducibility, adherence to peer-reviewed references, and consistent use of SI units.

## ⚓ Repository Structure

The repository is organized into the following directories:

- `/physics`: Functions related to soil physical properties and processes (e.g., temperature, water retention).
- `/hydrology`: Functions for modeling the water cycle (e.g., evapotranspiration, infiltration, water balance).
- `/biogeochemistry`: Functions for nutrient and carbon cycling (e.g., decomposition, mineralization, respiration).
- `/erosion`: Functions for estimating soil erosion (e.g., USLE model).
- `/tests`: Unit tests for all functions, built using the MATLAB Unit Test Framework.
- `/examples`: Example scripts that demonstrate how to use the functions and generate visualizations.

## 👷‍♂️ Installation and Usage

1.  **Clone or download the repository** to your local machine.
2.  **Open MATLAB**.
3.  **Add the function directories to your MATLAB path.** The example scripts in the `/examples` folder do this automatically. To do it manually for your own scripts, use the `addpath` command:
    ```matlab
    addpath('path/to/repository/physics');
    addpath('path/to/repository/hydrology');
    addpath('path/to/repository/biogeochemistry');
    addpath('path/to/repository/erosion');
    ```
4.  **Run the unit tests (optional)** to verify that all functions are working correctly in your environment. Execute the `runAllTests.m` script from the repository root:
    ```matlab
    runAllTests
    ```
5.  **Explore the example scripts** in the `/examples` directory to see how each function can be used and to generate plots of key processes.

## 🧩 Function Reference

Below are usage examples for each of the core functions in this repository.

---

### `physics/bulkDensityCalc.m`

Calculates bulk density from particle density and porosity.

**Usage:**
```matlab
pd = 2650; % Particle density in kg/m^3
p = 0.45;  % Porosity as a fraction
bd = bulkDensityCalc(pd, p)
% Expected output: 1457.5
```

---

### `physics/soilWaterRetentionVG.m`

Calculates soil water content using the van Genuchten model.

**Usage:**
```matlab
% Parameters for a typical loam soil
h = -10;      % Pressure head in meters
thetaR = 0.078;
thetaS = 0.43;
alpha = 3.6;  % 1/m
n = 1.56;
theta_h = soilWaterRetentionVG(h, thetaR, thetaS, alpha, n)
% Expected output: ~0.108
```

---

### `physics/soilTemperatureProfile.m`

Simulates soil temperature distribution over time.

**Usage:**
```matlab
% Setup a 2m profile with 10 layers (dz=0.2m)
dz = 0.2;
z = (dz:dz:2)';
T_initial = 15 * ones(size(z)); % Initial uniform temp
T_surface = 25; % Hot surface
T_bottom = 14;  % Cool bottom
K = 5e-7;       % Thermal diffusivity for a typical soil
dt = 3600;      % 1-hour time step
n_steps = 24;   % Simulate for 24 hours
T_final = soilTemperatureProfile(T_initial, T_surface, T_bottom, K, dt, dz, n_steps);
% plot(T_final, -z);
```

---

### `hydrology/penmanMonteithET.m`

Calculates reference evapotranspiration (ETo) using the FAO-56 Penman-Monteith equation.

**Usage:**
```matlab
% Example data for a location
T_mean = 20;    % °C
u2 = 2;         % m/s
R_n = 15;       % MJ/m^2/day
G = 0;          % MJ/m^2/day
RH_mean = 60;   % %
elevation = 100;% m
ETo = penmanMonteithET(T_mean, u2, R_n, G, RH_mean, elevation)
% Expected output: ~4.08 mm/day
```

---

### `hydrology/greenAmptInfiltration.m`

Solves for cumulative infiltration using the Green-Ampt model.

**Usage:**
```matlab
Ks = 1.8e-5;    % Saturated hydraulic conductivity in m/s (silty clay loam)
psi = 0.16;     % Wetting front suction head in m
delta_theta = 0.2; % Change in moisture content (0.45 - 0.25)
t = 0:300:3600; % Time vector for 1 hour, every 5 mins
F = greenAmptInfiltration(Ks, psi, delta_theta, t);
% plot(t/60, F*1000);
```

---

### `hydrology/soilMoistureBalance.m`

Implements a daily soil water balance.

**Usage:**
```matlab
% 30 days of data
days = 30;
precip = zeros(days, 1); precip([5, 15, 25]) = [20, 10, 30]; % Rain on days 5, 15, 25
ETo = 3.5 * ones(days, 1); % Constant ETo
FC = 0.34;      % Field capacity for a loam
WP = 0.18;      % Wilting point for a loam
rootZoneDepth = 600; % 600 mm root depth
initialMoisture = (FC - WP) * rootZoneDepth * 0.5 + WP * rootZoneDepth; % Start at 50% available water
[SM, Q] = soilMoistureBalance(precip, ETo, FC, WP, rootZoneDepth, initialMoisture);
% figure; subplot(2,1,1); plot(1:days, SM); subplot(2,1,2); bar(1:days, Q);
```

---

### `biogeochemistry/soilRespirationQ10.m`

Computes soil respiration rates with the Q10 formulation.

**Usage:**
```matlab
R_ref = 1.5;  % umol CO2/m^2/s at 10°C
T_ref = 10;   % °C
Q10 = 2.0;
T = 20;       % Calculate rate at 20°C
R = soilRespirationQ10(R_ref, Q10, T, T_ref)
% Expected output: 3.0
```

---

### `biogeochemistry/soilCarbonDecomposition.m`

Simulates first-order soil carbon decomposition.

**Usage:**
```matlab
C_initial = 10;     % kg C/m^2
k_max = 0.0005;     % per day (for a slow pool)
temp_scalar = 0.8;  % Favorable temperature
moisture_scalar = 0.6; % Sub-optimal moisture
dt = 30;            % 30-day time step
[C_loss, C_end] = soilCarbonDecomposition(C_initial, k_max, temp_scalar, moisture_scalar, dt);
```

---

### `biogeochemistry/nitrogenMineralization.m`

Simulates net N mineralization based on C decomposition.

**Usage:**
```matlab
C_initial = 10;     % kg C/m^2
k_max = 0.0005;     % per day
temp_scalar = 0.8;
moisture_scalar = 0.6;
dt = 30;            % days
CN_ratio = 12;      % C:N ratio of 12:1
N_min = nitrogenMineralization(C_initial, k_max, temp_scalar, moisture_scalar, dt, CN_ratio);
```

---

### `erosion/soilErosionUSLE.m`

Calculates soil loss using the Universal Soil Loss Equation (USLE).

**Usage:**
```matlab
R = 170;  % Erosivity for a sample location
K = 0.3;  % Erodibility for a silt loam
LS = 0.5; % Topography of a gentle, short slope
C = 0.1;  % Cover factor for conservation tillage
P = 1.0;  % No support practices
A = soilErosionUSLE(R, K, LS, C, P)
% Expected output: 2.55 t/ha/yr
```

## 🧩 Model Architecture (UML)

A UML diagram illustrating the functional dependencies between the modules is available in the `uml_diagram.md` file. It can be rendered using any Markdown viewer with Mermaid support (like the default view on GitHub).

## 📜 License

This project is licensed under a custom non-commercial license.

* ✅ **Free for personal, academic, and research use.**
* ❌ **Commercial use is strictly prohibited without a separate license.**

For commercial licensing inquiries, please contact me at ** s i a d s i m @ g m a i l . c o m  **.

## 📑 References

Allen, R.G., Pereira, L.S., Raes, D., & Smith, M. (1998). *Crop Evapotranspiration — Guidelines for computing crop water requirements*. FAO Irrigation and Drainage Paper 56.

Green, W.H. & Ampt, G.A. (1911). Studies on soil physics. *The Journal of Agricultural Science, 4*(1), 1-24.

Hillel, D. (1998). *Environmental Soil Physics*. Academic Press.

Lloyd, J. & Taylor, J.A. (1994). On the temperature dependence of soil respiration. *Functional Ecology, 8*(3), 315-323.

Parton, W.J., Schimel, D.S., Cole, C.V., & Ojima, D.S. (1987). Analysis of factors controlling soil organic matter levels in Great Plains grasslands. *Soil Science Society of America Journal, 51*(5), 1173-1179.

van Genuchten, M.T. (1980). A closed-form equation for predicting the hydraulic conductivity of unsaturated soils. *Soil Science Society of America Journal, 44*(5), 892-898.

Wischmeier, W.H., & Smith, D.D. (1978). *Predicting rainfall erosion losses*. USDA Agriculture Handbook 537.
