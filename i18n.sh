# shellcheck shell=ash
##########################################################################################
# KAM Framework - Internationalization (i18n) Module
# Optimized for multi-line text and ash environment (2025 Revised)
##########################################################################################
# è®¾ç½®å›½é™…åŒ–æ–‡æœ¬
# ç”¨æ³•: set_i18n "KEY" "zh" "æ–‡æœ¬å†…å®¹" "en" "Text Content" ...
set_i18n() {
    _s_key="$1"
    shift
    case "$_s_key" in
    ""|*[!A-Za-z0-9_]*|[0-9]*) return 2 ;;
    esac
    [ $(( $# % 2 )) -eq 0 ] || return 2
    _s_tmp=$(mktemp -d "${TMPDIR:-/tmp}/kam-i18n.XXXXXX") || return 1
    _s_index=0
    while [ $# -ge 2 ]; do
        _s_lang="$1"
        _s_text="$2"
        case "$_s_lang" in
        ""|*[!A-Za-z0-9_-]*|[0-9]*) rm -rf "$_s_tmp"; return 2 ;;
        esac
        printf %s "$_s_lang" >"$_s_tmp/$((_s_index)).lang"
        printf %s "$_s_text" >"$_s_tmp/$((_s_index)).text"
        _s_index=$((_s_index + 1))
        shift 2
    done
    _s_index=0
    while [ -f "$_s_tmp/$((_s_index)).lang" ]; do
        _s_lang=$(cat "$_s_tmp/$((_s_index)).lang")
        _s_text=$(cat "$_s_tmp/$((_s_index)).text")
        _s_safe_lang=$(printf %s "$_s_lang" | tr - _ )
        _s_var_name="_I18N_${_s_key}_${_s_safe_lang}"
        export "$_s_var_name=$_s_text"
        _s_index=$((_s_index + 1))
    done
    rm -rf "$_s_tmp"
    unset _s_key _s_lang _s_text _s_safe_lang _s_var_name _s_tmp _s_index
}
# èŽ·å–å¹¶æ‰“å°å›½é™…åŒ–æ–‡æœ¬
# ç”¨æ³•: i18n "WELCOME_MSG"
i18n() {
    _i1_key="$1"

    # èŽ·å–å½“å‰è¯­è¨€ä¼˜å…ˆçº§: KAM_UI_LANGUAGE > KAM_LANG (legacy) > ç³»ç»Ÿå±žæ€§ > é»˜è®¤ en
    _i1_lang="${KAM_UI_LANGUAGE:-${KAM_LANG:-$(getprop persist.sys.locale 2>/dev/null | cut -d'-' -f1)}}"
    _i1_lang="${_i1_lang:-en}"

    # å¦‚æžœä½¿ç”¨äº† legacy KAM_LANG å¹¶ä¸”å¯ç”¨äº†è°ƒè¯•ï¼ˆKAM_DEBUG_I18N=1ï¼‰ï¼Œåˆ™æ‰“å°å¼ƒç”¨æç¤º
    if [ -z "${KAM_UI_LANGUAGE:-}" ] && [ -n "${KAM_LANG:-}" ] && [ "${KAM_DEBUG_I18N:-}" = "1" ]; then
        print "Warning: KAM_LANG is deprecated; please use KAM_UI_LANGUAGE"
    fi

    case "$_i1_lang" in
    zh* | cn* | CN*) _i1_lang="zh" ;;
    ja* | JP*) _i1_lang="ja" ;;
    ko* | KR*) _i1_lang="ko" ;;
    *) _i1_lang="en" ;;
    esac

    _i1_var_name="_I18N_${_i1_key}_${_i1_lang}"

    # ä½¿ç”¨ eval ç›´æŽ¥è¯»å–å˜é‡ï¼Œä»¥æ”¯æŒå¤šè¡Œå†…å®¹
    eval "_i1_text=\$${_i1_var_name}"

    # è‡ªåŠ¨å›žé€€æœºåˆ¶ï¼šå¦‚æžœç›®æ ‡è¯­è¨€ä¸ºç©ºä¸”ä¸æ˜¯è‹±æ–‡ï¼Œå°è¯•è¯»å–è‹±æ–‡
    if [ -z "$_i1_text" ] && [ "$_i1_lang" != "en" ]; then
        _i1_var_name="_I18N_${_i1_key}_en"
        eval "_i1_text=\$${_i1_var_name}"
    fi

    # å¦‚æžœä¾ç„¶ä¸ºç©ºï¼Œåˆ™è¿”å›ž Key åæœ¬èº«
    if [ -z "$_i1_text" ]; then
        print "$_i1_key"
    else
        # å±•å¼€è½¬ä¹‰åºåˆ—ï¼ˆå¦‚ \nï¼‰å†ä½¿ç”¨ print è¾“å‡ºï¼Œä¿æŒè¾“å‡ºå‡½æ•°ä¸€è‡´æ€§
        _i1_out=$(printf '%b' "$_i1_text")
        print "$_i1_out"
    fi

    unset _i1_key _i1_lang _i1_var_name _i1_text
}

