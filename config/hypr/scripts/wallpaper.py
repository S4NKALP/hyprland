import os
import sys
import importlib.util
import argparse
import fcntl
import subprocess
import asyncio
import random as _random


lock_file_path = '/tmp/wallpaper.lock'


def acquire_lock():
    global lock_file
    lock_file = open(lock_file_path, 'w')
    try:
        fcntl.flock(lock_file, fcntl.LOCK_EX | fcntl.LOCK_NB)
        lock_file.write(str(os.getpid()))
        lock_file.flush()
    except IOError:
        print("Another instance of the script is already running.")
        sys.exit(1)


def release_lock():
    fcntl.flock(lock_file, fcntl.LOCK_UN)
    lock_file.close()
    os.remove(lock_file_path)


parser = argparse.ArgumentParser()
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('-I', '--image', type=str, help="Image")
group.add_argument('-R', '--random', help="Random image from folder", action='store_true')
parser.add_argument('-n', '--notify', help="Send notifications", action='store_true')
parser.add_argument('--status', type=str, help="Status file", default="/tmp/wallpaper.status")

args = parser.parse_args()

random = args.random
image = args.image
notify = args.notify
status = args.status

HOME = os.path.expanduser("~")


cache_file = f"{HOME}/.cache/current_wallpaper"
square = f"{HOME}/.cache/square_wallpaper.png"


def current_state(state_str: str):
    with open(status, 'w') as f:
        f.write(state_str)


def send_notify(label: str, desc: str):
    if not notify:
        return
    subprocess.run(["notify-send", label, desc])


def state(name: str | None, label: str | None, desc: str | None):
    if name is not None:
        current_state(name)
    if label is not None:
        send_notify(label, desc or "")


def join(*args):
    return os.path.join(*args)


async def main():
    state("init", None, None)

    new_wallpaper = f"{HOME}/Pictures/wallpapers/wall-01.jpg"

    if random:
        files = [f for f in os.listdir(f"{HOME}/Pictures/wallpapers") if f.endswith(('.png', '.jpg', '.jpeg'))]
        if files:
            new_wallpaper = join(f"{HOME}/Pictures/wallpapers", _random.choice(files))
            ...
    elif image is not None:
        new_wallpaper = os.path.abspath(image)

    print(f":: Wallpaper {new_wallpaper}")

    with open(cache_file, 'w') as f:
        f.write(new_wallpaper)

    with_image = f"with image {new_wallpaper}"

    # -----------------------------------------------------
    # Set the new wallpaper
    # -----------------------------------------------------

    transition_type = "wipe"
    # transition_type = "outer"
    # transition_type = "random"

    wallpaper_engine = "swww"  # Default wallpaper engine

    state("changing", "Changing wallpaper...", with_image)
    print(":: Changing wallpaper...")
    if wallpaper_engine == "swww":
        print(":: Using swww")

        cursor_pos = subprocess.getoutput('hyprctl cursorpos')

        subprocess.run([
            'swww', 'img', new_wallpaper,
            '--transition-bezier', '.43,1.19,1,.4',
            '--transition-fps', '60',
            '--transition-type', transition_type,
            '--transition-duration', '0.7',
            '--transition-pos', cursor_pos
        ])
    else:
        print(":: Wallpaper Engine disabled")

    # -----------------------------------------------------
    # Square image
    # -----------------------------------------------------
    square_task = asyncio.create_task(square_image(new_wallpaper))

    state("tasks", None, None)
    await asyncio.gather(square_task)
    state("finish", "Wallpaper procedure complete!", with_image)


async def square_image(wallpaper):
    with_image = f"with image {wallpaper}"
    state(None, "Creating square version...", with_image)
    print(":: Creating square version")
    cmd = f"magick {wallpaper} -gravity Center -extent 1:1 {square}"
    process = await asyncio.create_subprocess_shell(
        cmd,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE
    )
    stdout, stderr = await process.communicate()

    if process.returncode != 0:
        print(f":: Error while processing image: {stderr.decode()}")
    else:
        print(":: Square image created!")


if __name__ == "__main__":
    acquire_lock()
    try:
        asyncio.run(main())
    finally:
        release_lock()
