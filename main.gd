extends Control


@export var top_screen_bg_color: Color = Color.BLACK
@export var bottom_screen_bg_color: Color = Color.WHITE
@export var project_name: String = "TEST"
@export_multiline var global_vars: String = ""
@export var global_sprite_sheets: Array[String] = [
	"romfs:/gfx/sprites.t3x"
]
@export var global_groups: Array[String] = [
	"Game"
]
@export var global_group_defaults: Array[bool] = [
	true
]
@export_multiline var extra_init_functions: String = ""
@onready var top_screen = $"3DS Top"
@onready var bottom_screen = $"3DS Bottom"
var temp_code: String = ""
enum vis_type {
	top_vis,
	bot_vis,
	both_vis = -1
}
var current_vis_type: int = vis_type.both_vis
@export var textures: Array[PackedStringArray] = []


# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/TextEdit.text = DirAccess.get_drive_name(DirAccess.open(ProjectSettings.globalize_path("res://")).get_current_drive()).replace(":", "")
	for sheet in DirAccess.get_directories_at("res://Projects/" + project_name + "/gfx"):
		global_sprite_sheets.append(sheet)
		var texturepacked: PackedStringArray = []
		for gfx in DirAccess.get_files_at("res://Projects/" + project_name + "/gfx/" + sheet):
			if gfx.ends_with("png"):
				texturepacked.append("res://Projects/" + project_name + "/gfx/" + sheet + "/" + gfx)
		textures.append(texturepacked)
	print(str(textures))
	var next_line = "
	
"	
	temp_code += "#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
	
#include <citro2d.h>
#include <3ds.h>
#include <assert.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <errno.h>
#include <stdarg.h>
#include <unistd.h>
#include <time.h>
#include <stdint.h>

#define MAX_SPRITES   768
#define SCREEN_WIDTH  400
#define SCREEN_HEIGHT 240

static C2D_Sprite sprites[MAX_SPRITES];
"
	temp_code += "

	
ndspWaveBuf waveBuf;
u8* data = NULL;

