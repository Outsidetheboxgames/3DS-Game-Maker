# 3DS-Game-Maker
It makes GOOD games. (using DevkitPro and Godot game engine.)

# What it does:
It automates the process of making 3DS Citro2D sprite Initiate and Update code respectively from a custom class Sprite2D node.

# What it currently has:

Dedicated Citro2DSprite node class.

Multiple Spritesheet support.

Wav file support "borrowed" from CaptainSwag101. Converted to c by ME!

Global variables.

Local variables.

Global replacements like 'SELFOBJ' (Current node) and 'GROUPENABLE' (Current node's group) to replace text with the current objects name or variables.

C code variables to add your own functionality into a node.

Only 2D support. (I may add 3D soon.)

# How to use it?

Download and Install DevkitPro: https://devkitpro.org/wiki/Getting_Started

Download any Godot game engine build above 4.2: https://godotengine.org/download/windows/

Download this Repository and extract it somewhere safe. (The project will create a folder called '3DSProjects' in the root of the drive it is contained in. (C:/, D:/, E:/ or F:/ etc...) or the one that is specified in the 'drive letter' editbox while running the project before creating the folder using the 'Compile Game' button.)

After ''''Compiling the game'''' you are required (unless you don't want to make 3ds games) to open a cmd process (in the folder using the context menu or using 'cd' and the path to the created c project folder) with DevkitPro installed. Executing 'make' will compile the game with DevkitPro and Citro2D.

## Make sure to check out the wiki!!

https://github.com/Outsidetheboxgames/3DS-Game-Maker/wiki

# Credits:

ME - My neko wolf character named 'Experiment#13'.

Brett Driver - Voice of Arthur Ford screaming in agony.

CaptainSwag101 - Wav file decoding function.

Cheshyre (Composer of The Day Before from MADNESS Project Nexus: Classic) - https://www.newgrounds.com/audio/listen/477973

DigitalDesignDude - Current Updater/Maintainer of DS Game Maker. (Also where I got this idea to make this!)

https://digitaldesigndude.github.io/DSGM-Resource-Site/index.html

https://www.youtube.com/channel/UCVmba1o66nWG6p-82g22iyg
