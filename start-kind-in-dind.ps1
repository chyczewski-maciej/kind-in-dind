${container-name} = "kind-in-dind"
${cluster-name}= ${container-name}

# Kill and remove previous ${container-name} container if it exists
docker container rm ${container-name} --force

# Start docker in docker container
docker run --privileged --name ${container-name} -d docker:dind
docker container ls 

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
docker exec ${container-name} sh -c "kubectl config set-context ${cluster-name}"

# Create the hello-world app the hello world namespace
docker exec ${container-name} sh -c "kubectl create namespace hello-world"
docker exec ${container-name} sh -c "kubectl apply -f ./configs/hello-world.yaml"

# Wait a moment to make sure configs are applied
sleep 2

# Check what pods are created
docker exec ${container-name} sh -c "kubectl get pods --all-namespaces -o wide"

# Check nodes 
docker exec ${container-name} sh -c "kubectl get nodes -o wide"
