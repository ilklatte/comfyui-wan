# syntax=docker/dockerfile:1
ARG BASE_IMAGE=coohh88/comfyui-base:cuda12.8.1-torch2.11.0-comfyui0.36.0-python3.12-r5
FROM ${BASE_IMAGE}

ARG TEMPLATE_REPOSITORY_URL=https://github.com/ilklatte/comfyui-wan.git
ENV TEMPLATE_REPOSITORY_URL=${TEMPLATE_REPOSITORY_URL}

COPY src/start_script.sh /start_script.sh
RUN chmod +x /start_script.sh

CMD ["/start_script.sh"]
