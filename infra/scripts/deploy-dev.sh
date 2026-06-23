#!/bin/bash

set -e

BASE_DIR="$GITHUB_WORKSPACE"

echo "----------------------------------------"
echo "Iniciando deploy en el cluster 'develop'"
echo "----------------------------------------"

echo "Namespace (1/11)"
kubectl apply -f "$BASE_DIR/infra/k8s/base/namespace.yaml"

echo ""
echo "Redis (2/11)"
kubectl apply -f "$BASE_DIR/infra/k8s/base/redis.yaml"

echo ""
echo "Postgres (3/11)"
kubectl apply -f "$BASE_DIR/infra/k8s/base/postgres.yaml"

echo ""
echo "Servicios (4/11)"
kubectl apply -f "$BASE_DIR/infra/k8s/base/services.yaml"

echo ""
echo "Catalog (5/11)"
kubectl apply -f "$BASE_DIR/infra/k8s/base/catalog.yaml"

echo ""
echo "Cart (6/11)"
kubectl apply -f "$BASE_DIR/infra/k8s/base/cart.yaml"

echo ""
echo "Orders (7/11)"
kubectl apply -f "$BASE_DIR/infra/k8s/base/orders.yaml"

echo ""
echo "Checkout (8/11)"
kubectl apply -f "$BASE_DIR/infra/k8s/base/checkout.yaml"

echo ""
echo "UI (9/11)"
kubectl apply -f "$BASE_DIR/infra/k8s/base/ui.yaml"

echo ""
echo "Admin (10/11)"
kubectl apply -f "$BASE_DIR/infra/k8s/base/admin.yaml"

echo ""
echo "Ingress (11/11)"
kubectl apply -f "$BASE_DIR/infra/k8s/base/ingress.yaml"

echo "----------------------------------------"
echo "Deploy de 'develop' finalizado"
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