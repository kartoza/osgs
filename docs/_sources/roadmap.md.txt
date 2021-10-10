# OSGS Roadmap

Like most Open Source Software, the Open Source GIS Stack is an ongoing work in progress, however the project is anticipating some architectural changes which are likely to be breaking in nature.

This document outlines the various ongoing activities and critical changes expected to be introduced.

## Components

The current roadmap and update strategy consists of various components, some of which are being developed in parallel.

The core components currently under development include:

- Platform and application extension
- Blueprint framework development
- Ongoing documentation updates
- Deployment guidelines and strategies
- Contribution guidelines
- Administration Interface
- Cloud-native architecture migration

### Considerations

The current *main* branch is under heavy development and should be considered unstable.

Use the *deployment* branch for production deployments that avoid breaking changes.

Once the architecture changes, it is possible that a *compose-deployment* branch may be maintained for legacy environments, but a more sophisticared release management strategy is likely to be implemented.

### Architectural Changes

The current architecture and deployment strategy rely heavily on make targets and a relatively complex docker compose configuration to provide a reasonably simple interface for running a "setup wizard" and declarative infrastructure management.

The intention going forward is to develop a cloud-native infrastructure design using kubernetes with an integrated local deployment strategy for single-server deploys. It is expected that this migration will introduce breaking changes.

In-between the migration to k8s there may possibly be additional functionality introduced as a part of a python-based commandline management solution which leverages docker-compose rather than kubernetes.

### Blueprints

The concept for blueprints is to provide default configurations and end to end solutions for application specific purposes or to provide a scaffold for building solutions tailored to a particular domain vertical. These blueprints will be designed to be may include various boilerplate projects, sample data, and other components intended to lower the barrier for entry into location intelligence for various applications.

Currently, the intention is to identify key components critical to solution development along with their locations or endpoints, and develop a structured process or expose an API for merging or introducing additional components which are made available from a remote git repository, along with various hooks or bootstrapping operations.

### Administration

The osgs-admin UI is an ongoing effort to provide a "click to run" experience for stack deployment that includes a front-end management console. The application is designed as a unified configuration management and monitoring solution which is currently focussed on managing the stack via docker-compose.

The admin ui is under development at https://github.com/zacharlie/osgs-admin and once it reaches functional beta will likely be migrated to the kartoza github platform. A stripped-down version of the admin-ui application will likely be made available for providing end-users a method of managing docker-compose environments for application specific purposes, whilst the core application will be developed to support the cloud native architecture.
