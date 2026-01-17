# k8s-dr-demo
AWS EKS DR Demo

Commands to Setup
Terraform
terraform init
terraform plan -var-file="config/ap-southeast-1.tfvars" -target=module.vpc -target=module.eks -out=tfplan-core
terraform apply "tfplan-core"
terraform refresh -var-file="config/ap-southeast-1.tfvars"
terraform plan -var-file="config/ap-southeast-1.tfvars" -out=tfplan-eks
terraform apply "tfplan-eks"
terraform destroy -auto-approve -var-file="config/ap-southeast-1.tfvars"

Importing KubeConfig
aws eks update-kubeconfig --name demo-eks-cluster --region ap-southeast-1

Kubernetes Commands
kubectl config get-contexts
kubectl config current-context
kubectl config use-context <context>
kubectl config set-context --current --namespace=my-team

kubectl run nginx-pod --image=nginx --port=80
kubectl expose pod nginx-pod --port=80 --target-port=80 --type=LoadBalancer --name=nginx-service
kubectl get pods
kubectl describe pod nginx-pod
kubectl get service
kubectl describe service nginx-service
kubectl delete pod nginx-pod

kubectl create deployment nginx-deploy --image=nginx
kubectl get pods
kubectl describe pod <pod_name>
kubectl expose deployment nginx-deploy --port=80 --type=LoadBalancer