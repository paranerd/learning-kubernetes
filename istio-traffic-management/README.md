# Kubernetes Snippets: Istio Traffic Management

## Prerequisites

1. Install Istio

    ```bash
    export ISTIO_VERSION=1.20.2
    curl -L https://istio.io/downloadIstio | TARGET_ARCH=$(uname -m) sh -
    ```

1. Add istioctl to `PATH`

    ```bash
    cd istio-${ISTIO_VERSION}
    export PATH=$PWD/bin:$PATH
    ```

1. Install Istio to the Cluster

    ```bash
    istioctl install --set profile="default" -y
    ```

## Preparation

1. Create the Deployment

    ```bash
    kubectl apply -f deployment.yaml
    ```

1. Create the Service

    ```bash
    kubectl apply -f service.yaml
    ```

1. Create the Destination Rule

    ```bash
    kubectl apply -f destination-rule.yaml
    ```

1. Create the Gateway

    ```bash
    kubectl apply -f gateway.yaml
    ```

1. Create the Virtual Service

    ```bash
    kubectl apply -f virtual-service.yaml
    ```

## How to demo

1. Get the Istio Gateway's external IP address

    ```bash
    kubectl get service istio-ingressgateway -n istio-system
    ```

1. Visit `[Gateway IP]/` or `[Gateway IP]/v1` in a browser

    This should show the `hello-1` service

1. Visit `[Gateway IP]/v2` in a browser

    This should show the `hello-2` service

1. Visit `[Gateway IP]/v3` in a browser

    This should show the `hello-2` service again because there's a `rewrite` from `/v3` to `v2` in `virtual-service.yaml`

1. Visit `[Gateway IP]/v4` in a browser

    This should show the `hello-1` service again because there's no match for `/v4` so it ends up in the catch-all route

1. Show weighted routing

    ```bash
    kubectl apply -f virtual-service-80-20.yaml
    ```

    After a few moments to update you will experience a different routing behavior: When refreshing the page over and over, it will, on average, show `hello-1` and `hello-2` in about 80% and 20% of the time, respectively

1. Show round-robin routing

    ```bash
    kubectl apply -f destination-rule-round-robin.yaml
    ```

    ```bash
    kubectl apply -f virtual-service-round-robin.yaml
    ```

    Again, after a few moments to update, you'll see the following: When repeatedly refreshing the page very quickly, it will alternate between `hello-1` and `hello-2`. However, if you only refresh slowly, it will only ever show `hello-1` - most likely because there's no load balancing needed when there's no load.