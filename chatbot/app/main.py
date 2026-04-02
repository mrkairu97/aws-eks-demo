import os
import json
import boto3
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel

app = FastAPI(title="LLM Chatbot POC", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Config from environment variables
AWS_REGION = os.getenv("AWS_REGION", "ap-southeast-1")
MODEL_ID = os.getenv("BEDROCK_MODEL_ID", "anthropic.claude-opus-4-6-20250528-v1:0")

bedrock = boto3.client("bedrock-runtime", region_name=AWS_REGION)


class ChatRequest(BaseModel):
    message: str
    system_prompt: str = "You are a helpful enterprise assistant."


class ChatResponse(BaseModel):
    response: str
    model: str


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/chat", response_model=ChatResponse)
def chat(req: ChatRequest):
    try:
        body = {
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 1024,
            "system": req.system_prompt,
            "messages": [
                {"role": "user", "content": req.message}
            ],
        }

        response = bedrock.invoke_model(
            modelId=MODEL_ID,
            body=json.dumps(body),
            contentType="application/json",
            accept="application/json",
        )

        result = json.loads(response["body"].read())
        reply = result["content"][0]["text"]

        return ChatResponse(response=reply, model=MODEL_ID)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# Serve frontend
app.mount("/static", StaticFiles(directory="static"), name="static")


@app.get("/")
def serve_frontend():
    return FileResponse("static/index.html")
