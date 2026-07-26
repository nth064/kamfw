# shellcheck shell=ash

# =============================================================================
# base.sh
# =============================================================================
# 注意：输出/错误处理的唯一事实来源是 lib/kamfw/.kamfwrc 提供的
# print/ui_print/abort。这里禁止再定义 kam_print/kam_error/kam_abort。
# =============================================================================


# 判断是否在交互式终端（TTY）中运行
is_tty() {
    # [ -t 0 ] 检查标准输入是否连接到终端
    # [ -t 1 ] 检查标准输出是否连接到终端
    if [ -t 0 ] || [ -t 1 ]; then
        return 0
    else
        return 1
    fi
}
if is_tty; then
    export COL_RED='\033[0;31m'
    export COL_GRN='\033[0;32m'
    export COL_YLW='\033[0;33m'
    export COL_BLU='\033[0;34m'
    export COL_PUR='\033[0;35m'
    export COL_CYN='\033[0;36m'
    export COL_RST='\033[0m'
    export ANSI_CURSOR_UP='\033[%dA'
    export ANSI_CLEAR_LINE='\033[2K\r'
else
    export COL_RED='╳'
    export COL_GRN='▚'
    export COL_YLW='◬'
    export COL_BLU='◈'
    export COL_PUR='║'
    export COL_CYN='┆'
    export COL_RST='❖'
    export ANSI_CURSOR_UP=''
    export ANSI_CLEAR_LINE=''
fi

x() {
    _n=${1:-1}
    if [ ! -t 0 ]; then
        _input=$(cat)
        printf "%${_n}s" | sed "s/ /${input}/g"
    fi
    unset _n _input
}

# NOTE: Logging helpers have been moved to `src/MagicNet/lib/kamfw/logging.sh`

wait_key() {
    _wkr_match_list="$*"
    _wkr_event=""
    _wkr_res=""

    while :; do
        _wkr_event=$(getevent -qlc 1 2>/dev/null | awk '$2~/0001|EV_KEY/ && $4~/00000001|DOWN/ {print $3; exit}')
        [ -z "$_wkr_event" ] && continue
        case "$_wkr_event" in
        KEY_VOLUMEUP | 0073) _wkr_res="up" ;;
        KEY_VOLUMEDOWN | 0072) _wkr_res="down" ;;
        KEY_POWER | 0074) _wkr_res="power" ;;
        KEY_MUTE | 0071) _wkr_res="mute" ;;
        KEY_F*) _wkr_res="f${_wkr_event#KEY_F}" ;;
        *) _wkr_res="" ;;
        esac

        if [ -n "$_wkr_res" ]; then
            if [ "$_wkr_match_list" = "any" ]; then
                print "$_wkr_res"
                break
            else
                case " ${_wkr_match_list} " in
                *" ${_wkr_res} "*)
                    print "$_wkr_res"
                    break
                    ;;
                esac
            fi
        fi
    done
    unset _wkr_match_list _wkr_event _wkr_res
}

wait_key_up() {
    wait_key "up"
}

wait_key_down() {
    wait_key "down"
}

wait_key_up_down() {
    wait_key "up" "down"
}

wait_key_power() {
    wait_key "power"
}

wait_key_mute() {
    wait_key "mute"
}

wait_key_f() {
    wait_key "f1" "f2" "f3" "f4" "f5" "f6" "f7" "f8" "f9" "f10" "f11" "f12"
}

# 用于“按任意键继续”
wait_key_any() {
    wait_key "any"
}

# =============================================================================
# 进程精确识别 / exact process identity
# =============================================================================
# `pkill -f` 把模式匹配到整机每一条 cmdline 上；模块以 root 运行，一次误配就会
# 向陌生进程发信号。下面的函数改为逐字段比较完整 argv，只有参数向量完全吻合的
# 进程才会被处理。
#
# `read -d` is a bash/ksh extension that Android's ash lacks, so the result is
# probed once and cached. Callers may preset _kam_read_d_supported to exercise
# either path.
kam_read_d_supported() {
    if [ -z "${_kam_read_d_supported:-}" ]; then
        if { printf 'x\0' | { IFS= read -r -d '' _kam_probe_arg 2>/dev/null &&
            [ "$_kam_probe_arg" = x ]; }; }; then
            _kam_read_d_supported=1
        else
            _kam_read_d_supported=0
        fi
        unset _kam_probe_arg
    fi
    [ "$_kam_read_d_supported" = 1 ]
}

