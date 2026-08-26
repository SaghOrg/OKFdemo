#!/usr/bin/env python3
"""Focused tests for tools/check_queue.py Windows gh resolution."""

import importlib.util
import pathlib
import sys
import unittest

ROOT = pathlib.Path(__file__).resolve().parent.parent


def load():
    spec = importlib.util.spec_from_file_location(
        "check_queue", str(ROOT / "tools" / "check_queue.py"))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class FindGhTest(unittest.TestCase):
    def setUp(self):
        self.cq = load()
        self.platform = sys.platform

    def tearDown(self):
        sys.platform = self.platform

    def test_windows_finds_program_files_install_when_not_on_path(self):
        sys.platform = "win32"
        self.cq.shutil.which = lambda name: None
        self.cq.os.environ = {
            "ProgramFiles": r"C:\Program Files",
            "LOCALAPPDATA": r"C:\Users\ANU\AppData\Local",
        }
        self.cq.os.path.isfile = lambda path: path == r"C:\Program Files\GitHub CLI\gh.exe"

        self.assertEqual(self.cq.find_gh(), r"C:\Program Files\GitHub CLI\gh.exe")


if __name__ == "__main__":
    unittest.main(verbosity=2 if "-v" in __import__("sys").argv else 1)