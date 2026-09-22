# Wan 2.2 ComfyUI RunPod template scaffold

This repository is an independently deployable template scaffold built on the
immutable, version-qualified `comfyui-base` image published by the sibling base
repository.
It inherits CUDA 12.8, PyTorch cu128, ComfyUI, Manager, JupyterLab, tmux, TPM,
SageAttention, and the base template's 13 common custom-node packs.

## Current limitation

The T2V and I2V workflows are intentionally empty placeholders. No Wan model
URLs or Wan-specific custom nodes have been registered. The image can be
built and the pod can boot, but this version **cannot generate Wan video**.

## Environment flags

- `download_wan22_t2v=true` copies the T2V placeholder canvas.
- `download_wan22_i2v=true` copies the I2V placeholder canvas.

## Before publishing

1. Create a public Git repository and replace `template_repo` in `template.json`.
2. Add GitHub repository variable `TEMPLATE_REPOSITORY_URL` with the same URL.
3. Add repository variables `DOCKER_IMAGE` and `RUNPOD_TEMPLATE_IDS` for this template only.
4. Add Actions secrets `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`, and `RUNPOD_API_KEY`.
5. Confirm `coohh88/comfyui-base:cuda12.8.1-torch2.11.0-comfyui0.36.0-python3.12-r3`
   exists before publishing the Wan image.
6. Add real workflows, then derive the exact model registry and Wan-specific node packs
   from those workflows before calling the template generation-ready.
7. Validate and smoke-test on a fresh network volume before publishing `r1`.

Each release pushes a version-qualified tag such as
`wan2.2-cuda12.8.1-torch2.11.0-comfyui0.36.0-python3.12-r1` plus the rolling
`latest` tag. RunPod uses the immutable `rN` tag.

RunPod should expose TCP ports `8188` and `8888` and mount its network volume
at `/workspace`.

## Terminal environment

`tmux`, Oh My Tmux, and TPM are inherited for the root user. TPM already has
`tmux-sensible`, `tmux-resurrect`, and `tmux-continuum`; Oh My Tmux performs
the TPM integration, so `.tmux.conf.local` intentionally has no manual TPM
initializer. Continuum saves restorable session metadata under
`/workspace/.tmux/resurrect`. It cannot restore terminated processes.
