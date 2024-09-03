# Kuberenetes Snippet: Ingress using Nginx

This demonstrates how to create an Ingress using Nginx. It uses the `ingress-nginx` Helm chart.

One use case for this is to have more control over the rewrite configuration than in the default Ingress.

## How to demo

1. Install `ingress-nginx` via Helm

    ```bash
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    ```

    ```bash
    helm repo update
    ```

    ```bash
    helm install nginx-ingress ingress-nginx/ingress-nginx
    ```

2. Create the Deployments

    ```bash
    kubectl apply -f deployment.yaml
    ```

3. Create the Ingress

    ```bash
    kubectl apply -f ingress.yaml
    ```

    The important part here is `ingressClassName: nginx` to let the Controller know that we're using Nginx as the Proxy

    If you encounter a `no endpoints available for service` error, wait a moment and try again

4. Get the external IP

    ```bash
    kubectl get service --namespace default nginx-ingress-ingress-nginx-controller --output wide --watch
    ```

5. Test the endpoints

    Visit `[EXTERNAL_IP]/v1` and `[EXTERNAL_IP]/v2` to see the routing in action