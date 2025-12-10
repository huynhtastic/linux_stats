> Note: Although this README is made by hand, this app was mostly written by Gemini 3 Pro but will be changed by hand over time.

# gpu_usage_app

This is a simple app that monitors the GPU usage of an AMD GPU on Linux. This will be expanded to monitor other PC components (CPU, RAM, etc.) and documentation will change to reflect new additions.

## Motivation: Learning about Flutter performance
Linux surprisingly doesn't have a lot of choices for device monitoring. The best I could find was [Mission Center](https://missioncenter.io/) (which is amazing and gives a Windows Task Manager like experience).

This app will be (hopefully) a foray into measuring Flutter app performance and figuring out what can be done to squeeze performance out of Flutter apps. Being able to make this lightweight enough to be a viable option for Linux device monitoring is a plus, though my current hypothesis is that Flutter is probably too heavy for constant monitoring.

## Installation: Run it like a normal Flutter app

```bash
git clone https://github.com/richardtatum/gpu_usage_app.git
cd gpu_usage_app
flutter pub get
flutter run
```

## How it works

### How is device information retrieved?

The device information is retrieved by reading a file in the sysfs filesystem. This file is specific to AMD GPUs and may not be available on other GPUs or other OSes. The files are located in `/sys/class/drm/card2/device`.

## Considerations

### Viability: Flutter is probably too heavy for constant monitoring
Flutter apps are meant to be more robust and are shipped with a lot of tools to run the app. Thus, this app will have a heavier footprint than something written in like C++ or Rust (like Mission Center is). This makes it less viable to be an app that is open constantly for device monitoring such as [GPU-Z](https://www.techpowerup.com/gpuz/) on Windows or even [nvtop](https://github.com/Syllo/nvtop) (nvtop is an unfair comparison since it's a terminal-based program).

### Restrictions
- This app is currently only compatible with AMD GPUs on Linux
- The GPU usage is read from a file in the sysfs filesystem
    - This file is specific to AMD GPUs and may not be available on other GPUs or other OSes
- This is built on **Linux Mint** and has not been tested on other distros

## Known Supported Systems

### Linux
- Linux Mint