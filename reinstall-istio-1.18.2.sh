#!/bin/bash
set -e

echo "🔹 Verwijder bestaande Istio Helm releases..."
helm uninstall istio-base -n istio-system || true
helm uninstall istiod -n istio-system || true
helm uninstall istio-ingress -n istio-system || true

echo "🔹 Verwijder eventueel overgebleven namespace..."
kubectl delete namespace istio-system --ignore-not-found=true

echo "⏳ Wachten tot namespace echt weg is..."
while kubectl get ns istio-system >/dev/null 2>&1; do
  sleep 2
done

echo "✅ Namespace verwijderd. Installeer Istio 1.18.2 opnieuw."

echo "🔹 Istio Base installeren (CRDs en clusterrollen)..."
helm install istio-base istio/base --version 1.18.2 -n istio-system --create-namespace

echo "🔹 Istiod installeren (control plane)..."
helm install istiod istio/istiod --version 1.18.2 -n istio-system

echo "🔹 Ingress Gateway installeren..."
helm install istio-ingress istio/gateway --version 1.18.2 -n istio-system

echo "⏳ Even wachten tot pods starten..."
sleep 20

echo "🔹 Check pods:"
kubectl get pods -n istio-system

echo "🔹 Verifieer Istio versie:"
istioctl version