# powershell-folder-organizer

A simple PowerShell tool that organizes a folder by file type.

## Features

- Organizes files by extension
- Uses a JSON rules file
- Supports Downloads by default
- Has safe preview mode
- Avoids overwriting files with the same name
- Skips folders by default
- Can organize recursively if needed

## Usage

Preview what would happen:

    .\scripts\Organize-Folder.ps1 -DryRun

Organize Downloads:

    .\scripts\Organize-Folder.ps1

Organize another folder:

    .\scripts\Organize-Folder.ps1 -Path "C:\Path\To\Folder"

Organize subfolders too:

    .\scripts\Organize-Folder.ps1 -Recurse

## Configuration

Edit:

    config\rules.json

Default target:

    %USERPROFILE%\Downloads

## Example

Files like this:

    setup.exe
    image.png
    video.mp4
    document.pdf

Become:

    exe\setup.exe
    png\image.png
    video\video.mp4
    pdf\document.pdf

## Project status

> This project was later merged into [powershell-file-toolkit](https://github.com/hikmiau/powershell-file-toolkit).
>
> The newer toolkit includes the organizer, scanner, duplicate finder, and empty folder cleaner in one project.
