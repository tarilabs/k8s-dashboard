#!/bin/bash

helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard

echo "Waiting for all Deployments in kubernetes-dashboard..."
DEPLOYMENTS=$(kubectl get deployments -n kubernetes-dashboard -o jsonpath='{.items[*].metadata.name}')
for DEPLOYMENT in $DEPLOYMENTS; do # bash separation
  kubectl wait --for=condition=available --timeout=2m deployment/$DEPLOYMENT -n kubernetes-dashboard
done

echo
echo "instructions above ^^^"
echo

curl -s "https://raw.githubusercontent.com/tarilabs/k8s-dashboard/main/serviceAccount.yaml" | kubectl apply -f -
sleep 2
curl -s "https://raw.githubusercontent.com/tarilabs/k8s-dashboard/main/clusterRoleBinding.yaml" | kubectl apply -f -
sleep 2
curl -s "https://raw.githubusercontent.com/tarilabs/k8s-dashboard/main/bearerTokenSecret.yaml" | kubectl apply -f -
sleep 3

echo "Bearer token:"
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
echo ""

echo
echo "about to port-fwd to http://localhost:8443"
echo

kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
