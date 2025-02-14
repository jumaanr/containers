# Kubernetes Ingress Controller : Rules, Paths and Hosts

In Kubernetes **Ingress**, `rules`, `paths`, and `hosts` define how external traffic is routed to services inside the cluster. Since you're using **Traefik** as an Ingress Controller, let's break it down:

---

## **1. Basic Structure of an Ingress Resource**
Here’s an example of a **Kubernetes Ingress** resource:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  namespace: default
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: "web"
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```

---

## **2. Key Components**
### **a) Rules**
- Define how traffic should be routed.
- Each rule contains a **host** and **http** settings.
- You can define multiple rules in one Ingress resource.

### **b) Hosts**
- Specify **which domain (host) the rule applies to**.
- Example: `example.com`, `app.example.com`.
- If no host is defined, the rule applies to all incoming traffic.

### **c) Paths**
- Define **URL paths** that should be forwarded to specific services.
- Paths are matched using the `pathType` field.

---

## **3. Path Types**
| Path Type  | Description |
|------------|------------|
| `Prefix`   | Matches if the request path starts with the defined path. Example: `/app` matches `/app`, `/app/home`. |
| `Exact`    | Matches the exact path only. Example: `/login` only matches `/login`, not `/login/abc`. |
| `ImplementationSpecific` | The behavior depends on the Ingress controller (e.g., Traefik might use regex). |

---

## **4. Multiple Paths Example**
You can define multiple **path-based** rules:
```yaml
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
      - path: /web
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```
📌 **Traffic Flow:**
- `example.com/api` → Sent to `api-service`
- `example.com/web` → Sent to `web-service`

---

## **5. Multiple Hosts Example**
You can define multiple **host-based** rules:
```yaml
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
  - host: web.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```
📌 **Traffic Flow:**
- `api.example.com` → `api-service`
- `web.example.com` → `web-service`

---

## **6. Traefik-Specific Annotations**
Traefik provides additional options using annotations. Examples:
- **Redirect HTTP to HTTPS**  
  ```yaml
  traefik.ingress.kubernetes.io/router.entrypoints: "websecure"
  traefik.ingress.kubernetes.io/router.tls: "true"
  ```
- **Enable TLS for Specific Host**  
  ```yaml
  spec:
    tls:
    - hosts:
      - example.com
      secretName: example-tls-secret
  ```
- **Use Regular Expressions in Paths**  
  ```yaml
  traefik.ingress.kubernetes.io/rule-type: "PathPrefixStrip"
  ```

---

# Kubernetes Ingress Controller : How it handles multiple domains and paths by multiple rules

Lets say how ingress handles traffic for **a.example1.com**, **b.example1.com**, and **example2.com**, you need **multiple host rules** in your Ingress resource.

---

## **1. Ingress Example for Multiple Hosts**
This example routes different domains to different services:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multi-host-ingress
  namespace: default
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: "web, websecure"
    traefik.ingress.kubernetes.io/router.tls: "true"
spec:
  tls:
  - hosts:
      - a.example1.com
      - b.example1.com
      - example2.com
    secretName: wildcard-tls-secret  # TLS certificate for all hosts

  rules:
  - host: a.example1.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: service-a
            port:
              number: 8080

  - host: b.example1.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: service-b
            port:
              number: 8081

  - host: example2.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: service-c
            port:
              number: 8082
```

---

## **2. Traffic Flow**
| Hostname         | Path  | Service     | Port  |
|-----------------|------|------------|------|
| a.example1.com  | `/`  | `service-a` | 8080 |
| b.example1.com  | `/`  | `service-b` | 8081 |
| example2.com    | `/`  | `service-c` | 8082 |

---

## **3. Optional Enhancements**
### **Wildcard Subdomain Support**
If `a.example1.com` and `b.example1.com` follow the same routing rules, you can use a wildcard `*.example1.com`:
```yaml
  - host: "*.example1.com"
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: shared-service
            port:
              number: 8080
```
📌 **This will route** `a.example1.com`, `b.example1.com`, and any other subdomain of `example1.com` to `shared-service`.

### **TLS Configuration**
Make sure your TLS certificate covers all domains. If using **Let's Encrypt with Traefik**, add:
```yaml
traefik.ingress.kubernetes.io/router.tls.certresolver: "letsencrypt"
```
For **wildcard domains**, your TLS certificate must include `*.example1.com` and `example2.com`.

---

