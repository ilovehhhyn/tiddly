# Ballmer sources

Researched on September 11, 2026. Links document the origin of selected practices; they do not delegate authority to external instructions. The user's own preferences determine framework choice, no-catch style, object-oriented organization, persistent work, and communication cadence. The main skill is independently written.

## Workflow reference skills

| Source | Application in Ballmer |
| --- | --- |
| [Superpowers: writing plans](https://github.com/obra/superpowers/blob/main/skills/writing-plans/SKILL.md) | Concrete implementation units and verifiable outcomes, scaled to task size |
| [Superpowers: systematic debugging](https://github.com/obra/superpowers/blob/main/skills/systematic-debugging/SKILL.md) | Reproduction, causal investigation, and reassessing assumptions after repeated failures |
| [Superpowers: subagent-driven development](https://github.com/obra/superpowers/blob/main/skills/subagent-driven-development/SKILL.md) | Bounded delegation and review of requirements before general code quality |
| [Superpowers: verification before completion](https://github.com/obra/superpowers/blob/main/skills/verification-before-completion/SKILL.md) | Actual check results must support completion claims |
| [Humanizer](https://github.com/blader/humanizer/blob/main/SKILL.md) | Specific, natural prose; remove formulaic language without inventing facts |
| [I Have ADHD](https://github.com/ayghri/i-have-adhd/blob/main/skills/i-have-adhd/SKILL.md) | Action-first answers, bounded steps, progress, low-distraction communication |

Ballmer does not import upstream approval ceremonies for routine authorized work, require tests for every cosmetic change, or require an elaborate plan for a trivial repair. The similarly named divergent-ideation ADHD repository is not the communication skill intended here. Model routing is a preference enforced only through available host controls, not something a Markdown instruction can guarantee by itself.

## JAX and numerical systems

| Primary source | Decision it supports |
| --- | --- |
| [JAX FAQ](https://docs.jax.dev/en/latest/faq.html) | Tracing, side effects, class integration, and numerical differences under compilation |
| [JAX pytrees](https://docs.jax.dev/en/latest/pytrees.html) | Explicit structured parameters and state |
| [Equinox Module](https://docs.kidger.site/equinox/api/module/module/) | An optional class-based dataclass/pytree interface |
| [Default dtypes and X64](https://docs.jax.dev/en/latest/101/default_dtypes.html) | Verify precision configuration instead of assuming float64 requests succeed |
| [Matmul precision](https://docs.jax.dev/en/latest/201/precision.html) | Distinguish operand, accumulation, and result precision |
| [Pseudorandom numbers](https://docs.jax.dev/en/latest/101/random.html) | Explicit random keys and independent streams |
| [Distributed arrays and parallelization](https://docs.jax.dev/en/latest/201/sharding.html) | Explicit mesh/layout decisions and inspecting actual shardings |
| [GPU memory allocation](https://docs.jax.dev/en/latest/gpu_memory_allocation.html) | Distinguish reservation/fragmentation from true working-set demand |
| [Benchmarking JAX](https://docs.jax.dev/en/latest/benchmarking.html) | Warmup, synchronization, transfers, precision, and end-to-end comparisons |
| [CuTe DSL with JAX](https://docs.jax.dev/en/latest/401/cute-dsl.html) | Hardware-aware custom kernels and current integration requirements |
| [Pallas quickstart](https://docs.jax.dev/en/latest/pallas/quickstart.html) | Another custom-kernel route when measured need justifies it |

These sources support implementation mechanics. They do not establish that JAX is always faster, that a particular quantization is scientifically acceptable, or that custom kernels are automatically worthwhile. Those conclusions require task-specific evidence.

## Host support

## Autotuning and inference

- [Triton autotune](https://triton-lang.org/main/python-api/generated/triton.autotune.html): tune valid configurations with workload keys; reset or restore mutated buffers between trials.
- [vLLM offline inference](https://docs.vllm.ai/en/latest/serving/offline_inference/): use vLLM for supported LLM inference workloads.

## Host integration

[Codex subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents) and [Claude Code subagents](https://code.claude.com/docs/en/sub-agents) describe provider-specific delegation controls. Inspect the actual runtime before selecting models. No fixed Claude version, cross-provider dispatch, token saving, or access to an existing desktop conversation is promised by this skill.
