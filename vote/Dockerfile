# base defines a base stage that uses the official python runtime base image
# pinned to an exact version and digest so every build uses the same base
FROM python:3.11.18-slim-trixie@sha256:ffe4b0c76963e64f05484d74dbb3f67fad1effcf3c5c22c2235f0fafc8a9c98f AS base

# Add curl for healthcheck
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Create an unprivileged user to run the app (numeric so Kubernetes can verify runAsNonRoot)
RUN groupadd --system --gid 10001 app && \
    useradd --system --uid 10001 --gid app --create-home app

# Set the application directory
WORKDIR /usr/local/app

# Install our requirements.txt
# (setuptools ships with the base image and bundles outdated libraries, so bring it up to date)
COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir --upgrade setuptools && \
    pip install --no-cache-dir -r requirements.txt

# dev defines a stage for development, where it'll watch for filesystem changes
FROM base AS dev
RUN pip install --no-cache-dir watchdog
ENV FLASK_ENV=development
USER 10001
CMD ["python", "app.py"]

# final defines the stage that will bundle the application for production
FROM base AS final

# Copy our code from the current folder to the working directory inside the container
COPY . .

# Non-root users can't bind ports below 1024, so the app listens on 8080
EXPOSE 8080

USER 10001

# Define our command to be run when launching the container
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:8080", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]
