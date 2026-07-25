# shellcheck shell=ash
##########################################################################################
# KAM Framework - Internationalization (i18n) Module
# Optimized for multi-line text and ash environment (2025 Revised)
##########################################################################################
# ÃƒÂ¨Ã‚Â®Ã‚Â¾ÃƒÂ§Ã‚Â½Ã‚Â®ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â½ÃƒÂ©Ã¢â€žÂ¢Ã¢â‚¬Â¦ÃƒÂ¥Ã…â€™Ã¢â‚¬â€œÃƒÂ¦Ã¢â‚¬â€œÃ¢â‚¬Â¡ÃƒÂ¦Ã…â€œÃ‚Â¬
# ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¦Ã‚Â³Ã¢â‚¬Â¢: set_i18n "KEY" "zh" "ÃƒÂ¦Ã¢â‚¬â€œÃ¢â‚¬Â¡ÃƒÂ¦Ã…â€œÃ‚Â¬ÃƒÂ¥Ã¢â‚¬Â Ã¢â‚¬Â¦ÃƒÂ¥Ã‚Â®Ã‚Â¹" "en" "Text Content" ...
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
        ""|*[!A-Za-z0-9_-]*|[0-9_]*) rm -rf "$_s_tmp"; return 2 ;;
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
# ÃƒÂ¨Ã…Â½Ã‚Â·ÃƒÂ¥Ã‚ÂÃ¢â‚¬â€œÃƒÂ¥Ã‚Â¹Ã‚Â¶ÃƒÂ¦Ã¢â‚¬Â°Ã¢â‚¬Å“ÃƒÂ¥Ã‚ÂÃ‚Â°ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â½ÃƒÂ©Ã¢â€žÂ¢Ã¢â‚¬Â¦ÃƒÂ¥Ã…â€™Ã¢â‚¬â€œÃƒÂ¦Ã¢â‚¬â€œÃ¢â‚¬Â¡ÃƒÂ¦Ã…â€œÃ‚Â¬
# ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¦Ã‚Â³Ã¢â‚¬Â¢: i18n "WELCOME_MSG"
i18n() {
    _i1_key="$1"
    case "$_i1_key" in
    ""|*[!A-Za-z0-9_]*|[0-9]*) return 2 ;;
    esac

    # ÃƒÂ¨Ã…Â½Ã‚Â·ÃƒÂ¥Ã‚ÂÃ¢â‚¬â€œÃƒÂ¥Ã‚Â½Ã¢â‚¬Å“ÃƒÂ¥Ã¢â‚¬Â°Ã‚ÂÃƒÂ¨Ã‚Â¯Ã‚Â­ÃƒÂ¨Ã‚Â¨Ã¢â€šÂ¬ÃƒÂ¤Ã‚Â¼Ã‹Å“ÃƒÂ¥Ã¢â‚¬Â¦Ã‹â€ ÃƒÂ§Ã‚ÂºÃ‚Â§: KAM_UI_LANGUAGE > KAM_LANG (legacy) > ÃƒÂ§Ã‚Â³Ã‚Â»ÃƒÂ§Ã‚Â»Ã…Â¸ÃƒÂ¥Ã‚Â±Ã…Â¾ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â§ > ÃƒÂ©Ã‚Â»Ã‹Å“ÃƒÂ¨Ã‚Â®Ã‚Â¤ en
    _i1_lang="${KAM_UI_LANGUAGE:-${KAM_LANG:-$(getprop persist.sys.locale 2>/dev/null | cut -d'-' -f1)}}"
    _i1_lang="${_i1_lang:-en}"

    # ÃƒÂ¥Ã‚Â¦Ã¢â‚¬Å¡ÃƒÂ¦Ã…Â¾Ã…â€œÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â  legacy KAM_LANG ÃƒÂ¥Ã‚Â¹Ã‚Â¶ÃƒÂ¤Ã‚Â¸Ã¢â‚¬ÂÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â ÃƒÂ¨Ã‚Â°Ã†â€™ÃƒÂ¨Ã‚Â¯Ã¢â‚¬Â¢ÃƒÂ¯Ã‚Â¼Ã‹â€ KAM_DEBUG_I18N=1ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¥Ã‹â€ Ã¢â€žÂ¢ÃƒÂ¦Ã¢â‚¬Â°Ã¢â‚¬Å“ÃƒÂ¥Ã‚ÂÃ‚Â°ÃƒÂ¥Ã‚Â¼Ã†â€™ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¦Ã‚ÂÃ‚ÂÃƒÂ§Ã‚Â¤Ã‚Âº
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

    # ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ eval ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ¦Ã…Â½Ã‚Â¥ÃƒÂ¨Ã‚Â¯Ã‚Â»ÃƒÂ¥Ã‚ÂÃ¢â‚¬â€œÃƒÂ¥Ã‚ÂÃ‹Å“ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¤Ã‚Â»Ã‚Â¥ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¯ÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ¥Ã‚Â¤Ã…Â¡ÃƒÂ¨Ã‚Â¡Ã…â€™ÃƒÂ¥Ã¢â‚¬Â Ã¢â‚¬Â¦ÃƒÂ¥Ã‚Â®Ã‚Â¹
    eval "_i1_text=\$${_i1_var_name}"

    # ÃƒÂ¨Ã¢â‚¬Â¡Ã‚ÂªÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ©Ã¢â€šÂ¬Ã¢â€šÂ¬ÃƒÂ¦Ã…â€œÃ‚ÂºÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¯Ã‚Â¼Ã…Â¡ÃƒÂ¥Ã‚Â¦Ã¢â‚¬Å¡ÃƒÂ¦Ã…Â¾Ã…â€œÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â Ã¢â‚¬Â¡ÃƒÂ¨Ã‚Â¯Ã‚Â­ÃƒÂ¨Ã‚Â¨Ã¢â€šÂ¬ÃƒÂ¤Ã‚Â¸Ã‚ÂºÃƒÂ§Ã‚Â©Ã‚ÂºÃƒÂ¤Ã‚Â¸Ã¢â‚¬ÂÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¦Ã‹Å“Ã‚Â¯ÃƒÂ¨Ã¢â‚¬Â¹Ã‚Â±ÃƒÂ¦Ã¢â‚¬â€œÃ¢â‚¬Â¡ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¥Ã‚Â°Ã‚ÂÃƒÂ¨Ã‚Â¯Ã¢â‚¬Â¢ÃƒÂ¨Ã‚Â¯Ã‚Â»ÃƒÂ¥Ã‚ÂÃ¢â‚¬â€œÃƒÂ¨Ã¢â‚¬Â¹Ã‚Â±ÃƒÂ¦Ã¢â‚¬â€œÃ¢â‚¬Â¡
    if [ -z "$_i1_text" ] && [ "$_i1_lang" != "en" ]; then
        _i1_var_name="_I18N_${_i1_key}_en"
        eval "_i1_text=\$${_i1_var_name}"
    fi

    # ÃƒÂ¥Ã‚Â¦Ã¢â‚¬Å¡ÃƒÂ¦Ã…Â¾Ã…â€œÃƒÂ¤Ã‚Â¾Ã‚ÂÃƒÂ§Ã¢â‚¬Å¾Ã‚Â¶ÃƒÂ¤Ã‚Â¸Ã‚ÂºÃƒÂ§Ã‚Â©Ã‚ÂºÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¥Ã‹â€ Ã¢â€žÂ¢ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ Key ÃƒÂ¥Ã‚ÂÃ‚ÂÃƒÂ¦Ã…â€œÃ‚Â¬ÃƒÂ¨Ã‚ÂºÃ‚Â«
    if [ -z "$_i1_text" ]; then
        print "$_i1_key"
    else
        # ÃƒÂ¥Ã‚Â±Ã¢â‚¬Â¢ÃƒÂ¥Ã‚Â¼Ã¢â€šÂ¬ÃƒÂ¨Ã‚Â½Ã‚Â¬ÃƒÂ¤Ã‚Â¹Ã¢â‚¬Â°ÃƒÂ¥Ã‚ÂºÃ‚ÂÃƒÂ¥Ã‹â€ Ã¢â‚¬â€ÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ¥Ã‚Â¦Ã¢â‚¬Å¡ \nÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ¥Ã¢â‚¬Â Ã‚ÂÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ print ÃƒÂ¨Ã‚Â¾Ã¢â‚¬Å“ÃƒÂ¥Ã¢â‚¬Â¡Ã‚ÂºÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ¨Ã‚Â¾Ã¢â‚¬Å“ÃƒÂ¥Ã¢â‚¬Â¡Ã‚ÂºÃƒÂ¥Ã¢â‚¬Â¡Ã‚Â½ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¨Ã¢â‚¬Â¡Ã‚Â´ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â§
        _i1_out=$(printf '%b' "$_i1_text")
        print "$_i1_out"
    fi

    unset _i1_key _i1_lang _i1_var_name _i1_text
}

