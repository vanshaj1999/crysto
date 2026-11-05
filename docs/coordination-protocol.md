# Coordination protocol

Several agents work on the same folders. They do not share a conversation, and none of them can
see what another is doing right now. This protocol is how they avoid duplicate work and collisions.
It lives in one file, `COORDINATION.md`, at the hub. Template:
[templates/COORDINATION.md](../templates/COORDINATION.md).

## Rules

1. **Read `COORDINATION.md` before shared work.** Every agent, every session.
2. **Claim the task before you edit files or drive a browser.** A claim has an owner, the task,
   the date and the next step.
3. **Do not act on a task another agent owns.** Ask me instead. Two claims on one task are
   resolved by me, not by the agents.
4. **Record evidence, not intentions.** "Done" means the command ran and its output is quoted or
   linked: test counts, a commit hash, a URL. "Should work" is not done.
5. **Write the handover before you stop.** Owner, what was done, the evidence, and the exact next
   action. The next agent must be able to start from the file alone.
6. **Do not assume another agent read a changed file.** A live session holds the version it read.
   Tell it to read the handover again.
7. **One browser driver at a time.** The claim covers the browser. A second agent that needs it
   waits or asks.
8. **Never claim access you have not proved.** "I can read that inbox" needs a successful read,
   not a connected icon.
9. **A claim is coordination, not a lock.** Nothing stops an agent technically. The protocol
   works because every agent's rules tell it to follow the file.

## Entry format

Newest first. Each entry has a heading with the task, the date and a state in capitals, so a quick
scan shows what is live:

```markdown
# Website copy review, 4 November 2026: CLAIMED BY CODEX

Owner: Codex. Claimed 4 Nov 10:05.
Task: check every claim on the About page against the CV notes.
Done: 12 of 18 claims checked, 2 wording fixes in drafts/about.md.
Evidence: drafts/about.md diff; checklist in notes/claims.md.
Next: check the last 6 claims, then hand back to Claude for review.
```

States in use: `CLAIMED BY <AGENT>`, `PAUSED, NOTHING RUNNING`, `WAITING ON OWNER`, `DONE`.

## Why a file and not a tool

A shared file works across every agent I use, including ones with no plugin system and models that
run headless for an hour. It is diffable, it is in git, and when something goes wrong I can read
exactly who claimed what and when.
