#!/usr/bin/env python3
"""Tests for tools/check_gh.py -- specifically the install advice.

    python3 tests/test_check_gh.py            # all of it
    python3 tests/test_check_gh.py -v         # case by case

Standard library only, like the checker itself.

The advice is the part worth pinning. Everything else in check_gh.py reports
what it found; install_instructions() makes a claim about what will work on
this machine, and a wrong claim there costs someone a failed install on a box
where they may have one attempt and no way to debug it.

So each case asserts the *whole shape*: the right manager for the platform,
the right architecture in the asset name, the sudo note present only when the
emitted command actually uses sudo, and the version caveat present only for the
package managers that really do lag upstream. Asserting merely that some text
came back would pass for advice that is confidently wrong.

The release-asset names these tests pin were verified against the real
https://github.com/cli/cli releases (all four returned 200, and the macOS and
linux archives were extracted to confirm the internal bin/gh path).
"""

import importlib.util
import pathlib
import platform
import unittest

ROOT = pathlib.Path(__file__).resolve().parent.parent


def load():
    spec = importlib.util.spec_from_file_location(
        "check_gh", str(ROOT / "tools" / "check_gh.py"))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class InstallAdviceTest(unittest.TestCase):
    def setUp(self):
        self.cg = load()
        self.system = platform.system
        self.machine = platform.machine

    def tearDown(self):
        platform.system = self.system
        platform.machine = self.machine

    def advise(self, system, machine, present, family=None, euid=1000, env=None):
        platform.system = lambda: system
        platform.machine = lambda: machine
        self.cg.shutil.which = lambda n: ("/usr/bin/" + n) if n in present else None
        self.cg.linux_family = lambda: family
        self.cg.os.geteuid = lambda: euid
        self.cg.os.environ = {} if env is None else env
        return "\n".join(self.cg.install_instructions())

    # -- the manager chosen for the platform --------------------------------

    def test_macos_prefers_brew_without_sudo(self):
        text = self.advise("Darwin", "arm64", {"brew", "sudo", "curl"})
        self.assertIn("brew install gh", text)
        self.assertNotIn("sudo brew", text)
        # Homebrew tracks upstream, so the stale-package caveat must not appear.
        self.assertNotIn("often ship a gh older", text)

    def test_debian_uses_apt_with_sudo_and_the_stale_caveat(self):
        text = self.advise("Linux", "x86_64",
                           {"apt", "sudo", "curl", "tar"}, family="apt")
        self.assertIn("sudo apt install gh", text)
        self.assertIn("will prompt for a password", text)
        self.assertIn("often ship a gh older", text)

    def test_os_release_decides_when_several_managers_are_installed(self):
        # A box with both apt and dnf on PATH must follow os-release, not the
        # order this code happens to check them in.
        text = self.advise("Linux", "x86_64",
                           {"apt", "dnf", "sudo", "curl", "tar"}, family="dnf")
        self.assertIn("dnf install gh", text)
        self.assertNotIn("apt install gh", text)

    def test_root_does_not_get_a_sudo_prefix(self):
        text = self.advise("Linux", "x86_64",
                           {"apt", "sudo", "curl", "tar"}, family="apt", euid=0)
        self.assertIn("apt install gh", text)
        self.assertNotIn("sudo apt", text)

    def test_no_sudo_available_means_no_sudo_prefix(self):
        text = self.advise("Linux", "x86_64", {"dnf", "curl", "tar"}, family="dnf")
        self.assertIn("dnf install gh", text)
        self.assertNotIn("sudo", text.split("No-root")[0])

    # -- the no-root path, which is the one sandboxes need ------------------

    def test_linux_amd64_asset_name(self):
        text = self.advise("Linux", "x86_64", {"curl", "tar"})
        self.assertIn("gh_${VER}_linux_amd64.tar.gz", text)
        self.assertIn("/tmp/gh_${VER}_linux_amd64/bin/gh", text)

    def test_linux_arm64_asset_name(self):
        text = self.advise("Linux", "aarch64", {"curl", "tar"})
        self.assertIn("gh_${VER}_linux_arm64.tar.gz", text)

    def test_macos_arm64_asset_name(self):
        text = self.advise("Darwin", "arm64", {"curl", "tar"})
        self.assertIn("gh_${VER}_macOS_arm64.zip", text)
        self.assertIn("/tmp/ghx/gh_${VER}_macOS_arm64/bin/gh", text)

    def test_no_root_path_offered_even_when_a_manager_exists(self):
        # The package manager can be present and still unusable -- no sudo
        # rights, or a locked repository. The fallback must always be there.
        text = self.advise("Linux", "x86_64",
                           {"apt", "sudo", "curl", "tar"}, family="apt")
        self.assertIn("~/.local/bin", text)
        self.assertIn("export PATH=", text)

    def test_no_curl_means_no_download_command_is_suggested(self):
        text = self.advise("Linux", "x86_64", set())
        self.assertIn("No package manager was found", text)
        self.assertNotIn("curl -fsSL", text)
        # It must still tell the reader how to get there by hand.
        self.assertIn("Offline:", text)

    def test_every_case_names_the_egress_caveat_or_the_offline_route(self):
        for system, machine, present in (
            ("Darwin", "arm64", {"brew", "curl"}),
            ("Linux", "x86_64", {"apt", "curl", "tar"}),
            ("Linux", "x86_64", set()),
        ):
            text = self.advise(system, machine, present)
            self.assertIn("https://github.com/cli/cli#installation", text)


