# Installing

Run these from the repo root, not from inside scripts/.
If you get "permission denied", run `chmod +x scripts/install.sh` first, or
use `bash scripts/install.sh` which needs no permission change.

Pick one line, then follow the two commands it prints.

    ./scripts/install.sh                      # you paste your own Context7 key
    ./scripts/install.sh --oauth              # sign in to Context7 in the browser, nothing to paste
    ./scripts/install.sh --proxy https://...  # team gateway, no key on your machine at all

The script is safe to run twice. It appends to your shell file only if the line
is not already there, backs up ~/.claude/settings.json before editing it, and
never removes anything.
