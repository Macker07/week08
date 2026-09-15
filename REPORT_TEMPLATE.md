# SIT722 Task 8.1P — Continuous Delivery Using GitHub Actions

**Student:** [Name]  
**Student ID:** [ID]  
**Repository:** [GitHub URL]  
**Tested commit SHA:** `[SHA]`

## Introduction

This practical implements a continuous delivery pipeline for the KoalaTech microservices application. GitHub Actions performs integration testing and artifact publication, Azure Container Registry (ACR) stores immutable SHA-tagged images, and Azure Kubernetes Service (AKS) hosts separate staging and production environments. Terraform provides the Azure infrastructure as code.

# Part A — Workflow Analysis

## Pipeline overview

The pipeline is divided into four workflows so that artifact creation, staging deployment, post-deployment validation, and production promotion have clear responsibilities. The Docker images are tagged with the source commit SHA. That identifier provides traceability and allows production to reuse exactly the artifacts validated in staging.

| Workflow | Trigger | Responsibility | Result |
|---|---|---|---|
| `01 - CI` | Push to `main` or manual dispatch | Test five backend services, build six Docker images, and push them to ACR | SHA-tagged deployable artifacts |
| `02 - Deploy to Staging` | Successful completion of `01 - CI` on `main` | Deploy the CI commit to the `staging` namespace and wait for rollouts | Running staging release |
| `03 - Test Staging` | Successful completion of `02 - Deploy to Staging` | Test the frontend and a backend health endpoint through the frontend proxy | Validated staging release |
| `04 - Deploy to Production` | Manual dispatch with a full commit SHA | Validate and deploy the already-built SHA-tagged images to `production` | Manually promoted production release |

## Continuous Integration

The CI workflow uses a matrix to test `user-service`, `student-service`, `lecturer-service`, `course-service`, and `enrollment-service`. Each test job starts an isolated PostgreSQL 16 database, checks out the source, installs Python 3.12 dependencies, and runs pytest. The build-and-push matrix depends on all tests succeeding. It builds the frontend and five backend images and publishes each image to ACR with `${{ github.sha }}` as its tag. A failed test therefore prevents publication of a candidate release.

## Staging deployment and validation

The staging workflow is triggered by the successful CI workflow and checks out `workflow_run.head_sha`, ensuring it uses the tested revision. It creates the namespace and Kubernetes secrets, applies staging manifests, updates each deployment to its SHA-tagged ACR image, and waits for rollouts. The next workflow waits for the frontend LoadBalancer address and tests both the frontend document and `/api/users/health`. This distinguishes Kubernetes accepting a deployment from the deployed application actually responding.

## Production deployment

Production is intentionally manual. The operator supplies the full SHA that passed staging. The workflow validates its format, checks out that exact revision, and updates production deployments to existing ACR images with the supplied tag. It does not rebuild images. This prevents differences between the artifact tested in staging and the artifact released to production.

## Separation of CI and CD

CI verifies source changes and produces versioned artifacts. CD consumes those artifacts and moves them through staging validation and controlled production promotion. Keeping these responsibilities separate makes failures easier to locate and prevents deployment from beginning before integration tests pass.

## Multiple environments

Staging and production use different GitHub Environments, environment-scoped secrets, Kubernetes namespaces, and manifest directories. Staging deployment is automatic, while production is manual. The environment separation allows independent configuration and data while the shared SHA proves artifact continuity.

## Comparison with Chapter 8, Example 3

Chapter 8, Example 3 also uses GitHub Actions to automate deployment of a microservice to Kubernetes. It develops automation after first establishing a manual deployment, authenticates `kubectl`, and supplies configuration through GitHub secrets and context variables. Both approaches treat a source-control event as the entry point for repeatable automation and keep sensitive configuration outside the repository.

The Week 08 solution extends that basic microservice deployment into an explicit multi-environment delivery chain. It tests five backend services, publishes six images to ACR, deploys automatically to staging, performs a post-deployment smoke test, and requires manual promotion of the same SHA to production. The chapter also warns that direct production deployment is dangerous; the Week 08 staging gate and manual production workflow directly address that risk. The most important similarity is automated Kubernetes deployment using GitHub Actions and protected configuration. The most important difference is Week 08's separate staging validation and artifact-promotion process rather than one direct deployment workflow.

