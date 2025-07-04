

## 📚 Container Basics - Deep Dive

### Overview

Understanding the fundamental building blocks of containerization technology including chroot, namespaces, cgroups, and container runtime components.

### Core Concepts

#### 1. chroot (Change Root)

Isolates filesystem by changing the apparent root directory for a process.

```bash
# Create isolated environment
sudo mkdir -p /tmp/jail/{bin,lib,lib64}
sudo cp /bin/bash /bin/ls /tmp/jail/bin/
sudo cp /lib/x86_64-linux-gnu/{libc.so.6,ld-linux-x86-64.so.2} /tmp/jail/lib/

# Enter chroot jail
sudo chroot /tmp/jail /bin/bash
ls /  # Only shows jail directory contents
```

> 🛡️ Use Case: Base isolation mechanism for containers, security sandboxing.

#### 2. Linux Namespaces

Provides process-level isolation for various system resources.

* **PID Namespace**

```bash
sudo unshare --pid --fork --mount-proc /bin/bash
ps aux  # Shows only processes in this namespace
echo $$  # Shows PID 1 in namespace
```

* **Network Namespace**

```bash
sudo ip netns add container-net
sudo ip netns exec container-net ip link set lo up
sudo ip netns exec container-net ip addr show
```

* **Mount Namespace**

```bash
sudo unshare --mount /bin/bash
mount --bind /tmp /mnt
ls /mnt  # Shows /tmp contents without affecting host
```

#### 3. Control Groups (cgroups)

Limits and monitors resource usage of processes.

* **Memory Limiting**

```bash
sudo cgcreate -g memory:demo-container
echo 512M | sudo tee /sys/fs/cgroup/memory/demo-container/memory.limit_in_bytes
sudo cgexec -g memory:demo-container stress --vm 1 --vm-bytes 600M
```

* **CPU Limiting**

```bash
echo 50000 | sudo tee /sys/fs/cgroup/cpu/demo-container/cpu.cfs_quota_us
echo 100000 | sudo tee /sys/fs/cgroup/cpu/demo-container/cpu.cfs_period_us
```

### Container Runtime Architecture

```
┌─────────────────────────────────────┐
│           Application               │
├─────────────────────────────────────┤
│        Container Engine             │
│         (Docker)                    │
├─────────────────────────────────────┤
│       Container Runtime             │
│        (containerd)                 │
├─────────────────────────────────────┤
│        OCI Runtime                  │
│         (runc)                      │
├─────────────────────────────────────┤
│         Linux Kernel                │
│    (namespaces, cgroups, etc.)     │
└─────────────────────────────────────┘
```

### Container Engine vs Runtime

* **Container Engine (Docker):**

  * High-level interface
  * Image management
  * Network and volume handling

* **Container Runtime (containerd):**

  * Low-level operations
  * Image pulling/storage
  * Lifecycle management

* **OCI Runtime (runc):**

  * Implements OCI spec
  * Direct interaction with Linux kernel

### Practical Examples

#### Manual Container Creation

```bash
mkdir -p /tmp/container/{bin,etc,lib,lib64,proc,sys,tmp,var,dev}
cp /bin/{bash,ls,cat,ps} /tmp/container/bin/
cp -r /lib/x86_64-linux-gnu /tmp/container/lib/
echo "root:x:0:0:root:/:/bin/bash" > /tmp/container/etc/passwd
echo "nameserver 8.8.8.8" > /tmp/container/etc/resolv.conf

sudo unshare --pid --net --ipc --mount --fork \
  chroot /tmp/container /bin/bash
```

### Container vs VM Comparison

| Feature       | Container     | Virtual Machine |
| ------------- | ------------- | --------------- |
| Isolation     | Process-level | Hardware-level  |
| Overhead      | Minimal       | High            |
| Startup Time  | Seconds       | Minutes         |
| Image Size    | MB            | GB              |
| Host OS Share | Yes           | No              |

### Common Issues & Solutions

#### Issue 1: Permission Denied in chroot

```bash
# Error: bash: cannot set terminal process group
# Solution:
sudo mknod /tmp/jail/dev/null c 1 3
sudo mknod /tmp/jail/dev/zero c 1 5
sudo chmod 666 /tmp/jail/dev/{null,zero}
```

#### Issue 2: Namespace Cleanup

```bash
sudo lsns
sudo ip netns delete container-net
sudo cgdelete memory:demo-container
```

#### Issue 3: Resource Limits Not Working

```bash
mount | grep cgroup
# For cgroups v2:
echo "+memory +cpu" | sudo tee /sys/fs/cgroup/cgroup.subtree_control
```
## 🍎 BONUS: Colima Setup on macOS (M1/M2)
## Colima is a fast, lightweight container runtime for macOS (especially M1/M2 chips).

### 🔧 Install Colima (Homebrew)
```bash
brew install colima
```
### ▶️ Start Colima with containerd

colima start --runtime containerd --arch aarch64 --cpu 4 --memory 4
Use colima status to verify. If using Docker CLI, switch context:

```bash
docker context use colima
```

Colima provides a native Linux VM with containerd, ideal for Kubernetes and Docker-based workloads.


### ✅ Key Takeaways

* Containers ≠ VMs: Containers share the host kernel
* Layered Isolation: Multiple technologies work together
* Resource Efficiency: Minimal overhead compared to VMs
* Security Model: Process-level isolation with shared kernel
* Portability: Consistent environment across systems

### 📌 Next Steps

* Understand how Docker implements these concepts
* Learn about container orchestration
* Explore security implications of shared kernel

---


---

