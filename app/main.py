from fastapi import FastAPI

app = FastAPI(title="Production AWS CI/CD Demo")


@app.get("/")
def root():
    return {
        "message": "Production-ready AWS CI/CD pipeline demo!",
        "status": "running"
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy"
    }


@app.get("/api/version")
def version():
    return {
        "app": "aws-cicd-demo",
        "version": "1.0.0",
        "environment": "dev"
    }