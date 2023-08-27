@echo off
setlocal enabledelayedexpansion

:: Display folder selection dialog for source folder
set "tempfile=%temp%\folderpicker.vbs"
echo Set objShell = CreateObject("Shell.Application") > "%tempfile%"
echo Set objFolder = objShell.BrowseForFolder(0, "Select source folder", 0, 0) >> "%tempfile%"
echo if objFolder is nothing then >> "%tempfile%"
echo     wscript.echo "No folder selected" >> "%tempfile%"
echo else >> "%tempfile%"
echo     wscript.echo objFolder.self.path >> "%tempfile%"
echo end if >> "%tempfile%"
for /f "delims=" %%I in ('cscript //nologo "%tempfile%"') do set "source_folder=%%I"
del "%tempfile%"

:: Display folder selection dialog for destination folder
set "tempfile=%temp%\folderpicker.vbs"
echo Set objShell = CreateObject("Shell.Application") > "%tempfile%"
echo Set objFolder = objShell.BrowseForFolder(0, "Select destination folder", 0, 0) >> "%tempfile%"
echo if objFolder is nothing then >> "%tempfile%"
echo     wscript.echo "No folder selected" >> "%tempfile%"
echo else >> "%tempfile%"
echo     wscript.echo objFolder.self.path >> "%tempfile%"
echo end if >> "%tempfile%"
for /f "delims=" %%I in ('cscript //nologo "%tempfile%"') do set "destination_folder=%%I"
del "%tempfile%"

:: Print selected folder paths
echo Source folder: %source_folder%
echo Destination folder: %destination_folder%

:: Prompt user for watermark width
set /p "watermark_width=Enter watermark width percentage (default: 15%%): "
if not defined watermark_width_percentage set "watermark_width_percentage=15"

:: Prompt user for watermark offset
set /p "watermark_offset=Enter watermark offset percentage (default: 3%%): "
if not defined watermark_offset_percentage set "watermark_offset_percentage=3"

:: Overlay watermark using ImageMagick
set "watermark=watermark.png"
for %%A in ("%source_folder%\*.jpg", "%source_folder%\*.jpeg", "%source_folder%\*.png") do (
    set "input_image=%%~A"
    set "output_image=%destination_folder%\%%~nA%%~xA"
    echo Processing %%~A ...
    for /f "delims=" %%L in ('magick identify -format "image_width=%%w\nimage_height=%%h" "!input_image!"') do set %%L
    echo Input image: width=!image_width!, height=!image_height!
    if !image_width! gtr !image_height! (
        set "image_longest=!image_width!"
    ) else (
        set "image_longest=!image_height!"
    )
    :: Calculate watermark width
    set /a watermark_width=watermark_width_percentage*image_longest/100
    :: Calculate watermark offset
    set /a watermark_offset=watermark_offset_percentage*image_longest/100
    echo Watermark: width=!watermark_width! offset=!watermark_offset!
    magick composite -gravity southeast -compose atop -geometry !watermark_width!x+!watermark_offset!+!watermark_offset! "!watermark!" "!input_image!" "!output_image!"
    echo ==================================================
)

:: Display completion message and wait for user input before quitting
echo Operation completed. Press any key to quit.
pause > nul
