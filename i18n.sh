# shellcheck shell=ash
##########################################################################################
# KAM Framework - Internationalization (i18n) Module
# Optimized for multi-line text and ash environment (2025 Revised)
##########################################################################################
# Ã¨Â®Â¾Ã§Â½Â®Ã¥â€ºÂ½Ã©â„¢â€¦Ã¥Å’â€“Ã¦â€“â€¡Ã¦Å“Â¬
# Ã§â€Â¨Ã¦Â³â€¢: set_i18n "KEY" "zh" "Ã¦â€“â€¡Ã¦Å“Â¬Ã¥â€ â€¦Ã¥Â®Â¹" "en" "Text Content" ...
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
# Ã¨Å½Â·Ã¥Ââ€“Ã¥Â¹Â¶Ã¦â€°â€œÃ¥ÂÂ°Ã¥â€ºÂ½Ã©â„¢â€¦Ã¥Å’â€“Ã¦â€“â€¡Ã¦Å“Â¬
# Ã§â€Â¨Ã¦Â³â€¢: i18n "WELCOME_MSG"
i18n() {
    _i1_key="$1"

    # Ã¨Å½Â·Ã¥Ââ€“Ã¥Â½â€œÃ¥â€°ÂÃ¨Â¯Â­Ã¨Â¨â‚¬Ã¤Â¼ËœÃ¥â€¦Ë†Ã§ÂºÂ§: KAM_UI_LANGUAGE > KAM_LANG (legacy) > Ã§Â³Â»Ã§Â»Å¸Ã¥Â±Å¾Ã¦â‚¬Â§ > Ã©Â»ËœÃ¨Â®Â¤ en
    _i1_lang="${KAM_UI_LANGUAGE:-${KAM_LANG:-$(getprop persist.sys.locale 2>/dev/null | cut -d'-' -f1)}}"
    _i1_lang="${_i1_lang:-en}"

    # Ã¥Â¦â€šÃ¦Å¾Å“Ã¤Â½Â¿Ã§â€Â¨Ã¤Âºâ€  legacy KAM_LANG Ã¥Â¹Â¶Ã¤Â¸â€Ã¥ÂÂ¯Ã§â€Â¨Ã¤Âºâ€ Ã¨Â°Æ’Ã¨Â¯â€¢Ã¯Â¼Ë†KAM_DEBUG_I18N=1Ã¯Â¼â€°Ã¯Â¼Å’Ã¥Ë†â„¢Ã¦â€°â€œÃ¥ÂÂ°Ã¥Â¼Æ’Ã§â€Â¨Ã¦ÂÂÃ§Â¤Âº
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

    # Ã¤Â½Â¿Ã§â€Â¨ eval Ã§â€ºÂ´Ã¦Å½Â¥Ã¨Â¯Â»Ã¥Ââ€“Ã¥ÂËœÃ©â€¡ÂÃ¯Â¼Å’Ã¤Â»Â¥Ã¦â€Â¯Ã¦Å’ÂÃ¥Â¤Å¡Ã¨Â¡Å’Ã¥â€ â€¦Ã¥Â®Â¹
    eval "_i1_text=\$${_i1_var_name}"

    # Ã¨â€¡ÂªÃ¥Å Â¨Ã¥â€ºÅ¾Ã©â‚¬â‚¬Ã¦Å“ÂºÃ¥Ë†Â¶Ã¯Â¼Å¡Ã¥Â¦â€šÃ¦Å¾Å“Ã§â€ºÂ®Ã¦Â â€¡Ã¨Â¯Â­Ã¨Â¨â‚¬Ã¤Â¸ÂºÃ§Â©ÂºÃ¤Â¸â€Ã¤Â¸ÂÃ¦ËœÂ¯Ã¨â€¹Â±Ã¦â€“â€¡Ã¯Â¼Å’Ã¥Â°ÂÃ¨Â¯â€¢Ã¨Â¯Â»Ã¥Ââ€“Ã¨â€¹Â±Ã¦â€“â€¡
    if [ -z "$_i1_text" ] && [ "$_i1_lang" != "en" ]; then
        _i1_var_name="_I18N_${_i1_key}_en"
        eval "_i1_text=\$${_i1_var_name}"
    fi

    # Ã¥Â¦â€šÃ¦Å¾Å“Ã¤Â¾ÂÃ§â€žÂ¶Ã¤Â¸ÂºÃ§Â©ÂºÃ¯Â¼Å’Ã¥Ë†â„¢Ã¨Â¿â€Ã¥â€ºÅ¾ Key Ã¥ÂÂÃ¦Å“Â¬Ã¨ÂºÂ«
    if [ -z "$_i1_text" ]; then
        print "$_i1_key"
    else
        # Ã¥Â±â€¢Ã¥Â¼â‚¬Ã¨Â½Â¬Ã¤Â¹â€°Ã¥ÂºÂÃ¥Ë†â€”Ã¯Â¼Ë†Ã¥Â¦â€š \nÃ¯Â¼â€°Ã¥â€ ÂÃ¤Â½Â¿Ã§â€Â¨ print Ã¨Â¾â€œÃ¥â€¡ÂºÃ¯Â¼Å’Ã¤Â¿ÂÃ¦Å’ÂÃ¨Â¾â€œÃ¥â€¡ÂºÃ¥â€¡Â½Ã¦â€¢Â°Ã¤Â¸â‚¬Ã¨â€¡Â´Ã¦â‚¬Â§
        _i1_out=$(printf '%b' "$_i1_text")
        print "$_i1_out"
    fi

    unset _i1_key _i1_lang _i1_var_name _i1_text
}

