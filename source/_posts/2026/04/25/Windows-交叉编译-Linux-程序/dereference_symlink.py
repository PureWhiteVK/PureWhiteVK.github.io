#!/usr/bin/env python3
"""Replace symlinks under rootfs with copies of their targets (dereference in place)."""

from __future__ import annotations

import argparse
import os
import shutil
import sys
from argparse import ArgumentParser
from pathlib import Path
from typing import Iterable, Literal


def read_symlink_target(link: Path) -> Path:
    """Return the symlink target as a Path (raw, not yet resolved)."""
    if hasattr(link, "readlink"):
        return link.readlink()
    return Path(os.readlink(link))


def is_unsafe_dir_dereference(link: Path, target: Path) -> bool:
    """True when copying target into link would nest target inside itself.

    Typical case: a directory symlink pointing at ``..`` or another ancestor,
    so ``copytree(target, link)`` walks a tree that still contains ``link``.
    """
    try:
        link.relative_to(target.resolve(strict=False))
        return True
    except ValueError:
        return False


def resolve_symlink_target(link: Path, rootfs: Path) -> Path | None:
    """Resolve symlink target to an absolute path; None if outside rootfs."""
    raw = read_symlink_target(link)
    target = raw if raw.is_absolute() else (link.parent / raw)
    try:
        target = target.resolve(strict=False)
    except (OSError, RuntimeError) as exc:
        # RuntimeError: symlink loop (pathlib on Python 3.8); OSError: ELOOP on 3.9+
        print(f"Skipping {link}: cannot resolve target ({exc})", file=sys.stderr)
        return None

    root = rootfs.resolve(strict=False)
    try:
        if not target.is_relative_to(root):
            print(f"Skipping {link} -> {target} (outside rootfs)")
            return None
    except AttributeError:
        # Python < 3.9
        try:
            target.relative_to(root)
        except ValueError:
            print(f"Skipping {link} -> {target} (outside rootfs)")
            return None

    return target


def collect_symlinks(rootfs: Path) -> tuple[list[Path], list[Path]]:
    """Walk rootfs and return (file_symlinks, dir_symlinks) safe to dereference."""
    file_links: list[Path] = []
    dir_links: list[Path] = []

    try:
        entries: Iterable[Path] = rootfs.rglob("*")
    except OSError as exc:
        raise SystemExit(f"Cannot walk {rootfs}: {exc}") from exc

    for path in entries:
        try:
            if not path.is_symlink():
                continue
        except OSError as exc:
            print(f"Skipping {path}: {exc}", file=sys.stderr)
            continue

        target = resolve_symlink_target(path, rootfs)
        if target is None:
            continue
        if not target.exists():
            print(f"Skipping {path} -> {target} (target missing)")
            continue

        try:
            if target.is_file():
                file_links.append(path)
            elif target.is_dir():
                if is_unsafe_dir_dereference(path, target):
                    print(
                        f"Skipping {path} -> {target} "
                        "(directory symlink points inside its target; would recurse)"
                    )
                    continue
                dir_links.append(path)
            else:
                print(f"Skipping {path} -> {target} (not a regular file or directory)")
        except OSError as exc:
            print(f"Skipping {path} -> {target}: {exc}", file=sys.stderr)

    return file_links, dir_links


def remove_backup(backup: Path) -> None:
    """Remove a backup path left from a prior symlink move."""
    try:
        if backup.is_dir() and not backup.is_symlink():
            shutil.rmtree(backup)
        else:
            backup.unlink(missing_ok=True)
    except OSError as exc:
        print(f"Warning: failed to remove backup {backup}: {exc}", file=sys.stderr)


def dereference_file(link: Path, rootfs: Path, *, dry_run: bool) -> Literal["ok", "skip", "fail"]:
    target = resolve_symlink_target(link, rootfs)
    if target is None or not target.is_file():
        print(f"Skipping {link} (no longer a dereferenceable file symlink)")
        return "skip"

    if dry_run:
        print(f"[dry-run] Would dereference {link} -> {target}")
        return "ok"

    backup = link.with_suffix(link.suffix + ".bak")
    if backup.exists():
        print(f"Skipping {link}: backup {backup} already exists", file=sys.stderr)
        return "fail"

    try:
        shutil.move(link, backup)
        shutil.copy2(target, link)
    except OSError as exc:
        print(f"Failed {link} -> {target}: {exc}", file=sys.stderr)
        if backup.exists() and not link.exists():
            try:
                shutil.move(backup, link)
            except OSError as restore_exc:
                print(
                    f"Critical: could not restore {link} from {backup}: {restore_exc}",
                    file=sys.stderr,
                )
        elif link.exists() and backup.exists():
            remove_backup(backup)
        return "fail"

    remove_backup(backup)
    print(f"Dereferenced {link} -> {target}")
    return "ok"


def dereference_dir(link: Path, rootfs: Path, *, dry_run: bool) -> Literal["ok", "skip", "fail"]:
    target = resolve_symlink_target(link, rootfs)
    if target is None or not target.is_dir():
        print(f"Skipping {link} (no longer a dereferenceable directory symlink)")
        return "skip"
    if is_unsafe_dir_dereference(link, target):
        print(
            f"Skipping {link} -> {target} "
            "(directory symlink points inside its target; would recurse)",
            file=sys.stderr,
        )
        return "skip"

    if dry_run:
        print(f"[dry-run] Would dereference {link} -> {target}")
        return "ok"

    backup = link.with_suffix(link.suffix + ".bak")
    if backup.exists():
        print(f"Skipping {link}: backup {backup} already exists", file=sys.stderr)
        return "fail"

    try:
        shutil.move(link, backup)
        shutil.copytree(target, link, symlinks=True)
    except (OSError, RecursionError) as exc:
        print(f"Failed {link} -> {target}: {exc}", file=sys.stderr)
        if backup.exists() and not link.exists():
            try:
                shutil.move(backup, link)
            except OSError as restore_exc:
                print(
                    f"Critical: could not restore {link} from {backup}: {restore_exc}",
                    file=sys.stderr,
                )
        elif link.exists() and backup.exists():
            remove_backup(backup)
        return "fail"

    remove_backup(backup)
    print(f"Dereferenced {link} -> {target}")
    return "ok"


def parse_args() -> argparse.Namespace:
    parser = ArgumentParser(
        description="Replace symlinks under ROOTFS with copies of their targets.",
    )
    parser.add_argument(
        "rootfs",
        type=Path,
        help="Root directory to scan (only symlinks pointing inside it are processed)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="List actions without modifying the filesystem",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    rootfs: Path = args.rootfs

    if not rootfs.exists():
        print(f"Error: {rootfs} does not exist", file=sys.stderr)
        return 2
    if not rootfs.is_dir():
        print(f"Error: {rootfs} is not a directory", file=sys.stderr)
        return 2

    try:
        file_links, dir_links = collect_symlinks(rootfs)
    except SystemExit as exc:
        print(exc, file=sys.stderr)
        return 2

    print(f"Found {len(file_links)} file symlink(s) and {len(dir_links)} dir symlink(s)")

    stats = {"ok": 0, "skip": 0, "fail": 0}
    for link in file_links:
        stats[dereference_file(link, rootfs, dry_run=args.dry_run)] += 1
    for link in dir_links:
        stats[dereference_dir(link, rootfs, dry_run=args.dry_run)] += 1

    print(
        f"Done: {stats['ok']} dereferenced, {stats['skip']} skipped, {stats['fail']} failed"
    )
    return 1 if stats["fail"] else 0


if __name__ == "__main__":
    sys.exit(main())
