#!/bin/bash
# Precise calculator - 100% accurate math using JavaScript engine

set -e

TABLE_MODE=false
EXPRESSIONS=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --table|-t)
            TABLE_MODE=true
            shift
            ;;
        --help|-h)
            echo "Usage: calculate.sh [--table] <expression> [expression...]"
            echo ""
            echo "Examples:"
            echo "  calculate.sh '1000 * 0.0016'"
            echo "  calculate.sh '1 + 2' '3 * 4' '10 / 3'"
            echo "  calculate.sh --table 'grok:1000 * 0.0016' 'gemini:1000 * 0.0004'"
            exit 0
            ;;
        *)
            EXPRESSIONS+=("$1")
            shift
            ;;
    esac
done

if [ ${#EXPRESSIONS[@]} -eq 0 ]; then
    echo "Error: No expression provided"
    echo "Usage: calculate.sh <expression> [expression...]"
    exit 1
fi

# Build JavaScript code
JS_CODE="
const results = [];
"

for expr in "${EXPRESSIONS[@]}"; do
    # Check if expression has label (format: "label:expression")
    if [[ "$expr" == *":"* ]] && [ "$TABLE_MODE" = true ]; then
        label="${expr%%:*}"
        expression="${expr#*:}"
        JS_CODE+="
try {
    const result = $expression;
    results.push({ label: '$label', result: result });
} catch (e) {
    results.push({ label: '$label', result: 'ERROR: ' + e.message });
}
"
    else
        JS_CODE+="
try {
    const result = $expr;
    results.push({ label: null, result: result });
} catch (e) {
    results.push({ label: null, result: 'ERROR: ' + e.message });
}
"
    fi
done

if [ "$TABLE_MODE" = true ]; then
    JS_CODE+="
// Find max label width
const maxLabel = Math.max(...results.map(r => (r.label || '').length), 5);
const maxResult = Math.max(...results.map(r => String(r.result).length), 6);

console.log('| ' + 'Label'.padEnd(maxLabel) + ' | ' + 'Result'.padEnd(maxResult) + ' |');
console.log('|' + '-'.repeat(maxLabel + 2) + '|' + '-'.repeat(maxResult + 2) + '|');
results.forEach(r => {
    const label = (r.label || '-').padEnd(maxLabel);
    const result = String(r.result).padEnd(maxResult);
    console.log('| ' + label + ' | ' + result + ' |');
});
"
else
    JS_CODE+="
results.forEach(r => console.log(r.result));
"
fi

# Execute with Node.js
node -e "$JS_CODE"
