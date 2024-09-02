# Persistent Volume from Persistent Disk

[Official Documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/preexisting-pd)

The following example mounts a custom `www` directory for Nginx:

1. Create a Persistent Disk in the same zone as the k8s cluster and mount it to an existing Compute Engine instance OR create a temporary CE instance with a disk that will remain after instance deletion

2. Format the file system (replace X with the drive letter):

    ```bash
    sudo mkfs.ext4 /dev/sdX
    ```

3. Mount it

    ```bash
    sudo mount /dev/sdX /mnt
    ```

4. Create an `index.html`

    ```bash
    sudo echo "Hello, Nginx!" > /mnt/index.html
    ```

    ```bash
    sudo chmod 777 /mnt/index.html
    ```

5. Remove the disk from the instance or remove the instance (depending on what you did in step 1)

    This needs to be done because otherwise the Pod will complain that the Disk is already in use

6. Create the PersistentVolume(Claim)

    ```bash
    kubectl apply -f pv.yaml
    ```

7. Create the Deployment

    ```bash
    kubectl apply -f deployment.yaml
    ```

8. Create the service

    ```bash
    kubectl apply -f service.yaml
    ```

9. Visit the LoadBalancer's external IP to see the `index.html`
    ```