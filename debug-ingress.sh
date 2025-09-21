#!/bin/bash
# set -e

# APP_LABEL="brass-web-app"
# SERVICE_NAME="brass-web-service"
# INGRESS_NAME="brass-web-ingress"
# NAMESPACE="default"

# echo "🔎 Checking Pods for app=$APP_LABEL ..."
# kubectl get pods -l app=$APP_LABEL -n $NAMESPACE -o wide

# echo -e "\n🔎 Checking Endpoints for Service: $SERVICE_NAME ..."
# kubectl get endpoints $SERVICE_NAME -n $NAMESPACE -o wide

# echo -e "\n🔎 Curling the Service internally (via busybox) ..."
# kubectl run tmp-shell --rm -it --restart=Never --image=busybox:1.28 -n $NAMESPACE \
#   -- wget -qO- http://$SERVICE_NAME:8082 || echo "❌ Service test failed"

# echo -e "\n🔎 Curling the Pod directly ..."
# POD=$(kubectl get pod -l app=$APP_LABEL -n $NAMESPACE -o jsonpath='{.items[0].metadata.name}')
# kubectl exec -it $POD -n $NAMESPACE -- curl -s http://localhost:80 || echo "❌ Pod curl failed"

# echo -e "\n🔎 Describing Ingress: $INGRESS_NAME ..."
# kubectl describe ingress $INGRESS_NAME -n $NAMESPACE

# echo -e "\n🔎 Getting Ingress Address ..."
# kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o wide

# echo -e "\n🔎 Testing Ingress route from local machine ..."
# curl -H "Host: brass-web.com" http://192.168.49.2 || echo "❌ Ingress route failed"

# echo -e "\n✅ Debug run completed!"

# ==============


#!/bin/bash
set -e

APP_LABEL="brass-web-app"
SERVICE_NAME="brass-web-service"
INGRESS_NAME="brass-web-ingress"
NAMESPACE="default"

# Colors
GREEN="\033[0;32m"
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

pass() { echo -e "${GREEN}✔ PASS:${NC} $1"; }
fail() { echo -e "${RED}✘ FAIL:${NC} $1"; }
info() { echo -e "${CYAN}🔎 INFO:${NC} $1"; }

info "Checking Pods for app=$APP_LABEL ..."
kubectl get pods -l app=$APP_LABEL -n $NAMESPACE -o wide || fail "Pods not found"
echo

info "Checking Endpoints for Service: $SERVICE_NAME ..."
kubectl get endpoints $SERVICE_NAME -n $NAMESPACE -o wide
echo

info "Curling the Service internally (via BusyBox)..."
if kubectl run tmp-shell --rm -it --restart=Never --image=busybox:1.28 -n $NAMESPACE \
   -- wget -qO- http://$SERVICE_NAME:8082 >/dev/null 2>&1; then
    pass "Service is reachable internally"
else
    fail "Service is NOT reachable internally"
fi
echo

info "Curling the Pod directly ..."
POD=$(kubectl get pod -l app=$APP_LABEL -n $NAMESPACE -o jsonpath='{.items[0].metadata.name}')
if kubectl exec -it $POD -n $NAMESPACE -- curl -s http://localhost:80 >/dev/null 2>&1; then
    pass "Pod responds on port 80"
else
    fail "Pod does not respond on port 80"
fi
echo

info "Describing Ingress: $INGRESS_NAME ..."
kubectl describe ingress $INGRESS_NAME -n $NAMESPACE
echo

info "Getting Ingress Address ..."
kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o wide
echo

info "Testing Ingress route from local machine ..."
if curl -H "Host: brass-web.com" -s http://192.168.49.2 >/dev/null 2>&1; then
    pass "Ingress route works (brass-web.com → Service)"
else
    fail "Ingress route failed"
fi
echo

info "Debug run completed ✅"