# ä»Žæ–‡ä»¶åŠ è½½ I18N æ•°æ®
load_i18n() {
    _lic_file="$1"
    [ -f "$_lic_file" ] || return 1

    _lic_langs=""
    while IFS= read -r _lic_line || [ -n "$_lic_line" ]; do
        case "$_lic_line" in
        \#* | "") continue ;;
        esac

        # è§£æžè¡¨å¤´ KEY|zh|en...
        if [ -z "$_lic_langs" ]; then
            case "$_lic_line" in
            KEY\|*)
                _lic_hdr="${_lic_line#KEY|}"
                _lic_langs=$(printf '%s' "$_lic_hdr" | tr '|' ' ')
                continue
                ;;
            esac
            _lic_langs="zh en ja ko"
        fi

        _lic_key=$(printf '%s' "$_lic_line" | cut -d'|' -f1)
        [ -z "$_lic_key" ] && continue

        _field_idx=2
        for _lic_lang in $_lic_langs; do
            _lic_val=$(printf '%s' "$_lic_line" | cut -d'|' -f"$_field_idx")
            set_i18n "$_lic_key" "$_lic_lang" "$_lic_val"
            _field_idx=$((_field_idx + 1))
        done
    done <"$_lic_file"

    unset _lic_file _lic_line _lic_hdr _lic_langs _lic_key _lic_val _field_idx _lic_lang
}

# å¯¼å‡ºå½“å‰ I18N æ•°æ®åˆ°æ–‡ä»¶
dump_i18n() {
    _dic_file="$1"
    [ -n "$_dic_file" ] || return 1

    _dic_langs=$(env | grep '^_I18N_' | sed -n 's/^_I18N_.*_\([^=]*\)=.*/\1/p' | sort -u)
    [ -z "$_dic_langs" ] && _dic_langs="zh en ja ko"

    # æ‰“å°è¡¨å¤´
    _hdr="KEY"
    for _lang in $_dic_langs; do _hdr="${_hdr}|${_lang}"; done
    printf '%s\n' "$_hdr" >"$_dic_file"

    _dic_keys=$(env | grep '^_I18N_' | sed -n 's/^_I18N_\(.*\)_\([^=]*\)=.*/\1/p' | sort -u)

    for _dic_k in $_dic_keys; do
        _out="${_dic_k}"
        for _lang in $_dic_langs; do
            _var="_I18N_${_dic_k}_${_lang}"
            eval "_val=\$${_var}"
            # å¯¼å‡ºæ—¶å°†çœŸå®žæ¢è¡Œç¬¦è½¬ä¹‰ä¸º \n å­—ç¬¦ä¸²ä»¥ä¾¿å•è¡Œå­˜å‚¨
            _val=$(printf '%s' "$_val" | sed ':a;N;$!ba;s/\n/\\n/g')
            _out="${_out}|${_val}"
        done
        printf '%s\n' "$_out" >>"$_dic_file"
    done

    unset _dic_file _dic_langs _hdr _dic_keys _dic_k _lang _var _val _out
}

# Template function for string substitution
# Usage: echo "Hello $_1" | t "World"
t() {
    # If no piped stdin, fall back to printing the first argument (if any)
    if [ -t 0 ]; then
        if [ $# -gt 0 ]; then
            print "$1"
        fi
        return 0
    fi

    # Read entire piped input
    _template=$(cat -)

    _idx=1
    while [ $# -gt 0 ]; do
        _arg="$1"
        # Escape characters that may interfere with sed replacement
        _esc=$(printf '%s' "$_arg" | sed -e 's/\\/\\\\/g' -e 's/&/\\\&/g' -e 's/|/\\|/g')
        # Replace occurrences of $_<index> with the escaped argument
        _template=$(printf '%s' "$_template" | sed "s|\\\$_${_idx}|${_esc}|g")
        shift
        _idx=$((_idx + 1))
    done

    print "$_template"
    unset _template _idx _arg _esc
}

import i18ns
