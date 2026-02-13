from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class Payload(BaseModel):
    text: str

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/test-post")
def run(payload: Payload):
    # Minimal example: reverse the input text
    return {"result": f"{payload.text} -> {payload.text[::-1]}"}

class MultiplyPayload(BaseModel):
    a: float
    b: float

@app.post("/multiply")
def multiply(payload: MultiplyPayload):
    return {"result": payload.a * payload.b}
