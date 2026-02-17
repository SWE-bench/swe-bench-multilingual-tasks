# SWE-bench Dockerfiles (Multilingual)

Dockerfile generator for SWE-bench Multilingual benchmarks (C, Go, Java, JavaScript, PHP, Ruby, Rust).

## Usage

```bash
# From HuggingFace dataset
sb-dockerfile-gen-multilingual SWE-bench/SWE-bench_Multilingual --output_dir src/dockerfiles

# From local JSON/JSONL file
sb-dockerfile-gen-multilingual instances.jsonl --output_dir src/dockerfiles

# Specific instances
sb-dockerfile-gen-multilingual SWE-bench/SWE-bench_Multilingual --instance_ids some_instance --output_dir src/dockerfiles
```

## Output

Generated Dockerfiles are written to `src/dockerfiles/<instance_id>.Dockerfile`.

## Install

```bash
pip install -e .
```
