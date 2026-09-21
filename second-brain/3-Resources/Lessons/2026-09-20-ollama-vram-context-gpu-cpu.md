---
type: lesson
created: 2026-09-20
updated: 2026-09-20
tags: [ollama, vram, gpu, quantization, context]
project: OllamaConfigurator
---

# Ollama: VRAM, context, and “100% GPU” vs CPU

## Lesson

`ollama ps` / `GET /api/ps` **GPU%** means **memory placement** (`size_vram / size`), not live SM utilization. Full system RAM with a loaded model is often **OS page cache** of the GGUF, not CPU inference.

Unload/reload frees model memory; it does **not** restart the Ollama daemon.

## Hardware context (Philip)

Linux remote Ollama: dual **5060 Ti** ≈ **32 GB** total VRAM (two 16 GB cards, not one pool). Display on iGPU — discrete cards are for compute.

## Rules of thumb

1. **Context dominates** — e.g. Qwen ~196K or Devstral at 150–200K blows past 32 GB even at Q4.
2. Dual GPU free % on each card ≠ one contiguous placeable block; small CPU/RAM remainder (e.g. 5%) can be normal.
3. **Weight quant** (Q4/Q5/Q8) ≠ **KV cache quant** (`OLLAMA_KV_CACHE_TYPE=q8_0|q4_0`).
4. Official **devstral-small-2** Ollama tags: **Q4_K_M, Q8_0, fp16** only (no official Q5/Q6).
5. Q5 can show `ps` 100% GPU but still **CPU compute** if CUDA kernels fall back; Q8 often runs real GPU matmuls — verify with `nvidia-smi` **during** generation.
6. Practical Devstral Small 2 **Q4** on 32 GB: **~64K comfortable**, **~128K max to try**, **150K+ expect spill**.

## Useful server knobs

```bash
export OLLAMA_FLASH_ATTENTION=1
export OLLAMA_KV_CACHE_TYPE=q8_0   # or q4_0
# Modelfile: PARAMETER num_gpu 99, PARAMETER num_ctx <what fits>
```

## Related

- Project: [[../../1-Projects/OllamaConfigurator/_project|OllamaConfigurator]]
