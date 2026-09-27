# Auth Service CI/CD POC

A proof-of-concept CI/CD pipeline for an authentication service, including containerization, GitHub Actions, Docker Hub, environment-specific configuration, Nomad namespaces, Vault secret paths, and PostgreSQL databases.

## Architecture Overview

```text
Developer
   │
   ▼
GitHub Repository
   │
   ▼
GitHub Actions
   │
   ├── Install Dependencies
   ├── Start Auth Service
   ├── Health Check
   │
   └── Docker Build & Push
             │
             ▼
        Docker Hub
             │
             ▼
      Nomad Environment
       ┌─────┼─────┐
       ▼     ▼     ▼
      Dev  Staging Prod

Supporting Infrastructure
        │
        ├── Vault
        │    ├── secret/ai-service/dev
        │    ├── secret/ai-service/staging
        │    └── secret/ai-service/prod
        │
        └── PostgreSQL
             ├── glynac_auth_dev
             ├── glynac_auth_staging
             └── glynac_auth_prod
```

---

## 1. Project Objectives

The objective of this POC was to create a CI/CD setup for an authentication service and prepare environment-specific infrastructure for development, staging, and production.

### Key objectives

* Build a simple authentication service.
* Containerize the service using Docker.
* Build an automated GitHub Actions CI pipeline.
* Build and push the Docker image to Docker Hub.
* Configure GitHub Environments for `dev`, `staging`, and `prod`.
* Configure environment-specific variables and secrets.
* Create Nomad namespaces for AI and BE services.
* Configure Nomad ACL policies and environment-specific tokens.
* Create Vault secret paths for each AI service environment.
* Create PostgreSQL databases and users for authentication environments.
* Deploy the auth service to the local Nomad development environment.

---

## 2. Technology Stack

| Component               | Technology      |
| ----------------------- | --------------- |
| Application             | Node.js         |
| Framework               | Express.js      |
| Containerization        | Docker          |
| CI/CD                   | GitHub Actions  |
| Container Registry      | Docker Hub      |
| Orchestration           | HashiCorp Nomad |
| Secrets Management      | HashiCorp Vault |
| Database                | PostgreSQL      |
| Development Environment | WSL / Ubuntu    |

---

## 3. Auth Service

A lightweight Express.js service was created with two endpoints.

### Application endpoint

```text
GET /
```

Returns the service status.

### Health endpoint

```text
GET /health
```

Returns:

```json
{
  "status": "healthy"
}
```

### Local verification

The application was tested locally before containerization.

**📸 Screenshot 1 — Add here**

> Screenshot showing the terminal with the auth service running successfully and the `/health` endpoint returning `{"status":"healthy"}`.

---

## 4. Docker Containerization

The service was containerized using a Node.js Alpine base image.

### Docker build

```bash
docker build -t auth-service-cicd-poc .
```

### Run container

```bash
docker run -d --name auth-service -p 3001:3000 auth-service-cicd-poc
```

### Container verification

The container was verified using the health endpoint.

```bash
curl http://localhost:3001/health
```

Expected response:

```json
{
  "status": "healthy"
}
```

**📸 Screenshot 2 — Add here**

> Screenshot showing `docker ps` with the `auth-service` container running.

---

## 5. Docker Hub

The application image was published to Docker Hub.

```text
ramzan11/auth-service-cicd-poc:latest
```

### Image workflow

```text
Source Code
    │
    ▼
Docker Build
    │
    ▼
Docker Image
    │
    ▼
Docker Hub
```

The image was also pulled successfully from Docker Hub to verify that the published image was available.

```bash
docker pull ramzan11/auth-service-cicd-poc:latest
```

**📸 Screenshot 3 — Add here**

> Screenshot of the Docker Hub repository showing `auth-service-cicd-poc` and the `latest` image/tag.

---

## 6. GitHub Actions CI/CD

A GitHub Actions workflow was created at:

```text
.github/workflows/ci-cd.yml
```

The workflow performs:

1. Checkout source code.
2. Setup Node.js 20.
3. Install dependencies using `npm ci`.
4. Start the auth service.
5. Run the `/health` endpoint check.
6. Build the Docker image.
7. Login to Docker Hub.
8. Push the image to Docker Hub.

### Pipeline flow

```text
Push / Pull Request
        │
        ▼
   GitHub Actions
        │
        ▼
   Install Dependencies
        │
        ▼
   Start Application
        │
        ▼
    Health Check
        │
        ▼
    Docker Build
        │
        ▼
    Docker Hub Push
```

**📸 Screenshot 4 — Add here**

> Screenshot of a successful GitHub Actions workflow run showing both `test` and `docker` jobs completed successfully.

---

## 7. GitHub Environments

Three GitHub Environments were configured:

```text
dev
staging
prod
```

### Environment configuration

| Variable              | Dev                          | Staging                     | Prod                     |
| --------------------- | ---------------------------- | --------------------------- | ------------------------ |
| `NOMAD_ADDR`          | `http://your-nomad-dev:4646` | `http://your-nomad:4646`    | `http://your-nomad:4646` |
| `NOMAD_NAMESPACE`     | `ai-service-dev`             | `ai-service-staging`        | `ai-service-prod`        |
| `VAULT_SECRET_PREFIX` | `secret/ai-service/dev`      | `secret/ai-service/staging` | `secret/ai-service/prod` |
| `DOCKERHUB_USERNAME`  | `ramzan11`                   | `ramzan11`                  | `ramzan11`               |

The `NOMAD_TOKEN` secret was configured separately for each environment.

