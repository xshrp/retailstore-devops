#!/bin/bash

set -e

BASE_DIR="$GITHUB_WORKSPACE"

echo "----------------------------------------"
echo "Iniciando deploy en el cluster 'develop'"
echo "----------------------------------------"

echo "Namespace"
kubectl apply -f "$BASE_DIR/infra/k8s/base/namespace.yaml"
echo "Esperando 2 segundos para reducir la presion del cluster..."
sleep 2

echo ""
echo "Servicios (Networking)"
kubectl apply -f "$BASE_DIR/infra/k8s/base/services.yaml"
echo "Esperando 2 segundos para reducir la presion del cluster..."
sleep 2

echo ""
echo "Redis"
kubectl apply -f "$BASE_DIR/infra/k8s/base/redis.yaml"
echo "Esperando 5 segundos para reducir la presion del cluster..."
sleep 5

echo ""
echo "Postgres"
kubectl apply -f "$BASE_DIR/infra/k8s/base/postgres.yaml"
echo "Esperando 10 segundos para reducir la presion del cluster..."
sleep 10

echo ""
echo "Esperando DBs estabilizarse..."
kubectl wait --for=condition=ready pod -l app=redis -n retailstore --timeout=120s || true
kubectl wait --for=condition=ready pod -l app=postgres -n retailstore --timeout=120s || true
echo "Esperando 5 segundos para reducir la presion del cluster..."
sleep 5

echo ""
echo "Catalog"
kubectl apply -f "$BASE_DIR/infra/k8s/base/catalog.yaml"
echo "Esperando 2 segundos para reducir la presion del cluster..."
sleep 2

echo ""
echo "Cart"
kubectl apply -f "$BASE_DIR/infra/k8s/base/cart.yaml"
echo "Esperando 2 segundos para reducir la presion del cluster..."
sleep 2

echo ""
echo "Orders"
kubectl apply -f "$BASE_DIR/infra/k8s/base/orders.yaml"
echo "Esperando 2 segundos para reducir la presion del cluster..."
sleep 2

echo ""
echo "Checkout"
kubectl apply -f "$BASE_DIR/infra/k8s/base/checkout.yaml"
echo "Esperando 2 segundos para reducir la presion del cluster..."
sleep 2

echo ""
echo "UI"
kubectl apply -f "$BASE_DIR/infra/k8s/base/ui.yaml"
echo "Esperando 2 segundos para reducir la presion del cluster..."
sleep 2

echo ""
echo "Admin"
kubectl apply -f "$BASE_DIR/infra/k8s/base/admin.yaml"
echo "Esperando 2 segundos para reducir la presion del cluster..."
sleep 2

echo ""
echo "Ingress"
kubectl apply -f "$BASE_DIR/infra/k8s/base/ingress.yaml"
echo "Esperando 2 segundos para reducir la presion del cluster..."
sleep 2

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