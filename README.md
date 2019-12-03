## Overview

- This Jenkins Pipeline executes a Canary Deployment using Docker containers.
- A Git webhook initiates the running of the Pipeline
- Consul and Registrator work together to discover and register docker Services
- On Successful completion of tests, a docker image is created and pushed to dockerhub
- The Canary Deployment is achieved with Nginx providing weighted load balancing, where weight values are stored using the Consul KV store.
- When a KV pair is updated (Consul HTTP API) consul template dynamically updates the nginx configuration
- Docker compose override is used to deploy the new Services

### Setup

1. A jenkins server can be setup using the adjacent repo Jenkins-Server

2. Install Docker Pipeline Plugin. Setup Dockerhub credentials. See http://mattmyers.me/portfolio-project2/ for in depth details

3. A git webhook with integration with Jenkins is detailed here: http://mattmyers.me/portfolio-project2/

4. Jenkins workers can be added using the adjacent repo Jenkins-Worker which creates docker agents built on a server setup using vagrant


#### License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
