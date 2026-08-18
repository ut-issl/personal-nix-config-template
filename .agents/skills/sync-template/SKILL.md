---
name: sync-template
description: >-
  Bring this personal configuration repository up to date with the template it was created from:
  work out the base to merge from, merge, resolve conflicts,
  carry what the template introduced into this repository's own content,
  verify that dependency tracking still works, and open the pull request that lands the result.
  Use when the user asks to sync with, update from, or pull in changes from the template,
  or asks whether the template has anything new to take.
  Do not use for routine dependency updates inside this repository (Renovate handles those)
  or for the initial repository setup (that is the repo-setup skill).
---

# Sync With the Upstream Template

Bring this repository up to date with `ut-issl/personal-nix-config-template`, the template it was created from.

Converse in the language the user writes in, but keep all edits (code, comments, commit messages, etc.) in English.
The skill ends once the pull request exists; merging it stays the user's decision.
Ask before pushing and before opening the pull request, and stop at the commit on the branch if the user declines.

Give every `gh` command `--repo <owner>/<repo>` from `origin`:
a remote named `upstream` outranks `origin`, and `gh` would silently act on the template instead.

## Guiding Principle

**Trust the result of Git's three-way merge, and never undo what a clean merge decided.**

Where the template and this repository share content, the merge settles it:
intervene only to resolve what Git reports as conflicting.
Step 7 names the single exception, where a clean merge can undo a decision this repository already made.

**Where the template has no counterpart, the merge settled nothing.**

Everything by which this repository diverges from the template — its own modules,
its own sections inside shared files — had nothing to merge into, so silence there is not agreement.
A mechanism the template introduces can still reach into that content:
an option its own modules now gate themselves on, an output whose meaning they have to respect,
a convention its imports now depend on.
Step 6 carries such a mechanism the rest of the way, and it alone may edit what the merge never reached.
Its license is the incoming diff of this sync and nothing older:
an edit this repository could equally have made before the sync is customization, and belongs to the `customize` skill.
A sync does not re-run `repo-setup` either:
setup work a merge newly makes applicable is the user's to run, not this skill's.

A template commit is internally consistent: a version bump travels with the change that requires it,
and Git keeps the two together for every line this repository has not touched.
So never revert an incoming version bump because this repository has not reached that version yet.

A deliberate decision to stay on an older version cannot be expressed by not updating,
since Git cannot tell that apart from a line nobody touched.
If the user wants to hold a dependency back, record it in `.github/renovate.json5` (`allowedVersions` or `ignoreDeps`).

## 1. Check for an open sync pull request

```console
gh pr list --repo <owner>/<repo> --state open --head chore/sync-template --json number,url
```

If one is open, point the user at it and stop.
Its base has not reached `main` yet, so a second sync would repeat the same merge onto a branch of the same name.

## 2. Work out the base to merge from

This step only decides which commit the base is; step 4 puts it in place.
Run it from `main`, not behind `origin`, since step 4 branches from `HEAD`.
The merge needs a clean working tree, so ask the user to commit or stash anything outstanding first.

Add the remote unless one already points at the template, in which case use that name throughout.
Where the name `template` is taken by something else, `git remote add` fails: pick another name and use that.

```console
git remote -v
git remote add template https://github.com/ut-issl/personal-nix-config-template.git
git fetch template
```

Take the first of the three sources below that yields a commit.

**`.template-base`.** Every sync rewrites it, so this is the normal answer:

```console
grep -m1 -oE '^[0-9a-f]{40}$' .template-base
```

**The last sync's pull request**, for a repository that has lost the file.
GitHub keeps a pull request's pre-merge head even after a squash deleted the branch:

```console
gh pr list --repo <owner>/<repo> --state merged --head chore/sync-template --json number --limit 1
git fetch origin refs/pull/<number>/head && git show FETCH_HEAD:.template-base
```

