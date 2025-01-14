*[Русская версия](./README_ru.md) • English version*

# Script for Cursor Conversion
This is a series of scripts that can assist you in creating a cursor for Linux. For any questions or issues, feel free to open an Issue in this repository.

## Prehistory
I came across some animated cursors by an author ([\_BLZ\_](https://ko-fi.com/blz_404/shop)) designed for Windows and macOS, and I really liked them. I thought it would be a good idea to port them to Linux. Along the way, I encountered a number of challenges, which led me to write this script to address them.


The main issue was with KDE Plasma, which only allowed setting a cursor size of 32 pixels. To resolve this, it was necessary to decompile the XCursor file, resize each cursor frame to different sizes (for example, if you resize a frame to 16 and 36 pixels, KDE Plasma will allow setting the sizes 16 and 36), and reassemble it into an XCursor file. Doing this manually in GIMP would have taken hours.

## What tasks do these scripts perform?
Here, I’ll briefly describe the scripts. More detailed explanations and usage examples are provided below.

https://github.com/user-attachments/assets/b320720b-553a-49b1-945c-e0fa10611a6f

### config.sh
This is not a script and does not need to be executed. It contains the configuration settings for the scripts listed below.

### cursor_converting.sh
This script performs the following conversion operations:
1. Converts all ANI/CUR cursors from Windows to the XCursor format (configurable via the `CONVERT_WINDOWS_CURSOR` parameter — more on that later).
2. Unpacks each XCursor file and adapts it to various sizes (configurable via the `CURSOR_SIZES` parameter). For example, you can set sizes like 12, 18, 24, 30, 36, 42, 48, 54, 60, 66, and 72, as in the Breeze Cursor theme.
3. Reassembles the files into a single XCursor file and saves it to `PATH_TO_ADAPT_XCURSOR`. Voilà! KDE Plasma can now use cursors of different sizes.

### cursor_install.sh
This script collects all XCursor files into a single folder and allows you to install them into the system immediately. To function properly, it requires a template onto which the new cursors will be applied. You can use almost any cursor pack as a template, such as Breeze.
1. Executes the `cursor_converting.sh` script (can be disabled via the `CONVERTING` parameter).
2. Copies the template and configures the pack name and description (`PACK_NAME` and `PACK_DESCRIPTION`).
3. Overlays the generated XCursor files onto the template (configured via the `CURSOR_ACTIONS` parameter).
4. Installs the cursors into your system (`INSTALL_CURSOR_PACK`).

### clear.sh
Cleans up the `PATH_TO_ADAPT_XCURSOR` and `PATH_TO_XCURSOR` folders, where temporary files accumulate after cursor compilation.

## Dependencies
- [bc](https://git.gavinhoward.com/gavin/bc) (required for mathematical calculations)
- [win2xcur](https://github.com/quantum5/win2xcur) (optional, used for converting cursors from the Windows format)
- [xcur2png](https://github.com/eworm-de/xcur2png) (required for unpacking XCursor files)
- [ImageMagick](https://imagemagick.org/script/download.php) (required for converting images to different resolutions)
- xcursorgen (required for XCursor packaging)

## Configuration settings (config.sh)

### Configuring paths
- `PATH_TO_ANI_CUR_CURSORS`: the directory where Windows cursors are stored.
- `PATH_TO_XCURSOR`: the directory where raw XCursor files will be stored.
- `PATH_TO_ADAPT_XCURSOR`: the directory where XCursor files processed by the scripts will be stored.
- `PATH_TO_TEMPLATE`: the directory containing the third-party cursor pack. Your cursors will be applied on top of it. **The directory must include a "cursors" folder!**
- `PATH_TO_INSTALL`: the directory where the cursors will be installed.

### Setting up cursor_converting.sh
- `CONVERT_WINDOWS_CURSOR`: set this value to 1 if you need to convert Windows cursors to the XCursor format.
- `CURSOR_SIZES`: specify the sizes to which you want to convert the cursors. If you are using KDE Plasma, you can leave the default values.

### Setting up cursor_install.sh
- `CONVERTING`: set this value to 1 if you need to call `cursor_converting.sh` beforehand.
- `INSTALL_CURSOR_PACK`: set this value to 1 if the cursors should be installed in `PATH_TO_INSTALL`.
- `REINSTALL_PACK`: set this value to 1 if you are experimenting. This allows you to easily reinstall the cursor pack you previously built by simply deleting the previously generated pack.
- `PACK_NAME`: the name of the cursor pack. The folder containing the cursors will use this name.
- `PACK_DESCRIPTION`: the description of your cursor pack.
- `CURSOR_ACTIONS`: by default, this variable is configured to work with cursors created by [\_BLZ\_](https://ko-fi.com/blz_404/shop) (the author). The file name is on the left, and the cursor actions it corresponds to are listed on the right. For example, the "Link" file will be triggered on all links, such as pointer, hand1, and so on.

## An example of how to work with the scripts
1. Clone the repository:
```shell
git clone "https://github.com/Katze-942/xcursor-massive-resize" --depth=1
cd xcursor-massive-resize
```
2. Open the `config.sh` file and configure the settings described above.
3. Set up the template that will be used to create the theme. Your cursors will be applied on top of this template. I prefer to use [Breeze cursors](https://invent.kde.org/plasma/breeze/-/tree/master/cursors/Breeze_Light/Breeze_Light). **The template should only contain the "cursors" folder! There should be no other folders or files there.**
4. Download a Windows cursor pack (you can skip this step by copying the XCursor files into `PATH_TO_XCURSOR` and setting `CONVERT_WINDOWS_CURSOR=0`). As an example, let's use [this one](https://ko-fi.com/s/7ddcb948b6).
5. Unpack all .ani/.cur files into the `PATH_TO_ANI_CUR_CURSORS` directory *(skip this step if `CONVERT_WINDOWS_CURSOR=0`)*.
6. Run `cursor_converting.sh`. If everything goes smoothly, your XCursor files will appear in the `PATH_TO_ADAPT_XCURSOR` directory.
7. Configure `PACK_NAME` and `PACK_DESCRIPTION` in `config.sh` and make sure that all file names match in `CURSOR_ACTIONS`. If any file is missing, it will be skipped.
8. Run the `cursor_install.sh` file. If everything goes as planned, your cursor pack will appear both in the project folder and in `PATH_TO_INSTALL`. Further steps depend on your system. In KDE Plasma, your cursor will be available in the system settings.

## More detailed explanations of how the script works
### cursor_converting.sh
1. When `cursor_converting.sh` is run, the directories `PATH_TO_XCURSOR`, `PATH_TO_XCURSOR/post-processing`, and `PATH_TO_ADAPT_XCURSOR` are created.
2. When `CONVERT_WINDOWS_CURSOR=1`, the script moves to the `PATH_TO_ANI_CUR_CURSORS` directory and converts all .ani/.cur files to XCursor format using the `win2xcur` utility. All XCursor files are saved to the `PATH_TO_XCURSOR` folder.
3. The script moves to the `PATH_TO_XCURSOR` folder and generates a list of all files. Each XCursor file is converted into a series of **.png** images and a .conf cursor configuration file, which contains details about each frame (path to the .png image, cursor hitbox, animation delay, and cursor size).
4. All **.png** images and **.conf** files are moved to the `PATH_TO_XCURSOR/post-processing` folder to keep things organized.
5. Each **.conf** file is analyzed to find the largest cursor size, which is usually 32.
6. The **.conf** file is re-analyzed. Using ImageMagick, each **.png** image is resized to different sizes (as specified in `CURSOR_SIZES`). For example, `Normal_001.png` will be converted to `12px_Normal_001.png`, `18px_Normal_001.png`, and so on.
7. The new hitbox of the cursor is calculated. For example, if the cursor has a hitbox of X=15, Y=15, and we double its size, the hitbox becomes X=30, Y=30. We calculate and record this information.
8. All changes are saved to the **.conf** file (the terminal will display the lines that are written to the file).
9. Using `xcursorgen`, the **.conf** file and **.png** images are used to assemble the final XCursor file.

### cursor_install.sh
1. Run `cursor_converting.sh` if `CONVERTING=1`
2. Copy the template folder (`PATH_TO_TEMPLATE`) under a new name (`PACK_NAME`).
3. In this folder, create the `index.theme` and `cursor.theme` files with the name and description of our package.
4. Analyze `CURSOR_ACTIONS`. Look for the corresponding file in `PATH_TO_ADAPT_XCURSOR` and copy it to our package.
5. Create symbolic links to the files listed in `CURSOR_ACTIONS` (for example, `default`, `pointer`, and so on).
6. If `INSTALL_CURSOR_PACK=1`, copy the folder to `PATH_TO_INSTALL`.
