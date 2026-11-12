---
name: subagent-prompting
description: How to write prompts when delegating work to subagents via the Agent tool — self-contained context, explicit scope boundaries, output contract, and fallback rules, plus division of labor and model choice (sonnet vs opus). Use whenever spawning or messaging a subagent (Explore, Plan, general-purpose, or custom agents) to avoid cold-start failures and unusable reports.
---

# Subagent Prompting

A subagent starts **cold**: it has none of the current conversation's context.
Write every delegation prompt as if sending a single Slack DM to a new colleague
who must finish the job without asking follow-up questions.

## Decide whether to delegate at all

- Do the work inline when a few of your own tool calls would finish it;
  spawning re-derives context you already have and is the expensive path.
- Delegate when the user explicitly asks for a subagent,
  or when the task is a wide fan-out search where only the conclusion matters, not the process logs.
- To continue a previous subagent, use `SendMessage` with its ID instead of spawning fresh;
  a new `Agent` call loses all of its accumulated context.

## Pick the least-privileged agent type

- `Explore` — read-only, broad code search; specify search breadth ("medium" or "very thorough").
- `Plan` — architecture and implementation planning; returns a plan, does not edit.
- `general-purpose` — multi-step tasks that require editing or running commands.
- A custom agent type when one matches the domain.

## Division of labor and model choice

When the user delegates implementation (or the task is large enough to warrant it):

- Default split: you direct, verify, and review; subagents implement.
  After a subagent finishes, review its diff yourself before reporting —
  you own the result, and unrequested scope additions by the subagent must be surfaced to the user.
- Model choice: use `sonnet` for well-scoped implementation,
  mechanical fan-out (per-repo PR creation, log checks), and focused investigations;
  use `opus` for implementation requiring significant design judgment;
  do genuinely light tasks yourself instead of spawning.

## Prompt structure

Write the prompt in this order:

### 1. One-sentence task definition

State what "done" looks like, not just the activity.
Not "investigate the flaky test"
but "identify why test X intermittently fails and report the root cause with file:line references".

### 2. Embedded context

Transcribe every fact the subagent needs but cannot know:
repository paths (absolute), branch names, reproduction steps,
what has already been discovered, and what was already tried and failed.
References like "the file we discussed" or "the earlier error" do not exist for the subagent.

### 3. Scope boundaries

State explicitly what is in and out of bounds:

- Read-only, or allowed to edit?
- Commit, or leave changes in the working tree?
- Which directories or components are in scope?

Without boundaries, subagents expand scope in good faith.

### 4. Output contract

Only the subagent's **final message** comes back; nothing else survives.
Specify the report format concretely:

- Structure ("conclusion first, then evidence", "a list of file:line entries").
- The negative case ("if nothing is found, say so explicitly rather than padding").
- Anything that must be included verbatim (error messages, commands run, test output).

### 5. Fallback rules

The subagent cannot ask questions mid-task, so pre-answer its likely dilemmas:

- "If torn between A and B, choose A."
- "If confidence is low, return the ranked candidates instead of guessing."
- "If blocked, report exactly what is missing and stop."

## After the subagent returns

- The subagent's report is **not shown to the user**.
  Relay the parts that matter in your own words in your final message.
- Verify load-bearing claims before acting on them; a subagent's confident summary is a hypothesis, not ground truth.
