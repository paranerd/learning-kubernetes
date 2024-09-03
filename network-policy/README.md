# Kubernetes Snippet: Network Policy

This demonstrates how to create a Network Policy. It uses 3 containers `nginx-1`, `nginx-2` and `hello`. The Network Policy allows traffic from `nginx-1` to `hello` but not from `nginx-2`.

## How to demo

1. Create the Deployment

    ```bash
    kubectl apply -f deployment.yaml

2. Create the Service

    ```bash
    kubectl apply -f service.yaml
    ````

3. Create the Network Policy

    ```bash
    kubectl apply -f network-policy.yaml
    ```

4. SSH into `nginx-1`

    ```bash
    kubectl exec --stdin --tty [NGINX_1_POD_NAME] -- /bin/bash
    ```

5. Connect to `hello`

    ```bash
    curl --connect-timeout 2 http://hello/
    ```

    This should succeed.

6. SSH into `nginx-2`

    ```bash
    kubectl exec --stdin --tty [NGINX_2_POD_NAME] -- /bin/bash
    ```

7. Connect to `hello`

    ```bash
    curl --connect-timeout 2 http://hello/
    ```

    This should fail.