# Task 8.1P Evidence Commands

Run these commands from the `week08` directory. Replace bracketed values where required. Never capture secret values.

## Before deployment

```bash
git remote -v
git rev-parse HEAD
terraform -chdir=terraform validate
terraform -chdir=terraform plan -out=task81p.tfplan
terraform -chdir=terraform apply task81p.tfplan
```

## Infrastructure

```bash
az resource list --resource-group koalatech-8-1p-rg -o table
az aks get-credentials --resource-group koalatech-8-1p-rg --name koalatech-week08-aks --overwrite-existing
kubectl get nodes -o wide
```

## ACR

```bash
az acr repository list --name koalatech2314956acr -o table
az acr repository show-tags --name koalatech2314956acr --repository koalatech-frontend -o table
```

## Staging

```bash
kubectl get pods,services,pvc,deployments -n staging
kubectl get deployment frontend -n staging -o jsonpath='{.spec.template.spec.containers[0].image}'; echo
kubectl get service frontend -n staging -o jsonpath='{.status.loadBalancer.ingress[0].ip}'; echo
```

## Production

```bash
kubectl get pods,services,pvc,deployments -n production
echo "STAGING:"
kubectl get deployment frontend -n staging -o jsonpath='{.spec.template.spec.containers[0].image}'; echo
echo "PRODUCTION:"
kubectl get deployment frontend -n production -o jsonpath='{.spec.template.spec.containers[0].image}'; echo
kubectl get service frontend -n production -o jsonpath='{.status.loadBalancer.ingress[0].ip}'; echo
```

## Cleanup—only after all other evidence

```bash
terraform -chdir=terraform plan -destroy -out=destroy.tfplan
terraform -chdir=terraform apply destroy.tfplan
az resource list --resource-group koalatech-8-1p-rg -o table
```
