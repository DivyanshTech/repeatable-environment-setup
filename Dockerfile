FROM python:3.12-slim


WORKDIR /app

COPY service/ /app/

ENV APP_HOST=0.0.0.0
ENV APP_PORT=8000

RUN useradd --create-home --uid 10001 appuser

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/', timeout=2)"]

CMD ["python", "server.py"]
