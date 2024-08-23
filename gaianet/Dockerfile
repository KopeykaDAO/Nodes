FROM python:3.11-slim

WORKDIR /app

COPY request_gaia.py /app/request_gaia.py

RUN pip install requests
RUN pip install faker

CMD ["python", "/app/request_gaia.py"]
