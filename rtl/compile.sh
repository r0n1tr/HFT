if [ -z "$1" ]; then
  echo "Usage: $0 <module_name>"
  exit 1
fi

MODULE_NAME=$1

verilator --lint-only ${MODULE_NAME}.sv
