# Description
Reference base architecture for business that wants to adopt the cloud.

# Motivation
This was a project aimed to document and capture the best practices, techniques and knowledge into a single repository. A business that does not use the cloud might not know what to start with. 

The reference architecture is to optimize performance, security, cost and agility while also reducing refactoring in the later stage.

# Architecture
## __Compute__

### __Containers vs VMs.__
- Why Containers is preferred
  - Achieve dev prod parity
  - Spin up similar environment across all devs
  - Better tools for orchestration if scaling up in the future e.g. K8s
  - Less administration


## __Network__

### __Hub and Spoke__
- Isolate workloads
- Centralised connectivity for shared services such as firewall, bastion, jumpbox, VPN etc.
- Cost savings for shared services.

### __Private Endpoint__
- Prevent public access needlessly

## __Database__
### __NoSQL vs SQL__
- Why SQL is preferred
  - NoSQL increase developer velocity initially due to not enforcing any schema 
    but introduces tech debt later on.
  - NoSQL benefits such as sharding is available on SQL. E.g. Citus


## __Observability__

### __Azure Monitor__
- Setup Observability since day 1. Alternatively, might want to consider CNCF tools such as OpenTelemetry, Prometheus and Grafana


## __CI/CD__



# Philosophies
### Defer Commitment (Agile)

### Buy or use managed services if possible



# Project Status
__Ongoing__. 
This project is meant to grow along with my experiences, knowledge and skill sets. Things might change greatly in the future depending on what makes sense.

# TODO
- [ ] Create Service Principal
- [ ] Static Sites
- [ ] ACR Container Apps
- [ ] Log Analytics 
- [ ] APIM


## Extras
- [ ] CI pipeline to push frontend
- [ ] CI pipeline to push backend



# Links
[dev prod parity](https://12factor.net/dev-prod-parity)
