#!/bin/bash

# ==================== PATH ==================== #
# The folder where the ANI/CUR cursors will be stored.
PATH_TO_ANI_CUR_CURSORS="Windows-Cursors"

# The directory where XCursor will be stored.
# The converted ANI/CUR cursors will also be saved in this directory.
PATH_TO_XCURSOR="XCursor"

# # In this directory, we save all XCursor cursors, with cursors with different resolutions inside.
# The path to the XCursor files. The value must be the same here and in the file cursor_converting.sh.
PATH_TO_ADAPT_XCURSOR="XCursor-Adapt"

# The path to the folder with the template. A template is a folder with cursors, for example, Breeze, on top of which your cursor pack is superimposed. This is necessary for greater compatibility.
# The cursors label should be in the folder.
PATH_TO_TEMPLATE="Template"

# The path to install the cursor pack.
PATH_TO_INSTALL="$HOME/.local/share/icons/"


# =============== ./cursor_converting.sh =============== #
# Put 1 next to it to convert ANI/CUR cursors to XCursor format.
# If you don't have ANI/CUR cursors, set 0
CONVERT_WINDOWS_CURSOR=1

# Specify the size of the cursors you want to see. By default, there are so many sizes available in Breeze. 256 size is necessary for high-quality approximation in KDE Plasma.
CURSOR_SIZES=(12 18 24 30 36 42 48 54 60 66 72 256)


# ================== ./cursor_install.sh ================== #
# A value of 1 starts the script. cursor_converting.sh.
CONVERTING=0

# Set the value to 1 if you want the cursor to set to PATH_TO_INSTALL.
INSTALL_CURSOR_PACK=1

# With a value of 1, the script will be able to erase the finished package ($PACK_NAME) and install it again.
REINSTALL_PACK=1

# The name of the package and its description.
PACK_NAME="PACK NAME"
PACK_DESCRIPTION="Description"

# Establish a correspondence between the cursor name and its "actions".
# By default, the file names here are configured for cursors from the author of BLZ.
# For example, the cursor file "Alternate" will be used for the alias and dnd-move actions.
declare -A CURSOR_ACTIONS
CURSOR_ACTIONS=(
  ["Normal"]="default arrow left_ptr top_left_arrow"
  ["Link"]="pointer hand1 hand2 pointing_hand 9d800788f1b08800ae810202380a0822 e29285e634086352946a0e7090d73106 "
  ["Text"]="text vertical-text ibeam xterm"
  ["Busy"]="wait watch"
  ["Help"]="help question_arrow whats_this 5c6cd98b3f3ebcb1f9c7f1c204630408 d9ce0ab605698f320427677b458ad60b"
  ["Move"]="grabbing all-scroll fleur size_all"
  ["Unavailable"]="dnd-no-drop no-drop not-allowed circle crossed_circle forbidden"
  ["Working"]="progress half-busy left_ptr_watch 00000000000000020006000e7e9ffc3f 08e8e1c95fe2fc01f976f1e063a24ccd 3ecb610c1bf2410f44200f48c40d3599"
  ["Precision"]="crosshair cross tcross"
  ["Pin"]="copy openhand dnd-copy grab 1081e37283d90000800003c07f3ef6bf 6407b0e94181790501fd1e167b474872 b66166c04f8c3109214a4fbd64a50fc8"
  ["Diagonal1"]="size_fdiag nw-resize nwse-resize se-resize size-fdiag"
  ["Diagonal2"]="size_bdiag ne-resize nesw-resize size-bdiag sw-resize"
  ["Horizontal"]="col-resize size_hor e-resize ew-resize h_double_arrow left_ptr_help sb_h_double_arrow size-hor split_h w-resize"
  ["Vertical"]="row-resize size_ver n-resize ns-resize sb_v_double_arrow size-ver split_v s-resize v_double_arrow 00008160000006810000408080010102"
  ["Alternate"]="dnd-move dnd-none alias link closedhand move fcf21c00b30f7e3f83fe0dfd12e71cff 4498f0e0c1937ffe01fd06f973665830 9081237383d90e509aa00f00170e968f 3085a0e285430894940527032f8b26df 640fb0e74195791501fd1ed57b41487f a2a266d0498c3104214a47bd64ab0fc8"
  ["Handwriting"]="color-picker draft pencil"
  ["Person"]="context-menu"
)




# Don't edit it. These variables are responsible for the color output in the terminal.
D_GREEN="\e[92m"
D_RED="\e[31m"
D_CANCEL="\e[0m"
