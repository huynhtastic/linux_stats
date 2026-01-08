> Note: Although this README is made by hand, this app was mostly written by Gemini 3 Pro but will be changed by hand over time.

# Linux Stats

This is a simple app that monitors the GPU usage of an AMD GPU on Linux. This will be expanded to monitor other PC components (CPU, RAM, etc.) and documentation will change to reflect new additions.

## Motivation: Learning about Flutter performance
Linux surprisingly doesn't have a lot of choices for device monitoring. The best I could find was [Mission Center](https://missioncenter.io/) (which is amazing and gives a Windows Task Manager like experience).

This app will be (hopefully) a foray into measuring Flutter app performance and figuring out what can be done to squeeze performance out of Flutter apps. Being able to make this lightweight enough to be a viable option for Linux device monitoring is a plus, though my current hypothesis is that Flutter is probably too heavy for constant monitoring.

## Installation: Run it like a normal Flutter app

```bash
git clone https://github.com/huynhtastic/linux_stats.git
cd linux_stats
flutter pub get
flutter run
```

## How is device information retrieved?

### CPU
CPU info is read from [`procfs`](https://en.wikipedia.org/wiki/Procfs).

Default locations are:
- `/proc/cpuinfo`: to grab the CPU name ([cpuinfo man page](https://www.man7.org/linux/man-pages/man5/proc_cpuinfo.5.html))
- `/proc/stat`: to calculate CPU load ([proc/stat man page](https://www.man7.org/linux/man-pages/man5/proc_stat.5.html))
- `/proc/uptime`: to calculate CPU load ([proc/uptime man page](https://www.man7.org/linux/man-pages/man5/proc_uptime.5.html))

#### CPU Utilization Calculation

> Fun fact: I learned time here is measured in "jiffies" (1/USER_HZ), where USER_HZ is defined as 100 in most Linux distributions, but can be different. [Refer to this stackoverflow answer for more](https://stackoverflow.com/a/10885808).

> Also fun fact: I learned that a jiffy is used in electronics as "[...the period of an alternating current power cycle...](https://en.wikipedia.org/wiki/Jiffy_(time)#:~:text=In%20electronics%2C%20a%20jiffy%20is%20the%20period%20of%20an%20alternating%20current%20power%20cycle%2C%5B5%5D%201/60%20or%201/50%20of%20a%20second%20in%20most%20mains%20power%20supplies.)", which would be 1/60 in the US, since AC power runs at 60hz. Helps to remember what a jiffie is.

But if you don't want to know all of that, we're going to be using **clock ticks** instead of jiffies.

To calculate CPU utilization, we are subtracting **the percentage of clock ticks that were __idle__ over a time interval** from the total number of logical processors.

In other words:

$$ \text{CPU Usage (\\%)} = \left(N_{log\\_procs} - \frac{\Delta \text{Idle}}{\Delta \text{Total}}\right) \times 100 $$


- $N_{log\\_procs}$: the number of logical processors
- $\Delta \text{Idle}$: the difference in idle time between two readings of `/proc/stat` and `/proc/uptime`
- $\Delta \text{Total}$: the difference in total time between two readings of `/proc/stat` and `/proc/uptime`

Most formulas will use 1 as a constant in place of $N_{log\\_procs}$, but that's only for a single logical processor.

In the code, since we're actually getting idle time from `/proc/stat` in units of ticks but uptime from `/proc/stat` in seconds, we'll need to convert ΔIdle to seconds by dividing it by CLK_TCK (100 on most Linux systems).

$$ \text{CPU Usage (\\%)} = \left(N_{log\\_procs} - \frac{\left(\text{idle ticks}_{\text{new}} - \text{idle ticks}_{\text{old}}\right) / USER\_HZ}{\text{uptime}_{\text{new}} - \text{uptime}_{\text{old}}}\right) \times 100 $$

[Rosetta Code](https://rosettacode.org/wiki/Linux_CPU_utilization) has the calculations in different languages.
### GPU
GPU info is read from a file in [`sysfs`](https://en.wikipedia.org/wiki/Sysfs). The default location is `/sys/class/drm/card2/device`.

The usage is just parsed from `/sys/class/drm/card2/device/gpu_busy_percent`.

This file may be specific to AMD GPUs and may not be available on other GPUs or other OSes.

### RAM
RAM info is read from [`procfs`](https://en.wikipedia.org/wiki/Procfs). The default location is `/proc/meminfo`.

We grab the following values:
- `MemTotal`: the total amount of RAM
- `MemAvailable`: the amount of available RAM

Then do the following:

$$ \text{RAM Usage (\\%)} = \left(\frac{\text{MemTotal} - \text{MemAvailable}}{\text{MemTotal}}\right) \times 100 $$

## Considerations

### Why not just grab info from linux commands like `lscpu` or `free`?
They could be easier, but running terminal commands spawn another OS-level process and introduce even more overhead with memory allocation and process management. Parsing files in `/proc` and `/sys` is much faster and more lightweight.

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