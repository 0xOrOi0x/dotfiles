#!/usr/bin/env bash
# =============================================================================
# machine-detect.sh — Auto-detect machine profile
# -----------------------------------------------------------------------------
# Outputs a machine ID like "air-m5", "pro-intel", "mini-m4" etc.
# Used by:
#   - chezmoi (.chezmoi.toml.tmpl) for default machine prompt value
#   - bootstrap.sh for Brewfile selection
#   - dot-info function for status display
# =============================================================================
set -uo pipefail

detect_arch() {
  uname -m
}

detect_model() {
  # MacBookAir15,3 / MacBookPro16,1 / Mac15,7 등
  sysctl -n hw.model 2>/dev/null
}

detect_chip() {
  # On Apple Silicon: "Apple M5", "Apple M4 Pro" etc.
  # On Intel: "Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz"
  sysctl -n machdep.cpu.brand_string 2>/dev/null
}

detect_ram_gb() {
  local bytes
  bytes=$(sysctl -n hw.memsize 2>/dev/null || echo 0)
  echo $((bytes / 1024 / 1024 / 1024))
}

detect_macos_version() {
  sw_vers -productVersion 2>/dev/null || echo "unknown"
}

# Generate machine ID like "air-m5", "pro-intel"
detect_machine_id() {
  local arch model chip
  arch=$(detect_arch)
  model=$(detect_model)
  chip=$(detect_chip)

  # Form factor (air | pro | mini | studio | imac | unknown)
  local form="unknown"
  case "$model" in
    *MacBookAir*)  form="air" ;;
    *MacBookPro*)  form="pro" ;;
    *Macmini*)     form="mini" ;;
    *MacStudio*)   form="studio" ;;
    *iMac*)        form="imac" ;;
    Mac*)
      # Apple Silicon Macs sometimes report as "Mac15,X" only
      # Try to deduce from product name if possible
      local product
      product=$(system_profiler SPHardwareDataType 2>/dev/null | grep "Model Name" | awk -F': ' '{print $2}')
      case "$product" in
        *Air*)    form="air" ;;
        *Pro*)    form="pro" ;;
        *Mini*)   form="mini" ;;
        *Studio*) form="studio" ;;
        *iMac*)   form="imac" ;;
      esac
      ;;
  esac

  # Chip designator
  local chip_tag="unknown"
  if [[ "$arch" == "arm64" ]]; then
    # Apple Silicon: extract M-series number
    chip_tag=$(echo "$chip" | grep -oE 'M[0-9]+' | head -1 | tr '[:upper:]' '[:lower:]')
    [[ -z "$chip_tag" ]] && chip_tag="apple-silicon"
  else
    # Intel
    chip_tag="intel"
  fi

  echo "${form}-${chip_tag}"
}

# Profile (full | lite) based on RAM and arch
detect_profile() {
  local arch ram_gb
  arch=$(detect_arch)
  ram_gb=$(detect_ram_gb)

  if [[ "$arch" == "arm64" ]] && [[ "$ram_gb" -ge 16 ]]; then
    echo "full"
  elif [[ "$arch" == "arm64" ]] && [[ "$ram_gb" -ge 8 ]]; then
    echo "balanced"
  else
    # Intel or low RAM
    echo "lite"
  fi
}

# Recommended AI concurrent agents
recommend_ai_concurrent() {
  local profile
  profile=$(detect_profile)
  case "$profile" in
    full)     echo 4 ;;
    balanced) echo 3 ;;
    lite)     echo 2 ;;
    *)        echo 2 ;;
  esac
}

# Main: print as KEY=VALUE for shell sourcing, or single field if requested
main() {
  case "${1:-all}" in
    machine_id)        detect_machine_id ;;
    arch)              detect_arch ;;
    model)             detect_model ;;
    chip)              detect_chip ;;
    ram_gb)            detect_ram_gb ;;
    macos_version)     detect_macos_version ;;
    profile)           detect_profile ;;
    ai_concurrent)     recommend_ai_concurrent ;;
    all)
      echo "MACHINE_ID=$(detect_machine_id)"
      echo "ARCH=$(detect_arch)"
      echo "MODEL=$(detect_model)"
      echo "CHIP=$(detect_chip)"
      echo "RAM_GB=$(detect_ram_gb)"
      echo "MACOS_VERSION=$(detect_macos_version)"
      echo "PROFILE=$(detect_profile)"
      echo "AI_CONCURRENT=$(recommend_ai_concurrent)"
      ;;
    *)
      echo "Usage: $0 [machine_id|arch|model|chip|ram_gb|macos_version|profile|ai_concurrent|all]" >&2
      exit 1
      ;;
  esac
}

main "$@"
