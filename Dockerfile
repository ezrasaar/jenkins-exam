FROM python:3.14-slim AS builder

WORKDIR /build
COPY requirements.txt .

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN python -m pip install --no-cache-dir -r requirements.txt

FROM builder AS dev

WORKDIR /app
RUN python -m pip install --no-cache-dir pytest
COPY app/ ./app/

CMD ["python", "-m", "flask", "--app", "app.web:app", "run", "--reload", "--host=0.0.0.0", "--port=8000"]

FROM dev AS test

COPY tests/ ./tests/
RUN python -m pytest -v tests/
CMD ["python", "-m", "pytest", "-v", "tests/"]

FROM python:3.14-slim AS final

ARG APP_VERSION=0.1.0
ENV APP_VERSION=${APP_VERSION} \
    APP_ENV=production \
    PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app
COPY --from=builder /opt/venv /opt/venv
COPY app/ ./app/

USER nobody:nogroup
EXPOSE 8000

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s \
    CMD ["python", "-c", "from urllib.request import urlopen; urlopen('http://127.0.0.1:8000/health', timeout=2).close()"]

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app.web:app"]
