# /// script
# requires-python = ">=3.11"
# dependencies = ["json5==0.15.0"]
# ///
"""Check that Renovate can still track every pinned dependency.

Two things break silently when template updates are merged:

- A custom manager whose regular expression no longer matches anything.
  Renovate keeps such a manager without reporting an error, so the dependency
  simply stops being updated.
- A group whose members drift apart, for example the ruff version inlined in
  the CI workflow and the ruff revision pinned in the prek configuration.

Neither is caught by `renovate-config-validator`, which only checks syntax, nor
by the linters, which never compare the two files.

Usage: uv run .agents/skills/sync-template/scripts/check_pins.py [repository-root]
"""

import re
import sys
from fnmatch import fnmatchcase
from pathlib import Path

import json5

ROOT = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()


def to_python_regex(pattern: str) -> re.Pattern[str]:
    """Translate a Renovate (RE2) pattern into an equivalent Python one."""
    # RE2 spells named groups "(?<name>...)" where Python expects "(?P<name>...)".
    # Renovate compiles these with the "g" flag alone, so "^" and "$" anchor to the whole string.
    return re.compile(re.sub(r"\(\?<(?![=!])", "(?P<", pattern))


def matches_glob(parts: list[str], segments: list[str]) -> bool:
    """Match a minimatch pattern segment by segment, since only "**" crosses a "/"."""
    if not parts:
        return not segments
    if parts[0] == "**":
        return any(matches_glob(parts[1:], segments[index:]) for index in range(len(segments) + 1))
    return bool(segments) and fnmatchcase(segments[0], parts[0]) and matches_glob(parts[1:], segments[1:])


def matches_path(pattern: str, path: str) -> bool:
    # Renovate reads a pattern delimited by slashes as a regular expression and anything else as a glob.
    if pattern.startswith("/") and pattern.endswith("/"):
        return bool(to_python_regex(pattern[1:-1]).search(path))
    # Renovate always evaluates a glob case-insensitively.
    return matches_glob(pattern.lower().split("/"), path.lower().split("/"))


def matching_files(patterns: list[str]) -> list[Path]:
    return [
        path
        for path in sorted(ROOT.rglob("*"))
        if path.is_file()
        and ".git/" not in str(path)
        and any(matches_path(pattern, path.relative_to(ROOT).as_posix()) for pattern in patterns)
    ]


def captured_values(manager: dict, text: str) -> list[str]:
    """Apply the manager's matchStrings to one file and return every currentValue."""
    # The "recursive" strategy narrows the search space with each matchString in turn;
    # every other strategy applies each matchString to the whole file.
    strategy = manager.get("matchStringsStrategy")
    scopes = [text]
    values = []
    for pattern in manager["matchStrings"]:
        regex = to_python_regex(pattern)
        if strategy == "recursive":
            scopes = [match.group(0) for scope in scopes for match in regex.finditer(scope)]
        matches = [match for scope in scopes for match in regex.finditer(scope)]
        # The "combination" strategy builds a single dependency out of every matchString,
        # so one that matches nothing leaves no dependency at all.
        if strategy == "combination" and not matches:
            return []
        values += [match.groupdict().get("currentValue") for match in matches]
    return [value for value in values if value]


def uncommented(text: str) -> str:
    """Strip YAML comment markers so that a commented-out block reads as active."""
    return re.sub(r"^(\s*)#[ ]?", r"\1", text, flags=re.MULTILINE)


def normalize(version: str) -> str:
    # A prek hook release such as "v3.13.1-1" pins upstream shfmt "v3.13.1".
    # Only that trailing packaging revision is noise: a prerelease such as "-rc.1" tells two pins apart.
    return re.sub(r"-\d+$", "", version.lstrip("v"))


renovate_config = ROOT / ".github/renovate.json5"
if not renovate_config.is_file():
    sys.exit(f"{renovate_config} does not exist, so the pins cannot be checked.")

config = json5.loads(renovate_config.read_text())
versions: dict[str, set[str]] = {}
inactive: set[str] = set()
failures: list[str] = []

print("Custom managers")
for manager in config.get("customManagers", []):
    name = manager.get("depNameTemplate", "<unnamed>")
    paths = matching_files(manager["managerFilePatterns"])
    if not paths:
        print(f"  NO FILE   {name}: managerFilePatterns match no file")
        failures.append(name)
        continue
    values = [value for path in paths for value in captured_values(manager, path.read_text())]
    if not values:
        # An opt-in feature that is still commented out is inactive, not broken.
        if any(captured_values(manager, uncommented(path.read_text())) for path in paths):
            print(f"  inactive  {name}: only matches while the commented-out block is disabled")
            inactive.add(name)
            continue
        where = ", ".join(path.relative_to(ROOT).as_posix() for path in paths)
        print(f"  NO MATCH  {name}: matchStrings match nothing in {where}")
        failures.append(name)
        continue
    print(f"  ok        {name}: {len(values)} hit(s)")
    versions.setdefault(name, set()).update(normalize(value) for value in values)

# The pre-commit and github-actions managers are built in, so read their pins directly.
pre_commit_config = ROOT / ".pre-commit-config.yaml"
pre_commit = pre_commit_config.read_text() if pre_commit_config.is_file() else ""
for repo, rev, frozen in re.findall(
    r"- repo: https://github\.com/(\S+)\n\s+rev: (\S+)(?:[ \t]+# frozen: (\S+))?", pre_commit
):
    # A hook pinned to a digest names its release in the comment; one pinned to a tag is the version itself.
    version = (frozen or rev).strip("'\"")
    # A digest, abbreviated or not, carries no version. An all-digit tag is a date rather than a digest.
    if not (re.fullmatch(r"[0-9a-f]{7,40}", version) and not version.isdigit()):
        versions.setdefault(repo, set()).add(normalize(version))

for workflow in sorted((ROOT / ".github/workflows").glob("*.y*ml")):
    # A step without a name carries the "uses" on the list item itself, which Renovate reads the same way.
    uses = re.findall(r"^\s*(?:-\s+)?uses: ([^@\s]+)@[0-9a-f]{40}[ \t]+# (v\S+)", workflow.read_text(), re.MULTILINE)
    for action, version in uses:
        # A reusable workflow is referenced by path, but Renovate names it after the repository holding it.
        versions.setdefault("/".join(action.split("/")[:2]), set()).add(normalize(version))

print("\nGroups")
for rule in config.get("packageRules", []):
    group = rule.get("groupName")
    # A member of an inactive manager is absent on purpose, so it is not expected to have a version.
    members = [name for name in rule.get("matchDepNames", []) if name not in inactive]
    if not group or not members:
        continue
    # A member that yielded nothing means the group no longer compares what it was written to compare.
    missing = [name for name in members if name not in versions]
    if missing:
        print(f"  MISSING   {group}: no version found for {', '.join(missing)}")
        failures.append(group)
        continue
    # Two sources can share one dep name, so compare the versions rather than counting the names.
    distinct = set().union(*(versions[name] for name in members))
    if len(distinct) == 1:
        print(f"  ok        {group}: {distinct.pop()}")
    else:
        detail = ", ".join(f"{name}={sorted(versions[name])}" for name in members)
        print(f"  MISMATCH  {group}: {detail}")
        failures.append(group)

if failures:
    print(f"\n{len(failures)} problem(s): {', '.join(failures)}")
    sys.exit(1)
print("\nNo problems found.")
