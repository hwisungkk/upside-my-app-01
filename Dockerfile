FROM python:3.12-slim

# 1. 파이썬 및 uv 보안 설정
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_EXCLUDE_NEWER="7 days" 
    # ↑ [공급망 공격 방어] 출시된 지 7일이 지나지 않은 패키지는 설치를 차단합니다.

# 2. uv 바이너리 복사
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# 3. Lock 파일 복사 및 DevSecOps 표준 설치 (pip install 대신 uv sync 사용)
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project
# ↑ --frozen: lock 파일 변조 방지 및 정확히 일치하는 버전만 설치

# 4. 소스 코드 복사
COPY . .

# 5. 실행 경로 지정
ENV PATH="/app/.venv/bin:$PATH"

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
