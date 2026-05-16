# EKS Network IP Exhaustion Simulation

This repository contains the infrastructure definitions and automation logic used to simulate, isolate, and detect network IP address exhaustion within an Amazon EKS cluster.

## Architecture Overview

The infrastructure drops an EKS control plane and a managed node group into a custom VPC configuration with intentionally constrained private subnets. By placing the worker nodes within small subnet boundaries and leveraging standard node allocation, the environment simulates an immediate depletion of available network interfaces when scaling workloads. This demonstrates a failure domain where pod deployment is blocked by network limits entirely independent of compute or memory availability.

## Repository Structure

* **terraform/**: Contains the declarative infrastructure configuration files for the VPC architecture, subnets, route tables, security boundaries, and the EKS cluster.
* **agent.py**: A standalone Python agent that interfaces with the Kubernetes cluster event stream to filter scheduling failures, identify network capacity limits, and trigger programmatic remediation loops.

## Simulation Steps

1. Provision the network topology and EKS control plane using the configuration files within the terraform directory.
2. Authenticate the local environment to target the active control plane endpoint.
3. Deploy and scale the simulation workload to exhaust the available interface address pool.
4. Execute the monitoring agent to intercept the cluster failure signatures.
