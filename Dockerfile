# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/engine/reference/builder/

# docker compose up --build
# docker compose up --build -d
# docker compose down


# https://github.com/s0md3v/roop/wiki/1.-Installation
# https://github.com/s0md3v/roop/wiki/2.-Acceleration


ARG PYTHON_VERSION=3.10
#FROM python:${PYTHON_VERSION}-slim as base
FROM python:${PYTHON_VERSION} as base

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/go/dockerfile-user-best-practices/
ARG UID=10001
RUN adduser \
  --disabled-password \
  --gecos "" \
  --home "/nonexistent" \
  --shell "/sbin/nologin" \
  --no-create-home \
  --uid "${UID}" \
  appuser


#RUN apt-get install build-essential python3-dev


RUN pip install --upgrade pip
#RUN pip install --upgrade pip setuptools wheel

RUN python3.1 -m pip install onnxruntime

# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.cache/pip to speed up subsequent builds.
# Leverage a bind mount to requirements.txt to avoid having to copy them into
# into this layer.
RUN --mount=type=cache,target=/root/.cache/pip \
  --mount=type=bind,source=requirements.txt,target=requirements.txt \
  python -m pip install -r requirements.txt

# Switch to the non-privileged user to run the application.
USER appuser

# Copy the source code into the container.
COPY . .

# Expose the port that the application listens on.
EXPOSE 8989

# Run the application.
CMD python run.py --target /assets/tiktok.mp4 --source /assets/eve.png -o /assets/swapped.mp4 --execution-provider cuda --frame-processor face_swapper face_enhancer
# CMD ["python", "run.py"]
# python run.py --target /content/tiktok.mp4 --source /content/eve.png -o /content/swapped.mp4 --execution-provider cuda --frame-processor face_swapper face_enhancer
