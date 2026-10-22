# ==============================================================================
# TRAVERZA: Backend Production Dockerfile
# Multi-stage, non-root, security-hardened container for FastAPI Modular Monolith
# ==============================================================================

# Stage 1: Build stage
FROM python:3.12-slim AS builder

WORKDIR /build

# Install build dependencies for C extensions (e.g., asyncpg, argon2-cffi, shapely)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Production runtime stage
FROM python:3.12-slim AS runner

WORKDIR /app

# Install runtime dependencies for PostGIS/PostgreSQL libraries & curl for healthcheck
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create dedicated non-root user and group
RUN groupadd -g 10001 traverza && \
    useradd -u 10001 -g traverza -s /bin/bash -m traverza

# Copy installed wheels from builder
COPY --from=builder /root/.local /home/traverza/.local
ENV PATH=/home/traverza/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Copy application source code
COPY --chown=traverza:traverza app ./app
COPY --chown=traverza:traverza migrations ./migrations
COPY --chown=traverza:traverza alembic.ini .

# Switch to non-root user
USER traverza

# Expose port
EXPOSE 8000

# Container healthcheck against /health endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Production server command
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
