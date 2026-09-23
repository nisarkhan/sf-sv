# Installing

Pick one line, run it from this folder, then follow the two commands it prints.

    ./scripts/install.sh                      # you paste your own Context7 key
    ./scripts/install.sh --oauth              # sign in to Context7 in the browser, nothing to paste
    ./scripts/install.sh --proxy https://...  # team gateway, no key on your machine at all

The script is safe to run twice. It appends to your shell file only if the line
is not already there, backs up ~/.claude/settings.json before editing it, and
never removes anything.
