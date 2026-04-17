# Known‑Good Pangolin Host Baseline

**Purpose:**  
Define the exact, verified configuration of a secure and stable Pangolin front‑end host after rebuild. This baseline is intended to prevent container‑based compromise, minimize operational complexity, and support rapid recovery.

**Scope:**  
Pangolin edge host running Traefik, Gerbil (WireGuard), and Dockhand/Hawser for management.

***

## 1. Host & Network

### Operating System

*   Fresh OS install (no reused volumes or snapshots)
*   Same public IP retained (for rDNS)
*   All host access audited post‑rebuild

### Management Access

*   **Primary:** Tailscale
*   **SSH:** Enabled temporarily; may be restricted to Tailscale only
*   No public management APIs exposed

***

## 2. Firewall (UFW)

**Policy**

*   Default: `deny incoming`
*   Default: `allow outgoing`
*   No container‑aware rules
*   No ufw‑docker or similar helpers

**Allowed Ingress**

| Port  | Protocol | Purpose                                           |
| ----- | -------- | ------------------------------------------------- |
| 22    | TCP      | SSH (optional; remove after Tailscale validation) |
| 80    | TCP      | HTTP (Traefik)                                    |
| 443   | TCP      | HTTPS (Traefik)                                   |
| 51820 | UDP      | WireGuard (Gerbil)                                |
| 21820 | UDP      | Pangolin/Gerbil control                           |

**Notes**

*   Docker NAT handles forwarding internally
*   No `routed` or `forward` rules required

***

## 3. Docker Configuration (Hardened)

### Docker Engine Settings

`/etc/docker/daemon.json`:

```json
{
  "iptables": true,
  "userland-proxy": false,
  "live-restore": true,
  "no-new-privileges": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

### Security Guarantees

*   No Docker TCP API (`2375` / `2376`)
*   Docker socket only via Unix socket
*   Socket permissions: `root:docker` `660`
*   No world‑writable socket
*   No privileged containers (beyond Pangolin requirements)
*   No mounting of `/` or host filesystem into containers

### Operational Discipline

*   Images pulled fresh after rebuild
*   No reuse of pre‑incident images or volumes
*   All containers audited for mounts and privileges

***

## 4. Pangolin Stack

### Source of Truth

*   Pangolin config restored from:
    *   GitHub repository (pre‑incident state)
    *   Pangolin backup archive generated pre‑incident

### Runtime Validation

*   Traefik routing functional
*   Gerbil WireGuard tunnels established
*   Pangolin API responding
*   All managed resources reachable
*   No repeated handshake or routing errors

***

## 5. Dockhand / Hawser Agent

### Execution Model

*   Hawser runs as **systemd service (binary)** on host
*   No containerized management agents
*   Management traffic over **Tailscale only**

### Hawser systemd Highlights

*   Runs as:
    *   `User=root`
    *   `Group=docker`
*   Systemd sandboxing enabled:
    *   `ProtectSystem=strict`
    *   `ProtectHome=true`
*   Explicit write access only to:
    *   `/var/run/docker.sock`
    *   `/opt/stacks`

### Docker Access Model

*   Local Unix socket only
*   No network‑exposed Docker API
*   Group‑based access restores functionality without weakening security

***

## 6. Tailscale

*   Installed early in rebuild
*   Used as primary management plane
*   Dockhand ↔ Hawser connectivity over Tailscale IP / hostname
*   Public hostname preserved for clarity and logging; routing via Tailscale preferred

***

## 7. Anti‑Patterns (Explicitly Avoided)

*   ❌ ufw‑docker or container firewall manipulation
*   ❌ CrowdSec firewall bouncers on host
*   ❌ Firewalld
*   ❌ Privileged containers or host root mounts
*   ❌ Docker TCP API exposure
*   ❌ World‑writable Docker socket
*   ❌ Reusing compromised volumes or images

***

## 8. Validation Checklist (Quick)

*   `ufw status verbose` → only expected ports open
*   `ss -ltnp` → no Docker API listeners
*   `ls -l /var/run/docker.sock` → `root:docker 660`
*   `docker ps` → only expected Pangolin containers
*   Pangolin UI and all routes reachable externally
*   Dockhand shows host healthy and manageable

***

## 9. Baseline Statement

> This host reflects a **known‑good, post‑incident Pangolin frontend baseline**.  
> Any deviation from this configuration (firewall changes, Docker exposure, management plane changes) must be reviewed explicitly before deployment.
