# INTENTIONALLY WEAK (Lab 4): old base image, runs as root, no pinned digest
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .

EXPOSE 5000
RUN useradd -m appuser
USER appuser
CMD ["python", "app/app.py"]
