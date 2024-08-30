# Persitent Volume with ReadWriteMany access

This is to demonstrate how to mount a Persistent Volume with ReadWriteMany access.

## How to demo

1. Create the Persistent Volume and Claim

    ```bash
    kubectl apply -f pv.yaml
    ```

2. Create the Deployment

    ```bash
    kubectl apply -f deployment.yaml
    ```

3. Create the Service

    ```bash
    kubectl apply -f service.yaml
    ```

4. Create an `index.html` in the `nginx` Container

    ```bash
    kubectl exec --stdin --tty [pod-name] --container nginx -- /bin/bash
    ```

    ```bash
    echo "Hello from Nginx" > /usr/share/nginx/html/index.html
    ```

5. Visit the LoadBalancer's external IP to see the `index.html`

6. Modify the `index.html` from the `alpine` container

    ```bash
    kubectl exec --stdin --tty [pod-name] --container alpine -- /bin/bash
    ```

    ```bash
    echo "Hello from Alpine" > /mnt/index.html
    ```

7. Visit the LoadBalancer's external IP to see the modified `index.html`