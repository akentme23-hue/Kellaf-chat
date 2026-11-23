from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(title="Kellaf Chat Server", version="1.0.0")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"], allow_credentials=True)

class Register(BaseModel):
    name: str
    username: str

users: dict[str, dict] = {}
connections: dict[str, list[WebSocket]] = {}

@app.get("/health")
def health():
    return {"status": "ok", "service": "Kellaf Chat"}

@app.post("/api/auth/register")
def register(payload: Register):
    if payload.username in users:
        return {"ok": False, "error": "username exists"}
    users[payload.username] = {"name": payload.name, "username": payload.username}
    return {"ok": True, "user": users[payload.username]}

@app.websocket("/ws/{username}")
async def websocket_chat(websocket: WebSocket, username: str):
    await websocket.accept()
    connections.setdefault(username, []).append(websocket)
    try:
        while True:
            data = await websocket.receive_text()
            for group in connections.values():
                for connection in group:
                    await connection.send_text(data)
    except WebSocketDisconnect:
        connections[username].remove(websocket)
