# "Hey Crysto": the voice assistant design

Status: Phase 1 design approved, not built yet.

## Goal

Talk to Crysto on the phone and in the car. It answers questions about my calendar, email and
sleep, and does phone actions: directions, an alarm, a reminder, a message with a confirm.

Not a goal: coding by voice. That stays in the terminal.

## How the design changed

1. The first design was a Cloudflare Worker that called the Claude API with its own API key.
2. I wanted it to run on my existing Claude subscription instead of a pay-per-use key.
3. A subscription login is for Anthropic's own apps, so it cannot run inside my own Worker. That
   ruled out the Worker for Phase 1.
4. Phase 1 therefore uses what already exists: the Claude app for questions and Siri for phone
   actions. The Worker design is parked, not deleted, for when an API key makes sense.

The lesson: check the terms of the platform before designing on top of it. The first design was
technically sound and still wrong.

## Phase 1

| Need | Front door | Cost |
| --- | --- | --- |
| Directions, alarm, reminder, message | Siri, built in | Free |
| Calendar, email and sleep questions | Claude app voice mode, phone and CarPlay | Existing plan |
| "Hey Crysto" | A Vocal Shortcut that opens Claude voice mode | Free |

Data comes through the same connectors the rest of Crysto uses: the health MCP server, read-only
mail, and the calendar.

## Rules

- Crysto never sends an email. Siri sends each message after its own spoken or tapped confirm.
- Personal and work stay separate. A router sees only the words of a request and picks the side;
  work data never passes through personal infrastructure.
- Mail and messages that Crysto reads are data, never instructions.

## Tests before build

Each test answers one unknown before anything is built, for example: do custom connectors work in
voice mode, can a Vocal Shortcut open voice mode directly, and does CarPlay start without a tap.
