# EKS Network IP Exhaustion Simulation

This repository contains the infrastructure definitions and automation logic used to simulate, isolate, and detect network IP address exhaustion within an Amazon EKS cluster.

```mermaid
graph TD

    subgraph AWS["AWS Region: eu-west-1"]

        EKS["EKS Control Plane"]

        subgraph VPC["VPC Custom Network"]

            NAT["NAT Gateway"]

            subgraph Subnets["Constrained Private Subnets"]
                SubA["Private Subnet A<br/>10.0.10.0/27"]
                SubB["Private Subnet B<br/>10.0.10.32/27"]
            end

            subgraph Nodes["EKS Managed Node Group"]
                Node1["t3.micro Node<br/>Limit: 4 IPs"]
                Node2["t3.micro Node<br/>Limit: 4 IPs"]
            end
        end

        subgraph Workload["Nginx Deployment: 25 Replicas"]
                Running["2 Pods Running"]
                Pending["23 Pods Pending"]
        end
    end

    NAT --> SubA
    NAT --> SubB

    SubA --> Node1
    SubB --> Node2

    EKS <--> Node1
    EKS <--> Node2

    Node1 --> Running
    Node2 --> Running

    Node1 -.-> Pending
    Node2 -.-> Pending

    classDef error fill:#ffebe9,stroke:#ff8182,stroke-width:2px,color:#24292f;
    class Pending error;

    classDef success fill:#dafbe1,stroke:#4ac26b,stroke-width:2px,color:#24292f;
    class Running success;

    classDef aws fill:#ff9900,stroke:#232f3e,stroke-width:2px,color:#ffffff;
    class EKS aws;
```

---

## Architecture Overview

The infrastructure deploys an EKS control plane and managed node group into a custom VPC with intentionally constrained private subnets.

By placing worker nodes inside small subnet ranges and using standard ENI allocation behavior, the environment quickly exhausts available pod IP addresses during workload scaling. This simulates a real-world network exhaustion scenario where pods fail scheduling despite compute and memory remaining available.

---

## Repository Structure

- **terraform/**  
  Contains the infrastructure configuration for:
  - VPC architecture
  - private subnets
  - route tables
  - security groups
  - EKS cluster resources

- **agent.py**  
  A standalone Python monitoring agent that:
  - watches Kubernetes scheduling events
  - detects IP exhaustion failures
  - identifies network capacity limits
  - triggers remediation workflows

---

## Simulation Steps

1. Provision the VPC and EKS infrastructure using the Terraform configuration.
2. Authenticate locally against the active EKS cluster endpoint.
3. Deploy and scale the workload to intentionally exhaust subnet IP capacity.
4. Run the monitoring agent to detect and analyze cluster scheduling failures.