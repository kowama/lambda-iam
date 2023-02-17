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

3. Localhost DNS

    ```bash
    CLUSTER_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    NODE_PORT=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.ports[0].nodePort}')
    echo "${CLUSTER_IP} dev-pingaccess-admin.lambda.corp dev-pingaccess-engine.lambda.corp dev-pingauthorize.lambda.corp dev-pingauthorizepap.lambda.corp dev-pingdataconsole.lambda.corp dev-pingdelegator.lambda.corp dev-pingdirectory.lambda.corp dev-pingfederate-admin.lambda.corp dev-pingfederate-engine.lambda.corp dev-pingcentral.lambda.corp" | sudo tee -a /etc/hosts > /dev/null
    ```

4. Install the chart

    ```bash
    # Install the chart
    helm upgrade --install dev pingidentity/ping-devops -f cluster-lambda.yaml -f ingress-lambda.yaml
    ```

5. Verify the installation

    ```bash
    # Verify the pods are running
    kubectl get pods

    # Verify the ingress is running
    kubectl get ingress
    ```

6. Uninstall the chart

    ```bash
    # Uninstall the chart
    helm uninstall dev
    ```
