"""
RecordingLibrary.py
Helper library for saving Appium screen recordings to MP4 files.
Used by common.robot — called after Stop Recording Screen returns base64 content.
"""

import base64
import os
import re


class RecordingLibrary:

    def save_recording(self, b64_video, file_path):
        """
        Decode a base64-encoded video string and save it as an MP4 file.
        Returns the absolute path of the saved file.
        """
        os.makedirs(os.path.dirname(os.path.abspath(file_path)), exist_ok=True)
        with open(file_path, 'wb') as f:
            f.write(base64.b64decode(b64_video))
        return file_path

    def sanitize_filename(self, name):
        """
        Replace characters not safe for filenames with underscores.
        """
        return re.sub(r'[^\w\-]', '_', name)