# Part B — Pipeline Demonstration

## Infrastructure

**Figure 1.** [Insert successful Terraform apply screenshot.]  
Terraform created ACR, AKS with three nodes, Azure Storage, two private blob containers, and the AKS-to-ACR pull assignment.

**Figure 2.** [Insert Azure Resource Group screenshot.]  
The Azure resource inventory confirms that the infrastructure declared in Terraform exists.

**Figure 3.** [Insert `kubectl get nodes` screenshot.]  
All three AKS nodes report `Ready`, satisfying the capacity requirement for staging and production database workloads.

## Continuous Integration and ACR publication

I made the following small change to trigger CI: [describe change]. The change was committed and pushed to `main`.

**Figure 4.** [Insert overall `01 - CI` screenshot.]  
The CI run shows successful test and build matrices for the tested commit.

**Figure 5.** [Insert expanded pytest step.]  
The automated backend tests passed against the workflow's isolated PostgreSQL service.

**Figure 6.** [Insert expanded Docker build/push step.]  
The workflow built and published a commit-SHA-tagged image only after tests succeeded.

**Figure 7.** [Insert ACR repositories and tag evidence.]  
ACR contains the six application repositories, and the displayed tag matches the tested commit SHA.

## Staging deployment and validation

**Figure 8.** [Insert successful `02 - Deploy to Staging` screenshot.]  
The workflow automatically deployed the exact CI revision and completed all rollout checks.

**Figure 9.** [Insert staging pods/services/PVC output.]  
The staging namespace contains ready application and database pods, a frontend external address, and bound persistent volumes.

**Figure 10.** [Insert successful `03 - Test Staging` screenshot.]  
The automated validation confirmed both frontend reachability and backend health through the reverse proxy.

**Figure 11.** [Insert staging browser functionality screenshot.]  
The application loaded at the staging address and [describe login/list/create action], demonstrating frontend-to-backend communication.

## Production promotion and verification

**Figure 12.** [Insert manual workflow form with SHA.]  
The tested SHA was explicitly selected for controlled production promotion.

**Figure 13.** [Insert successful `04 - Deploy to Production` screenshot.]  
The workflow deployed the existing images without rebuilding them and completed all production rollouts.

**Figure 14.** [Insert production resources and staging/production SHA comparison.]  
Production resources are ready, and the image references prove that staging and production use the same SHA.

**Figure 15.** [Insert production browser functionality screenshot.]  
The production frontend loaded and [describe backend-driven action], confirming that the promoted release is operational.

# Part C — Reflection

Continuous Integration focuses on frequently combining and validating changes. In this project it runs backend tests, builds containers, and publishes traceable artifacts. Continuous Delivery begins with those verified artifacts and keeps them deployable by progressing them through staging and validation. The final production decision remains manual, so this is continuous delivery rather than uncontrolled automatic production deployment.

Staging provides a production-like checkpoint isolated from users and production data. It can reveal image-pull, secret, networking, storage, database, and application-startup problems that unit tests cannot. Testing the exact SHA in staging also gives meaning to the later production promotion.

GitHub Actions makes the process repeatable and auditable. Source events trigger consistent jobs, dependencies enforce ordering, matrices avoid duplicated configuration, logs retain evidence, and GitHub Environments scope secrets and deployment controls. Automating these steps reduces manual mistakes while retaining a deliberate production gate.

# Part D — Resource Cleanup

**Figure 16.** [Insert successful Terraform destroy screenshot.]  
Terraform removed every task resource it managed after all deployment evidence had been captured.

**Figure 17.** [Insert empty resource-group CLI/Portal evidence.]  
The final Azure inventory confirms that no task resources remain, preventing continued cloud consumption.

## References

Davis, A. (2024). *Bootstrapping Microservices with Docker, Kubernetes, GitHub Actions, and Terraform* (2nd ed.). Manning Publications.
