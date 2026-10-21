---
name: sprint-done
description: Close the current task - confirm verify passed, tick the sprint file, update STATUS, propose the commit.
disable-model-invocation: true
---

1. Confirm `/verify` passed in this session for the current changes. If not run or failing, run it / stop and report — never mark a failing task done.
2. In `docs/sprints/sprint-N.md`: tick completed checkboxes, set the task to `[x]`. Add at most 2 lines under the task for anything a future session must know (gotcha, deviation, follow-up). If something was intentionally skipped, write it there.
3. If the work changed a documented decision, schema, or RPC contract: update the relevant MVP/PRD section briefly and/or run `/adr`.
4. Rewrite `docs/STATUS.md` (keep < 20 lines): Current sprint, Last done (task ID + one line + short commit hash after commit), Next (next unchecked task ID + title), Blockers. If the sprint's exit criteria are all met, set Next to the first task of the next sprint and note "Sprint N complete".
5. Show `git status --short` and propose a commit message `<type>(<scope>): <summary> (SN-Tk)`. Commit only if the user asks or has said to commit after each task.
6. Tell the user: "Run /clear, then /sprint-next." If a sprint just completed, also remind them (in Bangla) that the next sprint's study cards can be created in a separate session ("docs/learning-এ Sprint N-এর কার্ড বানাও"). Do not read `docs/learning/` yourself.
