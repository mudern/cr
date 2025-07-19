# cr
A lightweight command runner with execution time tracking, smart output preview, and auto-managed command history.

`cr` (Command Runner) is a lightweight Bash utility that executes shell commands while automatically tracking runtime, logging output, and managing command history. It is designed for developers who want quick insights into command results without manually timing or managing logs.

**Key features:**
- Measures and displays command execution time with success/failure indicators.
- Automatically stores logs in `~/.clog` with metadata (command, runtime, status, output).
- Displays command output directly if ≤10 lines; otherwise, prompts to preview with `less`.
- Keeps history for 3 days (auto-cleanup) and provides `--list` and `--history` to review past commands.
- Colored and formatted output for better readability.

Perfect for troubleshooting and analyzing frequently run shell commands.