**The fork point**, for a repository that has never synced.
`git rev-list --max-parents=0 HEAD` prints one hash per root commit;
ask the user rather than continuing when it prints more than one,
since a repository with several roots has merged an unrelated history and is not a plain template copy.
The initial commit is a verbatim copy of the template,
so with that hash as `<initial>` the base is the template commit with the same tree:

```console
for commit in $(git log --format=%H template/main); do
  git diff --quiet "$commit" <initial> && echo "$commit" && break
done
```

If even that finds nothing, the repository was not created straight from the template.
Ask the user which template commit it started from rather than guessing, and stop if they cannot say.

Whatever the source, `git merge-base --is-ancestor <base> template/main` has to succeed before the base is used.
A value that fails is stale or corrupt: say so and fall through to the next source.

## 3. Review what is new

```console
git log --oneline <base>..template/main
```

Use the base from step 2, not `HEAD`, which is unrelated to the template once a sync has been squashed.

Summarize what changed, grouped by what it means for the user rather than commit by commit;
a `chore(deps)` commit may also carry the configuration change that the new version needs.
Then ask the user whether to merge now.

If there is nothing new, say so and stop.

## 4. Merge

An earlier run leaves the branch behind, locally where `git switch -c` refuses to recreate it,
or on `origin` alone where nothing stops it, so look for both before doing anything else.
Either is safe to overwrite once its sync has landed, which is true when `main` carries the same `.template-base`:

```console
git show origin/main:.template-base
git show <the leftover branch>:.template-base
```

Do not test this with `--is-ancestor`, which only a merge-commit landing satisfies.
`git show` reports `fatal:` where the file does not exist, which counts as differing rather than as breakage.
When the two differ, stop and ask: the branch holds conflict resolutions that never reached `main`.

The graft below makes the template an ordinary merge source; step 8 folds it away again.

```console
git rev-parse HEAD
git switch -c chore/sync-template
git merge -s ours --allow-unrelated-histories <base> -m "chore: graft the template base"
git merge --no-commit --no-ff template/main
```

Keep the first hash as `<branch point>`; step 8 folds back onto it and not onto `main`,
which would carry away anything committed there while this sync was in progress.

The graft reports `Already up to date.` and does nothing when the base is already an ancestor.
`--allow-unrelated-histories` is required even with `-s ours`.

If `git merge --no-commit --no-ff template/main` reports `Already up to date.`, the template is contained already.
Skip the conflict resolution, and record what `git rev-parse template/main` prints then,
since there will be no `MERGE_HEAD`.
Confirm it first with `git merge-base --is-ancestor <it> HEAD`, the containment this path rests on.

## 5. Resolve the conflicts

Resolve only what Git reports as conflicting, and leave everything else exactly as the merge produced it.
Taking one side of a conflict wholesale can leave a hunk the merge placed cleanly in the same file contradicting it;
read the resolved file through once, and drop only what the side you chose already says.
Anything not covered below is a genuine content conflict: read both sides and explain the choice to the user.

### A version pin

Take the newer version, and never roll this repository back.
If the template moved *backwards* relative to the base, that is a deliberate revert: follow the template.

### A version together with the change that accompanies it

Keep them together; never take the structural change while restoring the old version.

### Wording specific to this repository

Keep this repository's version: its name, its badge URLs, and anything describing it as a personal configuration.
The same holds for the sections `repo-setup` rewrote to match the choices made during setup.

### A copyright header

A header names who wrote the content, not which side of the merge won.
Keep this repository's header where the surviving content is its own,
even when the form around it came from the template.
Where the surviving content is the template's, take the template's header.

### A file or section this repository deleted during setup

Keep the deletion, but read the template's change and tell the user if it adds something they would want back.

### The shared ISSL configuration version

Follow the template.
The version appears in `flake.nix`, `flake.lock`, twice in `.github/workflows/test.yaml`
and in `README.md` (the bootstrap command, and any link into the shared documentation),
and all of them have to agree.
Search for the version string rather than trusting that list, which ages as the README grows.

