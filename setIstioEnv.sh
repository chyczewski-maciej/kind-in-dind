# export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
# export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
# export TCP_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].nodePort}')
# export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')

# https://istio.io/latest/docs/setup/getting-started/

# Get istioctl
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.8.0 TARGET_ARCH=x86_64 sh -
cp ./istio-1.8.0/bin/istioctl /bin/istioctl

# Install istio
istioctl install -y
# kubectl label namespace default istio-injection=enabled


# kubectl apply -f - <<EOF
# apiVersion: networking.istio.io/v1alpha3
# kind: Gateway
# metadata:
#   name: httpbin-gateway
# spec:
#   selector:
#     istio: ingressgateway # use Istio default gateway implementation
#   servers:
#   - port:
#       number: 80
#       name: http
#       protocol: HTTP
#     hosts:
#     - "*"
# ---
# apiVersion: networking.istio.io/v1alpha3
# kind: VirtualService
# metadata:
#   name: httpbin
# spec:
#   hosts:
#   - "*"
#   gateways:
#   - httpbin-gateway
#   http:
#   - match:
#     - uri:
#         prefix: /headers
#     route:
#     - destination:
#         port:
#           number: 8000
#         host: httpbin
# EOF


export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
export TCP_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].nodePort}')
export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')


curl http://$INGRESS_HOST:$INGRESS_PORT/hello
# curl http://$INGRESS_HOST:$INGRESS_PORT/headers