# syntax=docker/dockerfile:1
ARG BASE_IMAGE=coohh88/comfyui-base:latest
FROM ${BASE_IMAGE}

ARG BASE_IMAGE
ARG TEMPLATE_REPOSITORY_URL=https://github.com/ilklatte/comfyui-wan.git
ENV COMFYUI_BASE_IMAGE=${BASE_IMAGE} \
    TEMPLATE_REPOSITORY_URL=${TEMPLATE_REPOSITORY_URL}
LABEL org.opencontainers.image.base.name=${BASE_IMAGE}

COPY src/start_script.sh /start_script.sh
RUN chmod +x /start_script.sh

CMD ["/start_script.sh"]
