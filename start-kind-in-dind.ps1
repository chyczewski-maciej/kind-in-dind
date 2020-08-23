${container-name} = "kind"
${cluster-name}= ${container-name}

# Kill and remove previous ${container-name} container if it exists
docker container rm ${container-name} --force

# Start docker in docker container
docker run --privileged --name ${container-name} -d -p 80:80 -p 443:443 docker:dind

# Copy required binaries
docker cp ./bin/kubectl ${container-name}:/bin/kubectl
docker cp ./bin/kind ${container-name}:/bin/kind
docker exec ${container-name} sh -c "chmod +x /bin/kind"
docker exec ${container-name} sh -c "chmod +x /bin/kubectl"

# Copy yaml configs
docker cp -a ./configs ${container-name}:/

# Wait a moment to make sure docker deamon has started
sleep 2

# Start the cluster
docker exec ${container-name} sh -c "kind create cluster --name ${cluster-name} --config ./configs/cluster.yaml"
docker exec ${container-name} sh -c "kubectl cluster-info --context kind-${cluster-name}"
docker exec ${container-name} sh -c "kubectl config set-context kind-${cluster-name}"

# Create the hello-world app the hello world namespace
docker exec ${container-name} sh -c "kubectl apply -f ./configs/hello-world.yaml"

# Optional: Install Ambassador to support ingress. More information can be found at https://kind.sigs.k8s.io/docs/user/ingress
docker exec ${container-name} sh -c "kubectl apply -f ./configs/ambassador/ambassador-operator-crds.yaml" # Original source: https://github.com/datawire/ambassador-operator/releases/latest/download/ambassador-operator-crds.yaml
docker exec ${container-name} sh -c "kubectl apply -n ambassador -f ./configs/ambassador/ambassador-operator-kind.yaml" # Original source: https://github.com/datawire/ambassador-operator/releases/latest/download/ambassador-operator-kind.yaml

# Optional: Install metrics-server required to run `kubectl top` command
# Original source: https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.7/components.yaml
# The original yaml file had to be modified in the following way:
# metrics-server deployment got an extra command line argument --kubelet-insecure-tls
docker exec ${container-name} sh -c "kubectl apply -f ./configs/metrics-server.yaml"