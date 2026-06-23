#!/bin/bash

set -e

echo "----------------------------------------"
echo "Iniciando deploy en el cluster 'develop'"
echo "----------------------------------------"

echo "Namespace (1/12)"
kubectl apply -f k8s/base/namespace.yaml

echo ""
echo "Instalacion de NGINX Ingress Controller (2/12)"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.3/deploy/static/provider/cloud/deploy.yaml

echo ""
echo "Redis (3/12)"
kubectl apply -f k8s/base/redis.yaml

echo ""
echo "Postgres (4/12)"
kubectl apply -f k8s/base/postgres.yaml

echo ""
echo "Servicios (5/12)"
kubectl apply -f k8s/base/services.yaml

echo ""
echo "Catalog (6/12)"
kubectl apply -f k8s/base/catalog.yaml

echo ""
echo "Cart (7/12)"
kubectl apply -f k8s/base/cart.yaml

echo ""
echo "Orders (8/12)"
kubectl apply -f k8s/base/orders.yaml

echo ""
echo "Checkout (9/12)"
kubectl apply -f k8s/base/checkout.yaml

echo ""
echo "UI (10/12)"
kubectl apply -f k8s/base/ui.yaml

echo ""
echo "Admin (11/12)"
kubectl apply -f k8s/base/admin.yaml

echo ""
echo "Ingress (12/12)"
kubectl apply -f k8s/base/ingress.yaml

echo "----------------------------------------"
echo "Deploy de 'develop'" finalizado
echo "----------------------------------------"


echo ""
echo "Pods:"
kubectl get pods -n retailstore

echo ""
echo "Servicios:"
kubectl get svc -n retailstore

echo ""
echo "Ingress:"
kubectl get ingress -n retailstore
