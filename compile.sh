#!/bin/bash
shc -f start.sh
shc -f taperobot.sh
shc -f console.sh

cp start.sh.x ../start
cp taperobot.sh.x ../taperobot
cp console.sh.x ../console

chmod +x ../start
chmod +x ../taperobot
chmod +x ../console
