import os
from fastapi import FastAPI, HTTPException
from fastapi.responses import PlainTextResponse
from pydantic import BaseModel
import json

# Try to import llama_cpp, but don't fail if it's not available yet
try:
    from llama_cpp import Llama
    LLAMA_AVAILABLE = True
except ImportError:
    Llama = None
    LLAMA_AVAILABLE = False

MODEL_PATH = os.getenv("MODEL_PATH", "/model")
VERSION_FILE = os.path.join(MODEL_PATH, "model", "version.txt")
MODEL_FILE = os.path.join(MODEL_PATH, "model", "qwen2-0_5b-instruct-q4_k_m.gguf")

# Global model instance
llm = None

class ChatRequest(BaseModel):
    message: str
    max_tokens: int = 100
    temperature: float = 0.7

class ChatResponse(BaseModel):
    response: str
    model_version: str

app = FastAPI(title="ModelKit Demo API", version="1.0.0")

def load_model():
    global llm
    if not LLAMA_AVAILABLE:
        print("llama-cpp-python not available yet, model loading will be retried later")
        return
    
    if llm is None and os.path.exists(MODEL_FILE):
        try:
            llm = Llama(
                model_path=MODEL_FILE,
                n_ctx=2048,  # Context window
                n_threads=4,  # Number of CPU threads
                verbose=False
            )
            print(f"Model loaded successfully from {MODEL_FILE}")
        except Exception as e:
            print(f"Error loading model: {e}")
            llm = None

@app.on_event("startup")
async def startup_event():
    load_model()

@app.get("/health")
def health(): 
    model_exists = os.path.exists(MODEL_FILE)
    return {
        "ok": True, 
        "model_loaded": llm is not None, 
        "model_available": model_exists, 
        "model_path": MODEL_FILE,
        "llama_available": LLAMA_AVAILABLE
    }

@app.get("/version", response_class=PlainTextResponse)
def version():
    try:
        with open(VERSION_FILE, "r") as f:
            return f.read().strip()
    except FileNotFoundError:
        return "UNKNOWN"

@app.post("/chat", response_model=ChatResponse)
def chat(request: ChatRequest):
    if not LLAMA_AVAILABLE:
        model_version = version()
        return ChatResponse(
            response=f"llama-cpp-python is still being installed. Please wait a few minutes and try again. Your question was: '{request.message}'",
            model_version=model_version
        )
    
    if llm is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    try:
        # Format the prompt for Qwen2 instruct model
        prompt = f"<|im_start|>user\n{request.message}<|im_end|>\n<|im_start|>assistant\n"
        
        # Generate response
        response = llm(
            prompt,
            max_tokens=request.max_tokens,
            temperature=request.temperature,
            stop=["<|im_end|>", "<|im_start|>"]
        )
        
        # Extract the response text
        response_text = response['choices'][0]['text'].strip()
        
        # Get model version
        model_version = version()
        
        return ChatResponse(
            response=response_text,
            model_version=model_version
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating response: {str(e)}")

@app.get("/model/info")
def model_info():
    if not LLAMA_AVAILABLE:
        return {
            "loaded": False, 
            "error": "llama-cpp-python not available yet", 
            "model_available": os.path.exists(MODEL_FILE),
            "status": "Installing llama-cpp-python..."
        }
    
    if llm is None:
        return {"loaded": False, "error": "Model not loaded", "model_available": os.path.exists(MODEL_FILE)}
    
    return {
        "loaded": True,
        "model_path": MODEL_FILE,
        "context_size": llm.n_ctx(),
        "version": version()
    }