# Ã¤Â»Å½Ã¦â€“â€¡Ã¤Â»Â¶Ã¥Å Â Ã¨Â½Â½ I18N Ã¦â€¢Â°Ã¦ÂÂ®
load_i18n() {
    _lic_file="$1"
    [ -f "$_lic_file" ] || return 1

    _lic_langs=""
    while IFS= read -r _lic_line || [ -n "$_lic_line" ]; do
        case "$_lic_line" in
        \#* | "") continue ;;
        esac

        # Ã¨Â§Â£Ã¦Å¾ÂÃ¨Â¡Â¨Ã¥Â¤Â´ KEY|zh|en...
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

# Ã¥Â¯Â¼Ã¥â€¡ÂºÃ¥Â½â€œÃ¥â€°Â I18N Ã¦â€¢Â°Ã¦ÂÂ®Ã¥Ë†Â°Ã¦â€“â€¡Ã¤Â»Â¶
dump_i18n() {
    _dic_file="$1"
    [ -n "$_dic_file" ] || return 1

    _dic_langs=$(env | grep '^_I18N_' | sed -n 's/^_I18N_.*_\([^=]*\)=.*/\1/p' | sort -u)
    [ -z "$_dic_langs" ] && _dic_langs="zh en ja ko"

    # Ã¦â€°â€œÃ¥ÂÂ°Ã¨Â¡Â¨Ã¥Â¤Â´
    _hdr="KEY"
    for _lang in $_dic_langs; do _hdr="${_hdr}|${_lang}"; done
    printf '%s\n' "$_hdr" >"$_dic_file"

    _dic_keys=$(env | grep '^_I18N_' | sed -n 's/^_I18N_\(.*\)_\([^=]*\)=.*/\1/p' | sort -u)

    for _dic_k in $_dic_keys; do
        _out="${_dic_k}"
        for _lang in $_dic_langs; do
            _var="_I18N_${_dic_k}_${_lang}"
            eval "_val=\$${_var}"
            # Ã¥Â¯Â¼Ã¥â€¡ÂºÃ¦â€”Â¶Ã¥Â°â€ Ã§Å“Å¸Ã¥Â®Å¾Ã¦ÂÂ¢Ã¨Â¡Å’Ã§Â¬Â¦Ã¨Â½Â¬Ã¤Â¹â€°Ã¤Â¸Âº \n Ã¥Â­â€”Ã§Â¬Â¦Ã¤Â¸Â²Ã¤Â»Â¥Ã¤Â¾Â¿Ã¥Ââ€¢Ã¨Â¡Å’Ã¥Â­ËœÃ¥â€šÂ¨
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
