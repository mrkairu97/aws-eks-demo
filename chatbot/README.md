# Chatbot POC — Claude Opus on EKS via Amazon Bedrock
### AWS Security User Group PH — Apr 28

LLM-powered chatbot deployed on EKS with a built-in chat UI. Compares Lambda vs EKS deployment latency side by side.

---

## Architecture

```
         ┌─────────────────────────────────────────┐
         │           Amazon Bedrock                │
         │          (Claude Opus)                  │
         └────────────────┬────────────────────────┘
                          │ InvokeModel
          ┌───────────────┴───────────────┐
          │                               │
  ┌───────▼────────┐             ┌────────▼───────┐
  │   OPTION A     │             │   OPTION B     │
  │    Lambda      │             │     EKS        │
  │  + API Gateway │             │  + ALB Ingress │
  └───────┬────────┘             └────────┬───────┘
          │                               │
          └───────────────┬───────────────┘
                          │
                    Browser (Chat UI)
```

---

## File Structure

```
├── chatbot/
│   ├── app/
│   │   ├── main.py              # FastAPI app + frontend serving
│   │   ├── requirements.txt     # Python dependencies
│   │   └── static/
│   │       └── index.html       # Chat UI (Lambda vs EKS toggle + latency scoreboard)
│   ├── Dockerfile               # Container image for EKS deployment
│   └── README.md
├── helm/chatbot/                # Helm chart
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── _helpers.tpl
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── ingress.yaml
│       └── hpa.yaml
├── modules/k8s/main.tf          # IRSA role + service account (Terraform)
└── .github/workflows/
    └── deploy-chatbot.yaml      # GitHub Actions (build + helm deploy)
```

---

## Prerequisites

- EKS cluster running (use the root Terraform in this repo)
- AWS Load Balancer Controller installed
- Bedrock model access enabled for **Claude Opus** in `ap-southeast-1`
- ECR repository created

---

## Deploy

### Step 1 — Terraform (IAM + Service Account)

The IRSA role and namespace are managed in `modules/k8s/main.tf`. Apply Terraform:

```bash
terraform plan -var-file="config/ap-southeast-1.tfvars" -out=tfplan
terraform apply tfplan
```

This creates:
- `chatbot-poc` namespace
- `chatbot-sa` service account with Bedrock permissions
- IAM role with `bedrock:InvokeModel` access

### Step 2 — Deploy via GitHub Actions

1. Go to **Actions** → **Deploy Chatbot POC** → **Run workflow**
2. Select `deploy` → **Run**
3. The workflow builds the Docker image, pushes to ECR, and deploys via Helm
4. ALB URL is printed in the logs

### Or deploy manually

```bash
# Create ECR repo (first time only)
aws ecr create-repository --repository-name chatbot-poc --region ap-southeast-1

# Build and push
aws ecr get-login-password --region ap-southeast-1 | \
  docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.ap-southeast-1.amazonaws.com

docker build -t chatbot-poc ./chatbot
docker tag chatbot-poc:latest <ACCOUNT_ID>.dkr.ecr.ap-southeast-1.amazonaws.com/chatbot-poc:latest
docker push <ACCOUNT_ID>.dkr.ecr.ap-southeast-1.amazonaws.com/chatbot-poc:latest

# Deploy with Helm
helm upgrade --install chatbot ./helm/chatbot \
  --namespace chatbot-poc \
  --set image.repository=<ACCOUNT_ID>.dkr.ecr.ap-southeast-1.amazonaws.com/chatbot-poc \
  --set image.tag=latest
```

---

## Live Demo Flow

1. Show architecture slide
2. Run GitHub Actions workflow → deploy live
3. Open browser → chat with Claude Opus in real time
4. Toggle between Lambda and EKS in the UI — compare latency
5. `kubectl scale deployment chatbot -n chatbot-poc --replicas=5` — show scaling
