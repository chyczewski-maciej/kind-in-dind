docker container rm kind --force
# docker build --tag kindconfigured .
docker run --privileged --name kind -d docker:dind
docker container ls 

docker cp ./bin/kubectl kind:/bin/kubectl
docker cp ./bin/kind kind:/bin/kind
docker cp -a ./configs kind:/

docker exec kind sh -c "chmod +x /bin/kind"
docker exec kind sh -c "chmod +x /bin/kubectl"

sleep 2

docker exec kind sh -c "kind create cluster --name demo --config ./configs/cluster.yaml"
# docker exec kind sh -c "kubectl cluster-info --context kind-demo"
docker exec kind sh -c "kubectl config set-context kind-demo"
docker exec kind sh -c "kubectl get nodes"
# docker exec kind sh -c "kubectl get pods --all-namespaces"

docker exec kind sh -c "kubectl create namespace hello-world"
docker exec kind sh -c "kubectl apply -f ./hello-world"

sleep 2
docker exec kind sh -c "kubectl get pods --all-namespaces"
