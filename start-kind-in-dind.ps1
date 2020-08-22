${container-name} = "kind"
${cluster-name}= ${container-name}

# Kill and remove previous ${container-name} container if it exists
docker container rm ${container-name} --force

# Start docker in docker container
docker run --privileged --name ${container-name} -d -p 80:80 -p 443:443 docker:dind

# Copy required binaries
docker cp ./bin/kubectl ${container-name}:/bin/kubectl
docker cp ./bin/kind ${container-name}:/bin/kind
docker exec ${container-name} sh -c "chmod +x /bin/${container-name}"
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

# Optional: Install Ambassador to support ingress
docker exec ${container-name} sh -c "kubectl apply -f https://github.com/datawire/ambassador-operator/releases/latest/download/ambassador-operator-crds.yaml"
docker exec ${container-name} sh -c "kubectl apply -n ambassador -f https://github.com/datawire/ambassador-operator/releases/latest/download/ambassador-operator-kind.yaml"