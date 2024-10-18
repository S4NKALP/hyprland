import os
import subprocess
import psutil
import json
import socket
import fabric
import glob
from pathlib import Path
from fabric.widgets.image import Image
from fabric import Application
from fabric.hyprland.widgets import Language, WorkspaceButton, Workspaces
from fabric.system_tray.widgets import SystemTray
from fabric.utils import (
    FormattedString,
    bulk_connect,
    bulk_replace,
    exec_shell_command,
    exec_shell_command_async,
    get_relative_path,
    invoke_repeater,
    monitor_file,
    DesktopApp,
    get_desktop_applications,
    idle_add,
    remove_handler,
)
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.revealer import Revealer
from fabric.widgets.centerbox import CenterBox
from fabric.widgets.datetime import DateTime
from fabric.widgets.eventbox import EventBox
from fabric.widgets.label import Label
from fabric.widgets.overlay import Overlay
from fabric.widgets.wayland import WaylandWindow as Window
from gi.repository import GLib, Gtk, Gdk, GdkPixbuf
from typing import TypedDict
from fabric.hyprland.widgets import get_hyprland_connection
from fabric.bluetooth.service import BluetoothClient
from loguru import logger
from fabric.widgets.scrolledwindow import ScrolledWindow
from fabric.widgets.entry import Entry
from collections.abc import Iterator

AUDIO_WIDGET = True

if AUDIO_WIDGET is True:
    try:
        from fabric.audio.service import Audio
    except Exception as e:
        print(e)
        AUDIO_WIDGET = False


from modules.bar.widgets.TaskBar import TaskBar
from modules.bar.widgets.VolumeIndicator import VolumeIndicator
from modules.bar.widgets.MicrophoneIndicator import MicrophoneIndicator
from modules.bar.widgets.BatteryIndicator import BatteryLabel
from modules.bar.widgets.WifiIndicator import Wifi
from modules.bar.widgets.BluetoothIndicator import Bluetooth
from modules.bar.widgets.SystemInfo import RAMUsage, CPUUsage, SwapMemoryUsage
from modules.bar.widgets.PowerMenu import PowerMenu


from services.brightness import Brightness
from services.screen_record import ScreenRecorder
from services.emoji import EmojiService, EmojiItem
from services.sh import Sh

from modules.launcher.clipboard import ClipboardManager
from modules.launcher.emoji import EmojiManager
from modules.launcher.shell import ShellCommandManager
from modules.launcher.wallpaper import WallpaperManager
from modules.launcher.app import handle_application_search, bake_favorite_slot
from modules.launcher.launcher import Launcher

from modules.bar.bar import Bar  # Should always be the last module
