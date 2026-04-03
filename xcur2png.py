#!/usr/bin/env python3
"""xcur2png.py - Extract PNGs and config from XCursor files.

Drop-in replacement for xcur2png, fixing the white-pixels-become-black bug
caused by an integer overflow in xcur2png's premultiplied alpha conversion.
See: https://github.com/eworm-de/xcur2png/issues/6
"""

import argparse
import os
import struct
import sys

from PIL import Image

XCURSOR_MAGIC = b'Xcur'
IMAGE_TYPE = 0xFFFD0002


def parse_xcursor(filepath):
    """Parse an XCursor file and return a list of image frame dicts."""
    with open(filepath, 'rb') as f:
        data = f.read()

    if len(data) < 16 or data[:4] != XCURSOR_MAGIC:
        print(f"Error: '{filepath}' is not a valid XCursor file.", file=sys.stderr)
        sys.exit(1)

    header_size, version, ntoc = struct.unpack_from('<III', data, 4)

    images = []
    for i in range(ntoc):
        toc_offset = header_size + i * 12
        ttype, subtype, position = struct.unpack_from('<III', data, toc_offset)

        if ttype != IMAGE_TYPE:
            continue

        chunk_header_size = struct.unpack_from('<I', data, position)[0]
        _, nominal_size, _, width, height, xhot, yhot, delay = struct.unpack_from(
            '<IIIIIIII', data, position + 4
        )

        pixel_offset = position + chunk_header_size
        pixel_size = width * height * 4

        if pixel_offset + pixel_size > len(data):
            print(f"Error: Truncated pixel data in chunk {i}.", file=sys.stderr)
            sys.exit(1)

        images.append({
            'nominal_size': nominal_size,
            'width': width,
            'height': height,
            'xhot': xhot,
            'yhot': yhot,
            'delay': delay,
            'pixels': data[pixel_offset:pixel_offset + pixel_size],
        })

    if not images:
        print(f"Error: No image chunks found in '{filepath}'.", file=sys.stderr)
        sys.exit(1)

    return images


def save_images_and_conf(images, basename, output_dir, quiet):
    """Save PNG files and write a .conf file compatible with xcur2png output."""
    conf_path = f"{basename}.conf"

    if not output_dir.endswith('/'):
        output_dir += '/'

    with open(conf_path, 'w') as conf:
        conf.write(f"#size\txhot\tyhot\tPath to PNG image\tdelay\n")

        for i, frame in enumerate(images):
            png_filename = f"{basename}_{i:03d}.png"
            png_full_path = os.path.join(output_dir, png_filename)
            png_conf_path = f"{output_dir}{png_filename}"

            # XCursor stores premultiplied ARGB as little-endian uint32,
            # which means bytes in memory are: B, G, R, A (premultiplied).
            # Pillow's 'RGBa' mode + 'BGRa' raw decoder handles this correctly.
            # .convert('RGBA') un-premultiplies without the overflow bug.
            img = Image.frombytes(
                'RGBa',
                (frame['width'], frame['height']),
                frame['pixels'],
                'raw', 'BGRa',
            )
            img = img.convert('RGBA')
            img.save(png_full_path)

            if not quiet:
                print(f"  {png_full_path}", file=sys.stderr)

            conf.write(
                f"{frame['nominal_size']}\t{frame['xhot']}\t{frame['yhot']}\t"
                f"{png_conf_path}\t{frame['delay']}\n"
            )


def main():
    parser = argparse.ArgumentParser(description='Extract PNGs from XCursor files')
    parser.add_argument('xcursor_file', help='Path to the XCursor file')
    parser.add_argument('-d', '--directory', default='.', help='Output directory for PNGs')
    parser.add_argument('-q', '--quiet', action='store_true', help='Suppress output')
    args = parser.parse_args()

    if not os.path.isfile(args.xcursor_file):
        print(f"Error: File '{args.xcursor_file}' not found.", file=sys.stderr)
        sys.exit(1)

    if not os.path.isdir(args.directory):
        print(f"Error: Directory '{args.directory}' does not exist.", file=sys.stderr)
        sys.exit(1)

    basename = os.path.basename(args.xcursor_file)
    images = parse_xcursor(args.xcursor_file)
    save_images_and_conf(images, basename, args.directory, args.quiet)


if __name__ == '__main__':
    main()
