#!/usr/bin/env python3
"""Tests for tools/check_queue.py -- specifically Windows `gh` resolution.

    python3 tests/test_check_queue.py         # all of it
    python3 tests/test_check_queue.py -v      # case by case

Standard library only, like the checker itself.

find_gh() exists because a Windows box can have `gh` installed by the MSI or by
winget while the current session's PATH has not picked up the shim yet.
Reporting "gh is not installed" there is wrong in the one direction this
repository cares about, because a checker that cannot find `gh` and a queue with
nothing in it produce the same silence downstream.

These tests pin the *search*, not the separator. The checker builds its
candidate paths with os.path.join, so they come out with "/" when the suite runs
on the CI runner and "\\" on a developer's Windows box; the expected values here
are built the same way rather than hard-coded, so both machines assert the same
thing. Comparisons go through os.path.normcase for the same reason.

Every attribute stubbed below lives on a module the rest of the suite shares
(os, sys, shutil), so each is patched through unittest.mock and restored on the
way out. Leaving os.environ or os.path.isfile replaced would follow this file
into whatever runs after it under `unittest discover`.
"""

import importlib.util
import os
import pathlib
import unittest
from unittest import mock

ROOT = pathlib.Path(__file__).resolve().parent.parent

# Inert stand-ins. Nothing here is a real path from a real machine.
PROGRAM_FILES = r"C:\Program Files"
LOCALAPPDATA = r"C:\Users\Example\AppData\Local"


def load():
    spec = importlib.util.spec_from_file_location(
        "check_queue", str(ROOT / "tools" / "check_queue.py"))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class FindGhTest(unittest.TestCase):
    def setUp(self):
        self.cq = load()

    def resolve(self, on_disk, which=None, platform="win32", env=None):
        """Call find_gh() with PATH, the environment and the disk all stubbed."""
        if env is None:
            env = {"ProgramFiles": PROGRAM_FILES, "LOCALAPPDATA": LOCALAPPDATA}
        present = {os.path.normcase(p) for p in on_disk}
        with mock.patch.object(self.cq.sys, "platform", platform), \
             mock.patch.object(self.cq.shutil, "which", lambda name: which), \
             mock.patch.object(self.cq.os, "environ", env), \
             mock.patch.object(self.cq.os.path, "isfile",
                               lambda p: os.path.normcase(p) in present):
            return self.cq.find_gh()

    def test_path_wins_when_gh_is_on_it(self):
        self.assertEqual(
            self.resolve([], which="/usr/bin/gh", platform="darwin"), "/usr/bin/gh")

    def test_windows_finds_program_files_install_when_not_on_path(self):
        expected = os.path.join(PROGRAM_FILES, "GitHub CLI", "gh.exe")
        self.assertEqual(self.resolve([expected]), expected)

    def test_windows_finds_the_winget_shim(self):
        expected = os.path.join(
            LOCALAPPDATA, "Microsoft", "WinGet", "Links", "gh.exe")
        self.assertEqual(self.resolve([expected]), expected)

    def test_windows_reports_nothing_when_gh_is_genuinely_absent(self):
        self.assertIsNone(self.resolve([]))

    def test_non_windows_does_not_search_windows_install_locations(self):
        stranded = os.path.join(PROGRAM_FILES, "GitHub CLI", "gh.exe")
        self.assertIsNone(self.resolve([stranded], platform="linux"))


if __name__ == "__main__":
    unittest.main()
