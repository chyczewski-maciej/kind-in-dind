${name} = "kind"
${cluster-name}= ${name}

# Kill previous ${name} docker container 
docker container rm ${name} --force

# Start docker in docker container
docker run --privileged --name ${name} -d docker:dind
docker container ls 

docker cp ./bin/kubectl ${name}:/bin/kubectl
docker cp ./bin/kind ${name}:/bin/kind

docker cp -a ./configs ${name}:/

docker exec ${name} sh -c "chmod +x /bin/${name}"
docker exec ${name} sh -c "chmod +x /bin/kubectl"

sleep 2

docker exec ${name} sh -c "${name} create cluster --name ${cluster-name} --config ./configs/cluster.yaml"
docker exec ${name} sh -c "kubectl config set-context ${cluster-name}"
docker exec ${name} sh -c "kubectl get nodes"

docker exec ${name} sh -c "kubectl create namespace hello-world"
docker exec ${name} sh -c "kubectl apply -f ./configs/hello-world.yaml"

sleep 2
docker exec ${name} sh -c "kubectl get pods --all-namespaces"
