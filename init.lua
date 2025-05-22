ModMagicNumbersFileAdd( "mods/penman/extra/magic_numbers.xml" )

function OnWorldPreUpdate()
	if( HasFlagPersistent( "one_shall_not_spawn" )) then
		RemoveFlagPersistent( "one_shall_not_spawn" )
	end
end

--mrshll update + CANCER pack (actually good meme songs) + balance the pahntom pack better
--update and test most based modpack
--rhytm addon for mrshll (get song bpms; two modes: buff, if any song is playing then every shot made on bit will deal extra damage, and challenge, where shooting without a song playing or not on beat deals damage to the player)
--add this https://github.com/TakWolf/fusion-pixel-font

--logo is prospero themed book

--jpading for buttons (can_jpad param)
--Store 4 closest widgets for the left, right, up, down to the currently focused one + store the widget closest to 0 to pick as focusable when the time comes, allow one to force focus through code
--Allow emulating focusing inputs (0 is nothing, 1 is right, 2 is up, 3 is lmb, 4 is select, -1 is left, -2 is down, -3 is rmb, -4 is unselect)
--make sure this has an inherent compatibility with multiplayer (4 players max)
--(dpad/left_stick/keyborad_arrows to switch between, x/keypad_0 to select (dragger should work), triangle/keypad_. for rmb)

-- pen.animate
-- pen.get_creature_dimensions
-- pen.FONT_MODS
-- pen.new_input
-- pen.new_plot
-- pen.pid
-- pen.rate_projectile
-- pen.rate_spell
-- pen.rate_wand
-- pen.rate_creature

--[TODO]
--investigate gui shaders
--periodically executed functions
--https://github.com/LuaLS/lua-language-server/wiki/Annotations
--check this https://github.com/Copious-Modding-Industries/Noitilities
--check how file caching works with loadfile, maybe one can edit one lua script at runtime
--add commented-out section to the end that contain self-sufficient widget funcs for settings menu
--horizontal slider
--basic window container func (Hermes styled by default)
--a system that converts images into a pixel table to be drawn in settings.lua or assembled in real time
--some kind of message system (check how MQTT works)
--notification system (gameprintimportant-like but unified and with more capabilities)
--add pen.animate debugging that plots/demos motion/scaling in self-aligning grid
--coroutine-based sequencer that accepts a table of events (use varstorage to preserve the state between restarts)
--raytrace_entities
--sule-based lua context independent gateway (and steal ModMagicNumbersFileAdd from init.lua via it)
--in-gui particle system
--extract hybrid gui from 19a and make it better
--dropdown with search capabilities (combine input with scroller)
--cached get_terrain via raymarched GetSurfaceNormal (https://youtu.be/BNZtUB7yhX4?t=92)
--tinker with GamePlaySound and GameEntityPlaySound (thanks to lamia)
--tinker with copi's spriteemitter image concept
--add sfxes (separate banks for prospero, hermes, trigger) + pics
--make heres ferrei be compatible with controller and upload it to steam
--testing environment that has full in-world function simulation and supports autotesting
--things.lua which has a baseline collection of props 19a-style + lists of every single vanilla thing
--https://link.springer.com/content/pdf/10.1023/A:1007670802811.pdf for AI? (an environemnt where the data is being collected by dev roleplaying as enemy; https://vk.com/away.php?to=https%3A%2F%2Fmachinelearningmastery.com%2Fa-tour-of-machine-learning-algorithms%2F&utf=1)
--actually test all the stuff

penman_d = penman_d or ModImageMakeEditable
penman_r = penman_r or ModTextFileGetContent
penman_w = penman_w or ModTextFileSetContent
function OnWorldPostUpdate()
	dofile_once( "mods/penman/_libman.lua" )
	
	pen.init_pipeline()
	if( not( pen.c.matter_test_file )) then
		pen.c.matter_test_file = true
		pen.magic_write( pen.FILE_MATTER, pen.get_xy_matter_file())
	end
	if( not( pen.c.matter_color_file )) then
		pen.c.matter_color_file = true
		pen.magic_write( pen.FILE_MATTER_COLOR, pen.FILE_XML_MATTER_COLOR )
	end

	dofile( "mods/penman/extra/check_em.lua" )
end