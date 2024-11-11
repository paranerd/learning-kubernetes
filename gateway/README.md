# Kubernetes Snippets: Gateway

[Official Documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/deploying-gateways)

## Preparation

1. Update cluster to support Gateway

    ```bash
    gcloud container clusters update standard-cluster-1 \
    --location=us-central1-c \
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

### Internal

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

### External

1. Externally expose the Gateway

    The basic `gateway.yaml` is based on an Internal LoadBalancer (`gke-l7-rilb`) and thus only reachable internally. To expose it to the internet, we need to use an External LoadBalancer (`gke-l7-global-external-managed`).

    With the Deployment and Service in place from the internal version, we'll simply update the `gatewayClassName` in `gateway.yaml` from `gke-l7-rilb` to `gke-l7-global-external-managed`.

    Re-deploy the Gateway:

    ```bash
    kubectl apply -f gateway.yaml
    ```

    **Optional**: If the steps below don't work, the Gateway may need to be deleted and re-created:

    ```bash
    kubectl delete gateway gateways/example-gateway
    ```

    ```bash
    kubectl apply -f gateway.yaml
    ```

1. Get Gateway IP

    ```bash
    kubectl describe gateways/example-gateway
    ```

    Look for: Status > Addresses > Value

    Important: The IP may take a couple of minutes to be updated, so don't confuse it with the previous internal one!

1. (Optional) Set up DNS records

    If you want to demo routing based on hostnames, replace all occurrences of `.example.com` in `gateway-external.yaml` with your respective domain.
    
    Also create A Records for `hello1.your-domain.com` and `hello2.your-domain.com` to point to the Gateway IP

1. Test external routing

    ```bash
    curl [Gateway IP]
    ```

    --> Should return the "Hello 1" Service

    ```bash
    curl [Gateway IP]/v2
    ```

    --> Should return the "Hello 2" Service

    ```bash
    curl hello1.your-domain.com
    ```

    --> Should return the "Hello 1" Service

    ```bash
    curl hello2.your-domain.com
    ```

    --> Should return the "Hello 2" Service