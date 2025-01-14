#!/bin/bash

# I will explain the history of the creation of this script.
# I found some interesting animated cursors for Windows. However, it took a very long and tedious time to adapt them to Linux.

# This script does in a few seconds the dreary things that I did manually for several hours, namely:
# 1. Converts ANI/CUR files to XCursor
# 2. Extracts all data from XCursor
# 3. Adapts the animated cursor to different resolutions (so that in KDE, for example, you can select any cursor size)
# 4. Merges all changes into the XCursor-Adapt folder

# If you don't need to convert ANI/CUR files, then you can set the value of the CONVERT_WINDOWS_CURSOR variable to 0 and drop your cursors into the XCursor folder. Feel free to write about bugs, suggestions for improvements, and so on!


source ./config.sh

# Creating all the necessary folders.
mkdir -p "$PATH_TO_XCURSOR" "$PATH_TO_ADAPT_XCURSOR";

# The post-processing directory is needed for temporary files.
if [[ -d "$PATH_TO_XCURSOR/post-processing" ]]; then
    rm -rf "$PATH_TO_XCURSOR/post-processing";
fi

mkdir "$PATH_TO_XCURSOR/post-processing";

# A function for checking the presence of commands
function check_command() {
  if ! command -v "$1" &> /dev/null; then
    echo -e "${D_RED}Error: The \"$1\" command was not found!${D_CANCEL}" 1>&2;
    exit 1
  fi
}

# Converting ANI/CUR cursors to XCursor
if [ "$CONVERT_WINDOWS_CURSOR" -eq 1 ]; then
    echo "Starting the conversion of ANI/CUR cursors...";
    if [ -d "$PATH_TO_ANI_CUR_CURSORS" ]; then
        check_command "win2xcur";
        win2xcur "$PATH_TO_ANI_CUR_CURSORS"/*.ani -o "$PATH_TO_XCURSOR/";
        win2xcur "$PATH_TO_ANI_CUR_CURSORS"/*.cur -o "$PATH_TO_XCURSOR/";
    else
        echo -e "${D_RED}Error: The \"$PATH_TO_ANI_CUR_CURSORS\" directory was not found.${D_CANCEL}" 1>&2;
        exit 1;
    fi
    echo -e "${D_GREEN}The ANI/CUR cursor conversion process is complete!${D_CANCEL}";
else
    echo "The conversion of ANI/CUR cursors is skipped...";
fi

check_command "xcur2png";
check_command "magick";
check_command "xcursorgen";

# We get all the file names in the XCursor directory.
find "$PATH_TO_XCURSOR" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' file; do
    file_name=$(basename "$file");

    echo

    # Converting an animated (or regular) XCursor file to PNG images and a .conf file.
    echo "Extracting data from \"$file_name\"...";
    xcur2png -q "$PATH_TO_XCURSOR/$file_name" -d "$PATH_TO_XCURSOR/post-processing/";

    # Moving all the config files to the desired directory.
    mv "$file_name.conf" "$PATH_TO_XCURSOR/post-processing/";

    # We get the path to the config file that we will edit.
    path_config_file="$PATH_TO_XCURSOR/post-processing/$file_name.conf"

    # In this array, we store all the sizes that are already specified in the config file.
    config_cursor_sizes=();

    # The maximum cursor size specified in the configuration.
    max_cursor_size=0;

    # If several cursor sizes are specified in the configuration, we need to filter them.
    # This array will store the cursor sizes that are specified in CURSOR_SIZES, but which are not in the config.
    custom_cursor_sizes_filtered=();

    echo "Parsing data from a config file...";
    flag=0; # To skip the first line of the config file, we make this variable. After skipping the first line, we set the value to 1.
    while IFS=$'\t' read -r size xhot yhot path delay; do
        if [ $flag -eq 0 ]; then
            flag=1;
            continue;
        fi

        #  We check for the presence of a value in the array and ignore empty lines.
        if [[ -n "$size" && ! "${config_cursor_sizes[*]}" =~ $size ]]; then
            # Adding this size to the array.
            config_cursor_sizes+=("$size")

            # We check whether this size is the maximum. If yes, then set the value to a variable.
            if [[ $size -gt $max_cursor_size ]]; then
                max_cursor_size=$size;
            fi
        fi
    done < "$path_config_file"

    echo "The parsing is completed, we calculate the sizes of the cursors that need to be generated...";

    # From the CURSOR_SIZES array, we cut out all the values from config_cursor_sizes.
    found=();
    for i in "${config_cursor_sizes[@]}"; do
        found[i]=1
    done

    for i in "${CURSOR_SIZES[@]}"; do
        if [[ -z "${found[$i]}" ]]; then
            custom_cursor_sizes_filtered+=("$i")
        fi
    done

    echo -e "${D_GREEN}The cursor size calculation process is complete!${D_CANCEL}";

    echo "I'm reading the cursor config file..."
    # We are reading the config again, but now those lines in which the cursor size is maximum.
    # This is necessary for the most qualitative resizing of the cursor.
    while IFS=$'\t' read -r size xhot yhot path delay; do
        # Skip the iteration if the line is not with the maximum cursor size.
        if ! [[ "$size" == "$max_cursor_size" ]]; then
            continue;
        fi

        # The name of the file specified in the config.
        path_filename=$(basename "$path");
        echo
        echo "I'm starting to generate frames of different sizes for the \"$path_filename\" file..."

        # We go through each cursor size.
        for size in "${custom_cursor_sizes_filtered[@]}"; do
            # The new path to the file with the new name.
            new_file_png_path="$PATH_TO_XCURSOR/post-processing/${size}px_$path_filename";

            # Converting the image to a new size. -sample disables interpolation and removes the soap from the cursor.
            magick "$path" -background none -sample "${size}x${size}" "$new_file_png_path";
            echo -e "${D_GREEN}The image is saved in ${new_file_png_path}${D_CANCEL}"

            # When the size changes, its hot spots also change. We calculate and register them in the config
            X_nonInteger=0;
            Y_nonInteger=0;
            X=0;
            Y=0;
            if ! [[ $xhot == "0" ]]; then
                X_nonInteger=$(bc<<<"scale=1; $xhot * ($size/$max_cursor_size)");
                X=$(bc<<<"$X_nonInteger/1")
            fi

            if ! [[ $yhot == "0" ]]; then
                Y_nonInteger=$(bc<<<"scale=1; $yhot * ($size/$max_cursor_size)");
                Y=$(bc<<<"$Y_nonInteger/1")
            fi

            # Writing the changes to the cursor config file
            line="$size\t$X\t$Y\t$new_file_png_path\t$delay"
            echo -e "$line";
            echo -e "$line" >> "$path_config_file";
        done
        echo -e "${D_GREEN}Frame generation for $path_filename is complete!${D_CANCEL}";
    done < "$path_config_file"

    echo "Combining all images into a single cursor...";
    xcursorgen "$path_config_file" "$PATH_TO_ADAPT_XCURSOR/$file_name";
    echo -e "${D_GREEN}The merger is complete! The file is saved in $PATH_TO_ADAPT_XCURSOR/$file_name${D_CANCEL}";
done

echo "Done!"
