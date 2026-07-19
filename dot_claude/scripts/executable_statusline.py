#!/usr/bin/env python3
"""Pattern 5: Braille dots — dotted progress bar rendered with braille glyphs.

Reads the Claude Code statusLine JSON on stdin and prints a single line:

    <model> │ ctx <bar> NN% │ 5h <bar> NN% │ 7d <bar> NN%

Bars use braille density glyphs and a green→red gradient. Sections whose
metric is absent from the input are skipped.

Source: https://nyosegawa.com/posts/claude-code-statusline-rate-limits/
"""

import json
import sys

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

try:
    data = json.load(sys.stdin)
    if not isinstance(data, dict):
        data = {}
except Exception:
    data = {}

BRAILLE = " ⣀⣄⣤⣦⣶⣷⣿"  # index 0 (empty) .. 7 (full)
R = "\033[0m"
DIM = "\033[2m"


def gradient(pct):
    if pct < 50:
        r = int(pct * 5.1)
        return f"\033[38;2;{r};200;80m"
    g = int(200 - (pct - 50) * 4)
    return f"\033[38;2;255;{max(g, 0)};60m"


def braille_bar(pct, width=8):
    pct = min(max(pct, 0), 100)
    level = pct / 100
    bar = ""
    for i in range(width):
        seg_start = i / width
        seg_end = (i + 1) / width
        if level >= seg_end:
            bar += BRAILLE[7]
        elif level <= seg_start:
            bar += BRAILLE[0]
        else:
            frac = (level - seg_start) / (seg_end - seg_start)
            bar += BRAILLE[min(int(frac * 7), 7)]
    return bar


def fmt(label, pct):
    return f"{DIM}{label}{R} {gradient(pct)}{braille_bar(pct)}{R} {round(pct)}%"


model = (data.get("model") or {}).get("display_name") or "Claude"
parts = [model]

ctx = (data.get("context_window") or {}).get("used_percentage")
if ctx is not None:
    parts.append(fmt("ctx", ctx))

five = (data.get("rate_limits") or {}).get("five_hour", {}).get("used_percentage")
if five is not None:
    parts.append(fmt("5h", five))

week = (data.get("rate_limits") or {}).get("seven_day", {}).get("used_percentage")
if week is not None:
    parts.append(fmt("7d", week))

print(f" {DIM}│{R} ".join(parts), end="")
