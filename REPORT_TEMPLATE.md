# SIT722 Task 9.3C — Continuous Deployment Using GitHub Actions

**Student:** [Name]  
**Student ID:** [ID]  
**Repository:** [GitHub URL]  
**Deployed commit SHA:** `[40-character SHA]`

## 1. Introduction

This task extends the Task 8.1P Continuous Integration pipeline with Continuous Deployment. GitHub Actions tests the KoalaTech application, publishes immutable SHA-tagged images to Azure Container Registry (ACR), deploys them to Azure Kubernetes Service (AKS) staging, validates staging, and automatically deploys the same tested artifacts to production.

## 2. Existing CI Pipeline and CD Changes

The Task 8.1P CI workflow was retained for frontend/backend tests and container publication. The deployment extension adds authenticated AKS access, environment-scoped secrets, staging and production namespaces, staging smoke tests, automatic production deployment, and rollout verification.

| Workflow/job | Trigger | Responsibility |
|---|---|---|
| `01 - CI` | Pull request and push to `main` | Test the frontend and five backend services; on `main`, build and push six SHA-tagged images |
| `02 - Deploy to Staging` | Successful `01 - CI` run on `main` | Deploy the tested SHA to staging and verify rollouts |
| Staging smoke test in `03` | Successful staging deployment | Test the frontend and backend health endpoint |
| Production job in `03` | Successful staging smoke test | Automatically deploy the same tested SHA to production and verify rollouts |
| `04 - Deploy to Production` | Manual dispatch | Recovery/redeployment only; not used in the demonstration |

The production job does not rebuild images. It verifies the six SHA-tagged images in ACR and deploys those exact artifacts.

**Figure 1.** [Existing Task 8.1P CI workflow.]
**Figure 2.** [Task 9.3C workflow/configuration changes, including the automatic production dependency.]

## 3. Azure Deployment Environment

Terraform provides ACR, a three-node AKS cluster, Azure Storage, private blob containers, and the AKS-to-ACR pull role assignment. Staging and production use separate GitHub Environments, Kubernetes namespaces, secrets, manifests, databases, and persistent volumes.

**Figure 3.** [Successful Terraform apply.]

**Figure 4.** [Azure resource inventory.]
**Figure 5.** [`kubectl get nodes` showing three Ready nodes.]

## 4. Automated Deployment Demonstration

### 4.1 Original production application

Before changing the code, I recorded the original production frontend: [describe the original visible text or colour].

**Figure 6.** [Original production UI with URL/address visible.]

### 4.2 Frontend change and pull request

On branch `[branch]`, I changed [file and visible heading/text/colour]. I pushed the branch and opened a pull request to `main`.

**Figure 7.** [Frontend code diff.]
**Figure 8.** [Pull request before merge.]

### 4.3 CI, ACR, and staging

After the pull request checks passed and the PR was merged, `01 - CI` tested the merge commit and published six images tagged `[SHA]`. `02 - Deploy to Staging` deployed that SHA, and `03 - Validate Staging and Deploy Production` verified the frontend and `/api/users/health` endpoint.

**Figure 9.** [Successful PR checks and merge commit.]

**Figure 10.** [Successful CI test/build matrices.]

**Figure 11.** [ACR repositories/tags matching the merge SHA.]

**Figure 12.** [Staging resources and deployed image SHA.]
**Figure 13.** [Successful staging smoke-test steps.]

### 4.4 Automatic production deployment

The successful smoke-test job automatically started the dependent production job. It reused the staging-tested SHA, applied the production configuration, and waited for all six application rollouts. I did not manually deploy the demonstration change.

**Figure 14.** [Workflow graph showing smoke test followed by production.]

**Figure 15.** [Successful production rollout and image evidence.]

**Figure 16.** [Staging and production image references showing the same SHA.]
**Figure 17.** [Updated production UI with URL/address visible.]

## 5. Reflection

CI validates changes and creates traceable artifacts. CD consumes those artifacts and moves them automatically through staging validation into production. Staging catches deployment, secret, networking, storage, database, and startup failures that source-level tests may miss. The smoke-test dependency prevents a failed staging release from being promoted, while immutable SHA tags prevent production from receiving an untested rebuild.

## 6. Resource Cleanup

After collecting all other evidence, I ran Terraform destroy, deleted the resource group, and verified that it no longer existed.

**Figure 18.** [Successful Terraform destroy.]
**Figure 19.** [`az group exists --name <RESOURCE_GROUP>` returning `false` or equivalent Portal evidence.]

## 7. Conclusion

The merged frontend change progressed from CI through ACR and staging validation to production without a manual deployment. Production displayed the visible change and ran the exact image SHA tested in staging. All task Azure resources were then removed.

## References

Davis, A. (2024). *Bootstrapping Microservices with Docker, Kubernetes, GitHub Actions, and Terraform* (2nd ed.). Manning Publications.
