---
name: sprint-next
description: Resume work - load STATUS and the next sprint task with only the doc sections it needs, then propose a short plan.
disable-model-invocation: true
---

Goal: start a session with minimal context. Optional argument: a task ID (e.g. `S1-T4`) to override "Next".

1. Use `docs/STATUS.md` from the SessionStart context (Read it only if missing). Determine the task ID (argument wins over "Next").
2. Open `docs/sprints/sprint-N.md` for that sprint.
   - If the file does not exist: read only that sprint's subsection of MVP §৭ (Grep `^### Sprint N`), and create `docs/sprints/sprint-N.md` in the same format as `sprint-0.md` (task IDs `SN-T1…`, checkboxes, "Done when", references to MVP/PRD sections and story IDs). Show it to the user for approval before starting any task.
3. Read only the task block. For each doc reference in it (e.g. "MVP §৫.৬", "PRD A1b", "ADR 0005"), Grep the heading and read just that section. Do not read whole docs.
4. If the task is marked **(U)**, list exactly what the user must do and what you will prepare; don't pretend to do user steps.
5. Mark the task `[~]` in the sprint file.
6. Reply with: task ID + title, files you expect to touch, a 3–7 step plan, and any blocking question. For schema/matching/security tasks, wait for the user's OK before editing; otherwise proceed.
