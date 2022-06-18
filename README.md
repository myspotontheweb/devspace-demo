# k8s-dev-demo

A Kubernetes Development Demo

Inspired by this page

* https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/

# Software setup

Install Docker

* https://docs.docker.com/get-docker/

Use [arkade](https://arkade.dev) to install various client tools

    ark get buildx
    ark get kubectl
    ark get kubectx
    ark get helm
    ark get devspace
    ark get minikube
    ark get yq

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

Build and deploy the application

    devspace use namespace demo
    devspace deploy

