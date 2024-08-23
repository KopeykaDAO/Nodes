FROM python:3.11-slim

WORKDIR /app

COPY request_gaia.py /app/request_gaia.py
COPY requirements.txt /app/requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "/app/request_gaia.py"]