## 6. Land what the merge introduced

A change whose reach extends into content that is this repository's alone arrives half-landed:
Git has no counterpart to merge it into, so it changes nothing there and reports nothing.
This step carries such a change the rest of the way.
Skip it when step 4 ended in `Already up to date.`, since nothing came in.

First enumerate the mechanisms this sync introduces, from the code diff:

```console
git diff --stat <base> MERGE_HEAD -- ':(exclude)flake.lock'
git diff <base> MERGE_HEAD -- ':(exclude)flake.lock'
```

A mechanism is a change the template applied to its own files
that puts an obligation on files of the same kind it cannot see:
a new option together with the gate its own modules now wrap themselves in,
a flake output or check added, renamed, or removed,
a naming or placement convention the imports depend on.
A withdrawal counts as much as an introduction,
since an option or output the template dropped leaves this repository's references to it dangling.
A version bump is not a mechanism, and neither is a change confined to shared content, which the merge already settled.
Documentation that changed in the same diff helps name a mechanism, but its silence proves nothing:
the code diff is the bound.
Most syncs introduce none; say so in a sentence and go on to step 7.

Then enumerate what the merge could not reach, once the step 5 resolutions are staged,
from everything this repository still differs from the template tip by:

```console
git diff --stat MERGE_HEAD
```

This lists whole files the template lacks and this repository's own additions inside shared files alike.
It also lists what setup deleted or rewrote in template content: settled decisions this step never edits,
and step 7's wording check is their only follow-up.

Cross the two.
For each mechanism, give a verdict on every owned file or section of the kind the template applied it to:
**apply**, where leaving it as the merge produced it would contradict what the mechanism declares —
the option's description, the output's meaning, the convention the imports enforce;
**not applicable**, with the reason in a phrase;
or **unsure**, which is a question for the user rather than a judgement to bury.
Redundancy, style, and improvement are not contradiction, and change no verdict.

An edit changes existing content where it lives, never moves it:
this repository's arrangement of its own files is a decision it already made, and a sync does not revisit it.
Content moves only where placement is the mechanism, and the location is what makes it work.
A placement convention in the README chooses among ways of editing in place, and never licenses a move.
Where placement is not the mechanism, the edit takes the form the template gave the mechanism in its own files;
where more than one form conforms, the README's conventions decide, and ask when they do not.
Where only part of a file falls under the mechanism, apply the template's own expression to that part
and leave the rest as it is.
Joining that part to the rest may take a construct the template never needed, which is glue and is fine;
restating the mechanism itself in another form is not.
A mechanism the template declared but nowhere applied leaves no form to copy: report it and edit nothing.
Prose follows the same test: a sentence the incoming change made false gets the smallest correction that makes it true,
and a sentence left true stays as it is.

Where a mechanism tells one flake output from another, the per-file verdicts are not the last word:
with `nix` available, read what the outputs actually contain before showing the verdicts,
probing whatever content the distinction governs — for one that splits packages:

```console
nix eval --impure --json .#homeConfigurations.user.config.home.packages --apply 'map (p: p.name)'
```

Run it for each configuration the mechanism distinguishes, and hold the results against what the distinction promises;
content in an output the distinction promises to keep it out of is a verdict the crossing got wrong,
whichever file declares it.
Run it again once the edits are in, so the step 9 summary reports what the outputs became and not only what they were.
Without `nix`, say the check was skipped, so the review of the pull request knows to look there.

Show the user the verdicts before editing anything, one line each, and edit only once they agree.
A wrong verdict on that list is visible and correctable;
a file never listed is the silent failure this step exists against.
If the user declines an edit, leave the file as the merge produced it and keep the verdict for the step 9 summary.
An **unsure** verdict nobody answers is not an edit either: leave the file alone and carry the question into that summary.

## 7. Verify

Some failures survive a clean merge without any tool complaining.
Two of them have a command behind them:

