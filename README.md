# cr - Command Runner

`cr` is a lightweight command runner with execution time tracking, smart output preview, and auto-managed command history.

## Features

- Measure and display command execution time with **OK/ERR** status.
- Store logs in `~/.clog` with command, runtime, exit code, and full output.
- Automatically shows output if ≤10 lines, otherwise prompts to use `less`.
- Keep history for **3 days** (auto cleanup).
- `--list` / `-ls` to list recent commands.
- `--history` / `-h` to view a specific past command.
- Colored and formatted output for better readability.

---

## Installation

Run the following command:
```bash
curl -fsSL https://raw.githubusercontent.com/mudern/cr/main/install.sh | bash
