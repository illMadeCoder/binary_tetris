pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

--[[ 
tetris written in such a way that each major operation are
primarly computed through the binary ops.
--]]

-- Globals

-- Constants
c_cell_size = 6

c_well = {
   addr = 0,
   width = 10,
   height = 20,
   x = 33,
   y = 4
}

-- Mutables
cur = {
   bin = 0,
   x = 0,
   y = 0
}

-- hud variables
rows_cleared = 0
next_bin = 0

-- utilities
function bin_pos_to_bool(_bin, _pos)
   return band(_bin, shl(1, _pos-1)) != 0
end

function bin_pos_to_1_or_0 (_bin, _pos)
   return bin_pos_to_bool(_bin, _pos) and 1 or 0
end

-- debug
function printh_bin(_bin, _len)
   local p_str = ""
   for i=1, _len or 16 do
      p_str = p_str .. bin_pos_to_1_or_0(_bin, i)
   end
   printh(p_str)
end

-- initialization
function init_well()
   for i = 0, c_well.height-1 do
      poke(c_well.addr+i, 0) -- well base
   end
end


-- draw
function draw_well()
   for row_num = 0, c_well.height-1 do
      for col_num = 0, c_well.width-1 do
	 local s_x = c_well.x + col_num*c_cell_size
	 local s_y = c_well.y + row_num*c_cell_size
	 rect(s_x,
	      s_y,
	      s_x + c_cell_size,
	      s_y + c_cell_size,
	      2)
      end
   end
end

function draw_score()
   print("rows", flr(c_well.x/2), c_well.y, 10)   
   print(rows_cleared, flr(c_well.x/2)+5, c_well.y+6, 10)
end

function draw_next_piece()
end

-- Game Hooks
function _init()
   init_well()
   tests()
end

function _update()
end

function _draw()
   cls()
   -- draw current
   -- draw well
   draw_well()
   -- draw hud
   draw_score()
   -- draw background
end

function tests()
   assert(bin_pos_to_bool(1,1))
   assert(bin_pos_to_bool(2,2))
   assert(not bin_pos_to_bool(2,1))
   assert(bin_pos_to_bool(8,4))
   printh("testing printh_bin(0xf010, 16)")
   printh_bin(0xf010, 16)
   printh("as you can see this is little endian")
end