```console
uv run .agents/skills/sync-template/scripts/check_pins.py
prek run --all-files --skip no-commit-to-branch
```

The first reports custom managers in `.github/renovate.json5` that no longer match anything,
and groups whose members have drifted apart or lost a pin altogether.
A manager reported as `inactive` is fine: it belongs to an opt-in feature that is still commented out.
It only reports a manager that matches nothing at all, so a single pin left in a form Renovate no longer reads
still counts as `ok` while its siblings match.
Where a conflict was resolved inside a file that carries pins, read the resolved lines against the template's.

A hook reported as skipped proves nothing,
since hooks are filtered by file type while CI runs its linters unconditionally.
When a version pin changed for a tool whose hook was skipped,
check its configuration by hand for a constraint that the pin no longer satisfies.

One more failure has no command behind it: wording that assumes this repository is still in its template state.
`repo-setup` rewrote the README sections falsified by the choices made during setup.
Step 7 of that skill lists them, and its step 8 removes the entry for the skill itself once it is deleted.
Setup may have deleted the skill: read it from the template remote,
with `git show template/main:.agents/skills/repo-setup/SKILL.md`.
A later merge can bring the template's original wording back; where it did, restore what this repository had.
This is the one place to overrule what a clean merge decided:
step 5 drops only what the side it chose already says, and step 6 edits only what the merge never reached.

A code block illustrating file contents is not covered by that.
It shows what a file can look like rather than what this repository ships, so keep the template's version.
A command the README tells the reader to run is not an illustration, and follows the rule above.

## 8. Record the base and commit

Write the template commit this sync took into `.template-base`, replacing whatever the file held,
and create the file when it is not there yet.
Take it from `git rev-parse MERGE_HEAD`, or from the commit step 4 settled on when the merge was already up to date.
Never from `template/main` directly, which may have moved since step 4: recording a commit that was not merged
would skip everything between the two, silently and for good.

```text
# Last commit of ut-issl/personal-nix-config-template merged into this repository; updated by each template sync.
<the commit MERGE_HEAD names>
```

The comment is the only explanation a reader gets at the point of discovery, so keep it.
Nothing else may live in the file: step 2 reads the first line that is exactly forty hexadecimal characters.

The template does not ship this file, which is why it never conflicts
and why the template's own `REUSE.toml` does not mention it.
When `.github/workflows/reuse.yaml` is present and no longer guarded by
`if: ${{ github.repository == 'ut-issl/personal-nix-config-template' }}`,
add it to the `path` list of the CC0 entry that already covers `flake.lock`, so the same pull request stays compliant,
unless it is there already:

```toml
path = ["flake.lock", ".template-base"]
```

Stage the file along with everything else that was edited, since `git commit` records the index alone
and would otherwise leave a newly created `.template-base` out of the commit entirely.
Commit the merge with a Conventional Commits subject,
and explain in the body what was taken and why anything was resolved against the template.
Mark the subject breaking when the sync withdraws or renames something the user applies by name,
since the command they have been running stops working.

Then fold the merge into a single ordinary commit, which keeps that tree and that message:

```console
git reset --soft <branch point>
git commit -C ORIG_HEAD
```

`git reset --soft` refuses while a merge is uncommitted, so the commit above has to come first.

## 9. Open the pull request

Ask whether to push the branch and open the pull request.
Put the step 3 summary in the body, the only place the incoming changes appear:
the template's commits are not on the branch, so the pull request cannot list them.
Add what step 6 landed and the mechanism behind each edit,
since the diff shows the change but not why the sync required it;
the not-applicable verdicts stay out of the body.
A remote branch left by a landed sync makes the push non-fast-forward;
overwriting it with `--force-with-lease` is safe once the step 4 comparison says so.
If the user declines, stop at the commit on the branch.

Finish by showing what came in, what conflicted and how each conflict was resolved, and the full step 6 verdict list.
