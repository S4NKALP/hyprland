import subprocess
from gi.repository import GLib
from fabric.core.service import Service
from fabric.utils import exec_shell_command_async


class CliphistItem:
    def __init__(self, id: int, content: str, content_type: str):
        self.id = id
        self.content = content
        self.content_type = content_type


async def query(filter: str):
    fzf_args = '-f ""' if filter == "" else f"-f {filter}"

    try:
        result = exec_shell_command_async(
            ["bash", "-c", f"cliphist list | fzf {fzf_args} | head -n 16"]
        )
        items = set()  # Using a set to ensure uniqueness

        for line in result.split("\n"):
            if line:
                match = GLib.regex_match(r"(\d+)\s+(.*)", line)
                if match:
                    id = int(match.group(1))
                    content = match.group(2)
                    content_type = "text"
                    if content.startswith("[["):
                        binary_match = GLib.regex_match(
                            r"\[\[\s+binary data.*(jpg|png|webp|jpeg|bmp)", content
                        )
                        if binary_match:
                            content_type = binary_match.group(1)

                    items.add(CliphistItem(id, content, content_type))

        return list(items)

    except Exception as err:
        print(err)
        return []


async def run(args: CliphistItem):
    try:
        output = exec_shell_command_async(
            ["bash", "-c", f"cliphist decode {args.id} | wl-copy"]
        )
        print(f":cliphist {args.id}:")
        print(output)
    except Exception as err:
        print("hello")


async def get_file(item: CliphistItem):
    filepath = f"/tmp/cliphist-{item.id}.{item.content_type}"
    if not GLib.file_test(filepath, GLib.FileTest.EXISTS):
        exec_shell_command_async(
            ["bash", "-c", f"cliphist decode {item.id} > {filepath}"]
        )
    return filepath


class Cliphist(Service):
    def __init__(self):
        super().__init__()

    async def get_file(self, item: CliphistItem):
        return await get_file(item)

    async def query(self, filter: str):
        return await query(filter)

    async def run(self, args: CliphistItem):
        await run(args)


if __name__ == "__main__":
    cliphist = Cliphist()
    Service.register(cliphist)
