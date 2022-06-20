.EXPORT_ALL_VARIABLES:

INGRESS_IP = $(shell kubectl -n ingress-nginx get service ingress-nginx-controller -oyaml | yq '.status.loadBalancer.ingress[0].ip')

all:
	devspace use namespace demo
	devspace deploy

yaml:
	devspace render --skip-build
