# Kubernetes Snippet: Ingress

This demonstrates how to create a simple Ingress with two endpoints and a default backend.

## How to demo

1. Create the Deployments

    ```bash
    kubectl apply -f deployment.yaml
    ```

2. Create the Service

    ```bash
    kubectl apply -f service.yaml
    ```

3. Create the Ingress

    ```bash
    kubectl apply -f ingress.yaml
    ```

4. Get the Ingress' external IP

    ```bash
    kubectl get ingress
    ```

5. Visit the `/`, `/v1` and `/v2` endpoints to see routing the different backends in action