# k8s-dev-demo

A Kubernetes Development Demo that uses [Devspace](https://devspace.sh/).

# Software setup

Install Docker

* https://docs.docker.com/get-docker/

Use [arkade](https://arkade.dev) to install various client tools

    ark get buildx
    ark get kubectl
    ark get kubectx
    ark get kubens
    ark get helm
    ark get devspace
    ark get minikube
    ark get yq
    ark get argocd

Enable buildx docker plugin

    mkdir -p ~/.docker/cli-plugins
    ln -s ~/.arkade/bin/buildx ~/.docker/cli-plugins/docker-buildx

Install KVM

* https://minikube.sigs.k8s.io/docs/drivers/kvm2/

# Environment setup

Start a minikube cluster 

    # Start a cluster
    minikube start --driver=kvm2 --kubernetes-version=v1.23.3 --cpus=2 --memory=8g

    # Install platform dependencies
    arkade install ingress-nginx --namespace ingress-nginx

    # Start a tunnel to enable services of type load balancer
    minikube tunnel

# Usage

A Makefile exists to run a devspace build and deploy to the "demo" namespace

    make

# ArgoCD

## Installation

Core install of ArgoCD

    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/master/manifests/core-install.yaml

Open up the UI

    kubens argocd
    argocd login --core
    argocd admin dashboard

## Run the application

Create a registry pull secret in the target namespace

    # Remove the old registry credentials
    rm $HOME/.docker/config.json
    
    # Login to the registry
    docker login c8n.io

    # Create a registry secret in the target namespace
    kubectl create ns k8s-dev-demo
    kubectl --namespace k8s-dev-demo create secret generic regcred --from-file=.dockerconfigjson=$HOME/.docker/config.json --type=kubernetes.io/dockerconfigjson
    kubectl --namespace k8s-dev-demo patch serviceaccount default -p '{"imagePullSecrets": [{"name": "regcred"}]}'

Deploy the application

    kubectl -n argocd apply -f - <<END
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: k8s-dev-demo
      namespace: argocd
    spec:
      project: default
      destination:
        namespace: k8s-dev-demo
        server: https://kubernetes.default.svc
      source:
        chart: component-chart
        repoURL: https://charts.devspace.sh
        targetRevision: 0.8.4
        helm:
          values: |-
            containers:
            - image: c8n.io/myspotontheweb/k8s-dev-demo:v1.0
            service:
              ports:
              - port: 8080
            ingress:
              ingressClassName: nginx
              tls: false
              rules:
              - host: k8s-dev-demo.10.108.46.216.nip.io
                path: "/"
                pathType: "Prefix"
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
    END

