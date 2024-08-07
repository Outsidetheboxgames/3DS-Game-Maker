# 3DS-Game-Maker
It makes GOOD games. (using DevkitPro and Godot game engine.)

# What it does:
It automates the process of making 3DS Citro2D sprite Initiate an Update code from custom class Sprite2D nodes.

# What it currently has:

Dedicated Citro2DSprite node class.

Multiple Spritesheet support.

Wav file support "borrowed" from CaptainSwag101. Converted to c by ME!

Global variables.

Local variables.

Global replacements like 'SELFOBJ' (Current node) and 'GROUPENABLE' (Current node's group) to replace text with the current objects name or variables.

C code variables to add your own functionality into a node.

# How to use it?

Download and Install DevkitPro: https://devkitpro.org/wiki/Getting_Started
Download Godot game engine 4.0 SPECIFICLY: https://godotengine.org/download/windows/

Download this Repository and extract it somewhere safe. (The project will create a folder called '3DSProjects' in the root of the drive it is contained in. (C:/, D:/, E:/ or F:/ etc...) or the one that is specified in the 'drive letter' editbox while running the project before creating the folder using the 'Compile Game' button.)

After ''''Compiling the game'''' you are required (unless you don't want to make 3ds games) to open a cmd process (in the folder using the context menu or using 'cd' and the path to the created c project folder) with DevkitPro installed. Executing 'make' will compile the game with DevkitPro and Citro2D.

# Credits:

ME - My neko wolf character named 'Experiment#13'.

Brett Diver - Voice of Arthur Ford screaming in agony.

CaptainSwag101 - Wav file decoding function.

Cheshyre (Composer of The Day Before from MADNESS Project Nexus: Classic) - https://www.newgrounds.com/audio/listen/477973
