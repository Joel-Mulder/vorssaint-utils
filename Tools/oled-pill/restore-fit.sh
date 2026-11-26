#!/bin/zsh
# SPDX-License-Identifier: GPL-3.0-or-later
# The camera fit that lines the island up with the camera pill on a 14-inch
# OLED MacBook Pro (Mac17,13) at its default scaled resolution (1800 x 1182),
# tuned by eye with the alignment guides on 2026-11-26. Writes it to the
# official app and the Developer build; quit and reopen the app afterwards.
for domain in com.vorssaint.utils com.vorssaint.utils.dev; do
    defaults write "$domain" notchCameraFitWidth -float 15
    defaults write "$domain" notchCameraFitHeight -float -0.5
    defaults write "$domain" notchPillOffset -float 0.5
    defaults write "$domain" notchPillOffsetX -float 0
done
echo "Pill fit written: width +15, height -0.5, up/down +0.5, left/right 0."
