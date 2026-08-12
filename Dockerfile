FROM nvcr.io/nvidia/cuda:13.3.1-cudnn-runtime-ubuntu24.04

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

RUN uv python pin --global 3.12.11

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  ffmpeg \
  git \
  libgl1 \
  libglib2.0-0 \
  libpython3-dev \
  libsm6 \
  libxext6 \
  tzdata \
  wget \
  && ln -snf /usr/share/zoneinfo/UTC /etc/localtime \
  && echo UTC > /etc/timezone \
  && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -g 11000 appuser && \
  useradd -r -u 11000 -g appuser -m appuser

WORKDIR /app


ENV HOME=/home/appuser

RUN chown -R appuser:appuser /app /home/appuser

USER 11000

RUN mkdir -p /home/appuser/comfyui-uv-venv

WORKDIR /home/appuser/comfyui-uv-venv

RUN echo "3.12.11" > .python-version

RUN uv init .

RUN uv add pip

ENV PATH="/home/appuser/comfyui-uv-venv/.venv/bin:$PATH"

RUN git clone https://www.github.com/lesliebinbin/ComfyUI

WORKDIR /app/ComfyUI


RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install -r requirements.txt
RUN pip install -r manager_requirements.txt


