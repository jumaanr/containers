
# [Fix]: Flannel pod (CNI) and CoreDNS daemon sets are failing

The issue you're encountering stems from the `br_netfilter` kernel module not being loaded, which is necessary for the `/proc/sys/net/bridge/bridge-nf-call-iptables` and `/proc/sys/net/bridge/bridge-nf-call-ip6tables` entries to exist. Without these entries, `sysctl` cannot apply the settings, resulting in the error messages you're seeing.


### **Explanation of the Problem**

- **Error Message**: 
  ```
  sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-iptables: No such file or directory
  sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-ip6tables: No such file or directory
  ```
- **Cause**: These errors occur because the `br_netfilter` module is not loaded into the kernel. This module is responsible for enabling packet filtering on bridges, and without it, the system doesn't create the necessary entries in `/proc/sys/net/bridge/`.

References for the fix:

[Fixing ‘/proc/sys/net/bridge/bridge-nf-call-iptables does not exist’ Error When Executing the ‘kubeadm init’ Command](https://k21academy.com/docker-kubernetes/fixing-proc-sys-net-bridge-bridge-nf-call-iptables-does-not-exist-error-when-executing-the-kubeadm-init-command/)

[Fix sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-iptables](https://gist.github.com/iamcryptoki/ed6925ce95f047673e7709f23e0b9939)


### **Formulated Solution**

Here's a step-by-step guide combining the best practices from both suggestions:

#### **1. Load the `br_netfilter` Module Immediately**

```bash
sudo modprobe br_netfilter
```

#### **2. Ensure `br_netfilter` Loads on Boot**

Create a configuration file to load the module at startup:

```bash
echo "br_netfilter" | sudo tee /etc/modules-load.d/br_netfilter.conf
```

#### **3. Configure Sysctl Settings**

Create a dedicated sysctl configuration file:

```bash
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
# Enable packet forwarding for IPv4
net.ipv4.ip_forward = 1

# Enable bridge network filtering
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
```

#### **4. Reload Sysctl Settings**

Apply all sysctl settings:

```bash
sudo sysctl --system
```

**Note**: Using `sysctl --system` reads all the configuration files under `/etc/sysctl.d/` and `/etc/sysctl.conf`, applying the settings.

#### **5. Verify the Settings**

Check that the parameters are set correctly:

```bash
sysctl net.bridge.bridge-nf-call-iptables
sysctl net.bridge.bridge-nf-call-ip6tables
sysctl net.ipv4.ip_forward
```

You should see:

```
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
```

#### **6. Confirm Module is Loaded on Reboot**

Reboot your system and verify that the `br_netfilter` module is loaded:

```bash
sudo reboot
```

After reboot:

```bash
lsmod | grep br_netfilter
```

You should see an entry for `br_netfilter`, confirming it's loaded.

### **Summary**

- **Essential Steps**:
  - **Load `br_netfilter` Module**: Both immediately and ensure it's loaded on boot.
  - **Configure Sysctl Parameters**: Set necessary networking parameters for Kubernetes and bridge networking.
  - **Apply Settings**: Use `sysctl --system` to apply configurations.
- **First Solution Advantages**:
  - More comprehensive.
  - Ensures settings persist across reboots.
  - Places configurations in dedicated files for clarity and ease of management.

![image](https://github.com/user-attachments/assets/388f97f5-772f-4fbf-aed2-1dedbe2465c0)



By ensuring the `br_netfilter` module is loaded and the sysctl parameters are correctly set and persistent, you resolve the issue and prepare your system for Kubernetes networking with Flannel or other CNI plugins.
