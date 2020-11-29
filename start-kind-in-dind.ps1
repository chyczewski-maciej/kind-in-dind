docker system prune --all -y

${containerName} = "kind"
${clusterName}= ${containerName}

# Kill and remove previous ${containerName} container if it exists
docker container rm ${containerName} --force

# Start docker in docker container
docker run --privileged --name ${containerName} -d -p 8080:8080 -p 8081:8081 -p 80:80 -p 443:443 docker:dind

# Install curl and bash
docker exec ${containerName} sh -c "apk add curl"
docker exec ${containerName} sh -c "apk add bash"

# Install kubectl
docker exec ${containerName} sh -c "curl -Lo ./bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.19.0/bin/linux/amd64/kubectl"
docker exec ${containerName} sh -c "chmod +x /bin/kubectl"

# Install kind
docker exec ${containerName} sh -c "curl -Lo ./bin/kind https://kind.sigs.k8s.io/dl/v0.9.0/kind-linux-amd64"
docker exec ${containerName} sh -c "chmod +x /bin/kind"


# Copy required binaries
# docker cp ./bin/kubectl ${containerName}:/bin/kubectl
# docker cp ./bin/kind ${containerName}:/bin/kind

# Wait a moment to make sure docker deamon has started
sleep 2

# Start the cluster
docker exec ${containerName} sh -c "kind delete cluster ${clusterName}"
docker exec ${containerName} sh -c "kind create cluster --name ${clusterName} --config ./configs/cluster.yaml"
docker exec ${containerName} sh -c "kubectl cluster-info --context kind-${clusterName}"
docker exec ${containerName} sh -c "kubectl config set-context kind-${clusterName}"

# Optional: Install metrics-server required to run `kubectl top` command
# Original source: https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.7/components.yaml
# The original yaml file had to be modified in the following way:
# metrics-server deployment got an extra command line argument --kubelet-insecure-tls
docker exec ${containerName} sh -c "kubectl apply -f ./configs/metrics-server.yaml"

# Optional: Expose kubernetes api as localhost:8080 on the host machine
docker exec ${containerName} sh -c "kubectl proxy --address='0.0.0.0' --port=8080 --accept-hosts='.*' &"


# Install helm
# docker exec ${containerName} sh -c "curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash"

# TODO: Consider nats
#  https://docs.nats.io/nats-concepts/queue


# Install Istio
# docker exec ${containerName} sh -c "curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.8.0 TARGET_ARCH=x86_64 sh -"
# docker exec ${containerName} sh -c "./istio-1.8.0/bin/istioctl install -y"

# Setup ingress
# export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
# export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
# export TCP_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].nodePort}')
# export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')
# docker cp ./setIstioEnv.sh ${containerName}:/setIstioEnv.sh


# Get istioctl
docker exec ${containerName} sh -c "curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.8.0 TARGET_ARCH=x86_64 sh -"
docker exec ${containerName} sh -c "cp ./istio-1.8.0/bin/istioctl /bin/istioctl"

# Install istio
docker exec ${containerName} sh -c "istioctl install -y"
# docker exec ${containerName} sh -c "chmod +x /setIstioEnv.sh"
# docker exec ${containerName} sh -c "./setIstioEnv.sh"



# Copy yaml configs
docker cp -a ./configs ${containerName}:/

# Create the hello-world app in the hello-world namespace
docker exec ${containerName} sh -c "kubectl apply -f ./configs/hello-world.yaml"