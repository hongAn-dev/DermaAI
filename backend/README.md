# DermaAI Backend Server

This folder contains the Python backend server for the DermaAI application.

## Prerequisites

- Python 3.8+
- pip

## Setup

1.  Navigate to this directory:
    ```bash
    cd backend
    ```

2.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```

3.  **IMPORTANT:** Place your trained model file `skin_vgg16_model.keras` in this `backend` directory.
    - If you do not have this file, the server will start but will return an error when trying to analyze images.

## Running the Server

Run the server using uvicorn:

```bash
python server.py
```
Or directly:
```bash
uvicorn server:app --reload --host 0.0.0.0 --port 8000
```

The server will be available at `http://localhost:8000`.
- Android Emulator connects via `http://10.0.2.2:8000`.
- iOS Simulator / Web connects via `http://localhost:8000`.

## API Endpoints

-   `GET /`: Health check.
-   `POST /explain`: Analyze an image. Expects a `file` multipart upload.
