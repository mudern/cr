#!/bin/bash

VERSION="cr 1.0.0"

# ========== 颜色配置 ==========
green=$(tput setaf 2)
red=$(tput setaf 1)
yellow=$(tput setaf 3)
reset=$(tput sgr0)
bold=$(tput bold)

LOG_DIR="${HOME}/.clog"
mkdir -p "$LOG_DIR"

# ========== 清理过期日志 ==========
cleanup_logs() {
    find "$LOG_DIR" -name '*.log' -mtime +3 -delete
}

# ========== 列出最近的命令历史 ==========
show_history_list() {
    local files=("$LOG_DIR"/*.log)
    if [[ ${#files[@]} -eq 1 && ! -e "${files[0]}" ]]; then
        echo "No command history found"
        return
    fi

    echo "${bold}Recent commands (newest first):${reset}"
    local count=0
    while IFS= read -r log; do
        ((count++))
        [[ $count -gt 10 ]] && break
        
        local cmd=$(awk -F ': ' '/^CMD:/ {print $2; exit}' "$log")
        local status=$(awk -F ': ' '/^STATUS:/ {print $2; exit}' "$log")
        local runtime=$(awk -F ': ' '/^RUNTIME:/ {print $2; exit}' "$log")
        local output=$(awk '/^OUTPUT:/ {flag=1; next} /^END:/ {flag=0} flag' "$log")

        if [[ "$status" == "0" ]]; then
            local result_line=$(echo "$output" | tail -n 1)
            printf "%2d. ${green}[OK] ${runtime}s${reset} %s\n" "$count" "${cmd:0:70}"
            [[ -n "$result_line" ]] && echo "    → ${result_line:0:76}"
        else
            local err_line=$(echo "$output" | grep -v '^$' | tail -n 1)
            printf "%2d. ${red}[ERR] ${runtime}s${reset} %s\n" "$count" "${cmd:0:70}"
            [[ -n "$err_line" ]] && echo "    ✘ ${err_line:0:76}"
        fi
    done < <(find "$LOG_DIR" -name '*.log' -printf "%T@ %p\n" | sort -nr | cut -d' ' -f2-)
}

# ========== 查看指定历史记录 ==========
show_history_record() {
    if [[ -n "$1" && "$1" =~ ^[0-9]+$ ]]; then
        local files=($(find "$LOG_DIR" -name '*.log' -printf "%T@ %p\n" | sort -nr | cut -d' ' -f2-))
        local log_id=$1
        if [[ $log_id -gt 0 && $log_id -le ${#files[@]} ]]; then
            less "${files[$((log_id-1))]}"
        else
            echo "Invalid history index. Available records: 1-${#files[@]}"
        fi
    else
        echo "Usage: cr --history|-h <log-index>"
    fi
}

# ========== 主执行逻辑 ==========
run_command() {
    local start_time_ms=$(date +%s%3N)
    local log_id=$(date +%s%N)
    local log_file="${LOG_DIR}/${log_id}.log"
    local tmp_out=$(mktemp)

    bash -c "$*" >"$tmp_out" 2>&1
    local status=$?
    local end_time_ms=$(date +%s%3N)
    local runtime_ms=$(( end_time_ms - start_time_ms ))
    local runtime=$(awk "BEGIN {printf \"%.3f\", $runtime_ms/1000}")

    local line_count=$(wc -l < "$tmp_out")

    {
        echo "CMD: $*"
        echo "TIME: $(date -d @$((start_time_ms/1000)) +"%F %T")"
        echo "RUNTIME: $runtime"
        echo "STATUS: $status"
        echo "OUTPUT:"
        cat "$tmp_out"
        echo "END: $(date -d @$((end_time_ms/1000)) +"%F %T")"
    } > "$log_file"

    if [[ $status -eq 0 ]]; then
        echo "${green}${bold}[OK: ${runtime}s]${reset} ${green}$*${reset}"
        if [[ $line_count -le 10 ]]; then
            [[ $line_count -gt 0 ]] && cat "$tmp_out"
        else
            echo "${yellow}Output ($line_count lines, snippet):${reset}"
            head -n 3 "$tmp_out"
            echo "..."
            tail -n 2 "$tmp_out"
            read -r -p "${bold}Show full output with less? [y/N] ${reset}" response
            [[ "$response" =~ ^[Yy]$ ]] && less "$tmp_out"
        fi
    else
        echo "${red}${bold}[ERR: ${runtime}s]${reset} ${red}$*${reset}"
        tail -n 1 "$tmp_out"
        if [[ $line_count -gt 10 ]]; then
            echo "${yellow}Output ($line_count lines, snippet):${reset}"
            head -n 1 "$tmp_out"
            echo "..."
            tail -n 3 "$tmp_out"
            read -r -p "${bold}View full output with less? [y/N] ${reset}" response
            [[ "$response" =~ ^[Yy]$ ]] && less "$tmp_out"
        fi
    fi

    rm -f "$tmp_out"
    cleanup_logs
    exit $status
}

# ========== 参数处理 ==========
case "$1" in
    --list|-ls)
        cleanup_logs
        show_history_list
        ;;
    --history|-h)
        cleanup_logs
        show_history_record "$2"
        ;;
    --version|-v)
        echo "$VERSION"
        ;;
    "")
        echo "${bold}Command Runner (cr)${reset}"
        echo "Usage:"
        echo "  cr <command>          # Execute command"
        echo "  cr --list | -ls       # List recent commands"
        echo "  cr --history | -h ID  # View full command output"
        echo "  cr --version | -v     # Show version"
        exit 1
        ;;
    *)
        run_command "$@"
        ;;
esac