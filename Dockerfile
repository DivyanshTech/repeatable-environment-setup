FROM python:3.12-slim

WORKDIR /app

COPY service/ /app/

ENV APP_HOST=0.0.0.0
ENV APP_PORT=8000

EXPOSE 8000

CMD ["python", "server.py"]
