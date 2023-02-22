# Lambda.corp IAM Services - Kubernetes Cluster Configuration

This repository contains Kubernetes cluster configuration for the Lambda.corp IAM services.

## Setup Instructions

1. Create a namespace for running the stack in your Kubernetes cluster.

    ```bash
    # Create the namespace
    kubectl create ns lambda-iam

    # Set the kubectl context to the namespace
    kubectl config set-context --current --namespace=lambda-iam

    # Confirm
    kubectl config view --minify | grep namespace:
    ```

2. ngnix Ingress Controller

    ```bash
    # Install the ingress controller using Helm
    helm upgrade --install ingress-nginx ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx \
    --namespace ingress-nginx --create-namespace
    ```

3. PingDevOps Secret

   ```bash
   pingctl k8s generate devops-secret | kubectl apply -f -
    ```

4. Localhost DNS

    ```bash
    CLUSTER_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    echo "${CLUSTER_IP} pingaccess-admin.lambda.corp pingaccess-engine.lambda.corp pingauthorize.lambda.corp pingauthorizepap.lambda.corp pingdataconsole.lambda.corp pingdelegator.lambda.corp support.lambda.corp pingdirectory.lambda.corp pingfederate-admin.lambda.corp pingfederate-engine.lambda.corp auth.lambda.corp pingcentral.lambda.corp" | sudo tee -a /etc/hosts > /dev/null
    ```

5. Install the chart

    ```bash
    # Install the chart
    helm upgrade --install dev pingidentity/ping-devops -f iam-cluster.yaml -f ingress.yaml
    ```

6. Verify the installation

    ```bash
    # Verify the pods are running
    kubectl get pods

    # Verify the ingress is running
    kubectl get ingress
    ```

7. Uninstall the chart

    ```bash
    # Uninstall the chart
    helm uninstall dev
    ```
