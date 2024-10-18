from __init__ import *

CACHE_DIR = os.getenv("XDG_CACHE_HOME", os.path.join(os.path.expanduser("~"), ".cache"))
BINS = os.path.join(CACHE_DIR, "binaries")


class Sh:
    def __init__(self):
        self.reload()  # Load binaries on initialization

    def ls(self, path):
        if not os.path.exists(path):
            return []
        try:
            return (
                subprocess.check_output(f"ls {path}", shell=True, text=True)
                .strip()
                .splitlines()
            )
        except subprocess.CalledProcessError:
            return []

    def reload(self):
        """Reload the binaries from the PATH environment variable."""
        paths = os.getenv("PATH", "").split(":")
        bins = []

        for path in paths:
            bins.extend(self.ls(path))

        # Remove duplicates and save to file
        unique_bins = set(bins)
        with open(BINS, "w") as f:
            f.write("\n".join(unique_bins))

    @staticmethod
    def query(filter_str):
        """Filter binaries using fzf and return the results."""
        try:
            result = subprocess.check_output(
                f"cat {BINS} | fzf -f {filter_str} | head -n 16", shell=True, text=True
            )
            return list(dict.fromkeys(result.splitlines()))  # Deduplicate results
        except subprocess.CalledProcessError:
            return []

    @staticmethod
    def run(args: str):
        """Execute a command and print its output."""
        try:
            output = subprocess.check_output(args, shell=True, text=True)
            print(f":sh {args.strip()}:")
            print(output)
        except subprocess.CalledProcessError as err:
            print(f"Error running command: {err}")
