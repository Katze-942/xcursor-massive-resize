#!/bin/bash

# This script is an addition to cursor_converting.sh .
# It runs much faster than the previous script.
#
# Its essence is to take some ready-made theme (PATH_TO_TEMPLATE) and overlay your icons on top of it, which you have prepared in the PATH_TO_ADAPT_XCURSOR folder.
#
# There is a config file below to configure the correspondences between the cursor file and the file in the theme itself.

source ./config.sh
PACK_FOLDER=$(echo $PACK_NAME | sed 's/ /_/g');


# Starting the cursor conversion process.
if [ "$CONVERTING" -eq 1 ]; then
    echo "Converting cursors..."
    ./cursor_converting.sh || exit
else
    echo "Skipping cursor conversion...";
fi

# We check the availability of all necessary directories.
if [ "$INSTALL_CURSOR_PACK" -eq 1 ]; then
    if ! [[ -d $PATH_TO_INSTALL ]]; then
        echo -e "${D_RED}Error: the package installation directory was not found (\"$PATH_TO_INSTALL\")${D_CANCEL}" 1>&2;
        exit 1;
    fi

    # We check if there is a folder with the name of the theme in our directory.
    if [[ -d "$PACK_FOLDER" ]]; then
        if [ "$REINSTALL_PACK" -eq 1 ]; then
            echo "Deleting the \"$PACK_FOLDER\" theme...";
            rm -rf "$PACK_FOLDER";
        else
            echo -e "${D_RED}Error: the \"$PACK_FOLDER\" theme already exists in \"$PATH_TO_INSTALL\"!${D_CANCEL}" 1>&2;
            exit 1;
        fi
    fi
fi

if ! [[ -d $PATH_TO_ADAPT_XCURSOR ]]; then
    echo -e "${D_RED}Error: The \"$PATH_TO_ADAPT_XCURSOR\" directory was not found.${D_CANCEL}" 1>&2;
    exit 1;
fi

if ! [[ -d "$PATH_TO_TEMPLATE/cursors" ]]; then
    echo -e "${D_RED}Error: The \"$PATH_TO_TEMPLATE/cursors\" directory was not found.${D_CANCEL}" 1>&2;
    exit 1;
fi

echo "Copying the folder with the template..."
cp -r "$PATH_TO_TEMPLATE" "$PACK_FOLDER";

cd "$PACK_FOLDER" || exit;

rm index.theme cursor.theme 2>/dev/null

cat << EOF >> index.theme
[Icon Theme]
Name=${PACK_NAME}
Comment=${PACK_DESCRIPTION}
EOF

ln -s "index.theme" "cursor.theme";

cd cursors || exit;

echo -e "${D_GREEN}Copying is completed!${D_CANCEL}"

# We go through each cursor.
for Name in "${!CURSOR_ACTIONS[@]}"; do
    echo;

    # We check whether this cursor is used for something.
    if [[ "${CURSOR_ACTIONS[$Name]}" == "" ]]; then
        echo -e "${D_YELLOW}The cursor \"$Name\" is not used anywhere. Skipping...${D_CANCEL}"
        continue
    fi

    # We check if the cursor file exists.
    if ! [[ -f "../../$PATH_TO_ADAPT_XCURSOR/$Name" ]]; then
        echo -e "${D_YELLOW}The cursor \"$PATH_TO_ADAPT_XCURSOR/$Name\" was not found. Skipping...${D_CANCEL}"
        continue
    fi

    # Copy this cursor to the folder with the theme.
    cp -r "../../$PATH_TO_ADAPT_XCURSOR/$Name" .

    # Turning the key value into an array.
    IFS=' ' read -ra icons <<< "${CURSOR_ACTIONS[$Name]}";
    for fileName in "${icons[@]}"; do
        # Removing the cursor from the template.
        rm "$fileName";

        # And replace it with your cursor.
        ln -s "$Name" "$fileName";
    done;

    echo -e "${D_GREEN}The \"$Name\" cursor is saved in the theme!${D_CANCEL}";
done

cd ../../

if [ "$INSTALL_CURSOR_PACK" -eq 1 ]; then
    # We check if there is a folder with the name of the theme in the system directory.
    if [[ -d "$PATH_TO_INSTALL/$PACK_FOLDER" ]]; then
        if [ "$REINSTALL_PACK" -eq 1 ]; then
            echo "Removing the \"$PACK_FOLDER\" package from \"$PATH_TO_INSTALL\"...";
            rm -rf "${PATH_TO_INSTALL:?}/${PACK_FOLDER}";
        else
            echo -e "${D_RED}Error: the \"$PATH_TO_INSTALL/$PACK_FOLDER\" theme already exists in \"$PATH_TO_INSTALL\"!${D_CANCEL}" 1>&2;
            exit;
        fi
    fi

    echo "Copying the theme to $PATH_TO_INSTALL...";
    cp -r "$PACK_FOLDER" "$PATH_TO_INSTALL";
    echo -e "${D_GREEN}Copying is completed!${D_CANCEL}"
fi

echo
echo "Done!";
