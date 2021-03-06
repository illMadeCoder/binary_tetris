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
   addr = 0x4300,
   width = 10,
   height = 20,
   x = 33,
   y = 4
}

-- Mutables
cur = {
   bin = 0x8888,
   anchor = {
      col = 0,
      row = 0
   }
}

-- hud variables
rows_cleared = 0
next_bin = 0

-- pieces
pieces = {
   i = 0x8888
}

-- utilities
function bin_pos_to_bool(_bin, _pos)
   return band(_bin, shl(1, _pos-1)) != 0
end

function bin_pos_to_1_or_0 (_bin, _pos)
   return bin_pos_to_bool(_bin, _pos) and 1 or 0
end

function set_bit_in_bin (_bin, _bit, _pos)
   --[[
      p q 
      0 0 0
      1 0 1
      0 1 0
      1 1 1

      p & ~q | p & q
   --]]
   local mask = rotl(_bit, _pos-1)

   if _bit == 1 then
      return bor(_bin, mask)
   else
      return band(_bin, mask)
   end
end

function apply_bin_w_index(_bin, _f, _len)
   for i = 1, _len or 16 do
      _f(bin_pos_to_1_or_0(_bin, i), i)
   end
end

function apply_piece_w_row_col(_piece, _f)
   for i = 1, _len or 16 do
      _f(bin_pos_to_1_or_0(_bin, i), flr(i / 4)+1, i % 4)
   end
end

function reduce_bin(_bin, _reducer, _len)
   assert(_len == nil or _len > 2)
   local l = bin_pos_to_1_or_0(_bin, 1)
   for i=2, _len or 16 do
      l = _reducer(l, bin_pos_to_1_or_0(_bin, i))
   end
   return l
end

-- debug
function printh_bin(_bin, _len)
   printh(reduce_bin(_bin,
		     function (l, r)
			return l .. r
		     end
		     , _len))
end

-- initialization
function init_well()
   for i = 0, c_well.height-1 do
      well_set(i, 0) -- well base
   end
end

-- well api
function well_set(_row, _bin)
   poke(c_well.addr+_row, _bin)
end

function well_get(_row)
   return peek(c_well.addr+_row)
end

-- draw
function draw_well()
   for row_num = 0, c_well.height-1 do
      apply_bin_w_index(well_get(row_num),
      		      function (_x, _i)
			 if _x == 1 then
			    col_num = _i-1
			    local s_x = c_well.x + col_num*c_cell_size
			    local s_y = c_well.y + row_num*c_cell_size
			    rectfill(s_x,
				     s_y,
				     s_x + c_cell_size,
				     s_y + c_cell_size,
				     14)
			 end

			 col_num = _i-1
			 local s_x = c_well.x + col_num*c_cell_size
			 local s_y = c_well.y + row_num*c_cell_size
			 rect(s_x,
			      s_y,
			      s_x + c_cell_size,
			      s_y + c_cell_size,
			      2)		 
		      end,
		      c_well.width
      )
   end  
end

function draw_score()
   print("rows", flr(c_well.x/2), c_well.y, 10)   
   print(rows_cleared, flr(c_well.x/2)+5, c_well.y+6, 10)
end

function draw_next_piece()
end

function draw_piece(_x, _y, _piece)

   apply_piece_w_row_col(_piece,
		       function (_bit, _row, _col)
			  if _bit == 1 then
			     printh("her")
			     rectfill(_x,
				      _y,
				      _x+c_cell_size,
				      _y+c_cell_size,
				      11)
			  end   
		       end
   )
end

function draw_cur()
   draw_piece(c_well.x+c_cell_size*cur.anchor.col,
	      c_well.y+c_cell_size*cur.anchor.row,
	      cur.bin)
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
--   draw_well()
   draw_cur()
   -- draw hud
--   draw_score()
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
   assert(reduce_bin(0xffff, function (l, r) return l + r end, 16) == 16)
   assert(reduce_bin(0xff, function (l, r) return l + r end, 8) == 8)
   local working_bin = 0
   for i = 1, 8 do 
      working_bin = bor(working_bin, set_bit_in_bin(working_bin, 1, i))
      assert(working_bin == rotl(1, i)-1, working_bin .. " is not " .. rotl(1, i)-1)
   end
   -- 0101
   printh("printing x with apply_bin_w_index")
   local x = 0x5
   printh_bin(x, 16)
   apply_bin_w_index(x,
		     function (x, i)
			printh("i: " .. i .. " x: " .. x)
			if i == 1 or i == 3 then
			   assert(x == 1, x)
			elseif i == 2 or i == 4 then
			   assert(x == 0, x)
			end
		     end,
		     8)

   
end