int playWav(char path[], int channel, bool toloop) {
	u32 sampleRate;
	u32 dataSize;
	u16 channels;
	u16 bitsPerSample;
  
	ndspSetOutputMode(NDSP_OUTPUT_STEREO);
	ndspSetOutputCount(2); // Num of buffers
  
	// Reading wav file
	FILE* fp = fopen(path, \"rb\");
  
	if(!fp)
	{
		printf(strcat(strcat(\"Could not open the \",  path), \" file.\"));
		return -1;
	}
  
	char signature[4];
  
	fread(signature, 1, 4, fp);
  
	if( signature[0] != 'R' &&
		signature[1] != 'I' &&
		signature[2] != 'F' &&
		signature[3] != 'F')
	{
		printf(\"Wrong file format.\");
		fclose(fp);
		return -1;
	}
  
	fseek(fp,0,SEEK_END);
	dataSize = ftell(fp);
	fseek(fp, 22, SEEK_SET);
	fread(&channels, 2, 1, fp);
	fseek(fp, 24, SEEK_SET);
	fread(&sampleRate, 4, 1, fp);
	fseek(fp, 34, SEEK_SET);
	fread(&bitsPerSample, 2, 1, fp);
  
	if (dataSize == 0 || (channels != 1 && channels != 2) || (bitsPerSample != 8 && bitsPerSample != 16))
	{
		printf(\"Corrupted wav file.\");
		fclose(fp);
		return -1;
	}
 
	// Allocating and reading samples
	data = (linearAlloc(dataSize));
	fseek(fp, 44, SEEK_SET);
	fread(data, 1, dataSize, fp);
	fclose(fp);
  
	fseek(fp, 44, SEEK_SET);
	fread(data, 1, dataSize, fp);
	fclose(fp);
	dataSize/=2;
	// Find the right format
	u16 ndspFormat;
  
	if(bitsPerSample == 8)
	{
		ndspFormat = (channels == 1) ?
			NDSP_FORMAT_MONO_PCM8 :
			NDSP_FORMAT_STEREO_PCM8;
	}
	else
	{
		ndspFormat = (channels == 1) ?
			NDSP_FORMAT_MONO_PCM16 :
			NDSP_FORMAT_STEREO_PCM16;
	}
  
	ndspChnReset(channel);
	ndspChnSetInterp(channel, NDSP_INTERP_NONE);
	ndspChnSetRate(channel, (float)sampleRate);
	ndspChnSetFormat(channel, ndspFormat);
  
	// Create and play a wav buffer
	memset(&waveBuf, 0, sizeof(waveBuf));
  
	waveBuf.data_vaddr = (data);
	waveBuf.nsamples = dataSize / (bitsPerSample >> 3);
	waveBuf.looping = toloop;
	waveBuf.status = NDSP_WBUF_FREE;
  
	DSP_FlushDataCache(data, dataSize);
  
	ndspChnWaveBufAdd(channel, &waveBuf);
  
	return ((dataSize / (bitsPerSample >> 3)) / sampleRate); // Return duration in seconds, for debugging purposes
  
}

// Function to calculate distance
float distance(int x1, int y1, int x2, int y2)
{
	// Calculating distance
	return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2) * 1.0);
}
	
" + global_vars
	temp_code += "

u32 kHeld;
u32 kDown;
touchPosition touch;

" + "

"
	var default = 0
	for group in global_groups:
		temp_code += "bool " + group + "GroupEnabled;
"
		default += 1

	for sheet in global_sprite_sheets:
		var sheets_to_add = "static C2D_SpriteSheet spriteSheet" + str(global_sprite_sheets.find(sheet, 0)) + ";"
		temp_code += next_line + sheets_to_add
	for node in get_tree().get_nodes_in_group("CitroSprite"):
		if node is Citro2DSprite:
			for config in node.configs:
				var xtra_vars = next_line + config.extra_variables_to_add.replace("SELFOBJ", node.name)
				temp_code += xtra_vars
			var vars_to_add = "static C2D_Sprite " + node.name + ";
bool " + node.name + "Enabled = " + str(node.enabled_by_default) + ";
"
			
			temp_code += next_line + vars_to_add
			temp_code += "bool " + node.name + "DrawingEnabled = " + "true" + ";
"
	for node in get_tree().get_nodes_in_group("CitroSprite"):
		if node is Citro2DSprite:
			var screen
			if node.screen == 0:
				screen = top_screen
			elif node.screen == 1:
				screen = bottom_screen
			temp_code += "

static void init" + node.name + "() {" 
			for sheet in global_sprite_sheets:
				if node.sheet_variable.ends_with(str(global_sprite_sheets.find(sheet))):
					temp_code += "
	C2D_SpriteFromSheet(" + "&" + node.name + ", " + node.sheet_variable +", " + str(textures[global_sprite_sheets.find(sheet)].find(node.texture.resource_path)) + ");"
			print(str(node.get_index()))
			if not node.get_parent() is Citro2DSprite:
				temp_code += "
	C2D_SpriteSetPos(" + "&" + node.name + ", " + str(node.position.x - screen.position.x) + ", " + str(node.position.y - screen.position.y) + ");"
			temp_code += "
	C2D_SpriteSetCenterRaw(" + "&" + node.name + ", " + str(-node.offset.x) + ", " + str(-node.offset.y) + ");"		

			temp_code += "
	C2D_SpriteSetDepth(" + "&" + node.name + ", " + str(float(node.z_index) / 10) + "f);"
			if node.scale != Vector2.ONE:
				temp_code += "
	C2D_SpriteScale(&" + node.name + ", " + str(node.scale.x * 0.99) + "f, " + str(node.scale.y * 0.99) + "f);"
			temp_code += "
}

"
			var isIt
			for config in node.configs:
				isIt = config.extra_code_to_add_to_update != "" or config.extra_code_to_add_to_global_update != ""
			
			if isIt:
				var to_add_2 = "static void update" + node.name + "() {" 
				temp_code += to_add_2
				for config in node.configs:
					if config.extra_code_to_add_to_update != "" or config.extra_code_to_add_to_global_update != "":
						temp_code += "
" + config.extra_code_to_add_to_update.replace("SELFOBJ", node.name).replace("GROUPENABLE", node.group + "GroupEnabled").indent("		")
						temp_code += "
" 

					if node.get_parent().is_in_group("CitroSprite"):
						temp_code += "
		C2D_SpriteSetPos(" + "&" + node.name + ", " + str(node.get_parent().name) + ".params.pos.x + " + str(node.position.x) + ", " + str(node.get_parent().name) + ".params.pos.y + " + str(node.position.y) + ");"

			if isIt:
				temp_code += "
}				
"
	var to_ad = "int main(int argc, char* argv[]) {
	romfsInit();
	ndspInit();	
	gfxInitDefault();
	C3D_Init(C3D_DEFAULT_CMDBUF_SIZE);
	C2D_Init(C2D_DEFAULT_MAX_OBJECTS);
	C2D_Prepare();

	C3D_RenderTarget* top = C2D_CreateScreenTarget(GFX_TOP, GFX_LEFT);
	C3D_RenderTarget* bot = C2D_CreateScreenTarget(GFX_BOTTOM, GFX_LEFT);
	"
	temp_code += next_line + to_ad
	var default2 = 0
	for group in global_groups:
		temp_code += "
	" + group + "GroupEnabled = " + str(global_group_defaults[default2]) + ";
"
		default2 += 1
		
	temp_code += "
"
	for sheet in global_sprite_sheets:
		var addd = "
	spriteSheet" + str(global_sprite_sheets.find(sheet, 0)) + " = C2D_SpriteSheetLoad(\"romfs:/gfx/" + sheet + ".t3x\"" + ");" + "
	if (!spriteSheet" + str(global_sprite_sheets.find(sheet, 0)) + ") svcBreak(USERBREAK_PANIC);
	"
		temp_code += next_line + addd
	for node in get_tree().get_nodes_in_group("CitroSprite"):
		if node is Citro2DSprite:
			var to_a = "
	init" + node.name + "();
"
			temp_code += to_a
	
	temp_code += "
" + extra_init_functions.indent("	") + "
"
	
	var to = "
	// Main loop
	while (aptMainLoop())
	{
		hidTouchRead(&touch);
		hidScanInput();
		kHeld = hidKeysHeld();
		kDown = hidKeysDown();"
	
	temp_code += next_line + to
	
	for node in get_tree().get_nodes_in_group("CitroSprite"):
		if node is Citro2DSprite:
			for config in node.configs:
				if config.extra_code_to_add_to_global_update != "":
					temp_code += "
" + config.extra_code_to_add_to_global_update.replace("SELFOBJ", node.name).replace("GROUPENABLE", node.group + "GroupEnabled").indent("		")
			var yestext
			for config in node.configs:

				if config.extra_code_to_add_to_update != "":
					yestext = "
			update" + node.name + "();"
			
			if yestext:
				temp_code += "
		if (" + node.name + "Enabled)
		{" + yestext
			if yestext:
				temp_code += "
		}"
	temp_code += "
	
		// Render the scene
		C3D_FrameBegin(C3D_FRAME_SYNCDRAW);
		C2D_TargetClear(top, C2D_Color32(" + str(int(top_screen_bg_color.r * 255)) + ", " + str(int(top_screen_bg_color.g * 255)) + ", " + str(int(top_screen_bg_color.b * 255)) + ", 1));
		C2D_SceneBegin(top);"
	for node in get_tree().get_nodes_in_group("CitroSprite"):
		if node is Citro2DSprite:
			if node.screen == 0:
				temp_code += "
		if (" + node.name + "Enabled && " + node.name + "DrawingEnabled)
		{
			C2D_DrawSprite(" + "&" + node.name + ");
		}"
	
	temp_code += "
		C2D_TargetClear(bot, C2D_Color32(" + str(int(bottom_screen_bg_color.linear_to_srgb().r)) + ", " + str(int(bottom_screen_bg_color.linear_to_srgb().g)) + ", " + str(int(bottom_screen_bg_color.linear_to_srgb().b)) + ", 1));
		C2D_SceneBegin(bot);"
	for node in get_tree().get_nodes_in_group("CitroSprite"):
		if node is Citro2DSprite:
			if node.screen == 1:
				temp_code += "
		if (" + node.name + "Enabled && " + node.name + "DrawingEnabled)
		{
			C2D_DrawSprite(" + "&" + node.name + ");
		}"
	temp_code += "
	
		C3D_FrameEnd(0);
	}

	// Cleanup audio things and de-init platform features
	ndspExit();
	
	// Deinit libs
	C2D_Fini();
	C3D_Fini();
	gfxExit();
	romfsExit();
	return 0;
}
"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Code.text = temp_code


func _on_export_c_pressed():
	var path = ProjectSettings.globalize_path("res://")
	if not DirAccess.dir_exists_absolute($HBoxContainer/TextEdit.text + ":/3DSProjects"):
		DirAccess.make_dir_absolute($HBoxContainer/TextEdit.text + ":/3DSProjects")
	if DirAccess.dir_exists_absolute($HBoxContainer/TextEdit.text + ":/3DSProjects"):
		if not DirAccess.dir_exists_absolute($HBoxContainer/TextEdit.text + ":/3DSProjects/" + project_name):
			DirAccess.make_dir_absolute($HBoxContainer/TextEdit.text + ":/3DSProjects/" + project_name)
	if DirAccess.dir_exists_absolute($HBoxContainer/TextEdit.text + ":/3DSProjects/" + project_name):
		if not DirAccess.dir_exists_absolute($HBoxContainer/TextEdit.text + ":/3DSProjects/" + project_name + "/gfx"):
			DirAccess.make_dir_absolute($HBoxContainer/TextEdit.text + ":/3DSProjects/" + project_name + "/gfx")
		if not DirAccess.dir_exists_absolute($HBoxContainer/TextEdit.text + ":/3DSProjects/" + project_name + "/romfs"):
			DirAccess.make_dir_absolute($HBoxContainer/TextEdit.text + ":/3DSProjects/" + project_name + "/romfs")
		if not DirAccess.dir_exists_absolute($HBoxContainer/TextEdit.text + ":/3DSProjects/" + project_name + "/romfs/snd"):
			DirAccess.make_dir_absolute($HBoxContainer/TextEdit.text + ":/3DSProjects/" + project_name + "/romfs/snd")
		for snd in DirAccess.get_files_at(path + "Projects/" + project_name + "/snd"):
			if snd.ends_with("wav"):
				print(snd)
				var dir = DirAccess.open(path + "Projects/")
				dir.copy(path + "Projects/" + project_name + "/snd/" + snd, $HBoxContainer/TextEdit.text + ":/3DSProjects/" + project_name + "/romfs/snd/" + snd)
				print(str(path + "Projects/" + project_name + "/snd"))
				print(str(path))
				
		if $CName.text != "":
			if DirAccess.dir_exists_absolute($HBoxContainer/TextEdit.text + ":/3DSProjects/" + project_name):
				if not DirAccess.dir_exists_absolute($HBoxContainer/TextEdit.text + ":/3DSProjects/" + project_name + "/source"):
					DirAccess.make_dir_absolute($HBoxContainer/TextEdit.text + ":/3DSProjects/" + project_name + "/source")
			var file = FileAccess.open($HBoxContainer/TextEdit.text + ":/3DSProjects/" + project_name + "/source/" + $CName.text + ".c", FileAccess.WRITE)
			file.store_string(temp_code)
			var addddds: Array[String] = []
			for sheet in global_sprite_sheets:
				addddds.append("--atlas -f rgba8888 -z auto
")
				for gfx in DirAccess.get_files_at("res://Projects/" + project_name + "/gfx/" + sheet):
					var png = load("res://Projects/" + project_name + "/gfx/" + sheet + "/" + gfx)
					if png is Texture2D:
						var img: Image = png.get_image()
						var nameofimg = png.resource_path.replace("res://Projects/" + project_name + "/gfx/" + sheet + "/", "")
						img.save_png($HBoxContainer/TextEdit.text + ":/3DSProjects/" + project_name + "/gfx/" + nameofimg)
						addddds[global_sprite_sheets.find(sheet, 0)] += nameofimg + "
"				
				for icon in DirAccess.get_files_at("res://Projects/" + project_name):
					if icon.begins_with("icon"):
						var png = load("res://Projects/" + project_name + "/" + icon)
						if png is Texture2D:
							var img: Image = png.get_image()
							var nameofimg = png.resource_path.replace("res://Projects/" + project_name + "/", "")
							img.save_png($HBoxContainer/TextEdit.text + ":/3DSProjects/" + project_name + "/" + nameofimg)
							
				var t3s = FileAccess.open($HBoxContainer/TextEdit.text + ":/3DSProjects/" + project_name + "/gfx/" + sheet + ".t3s", FileAccess.WRITE)			
				t3s.store_string(addddds[global_sprite_sheets.find(sheet, 0)])
			var makefile = FileAccess.open($HBoxContainer/TextEdit.text + ":/3DSProjects/" + project_name + "/Makefile", FileAccess.WRITE)
			var temp_mf = FileAccess.open("res://Projects/" + project_name + "/Makefile", FileAccess.READ)
			makefile.store_string(temp_mf.get_as_text())
			OS.shell_open($HBoxContainer/TextEdit.text + ":/3DSProjects/" + project_name)
			
func _on_togge_screen_pressed():
	current_vis_type += 1
	if current_vis_type >= 2:
		current_vis_type = vis_type.both_vis
	if current_vis_type == vis_type.top_vis:
		for node in get_tree().get_nodes_in_group("CitroSprite"):
			if node is Citro2DSprite:
				if node.screen == 0:
					node.visible = true
				elif node.screen == 1:
					node.visible = false
		top_screen.visible = true
		bottom_screen.visible = false
	elif current_vis_type == vis_type.bot_vis:
		for node in get_tree().get_nodes_in_group("CitroSprite"):
			if node is Citro2DSprite:
				if node.screen == 0:
					node.visible = false
				elif node.screen == 1:
					node.visible = true
		top_screen.visible = false
		bottom_screen.visible = true
	elif current_vis_type == vis_type.both_vis:
		for node in get_tree().get_nodes_in_group("CitroSprite"):
			if node is Citro2DSprite:
				node.visible = true
		top_screen.visible = true
		bottom_screen.visible = true		
