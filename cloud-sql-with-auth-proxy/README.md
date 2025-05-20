# How to query Cloud SQL from GKE

Based on the [official documentation](https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine)

## Prerequisites

1. **Enable Cloud SQL Admin API**

    ```bash
    gcloud services enable sqladmin.googleapis.com
    ```

1. **Create Cloud SQL instance**

    ```bash
    gcloud sql instances create cloudsql-demo --tier=db-f1-micro --region=us-central1
    ```

1. **Set root password**

    ```bash
    gcloud sql users set-password root --host=% --instance=cloudsql-demo --password=root
    ```

1. **Connect to the instance**

    ```bash
    gcloud sql connect cloudsql-demo --user=root
    ```

1. **Prepare database**

    - Create database

        ```bash
        CREATE DATABASE demo;
        ```

    - Create table

        ```bash
        CREATE TABLE demo.users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            email VARCHAR(255) NOT NULL
        );
        ```

    - Add user data

        ```bash
        INSERT INTO demo.users (name, email) VALUES ('John', 'john@mail.com');

1. **Create GKE Autopilot cluster**

    ```bash
    gcloud container clusters create-auto cloudsql-demo --location=us-central1
    ```

1. **Connect to the cluster**

    ```bash
    gcloud container clusters get-credentials cloudsql-demo --region=us-central1
    ```

1. **Create credentials secret**

    ```bash
    kubectl create secret generic db-secret --from-literal=username=root --from-literal=password=root --from-literal=database=demo
    ```

1. **Grant GKE Service Account access to pull from Artifact Registry**

    ```bash
    gcloud projects add-iam-policy-binding [PROJECT_ID] --member=serviceAccount:[SERVICE_ACCOUNT_EMAIL] --role=roles/artifactregistry.reader
    ```

1. **Create GCP Service Account for Workload Identity**

    ```bash
    gcloud iam service-accounts create cloudsql-demo
    ```

    Grant the Service Account access to Cloud SQL

    ```bash
    gcloud projects add-iam-policy-binding [PROJECT_ID] --member="serviceAccount:cloudsql-demo@[PROJECT_ID].iam.gserviceaccount.com" --role="roles/cloudsql.client"
    ```

1. **Set up Workload Identity**

    - **Create Kubernetes Service Account**

        ```bash
        kubectl create serviceaccount cloudsql-demo
        ```

    - **Create the binding**

        ```bash
        gcloud iam service-accounts add-iam-policy-binding --role="roles/iam.workloadIdentityUser" --member="serviceAccount:[PROJECT_ID].svc.id.goog[default/cloudsql-demo]" cloudsql-demo@[PROJECT_ID].iam.gserviceaccount.com
        ```

    - **Annotate Kubernetes Service Account to complete the binding**

        ```bash
        kubectl annotate serviceaccount cloudsql-demo iam.gke.io/gcp-service-account=cloudsql-demo@[PROJECT_ID].iam.gserviceaccount.com
        ```

1. **Create Artifact Registry repository**

    ```bash
    gcloud artifacts repositories create cloudsql-demo --repository-format=docker --location=us-central1
    ```

1. **Prepare the image**

    - **Build the image**

        ```bash
        docker build -t cloudsql-demo .
        ```

    - **Tag the image**

        ```bash
        docker tag cloudsql-demo us-central1-docker.pkg.dev/[PROJECT_ID]/cloudsql-demo/cloudsql-demo-app:latest
        ```

    - **Push the image**

        ```bash
        docker push us-central1-docker.pkg.dev/[PROJECT_ID]/cloudsql-demo/cloudsql-demo-app:latest
        ```

1. **Update `deployment.yaml`**

    ```bash
    sed -i "s/PROJECT_ID/$(gcloud config get-value project 2> /dev/null)/g" deployment.yaml
    ```

1. **Deploy**

    ```bash
    kubectl apply -f deployment.yaml
    ```

1. **Get Ingress IP address**

    ```bash
    kubectl get ingress cloudsql-demo-ingress
    ```