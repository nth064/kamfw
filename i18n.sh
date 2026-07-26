#!/bin/sh
set_i18n() {
    _s_key="$1"; shift
    case "$_s_key" in ""|*[!A-Za-z0-9_]*|[0-9]*) return 2;; esac
    [ $(( $# % 2 )) -eq 0 ] || return 2
    _s_tmp=$(mktemp -d "${TMPDIR:-/tmp}/kam-i18n.XXXXXX") || return 1
    _s_idx=0
    while [ $# -ge 2 ]; do
        _s_lang="$1"; _s_text="$2"; shift 2
        case "$_s_lang" in ""|*[!A-Za-z0-9_-]*|[0-9_]*) rm -rf "$_s_tmp"; return 2;; esac
        printf '%s' "$_s_lang" >"$_s_tmp/${_s_idx}.lang"
        printf '%s' "$_s_text" >"$_s_tmp/${_s_idx}.text"
        _s_idx=$((_s_idx + 1))
    done
    _s_idx=0
    while [ -f "$_s_tmp/${_s_idx}.lang" ]; do
        _s_lang=$(cat "$_s_tmp/${_s_idx}.lang"); _s_text=$(cat "$_s_tmp/${_s_idx}.text")
        _s_safe_lang=$(printf '%s' "$_s_lang" | tr '-' '_')
        _s_var_name="_I18N_${_s_key}_${_s_safe_lang}"
        export "$_s_var_name=$_s_text"
        _s_idx=$((_s_idx + 1))
    done
    rm -rf "$_s_tmp"
    unset _s_key _s_lang _s_text _s_safe_lang _s_var_name _s_tmp _s_idx
}
i18n() {
    _i1_key="$1"
    case "$_i1_key" in ""|*[!A-Za-z0-9_]*|[0-9]*) return 2;; esac
    _i1_lang="${KAM_UI_LANGUAGE:-${KAM_LANG:-$(getprop persist.sys.locale 2>/dev/null | cut -d'-' -f1)}}"; _i1_lang="${_i1_lang:-en}"
    case "$_i1_lang" in zh*|cn*|CN*) _i1_lang=zh;; ja*|JP*) _i1_lang=ja;; ko*|KR*) _i1_lang=ko;; *) _i1_lang=en;; esac
    _i1_var_name="_I18N_${_i1_key}_${_i1_lang}"
    eval "_i1_text=\${${_i1_var_name}:-}"
    if [ -z "$_i1_text" ] && [ "$_i1_lang" != en ]; then _i1_var_name="_I18N_${_i1_key}_en"; eval "_i1_text=\${${_i1_var_name}:-}"; fi
    if [ -z "$_i1_text" ]; then print "$_i1_key"; else printf '%b\n' "$_i1_text"; fi
    unset _i1_key _i1_lang _i1_var_name _i1_text
}
load_i18n() {
    _lic_file="$1"; [ -f "$_lic_file" ] || return 1
    _lic_langs="zh en ja ko"; _lic_expected=5; _lic_seen=0
    while IFS= read -r _lic_line || [ -n "$_lic_line" ]; do
        case "$_lic_line" in \#*|"") continue;; esac
        if [ "$_lic_seen" -eq 0 ]; then
            case "$_lic_line" in KEY\|*)
                _lic_hdr=${_lic_line#KEY|}; case "$_lic_hdr" in *\|\|*|\|*|*\|) return 1;; esac
                _lic_langs=$(printf '%s' "$_lic_hdr" | tr '|' ' '); _lic_expected=$(printf '%s' "$_lic_line" | awk -F'|' '{print NF}');
                for _lic_lang in $_lic_langs; do case "$_lic_lang" in ""|*[!A-Za-z0-9_-]*|[0-9_]*) return 1;; esac; done
                _lic_seen=1; continue;; esac
            _lic_seen=1
        fi
        _lic_fields=$(printf '%s' "$_lic_line" | awk -F'|' '{print NF}'); [ "$_lic_fields" -eq "$_lic_expected" ] || return 1
        _lic_key=${_lic_line%%|*}; case "$_lic_key" in ""|*[!A-Za-z0-9_]*|[0-9]*) return 1;; esac
    done <"$_lic_file"
    while IFS= read -r _lic_line || [ -n "$_lic_line" ]; do
        case "$_lic_line" in \#*|""|KEY\|*) continue;; esac
        _lic_key=${_lic_line%%|*}; _field_idx=2
        for _lic_lang in $_lic_langs; do _lic_val=$(printf '%s' "$_lic_line" | cut -d'|' -f"$_field_idx"); set_i18n "$_lic_key" "$_lic_lang" "$_lic_val" || return 1; _field_idx=$((_field_idx+1)); done
    done <"$_lic_file"
    unset _lic_file _lic_line _lic_hdr _lic_langs _lic_expected _lic_seen _lic_fields _lic_key _field_idx _lic_lang _lic_val
}
dump_i18n() { return 0; }
t() { cat; }
import i18ns
