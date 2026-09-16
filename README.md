# agent-sessions

Resume Claude Code and Codex CLI sessions as iTerm2 tabs. Park a whole tab
layout and restore it later.

One file. Python 3 standard library only. macOS + iTerm2.

## What it does

`agent-sessions` reads the session stores that Claude Code (`~/.claude`) and
Codex (`~/.codex`) already keep on disk. It shows both in one list, newest
first, and marks the sessions that are open in an iTerm2 tab right now.

```
Agent sessions  ● open in iTerm2
Space select  Enter open tabs  / search  a all  c clear  q quit

SESSION                                    │ CONTENT
[ ] ● 3m      Claude                       │ First  Fix the flaky test in auth
    ~/Code/app                             │ Last   Run the suite again
[ ]   2h      Codex                        │ First  Add retry to the uploader
    ~/Code/uploader                        │ Last   Looks good, ship it
```

Select one or more sessions and press Enter. Each one opens in a new iTerm2
tab, in its original directory, with `claude --resume` or `codex resume`
already running.

### Park and restore

`agent-sessions park` snapshots every open iTerm2 tab, then closes them all.
`agent-sessions restore` reopens the layout:

- Agent tabs resume their Claude Code or Codex session.
- Shell tabs reopen in the same directory.
- Service tabs (dev servers, watchers) reopen in the same directory, but the
  service does not restart.

With the optional zsh hook, restored shell tabs also print the last commands
you ran before you parked, so you can pick up where you left off.

### Headless runs are hidden

Automation that drives Claude Code through `claude -p` or the Agent SDK writes
transcripts to the same `~/.claude/projects` tree as interactive sessions.
`agent-sessions` filters those out (`entrypoint: "sdk-cli"`), so the list only
shows sessions you can meaningfully resume. Codex `exec` runs and sub-agent
threads are filtered the same way.

## Install

Requirements:

- macOS with iTerm2. The first run asks for Automation permission.
- `python3` (the Xcode Command Line Tools copy is enough).
- `claude` and/or `codex` on your `PATH`. Either one is optional.

Install the script:

```sh
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/mattvickersnz/agent-sessions/main/agent-sessions \
  -o ~/.local/bin/agent-sessions
chmod +x ~/.local/bin/agent-sessions
```

Make sure `~/.local/bin` is on your `PATH`.

Optional — install the zsh hook so `restore` can show recent commands:

```sh
mkdir -p ~/.config/agent-sessions
curl -fsSL https://raw.githubusercontent.com/mattvickersnz/agent-sessions/main/agent-sessions.zsh \
  -o ~/.config/agent-sessions/agent-sessions.zsh
echo 'source ~/.config/agent-sessions/agent-sessions.zsh' >> ~/.zshrc
```

## Usage

```
agent-sessions                # interactive picker (default)
agent-sessions --list         # print sessions and exit
agent-sessions --json         # print session metadata as JSON
agent-sessions --agent claude # only Claude Code sessions
agent-sessions --days 7       # sessions updated in the last 7 days

agent-sessions save           # snapshot the iTerm2 layout, keep tabs open
agent-sessions park           # snapshot, then close every tab
agent-sessions restore        # reopen the last snapshot
agent-sessions park --dry-run # show what would happen
```

Snapshots live in `$XDG_STATE_HOME/agent-sessions/last.json`
(default `~/.local/state/agent-sessions/last.json`). Pass `--file` to use a
different path.

## How it finds sessions

- **Claude Code** — scans `~/.claude/projects/*/*.jsonl`. Reads the head of
  each file for the session id, working directory, and first prompt. Skips
  sidechain (sub-agent) transcripts and headless `sdk-cli` runs.
- **Codex** — reads `~/.codex/state_5.sqlite` (read-only). Falls back to the
  rollout files under `~/.codex/sessions` if the database is missing. Skips
  `exec` runs and named sub-agent threads.
- **Open sessions** — matches the `claude` and `codex` processes on each
  iTerm2 tty back to their session ids via `~/.claude/sessions/*.json` and
  `lsof`.

## Prior art

- [Cepstral/claude-codex-resume](https://github.com/Cepstral/claude-codex-resume)
  does the same picker for Windows Terminal, in PowerShell.
- [asadtariq96/cc-session-restore](https://github.com/asadtariq96/cc-session-restore)
  reopens Claude Code sessions in iTerm2 after a reboot.
- [mimen/claude-sessions](https://github.com/mimen/claude-sessions) and
  [tradchenko/claude-sessions](https://github.com/tradchenko/claude-sessions)
  are cross-directory pickers without the iTerm2 layout features.

## License

MIT.