class WindowsTest(unittest.TestCase):
    """Windows is not a Unix with different slashes.

    Three things break there and none of them announce themselves as a Windows
    problem: os.geteuid does not exist, `export X=y` and `cmd < file` are parse
    errors in PowerShell rather than failing commands, and the Windows release
    archive does not nest under a version directory the way the others do.
    """

    def setUp(self):
        self.cg = load()
        self.system, self.machine = platform.system, platform.machine

    def tearDown(self):
        platform.system, platform.machine = self.system, self.machine

    def advise(self, present, env=None, machine="AMD64"):
        platform.system = lambda: "Windows"
        platform.machine = lambda: machine
        self.cg.shutil.which = lambda n: ("C:\\bin\\" + n) if n in present else None
        self.cg.os.environ = {} if env is None else env
        return "\n".join(self.cg.install_instructions())

    def test_is_root_does_not_explode_without_geteuid(self):
        # The real failure: AttributeError takes down the whole checker, so it
        # reports nothing at all rather than reporting that gh is missing.
        real = self.cg.os
        class NoGeteuid:
            def __getattr__(self, name):
                if name == "geteuid":
                    raise AttributeError("no geteuid on Windows")
                return getattr(real, name)
        self.cg.os = NoGeteuid()
        try:
            self.assertFalse(self.cg.is_root())
        finally:
            self.cg.os = real

    def test_bare_powershell_gets_powershell_syntax(self):
        text = self.advise({"winget"})
        self.assertIn("winget install --id GitHub.cli", text)
        self.assertIn("$env:LOCALAPPDATA", text)
        # The two constructs that are parse errors in PowerShell.
        self.assertNotIn("export ", text)
        self.assertNotIn("~/.local/bin", text)

    def test_git_bash_on_windows_gets_posix_syntax(self):
        text = self.advise({"curl", "tar"}, env={"MSYSTEM": "MINGW64"})
        self.assertIn("export PATH=", text)
        self.assertNotIn("$env:LOCALAPPDATA", text)

    def test_windows_archive_has_no_version_directory(self):
        # Verified against the real published zip: it unpacks to bin/gh.exe,
        # while macOS and linux nest under gh_<ver>_<os>_<arch>/.
        text = self.advise({"curl", "tar"}, env={"MSYSTEM": "MINGW64"})
        self.assertIn("/tmp/ghx/bin/gh.exe", text)
        self.assertNotIn("gh_${VER}_windows_amd64/bin", text)

    def test_windows_arm64_asset_name(self):
        text = self.advise({"winget"}, machine="ARM64")
        self.assertIn("gh_${VER}_windows_arm64.zip", text)

    def test_no_sudo_prefix_is_ever_emitted_on_windows(self):
        text = self.advise({"winget", "scoop", "choco"})
        self.assertNotIn("sudo", text)


class ShellKindTest(unittest.TestCase):
    def setUp(self):
        self.cg = load()
        self.system = platform.system

    def tearDown(self):
        platform.system = self.system

    def kind(self, system, env):
        platform.system = lambda: system
        self.cg.os.environ = env
        return self.cg.shell_kind()

    def test_unix_is_always_posix(self):
        self.assertEqual(self.kind("Linux", {}), "posix")
        self.assertEqual(self.kind("Darwin", {}), "posix")

    def test_bare_windows_is_powershell(self):
        self.assertEqual(self.kind("Windows", {}), "powershell")

    def test_git_bash_and_wsl_shells_are_posix(self):
        self.assertEqual(self.kind("Windows", {"MSYSTEM": "MINGW64"}), "posix")
        self.assertEqual(self.kind("Windows", {"SHELL": "/bin/bash"}), "posix")

    def test_set_env_matches_the_shell(self):
        platform.system = lambda: "Windows"
        self.cg.os.environ = {}
        self.assertEqual(self.cg.set_env("GH_TOKEN", "x"), '$env:GH_TOKEN = "x"')
        platform.system = lambda: "Linux"
        self.assertEqual(self.cg.set_env("GH_TOKEN", "x"), 'export GH_TOKEN="x"')


class VersionGateTest(unittest.TestCase):
    def setUp(self):
        self.cg = load()

    def test_parses_a_real_version_banner(self):
        self.assertEqual(
            self.cg.parse_version("gh version 2.97.0 (2026-07-31)"), (2, 97, 0))

    def test_returns_none_on_unparseable_output(self):
        self.assertIsNone(self.cg.parse_version("some other program"))

    def test_the_floor_rejects_old_and_accepts_current(self):
        self.assertLess(self.cg.parse_version("gh version 1.14.0 (2021-01-01)"),
                        self.cg.MIN_VERSION)
        self.assertGreaterEqual(
            self.cg.parse_version("gh version 2.0.0 (2021-08-24)"),
            self.cg.MIN_VERSION)


if __name__ == "__main__":
    unittest.main(verbosity=2 if "-v" in __import__("sys").argv else 1)
