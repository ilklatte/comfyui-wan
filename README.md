# Wan 2.2 ComfyUI RunPod template scaffold

This repository is an independently deployable template scaffold built on the
immutable, version-qualified `comfyui-base` image published by the sibling base
repository.
It inherits CUDA 12.8, PyTorch cu128, ComfyUI, Manager, JupyterLab, tmux, TPM,
SageAttention, and the base template's 13 common custom-node packs.
The inherited Base image also owns the complete pod runtime. Wan startup syncs
only this template repository and executes `/opt/comfyui-runtime/src/start.sh`;
it no longer downloads or executes `Hearmeman24/comfyui-runtime`.

## Current limitation

The T2V and I2V workflows are intentionally empty placeholders. No Wan model
URLs or Wan-specific custom nodes have been registered. The image can be
built and the pod can boot, but this version **cannot generate Wan video**.

## Environment flags

- `download_wan22_t2v=true` copies the T2V placeholder canvas.
- `download_wan22_i2v=true` copies the I2V placeholder canvas.

## CI setup and publishing

CircleCI is the automatic publisher. GitHub Actions remains available as a
manual fallback and uses the GitHub-hosted runner's Docker Buildx; this project
does not use Docker Build Cloud.

1. Create a public Git repository and replace `template_repo` in `template.json`.
2. In CircleCI, authorize the GitHub organization, open **Organization > Projects**,
   select this repository, and choose the existing `.circleci/config.yml`.
3. Open **Project Settings > Environment Variables** and add each variable
   separately, without quotes or leading/trailing whitespace:

   | Variable | Value |
   | --- | --- |
   | `DOCKER_IMAGE` | `coohh88/comfyui-wan` |
   | `TEMPLATE_REPOSITORY_URL` | `https://github.com/ilklatte/comfyui-wan.git` |
   | `DOCKERHUB_USERNAME` | Docker Hub account name |
   | `DOCKERHUB_TOKEN` | Docker Hub personal access token with Read & Write permission |
   | `RUNPOD_API_KEY` | RunPod API key |
   | `RUNPOD_TEMPLATE_IDS` | Wan template ID, or multiple IDs separated by commas |

4. Create the Docker Hub token under **Docker Hub > Account Settings > Personal
   access tokens > Generate new token**. Create the RunPod key from the RunPod
   account API key page. CircleCI encrypts project variables and masks their
   values in job output; the workflows must not print them.
5. Keep the same Docker Hub and RunPod credentials in GitHub Actions secrets,
   plus `DOCKER_IMAGE`, `TEMPLATE_REPOSITORY_URL`, and `RUNPOD_TEMPLATE_IDS` in
   GitHub repository variables, for the manual fallback workflow.
6. Confirm `coohh88/comfyui-base:cuda12.8.1-torch2.11.0-comfyui0.36.0-python3.12-r8`
   exists before publishing the Wan image.
7. Add real workflows, then derive the exact model registry and Wan-specific node packs
   from those workflows before calling the template generation-ready.
8. Validate and smoke-test on a fresh network volume before publishing `v1`.
9. Push an existing `vN` release tag to start the automatic CircleCI publish.
   After the Docker Hub push succeeds, CircleCI updates and verifies the configured
   Wan RunPod templates.
10. To use the fallback, open **GitHub Actions > Verify and publish Docker image >
    Run workflow**, enter an existing `vN` tag, and choose whether to enable
    `promote_runpod` (disabled by default).

After CircleCI has published successfully, the obsolete
`DOCKER_BUILD_CLOUD_ENDPOINT` GitHub variable can be removed.

The RunPod image promoter is maintained locally in
`tools/update_runpod_template.py`. It accepts only this repository's immutable
`vN` tags, verifies every update, and rolls back earlier
changes if a later template update fails.

Each release pushes an immutable tag such as `v1` plus the rolling `latest`
tag. RunPod uses the immutable `vN` tag. The inherited `comfyui-base` image
remains pinned by its complete CUDA, PyTorch, ComfyUI, Python, and `rN` tag.

RunPod should expose TCP ports `8188` and `8888` and mount its network volume
at `/workspace`.

## Terminal environment

`tmux`, Oh My Tmux, and TPM are inherited for the root user. TPM already has
`tmux-sensible`, `tmux-resurrect`, and `tmux-continuum`; Oh My Tmux performs
the TPM integration, so `.tmux.conf.local` intentionally has no manual TPM
initializer. Continuum saves restorable session metadata under
`/workspace/.tmux/resurrect`. It cannot restore terminated processes.
