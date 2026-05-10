# DOCKER-DOOM
Welcome to DOCKER-DOOM, your gateway to experiencing the classic game DOOM right from your browser within a Docker container using noVNC.

![Banner](Resources/DOOM-BANNER.png)

## Overview
DOCKER-DOOM offers a hassle-free way to enjoy DOOM by encapsulating it within a Docker container, made accessible through noVNC. Whether you prefer building the container based on our Dockerfile or running it directly from a pre-built image.

## Usage
### Building from Dockerfile
1. **Clone the Repository**: Begin by cloning the DOCKER-DOOM repository to your local machine.
```bash
git clone https://github.com/b0nam/DOCKER-DOOM.git
```

2. **Build the Docker Image**: Navigate into the project directory and build the Docker image using the provided Dockerfile.

```bash
cd DOCKER-DOOM/Docker
docker build -t docker-doom .
```

3. **Run the Docker Container**: Once the image is built, start the Docker container, exposing the necessary ports.

```bash
docker run -p 8080:8080 b0nam/docker-doom
```

You can optionally set the `TIGER_VNC_PASSWORD` environment variable to customize the VNC password.

### Running from Docker Hub
Alternatively, you can run DOCKER-DOOM directly from a pre-built image available on Docker Hub. ([b0nam/docker-doom](https://hub.docker.com/r/b0nam/docker-doom))

```bash
docker run -d -p 8080:8080 b0nam/docker-doom
```

4. **Access DOOM**: Open your web browser and navigate to `http://localhost:8080` to start playing DOOM. Customize the container configuration or mount game files as needed to enhance your gaming experience. The default NoVNC password is `PASSWORD`.

## PREVIEW
![](Resources/PREVIEW.gif)