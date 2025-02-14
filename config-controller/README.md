# Kubernetes Snippets: Config Connector

Config Connector lets you manage Google Cloud resources through Kubernetes.

## Prerequisites

1. **Enable APIs**

    [Documentation](https://cloud.google.com/kubernetes-engine/enterprise/config-controller/docs/setup#production_considerations)

    ```bash
    gcloud services enable krmapihosting.googleapis.com \
    anthos.googleapis.com  \
    cloudresourcemanager.googleapis.com \
    serviceusage.googleapis.com
    ```

1. **Create a Cluster**

    ```bash
    gcloud anthos config controller create my-cc-cluster \
    --location=us-central1 \
    --full-management
    ```

1. **Grant permissions**

    - Get Kubernetes Service Account

        ```bash
        export SA_EMAIL="$(kubectl get ConfigConnectorContext -n config-control -o jsonpath='{.items[0].spec.googleServiceAccount}' 2> /dev/null)"
        ```

    - Grant permissions

        Replace `<PROJECT_ID>` with your Project ID

        ```bash
        export PROJECT_ID=<PROJECT_ID>
        ```

        ```bash
        gcloud projects add-iam-policy-binding ${PROJECT_ID} \
        --member "serviceAccount:${SA_EMAIL}" \
        --role "ROLE" \
        --project ${PROJECT_ID}
        ```

## How to demo

1. **Find configuration**

    Use [this documentation](https://cloud.google.com/config-connector/docs/reference/overview) to get all available resources to be managed with Config Connector.

    Be aware that some of the resources have pre-conditions!

1. **Apply configuration**

    Simply run:

    ```bash
    kubectl apply -f <config.yaml>
    ```

## Troubleshooting

- Get logs

    ```bash
    kubectl logs -n cnrm-system -l cnrm.cloud.google.com/component=cnrm-controller-manager -c manager
    ```