# Kubernetes Snippet: Nginx as Reverse Proxy

This showcases how to use Nginx as a reverse proxy without using an Ingress. For simplicity, it stores the configuration in a ConfigMap.

There are 3 containers:

- `nginx` as the Reverse Proxy
- `hello-1` as a sidecar together with `nginx`
- `hello-2` in a separate Deployment

This is to show how to proxy to both locations.

## How to demo

1. Create ConfigMap from `hello.conf`

    ```bash
    kubectl create configmap nginx-config --from-file hello.conf
    ```

2. Create Deployment

    ```bash
    kubectl apply -f deployment.yaml
    ```

3. Create Service

    ```bash
    kubectl apply -f service.yaml
    ```
