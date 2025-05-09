# Containerized Unity Editor

This repository provides Docker images and scripts to build and run Unity projects in a containerized environment. The build process is structured in three main stages: base, hub, and editor.

## Quick Start

### 1. BASE

Build the base image:

```sh
docker build -t unitydocker/unity-base ./base/
```

### 2. HUB

Build the hub image:

```sh
docker build -t unitydocker/unity-hub ./hub/
```

**Build args:**
- `hubVersion`: Unity Hub version (default: 3.7.0 | optional)

### 3. EDITOR

Build the editor image:

```sh
docker build -t unitydocker/unity-editor --build-arg module="android webgl" --build-arg version=6000.0.48f1 --build-arg changeSet=170d2541580d ./editor/
```

**Build args:**
- `version`: Unity Editor version (e.g., 6000.0.29f1 | required), [Unity Archives](https://unity.com/releases/editor/archive)
- `changeSet`: Unity Editor changeSet (e.g., 9fafe5c9db65 | required), [Release Changeset](https://unity.com/releases/editor/whats-new/6000.0.29)
- `module`: Unity Editor modules, separated by space (e.g., webgl android ios | required)

---

You can now use the built `unitydocker/unity-editor` image to run Unity builds in your CI/CD pipeline or locally by mounting your project and output directories.

## Example Usage

```sh
docker run --rm -it \
  -v /path/to/your/project:/project \
  -v /path/to/output:/output \
  unitydocker/unity-editor
```

## Environment Variables

- `UNITY_PROJECT_PATH`: Path to Unity project (default: /project)
- `UNITY_OUTPUT_PATH`: Path for build output (default: /output)
- `UNITY_BUILD_TARGET`: Build target (e.g., Android, WebGL)
- `UNITY_PLATFORMS`: Platforms to include (e.g., android, webgl)
- `UNITY_SCRIPTING_BACKEND`: Scripting backend (e.g., il2cpp, mono)
- `UNITY_SCRIPTING_DEFINE_SYMBOLS`: Scripting define symbols
- `UNITY_ADDRESSABLES_BUILD_PATH`: Addressables build path
- `UNITY_ADDRESSABLES_LOAD_PATH`: Addressables load path

---

For Jenkins agent or advanced usage, see the `agent` directory and adapt as needed for your CI/CD setup.
