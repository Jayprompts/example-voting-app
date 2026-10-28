# pinned to an exact version and digest (Python 3.9 is end-of-life)
FROM python:3.11.18-slim-trixie@sha256:ffe4b0c76963e64f05484d74dbb3f67fad1effcf3c5c22c2235f0fafc8a9c98f

# add apache bench (ab) tool
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    apache2-utils \
    && rm -rf /var/lib/apt/lists/*

# Create an unprivileged user to run the seeder
RUN groupadd --system --gid 10001 app && \
    useradd --system --uid 10001 --gid app --no-create-home app

WORKDIR /seed

COPY . .

# create POST data files with ab friendly formats
RUN python make-data.py

USER 10001

CMD ["/seed/generate-votes.sh"]
