# EKS Network IP Exhaustion Simulation

This repository contains the infrastructure definitions and automation logic used to simulate, isolate, and detect network IP address exhaustion within an Amazon EKS cluster.

```mermaid
graph TB
    subgraph AWS [AWS Region: eu-west-1]
        direction TB
        EKS((EKS Control<br/>Plane))
        
        subgraph VPC [VPC Custom Network]
            direction TB
            NAT[NAT Gateway]
            
            subgraph Subnets [Constrained Private Subnets]
                direction LR
                SubA[Private Subnet A<br/>10.0.10.0/27]
                SubB[Private Subnet B<br/>10.0.10.32/27]
            end
            
            subgraph Nodes [EKS Managed Node Group]
                direction LR
                Node1[t3.micro Node<br/>Limit: 4 IPs]
                Node2[t3.micro Node<br/>Limit: 4 IPs]
            end
        end
    end

    %% Network Routing
    NAT --> Subnets
    SubA --- Node1
    SubB --- Node2
    EKS <==> Nodes

    %% Workload State
    subgraph Workload [Nginx Deployment: 25 Replicas]
        direction LR
        Running[2 Pods<br/>Running]
        Pending[23 Pods<br/>Pending]
    end

    Nodes ---> Running
    Nodes -.-x Pending

    %% Styling
    classDef error fill:#ffebe9,stroke:#ff8182,stroke-width:2px,color:#24292f;
    class Pending error;
    classDef success fill:#dafbe1,stroke:#4ac26b,stroke-width:2px,color:#24292f;
    class Running success;
    classDef aws fill:#ff9900,stroke:#232f3e,stroke-width:2px,color:#fff;
    class EKS aws;

```## Architecture Overview

The infrastructure drops an EKS control plane and a managed node group into a custom VPC configuration with intentionally constrained private subnets. By placing the worker nodes within small subnet boundaries and leveraging standard node allocation, the environment simulates an immediate depletion of available network interfaces when scaling workloads. This demonstrates a failure domain where pod deployment is blocked by network limits entirely independent of compute or memory availability.

## Repository Structure

* **terraform/**: Contains the declarative infrastructure configuration files for the VPC architecture, subnets, route tables, security boundaries, and the EKS cluster.
* **agent.py**: A standalone Python agent that interfaces with the Kubernetes cluster event stream to filter scheduling failures, identify network capacity limits, and trigger programmatic remediation loops.

## Simulation Steps

1. Provision the network topology and EKS control plane using the configuration files within the terraform directory.
2. Authenticate the local environment to target the active control plane endpoint.
3. Deploy and scale the simulation workload to exhaust the available interface address pool.
4. Execute the monitoring agent to intercept the cluster failure signatures.
