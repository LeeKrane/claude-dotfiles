---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

<!-- Source: mattpocock/skills@d65391149dbb skills/engineering/implement. Vetted 2026-11-24 by skill-scout (SkillSpector + manual read). Local edits: Skill calls remapped: tdd -> superpowers:test-driven-development, code-review -> spec-review. -->

Implement the work described by the user in the spec or tickets.

If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.

Call the Skill tool with "superpowers:test-driven-development" where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, call the Skill tool with "spec-review" to review the work.

Commit your work to the current branch.
