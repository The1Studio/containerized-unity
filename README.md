# CONTAINERIZED UNITY JENKINS AGENT

## Enduser instruction

Pull and run container: `unitydocker/unity-agent:latest`

## Following this instruction to build and run an agent

### 1. BASE

**Build base image**

```sh
docker build -t unitydocker/unity-base .\base\
```

### 2. HUB

**Build hub image**

```sh
docker build -t unitydocker/unity-hub .\hub\
```

**Build args**

- **hubVersion**: Unity Hub version (default: 3.7.0 | optional)

### 3. EDITOR

**Build editor image**

```sh
docker build -t unitydocker/unity-editor --build-arg module="android webgl" --build-arg version=6000.0.48f1 --build-arg changeSet=170d2541580d .\editor\
```

**Build args**

- **version**: Unity Editor version (ex: 6000.0.29f1 | required), [Unity Archives](https://unity.com/releases/editor/archive)
- **changeSet**: Unity Editor changeSet (ex: 9fafe5c9db65 | required), [Go > Release > Changeset](https://unity.com/releases/editor/whats-new/6000.0.29)
- **module**: Unity Editor modules, seperate by space " " (ex: webgl, android, ... | required)

### 4. AGENT

**Build agent image**

```sh
docker build -t unitydocker/unity-jenkins-agent .\agent\
```

**Run agent container**

```sh
docker run --rm -it --env "JENKINS_HOST=???" --env "JENKINS_WORKDIR=???" --env "JENKINS_SECRET=???" --env "JENKINS_NAME=???" unitydocker/unity-jenkins-agent
```

## **Container env**

- **JENKINS_HOST**: Jenkins host (with no / at the end)
- **JENKINS_WORKDIR**: WorkDir path
- **JENKINS_SECRET**: Agent secret
- **JENKINS_NAME**: Name of agent