# kam_pid_argv_matches <pid> <expected-argv0> [<expected-argv1> ...]
#
# True only when the process argv has exactly as many fields as expected values
# and every field is identical. An empty expected value matches any field, for
# the positions we do not control (argv0 is the interpreter the kernel picked:
# `sh`, `/system/bin/sh` and `busybox sh` are all legitimate).
kam_pid_argv_matches() {
    _kam_argv_pid="$1"
    shift || return 1
    [ "$#" -gt 0 ] || return 1
    case "$_kam_argv_pid" in
    "" | *[!0-9]*) return 1 ;;
    esac
    _kam_argv_file="/proc/${_kam_argv_pid}/cmdline"
    [ -r "$_kam_argv_file" ] || return 1

    _kam_argv_rc=0
    if kam_read_d_supported; then
        while IFS= read -r -d '' _kam_argv_field; do
            if [ "$#" -eq 0 ]; then
                _kam_argv_rc=1
                continue
            fi
            if [ -n "$1" ] && [ "$1" != "$_kam_argv_field" ]; then
                _kam_argv_rc=1
            fi
            shift
        done <"$_kam_argv_file"
    else
        # One `tr` converts the NUL separated argv. The sentinel preserves a
        # trailing empty field that command substitution would otherwise strip,
        # so an explicitly empty last argument is still counted.
        _kam_argv_dump="$( {
            tr '\0' '\n' <"$_kam_argv_file"
            printf 'x'
        } )"
        # Each line is compared only once the next one has been read, so the
        # sentinel is left pending at EOF and never treated as an argument.
        _kam_argv_pending=0
        _kam_argv_prev=""
        while IFS= read -r _kam_argv_field; do
            if [ "$_kam_argv_pending" = 1 ]; then
                if [ "$#" -eq 0 ]; then
                    _kam_argv_rc=1
                elif [ -n "$1" ] && [ "$1" != "$_kam_argv_prev" ]; then
                    _kam_argv_rc=1
                    shift
                else
                    shift
                fi
            fi
            _kam_argv_prev="$_kam_argv_field"
            _kam_argv_pending=1
        done <<EOF
$_kam_argv_dump
EOF
    fi
    # Expected values left over mean the process had fewer arguments.
    [ "$#" -eq 0 ] || _kam_argv_rc=1

    unset _kam_argv_pid _kam_argv_file _kam_argv_field _kam_argv_dump
    unset _kam_argv_pending _kam_argv_prev
    return "$_kam_argv_rc"
}

# kam_stop_pids_by_argv <expected-argv0> [<expected-argv1> ...]
#
# Terminate every process whose argv matches exactly, then escalate to SIGKILL
# for the ones that ignored SIGTERM. Prints how many were signalled.
kam_stop_pids_by_argv() {
    [ "$#" -gt 0 ] || return 1
    _kam_stop_pids=""
    _kam_stop_count=0
    for _kam_stop_entry in /proc/[0-9]*; do
        _kam_stop_pid="${_kam_stop_entry#/proc/}"
        case "$_kam_stop_pid" in
        "" | *[!0-9]*) continue ;;
        esac
        # Written as an `if` rather than `[ ... ] && continue`: the latter makes
        # the loop body return non-zero for every pid that is not this one,
        # which aborts the caller under `set -e`.
        if [ "$_kam_stop_pid" = "$$" ]; then
            continue
        fi
        kam_pid_argv_matches "$_kam_stop_pid" "$@" || continue
        kill "$_kam_stop_pid" 2>/dev/null || true
        _kam_stop_pids="$_kam_stop_pids $_kam_stop_pid"
        _kam_stop_count=$((_kam_stop_count + 1))
    done
    if [ -n "$_kam_stop_pids" ]; then
        sleep 1
        for _kam_stop_pid in $_kam_stop_pids; do
            kill -0 "$_kam_stop_pid" 2>/dev/null || continue
            # The pid could have been recycled during the grace period, and
            # SIGKILL on a stranger cannot be taken back. Re-verify identity.
            kam_pid_argv_matches "$_kam_stop_pid" "$@" || continue
            kill -9 "$_kam_stop_pid" 2>/dev/null || true
        done
    fi
    print "$_kam_stop_count"
    unset _kam_stop_pids _kam_stop_count _kam_stop_entry _kam_stop_pid
}

# 其他分支暂不计入
# 如有必要欢迎提交PR补全！
get_manager() {
    if [ -n "$_GM_CACHE" ]; then
        print "$_GM_CACHE"
        return 0
    fi

    _gm_type="unknown"
    if command -v magisk >/dev/null 2>&1; then
        _gm_type="magisk"
    elif [ -f "/data/adb/ksud" ] || command -v ksud >/dev/null 2>&1; then
        _gm_type="ksud"
    elif [ -f "/data/adb/apd" ] || command -v apd >/dev/null 2>&1; then
        _gm_type="ap"
    fi

    _GM_CACHE="$_gm_type"
    print "$_gm_type"
    unset _gm_type
}

is_magisk() {
    _im_mgr=$(get_manager)
    [ "$_im_mgr" = "magisk" ]
}

is_ksu() {
    _ik_mgr=$(get_manager)
    [ "$_ik_mgr" = "ksud" ]
}

is_ap() {
    _ia_mgr=$(get_manager)
    [ "$_ia_mgr" = "ap" ]
}
