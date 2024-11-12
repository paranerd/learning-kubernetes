# Kubernetes Snippets: Config Sync

Config Sync lets you use GitOps for deployment and configuration of Kubernetes Clusters

## Prerequisites

1. **Create GitHub repository**

    In order to have something to sync from, a GitHub repo is required.

    All that's required in that repo (at least for this demo) is the `namespace.yaml` in the root directory.

1. **Update repo in config files**

    Update the repo reference in the following files:

    - `fleet-spec-with-git.yaml`
    - `root-sync.yaml`

1. **Enable APIs**

    ```bash
    gcloud services enable compute.googleapis.com gkehub.googleapis.com anthos.googleapis.com
    ```

1. **Create network**

    ```bash
    gcloud compute networks create default
    ```

1. **Create Fleet**

    The Cluster must be a Fleet-member as part of the requirements for ConfigSync.

    ```bash
    gcloud container fleet create
    ```

1. **Create Cluster**

    ```bash
    gcloud container clusters create config-sync-demo \
      --region us-central1 \
      --enable-fleet
    ```

1. **Enable Config Management**

    ```bash
    gcloud beta container fleet config-management enable
    ```

1. **Configure Config Sync**

    - **Via UI**

      1. Go to GKE > Features > Config > Deploy Package

      1. Select `config-sync-demo` as the cluster and continue

      1. Select "Package hosted on Git" and continue

      1. Fill in the form according to your setup

      1. Click "Deploy Package"

    - **Via Fleet Config Management**

      1. **Enable ConfigSync and link the repository in a single step**

            ```bash
            gcloud beta container fleet config-management apply \
                --membership=config-sync-demo \
                --config=fleet-spec-with-git.yaml
            ```

    - **Via `kubectl`**

      1. **Enable ConfigSync without referencing a repository**

            ```bash
            gcloud beta container fleet config-management apply \
                --membership=config-sync-demo \
                --config=fleet-spec.yaml
            ```

      1. **Configure ConfigSync using `kubectl`**
      
            ```bash
            kubectl apply -f root-sync.yaml
            ```

            For more settings options check out the documentation of the [RootSync](https://cloud.google.com/kubernetes-engine/enterprise/config-sync/docs/reference/rootsync-reposync-fields) fields

## How to demo

1. **List available namespaces**

    ```bash
    kubectl get ns
    ```

    Take note of the `AGE`

1. **Delete `config-sync-demo-ns` namespace**

    ```bash
    kubectl delete ns/config-sync-demo-ns
    ```

1. **See the namespace re-appear**

    ```bash
    kubectl get ns
    ```

    Should show the namespace with a younger `AGE`

1. **See updates pulled from the repository**

    Update `namespace.yaml` in the repository and wait a couple of seconds (default: 15s), then list namespaces again to see the old one dissapear and the updated one created