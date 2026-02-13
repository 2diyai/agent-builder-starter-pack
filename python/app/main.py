from fastapi import FastAPI, File, HTTPException, UploadFile
from io import BytesIO
from openpyxl import load_workbook
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

@app.post("/upload-excel")
async def upload_excel(file: UploadFile = File(...)):
    if not file.filename:
        raise HTTPException(status_code=400, detail="Missing file name")

    allowed_extensions = (".xlsx", ".xlsm", ".xltx", ".xltm")
    if not file.filename.lower().endswith(allowed_extensions):
        raise HTTPException(
            status_code=400,
            detail="Only modern Excel files are supported (.xlsx, .xlsm, .xltx, .xltm)",
        )

    file_bytes = await file.read()
    if not file_bytes:
        raise HTTPException(status_code=400, detail="Uploaded file is empty")

    try:
        workbook = load_workbook(filename=BytesIO(file_bytes), data_only=True)
    except Exception as error:
        raise HTTPException(status_code=400, detail=f"Invalid Excel file: {error}")

    sheets = []
    for sheet_name in workbook.sheetnames:
        worksheet = workbook[sheet_name]
        sheets.append(
            {
                "name": sheet_name,
                "max_row": worksheet.max_row,
                "max_column": worksheet.max_column,
            }
        )

    return {
        "filename": file.filename,
        "sheet_count": len(workbook.sheetnames),
        "sheets": sheets,
    }

