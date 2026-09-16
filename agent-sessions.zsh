# Optional zsh hook for agent-sessions.
# Records the last commands run in each iTerm2 tab. `agent-sessions restore`
# prints them when it reopens the tab, so you can see what you were doing.
#
# Install: source this file from your ~/.zshrc.

autoload -Uz add-zsh-hook

_agent_sessions_record_command() {
  [[ -n "${ITERM_SESSION_ID:-}" ]] || return
  local session_id="${ITERM_SESSION_ID##*:}"
  [[ -n "$session_id" && "$session_id" != *[^A-Za-z0-9-]* ]] || return

  local state_root="${XDG_STATE_HOME:-$HOME/.local/state}"
  local history_dir="$state_root/agent-sessions/commands"
  local history_file="$history_dir/$session_id.log"
  local command_text="${1//$'\n'/ ↩ }"
  case "$command_text" in
    ": __agent_sessions_restore__;"*|"agent-sessions park"*|"agent-sessions close"*|"agent-sessions save"*) return ;;
  esac
  (umask 077; mkdir -p -- "$history_dir") 2>/dev/null || return
  if [[ ! -e "$history_file" ]]; then
    (umask 077; : > "$history_file") 2>/dev/null || return
  fi
  print -r -- "$command_text" >> "$history_file"

  if (( $(wc -l < "$history_file") > 50 )); then
    tail -n 25 "$history_file" > "$history_file.tmp" &&
      mv -f "$history_file.tmp" "$history_file"
  fi
}

add-zsh-hook preexec _agent_sessions_record_command