# ÃƒÂ¤Ã‚Â»Ã…Â½ÃƒÂ¦Ã¢â‚¬â€œÃ¢â‚¬Â¡ÃƒÂ¤Ã‚Â»Ã‚Â¶ÃƒÂ¥Ã…Â Ã‚Â ÃƒÂ¨Ã‚Â½Ã‚Â½ I18N ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®
load_i18n() {
    _lic_file="$1"
    [ -f "$_lic_file" ] || return 1

    _lic_langs=""
    while IFS= read -r _lic_line || [ -n "$_lic_line" ]; do
        case "$_lic_line" in
        \#* | "") continue ;;
        esac

        # ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ¦Ã…Â¾Ã‚ÂÃƒÂ¨Ã‚Â¡Ã‚Â¨ÃƒÂ¥Ã‚Â¤Ã‚Â´ KEY|zh|en...
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

# ÃƒÂ¥Ã‚Â¯Ã‚Â¼ÃƒÂ¥Ã¢â‚¬Â¡Ã‚ÂºÃƒÂ¥Ã‚Â½Ã¢â‚¬Å“ÃƒÂ¥Ã¢â‚¬Â°Ã‚Â I18N ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®ÃƒÂ¥Ã‹â€ Ã‚Â°ÃƒÂ¦Ã¢â‚¬â€œÃ¢â‚¬Â¡ÃƒÂ¤Ã‚Â»Ã‚Â¶
dump_i18n() {
    _dic_file="$1"
    [ -n "$_dic_file" ] || return 1

    _dic_langs=$(env | grep '^_I18N_' | sed -n 's/^_I18N_.*_\([^=]*\)=.*/\1/p' | sort -u)
    [ -z "$_dic_langs" ] && _dic_langs="zh en ja ko"

    # ÃƒÂ¦Ã¢â‚¬Â°Ã¢â‚¬Å“ÃƒÂ¥Ã‚ÂÃ‚Â°ÃƒÂ¨Ã‚Â¡Ã‚Â¨ÃƒÂ¥Ã‚Â¤Ã‚Â´
    _hdr="KEY"
    for _lang in $_dic_langs; do _hdr="${_hdr}|${_lang}"; done
    printf '%s\n' "$_hdr" >"$_dic_file"

    _dic_keys=$(env | grep '^_I18N_' | sed -n 's/^_I18N_\(.*\)_\([^=]*\)=.*/\1/p' | sort -u)

    for _dic_k in $_dic_keys; do
        _out="${_dic_k}"
        for _lang in $_dic_langs; do
            _var="_I18N_${_dic_k}_${_lang}"
            eval "_val=\$${_var}"
            # ÃƒÂ¥Ã‚Â¯Ã‚Â¼ÃƒÂ¥Ã¢â‚¬Â¡Ã‚ÂºÃƒÂ¦Ã¢â‚¬â€Ã‚Â¶ÃƒÂ¥Ã‚Â°Ã¢â‚¬Â ÃƒÂ§Ã…â€œÃ…Â¸ÃƒÂ¥Ã‚Â®Ã…Â¾ÃƒÂ¦Ã‚ÂÃ‚Â¢ÃƒÂ¨Ã‚Â¡Ã…â€™ÃƒÂ§Ã‚Â¬Ã‚Â¦ÃƒÂ¨Ã‚Â½Ã‚Â¬ÃƒÂ¤Ã‚Â¹Ã¢â‚¬Â°ÃƒÂ¤Ã‚Â¸Ã‚Âº \n ÃƒÂ¥Ã‚Â­Ã¢â‚¬â€ÃƒÂ§Ã‚Â¬Ã‚Â¦ÃƒÂ¤Ã‚Â¸Ã‚Â²ÃƒÂ¤Ã‚Â»Ã‚Â¥ÃƒÂ¤Ã‚Â¾Ã‚Â¿ÃƒÂ¥Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ¨Ã‚Â¡Ã…â€™ÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¥Ã¢â‚¬Å¡Ã‚Â¨
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
