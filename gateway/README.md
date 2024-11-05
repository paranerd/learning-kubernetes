# Kubernetes Snippets: Gateway

[Official Documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/deploying-gateways)

## Preparation

1. Update cluster to support Gateway

    ```bash
    gcloud container clusters update standard-cluster-1 \
    --location=us-central1-c\
    --gateway-api=standard
    ```

1. Create a proxy-only subnet

    ```bash
    gcloud compute networks subnets create k8s-gateway \
      --purpose=REGIONAL_MANAGED_PROXY \
      --role=ACTIVE \
      --region=us-central1 \
      --network=default \
      --range=10.0.0.0/23
    ```

## How to demo

1. Create the Deployments

    ```bash
    kubectl apply -f deployment.yaml
    ```

1. Create the Services

    ```bash
    kubectl apply -f service.yaml
    ```

1. Create the Gateway

    ```bash
    kubectl apply -f gateway.yaml
    ```

1. Get Gateway IP

    ```bash
    kubectl describe gateways/example-gateway
    ```

    Look for: Status > Addresses > Value

1. Create a GCE instance

    - Make sure it's in the same region/zone and network as the GKE Cluster
    - Don't add it to the proxy-only subnet

1. Test routing

    ```bash
    curl [Gateway IP]
    ```

    --> Should return the "Hello 1" Service

    ```bash
    curl [Gateway IP]/v2
    ```

    --> Should return the "Hello 2" Service

        ```bash
    curl [Gateway IP]/v3
    ```

    --> Should also return the "Hello 1" Service because of the "catch all"