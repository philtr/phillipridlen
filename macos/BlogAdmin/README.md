# BlogAdmin (macOS)

Native macOS editor for this repo's Markdown posts. The app reads and writes files directly in the repo (no local web server).

## Setup

1. Open the Swift package in Xcode:

   ```bash
   open macos/BlogAdmin/Package.swift
   ```

2. Run the app from Xcode.

## Usage

- Click **Choose Folder** and select the repo root (the folder containing `src/`).
- Choose **Notes** or **Drafts** from the scope picker.
- Select a post, edit fields, and hit **Save**.

## Notes

- Posts are loaded from `src/posts/notes` or `src/drafts/notes`.
- Front matter is parsed by the app and rewritten on save (no external dependencies).