> **Security:** Secret values and access tokens are intentionally not documented or displayed in this README.

### Environment protection

* `dev`: No protection rules.
* `staging`: Required reviewers — pending manager GitHub username.
* `prod`: Required reviewers + required approval — pending manager GitHub username.

**📸 Screenshot 5 — Add here**

> Screenshot showing the three GitHub Environments (`dev`, `staging`, `prod`) in the repository settings.

**Do NOT screenshot the actual secret values.**

---

## 8. Nomad Infrastructure

Nomad was configured with separate namespaces for AI and backend services.

### AI service namespaces

```text
ai-service-dev
ai-service-staging
ai-service-prod
```

### BE service namespaces

```text
be-service-dev
be-service-staging
be-service-prod
```

### Final namespace list

```text
ai-service-dev
ai-service-staging
ai-service-prod

be-service-dev
be-service-staging
be-service-prod
```

**📸 Screenshot 6 — Add here**

> Screenshot of `nomad namespace list` showing all six required service namespaces.

---

## 9. Nomad ACL Configuration

Environment-specific Nomad ACL policies and tokens were created for the AI service environments.

Example policy structure:

```hcl
namespace "ai-service-dev" {
  policy = "write"
}

agent {
  policy = "read"
}
```

Equivalent environment-specific policies were created for:

```text
ai-service-dev
ai-service-staging
ai-service-prod
```

Environment-specific `NOMAD_TOKEN` secrets were then configured in GitHub.

> **Security:** Actual Nomad tokens are never committed to the repository.

---

## 10. Auth Service Deployment on Nomad

The auth service Docker image was deployed to the local Nomad development environment using:

```text
Namespace: ai-service-dev
Job: auth-service
Type: service
```

The deployment used the Docker Hub image:

```text
ramzan11/auth-service-cicd-poc:latest
```

### Deployment verification

The Nomad deployment completed successfully with:

```text
Status        = running
Deployment    = successful
Healthy       = 1
Unhealthy     = 0
```

The allocation was also verified as running.

**📸 Screenshot 7 — Add here**

> Screenshot of `nomad job status -namespace=ai-service-dev auth-service` showing the deployment as running and healthy.

---

## 11. Vault Configuration

Vault was configured with environment-specific secret paths for the authentication service.

### Secret paths

```text
secret/ai-service/dev
secret/ai-service/staging
secret/ai-service/prod
```

Each environment contains its corresponding database configuration.

> **Security:** Passwords, tokens, and other secret values are not committed to GitHub or documented in this README.

**📸 Screenshot 8 — Add here**

> Screenshot showing the Vault secret paths/listing only. Do not show secret values or passwords.

---

## 12. PostgreSQL Configuration

Separate PostgreSQL databases were created for the authentication service environments.

### Databases

```text
glynac_auth_dev
glynac_auth_staging
glynac_auth_prod
```

Environment-specific database users were also created.

The database connections were verified using PostgreSQL client tools.

**📸 Screenshot 9 — Add here**

> Screenshot showing the PostgreSQL database list with the three `glynac_auth_*` databases. Avoid showing passwords.

---

## 13. Verification Summary

| Area                              | Status                            |
| --------------------------------- | --------------------------------- |
| Auth service                      | ✅ Complete                        |
| Docker containerization           | ✅ Complete                        |
| Docker Hub image                  | ✅ Complete                        |
| GitHub Actions CI                 | ✅ Complete                        |
| GitHub Actions Docker push        | ✅ Complete                        |
| GitHub `dev` environment          | ✅ Complete                        |
| GitHub `staging` environment      | ✅ Created                         |
| GitHub `prod` environment         | ✅ Created                         |
| Environment variables             | ✅ Complete                        |
| Environment `NOMAD_TOKEN` secrets | ✅ Complete                        |
| AI service namespaces             | ✅ Complete                        |
| BE service namespaces             | ✅ Complete                        |
| Nomad ACL policies/tokens         | ✅ Complete                        |
| Local Nomad deployment            | ✅ Running                         |
| Vault secret paths                | ✅ Complete                        |
| PostgreSQL databases              | ✅ Complete                        |
| Staging required reviewers        | ⏳ Pending manager GitHub username |
| Prod required reviewers           | ⏳ Pending manager GitHub username |

---

## 14. Security Considerations

The following security practices were followed during the POC:

* Secrets are stored in GitHub Environment Secrets rather than source code.
* Nomad tokens are not committed to Git.
* Vault passwords are not committed to Git.
* Database passwords are not documented in the repository.
* Docker Hub authentication uses a GitHub secret.
* Environment-specific configuration is separated through GitHub Environments.

---

## 15. Repository Structure

```text
auth-service-cicd-poc/
│
├── src/
│   └── server.js
│
├── nomad/
│   ├── auth-service-dev.nomad
│   ├── ai-service-dev.hcl
│   ├── ai-service-staging.hcl
│   └── ai-service-prod.hcl
│
├── .github/
│   └── workflows/
│       └── ci-cd.yml
│
├── Dockerfile
├── .dockerignore
├── package.json
├── package-lock.json
└── README.md
```

---

## 16. Conclusion

This POC establishes the core infrastructure and CI/CD foundation for the auth service across development, staging, and production environments.

The implementation covers application containerization, automated CI validation, Docker image publishing, environment-specific GitHub configuration, Nomad namespaces and ACLs, Vault secret paths, PostgreSQL environment databases, and local Nomad deployment verification.

The remaining GitHub Environment protection configuration requires the correct manager GitHub username for the staging and production required-reviewer settings.

