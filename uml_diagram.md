# UML Diagram

This file contains the UML diagram for the project, showing the functional dependencies between the different modules and functions. The diagram is written in Mermaid syntax and can be viewed in any compatible Markdown renderer (e.g., GitHub, GitLab, or a local editor with a Mermaid plugin).

```mermaid
classDiagram
    direction LR

    package "physics" {
        class bulkDensityCalc {
            +bulkDensityCalc(particleDensity, porosity)
        }
        class soilWaterRetentionVG {
            +soilWaterRetentionVG(h, thetaR, thetaS, alpha, n)
        }
        class soilTemperatureProfile {
            +soilTemperatureProfile(T_initial, T_surface, T_bottom, K, dt, dz, n_steps)
        }
    }

    package "hydrology" {
        class penmanMonteithET {
            +penmanMonteithET(T_mean, u2, R_n, G, RH_mean, elevation)
        }
        class greenAmptInfiltration {
            +greenAmptInfiltration(Ks, psi, delta_theta, t_vector)
        }
        class soilMoistureBalance {
            +soilMoistureBalance(precip, ETo, FC, WP, rootZoneDepth, initialMoisture)
        }
    }

    package "biogeochemistry" {
        class soilRespirationQ10 {
            +soilRespirationQ10(R_ref, Q10, T, T_ref)
        }
        class soilCarbonDecomposition {
            +soilCarbonDecomposition(C_initial, k_max, temp_scalar, moisture_scalar, dt)
        }
        class nitrogenMineralization {
            +nitrogenMineralization(C_initial, k_max, temp_scalar, moisture_scalar, dt, CN_ratio)
        }
    }

    package "erosion" {
        class soilErosionUSLE {
            +soilErosionUSLE(R, K, LS, C, P)
        }
    }

    ' Dependencies
    soilMoistureBalance ..> penmanMonteithET : "uses ETo from"

    ' Conceptual dependencies (important for understanding the model)
    soilCarbonDecomposition ..> soilTemperatureProfile : "uses temperature from"
    soilCarbonDecomposition ..> soilMoistureBalance : "uses moisture from"
    nitrogenMineralization ..> soilCarbonDecomposition : "is coupled to"
    soilRespirationQ10 ..> soilTemperatureProfile : "uses temperature from"

```
