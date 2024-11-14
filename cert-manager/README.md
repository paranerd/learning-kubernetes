# Kubernetes Snippets: Cert Manager

Using [Cert Manager](https://cert-manager.io/) to automate SSL certificates with Let's Encrypt.

Based on the [official tutorial](https://cert-manager.io/docs/tutorials/getting-started-with-cert-manager-on-google-kubernetes-engine-using-lets-encrypt-for-ingress-ssl)

## Prererquisites

1. **Create a domain**

    This is not part of this tutorial

1. **Create global IP address**

    ```bash
    gcloud compute addresses create hello-ip --global
    ```

1. **Create a DNS A-Record to point to the LoadBalancer's IP**

    To get the IP, run:

    ```bash
    gcloud compute addresses list
    ```

1. **Create a Standard (!) GKE Cluster**

    Cert Manager webhooks won't work with Autopilot Clusters because of [policy reasons](https://github.com/cert-manager/cert-manager/issues/3717)

    ```bash
    gcloud container clusters create hello-cluster --num-nodes=1 --region=us-central1
    ```

## How to demo

1. **Install Cert Manager**

    Check for the most recent version at demo time

    ```bash
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.1/cert-manager.yaml
    ```

1. **Deploy the Deployment**

    ```bash
    kubectl apply -f deployment.yaml
    ```

1. **Deploy the Service**

    ```bash
    kubectl apply -f service.yaml
    ```

1. **Create Let's Encrypt Issuer**

    Make sure to update `email:` in `issuer.yaml` with a proper email address (@example.com doesn't work)

    ```bash
    kubectl apply -f issuer.yaml
    ```

1. **Create a secret to hold the TLS certificate**

    ```bash
    kubectl apply -f secret.yaml
    ```

1. **Deploy the Ingress**

    First, update `hosts:` in `ingress.yaml` with your domain, then run:

    ```bash
    kubectl apply -f ingress.yaml
    ```

1. **Visit the HTTPS protected website**

    Either in a browser or by running:

    ```bash
    curl https://your-domain.com
    ```