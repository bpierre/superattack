-- foes format:
--   * sprite index
--   * width (multiple of 8)
--   * name
--   * banner color
-- }
foes={
  {1,4,'owlman',3},
  {5,4,'diabol',4},
  {9,7,'emils',2},
  {64,5,'snek',12},
  {69,4,'globulo',1}
}

-- state vars
p1_press_start=-1
p1_press_stop=-1
p2_press_start=-1
p2_press_stop=-1
p1_foe=1

banner_height=40
turn=1
round_start=-1

function _update60()
  if btnp(0) then
    update_foe(-1)
  end
  if btnp(1) then
    update_foe(1)
  end
  p1_btn(btn(4))
  p2_btn(btn(5))
end

function p1_btn(pressed)
  if pressed then
    if p1_press_start == -1 then
      p1_press_stop=-1
      p1_press_start=t()
    end
  else
    if p1_press_start != -1 then
      p1_press_start=-1
      p1_press_stop=t()
    end
  end
end

function p2_btn(pressed)
  if pressed then
    if p2_press_start == -1 then
      p2_press_stop=-1
      p2_press_start=t()
    end
  else
    if p2_press_start != -1 then
      p2_press_start=-1
      p2_press_stop=t()
    end
  end
end

function restart_round()
  round_start=t()
end

function update_foe(incr)
  local incr_foe = p1_foe + incr
  if incr_foe > 0 and incr_foe <= #foes then
    p1_foe = incr_foe
  end
end

function draw_split(progress, from_right)
  local split_width = 20
  local split_x = -split_width + (127/2 + split_width/2) * progress
  if from_right then
    rectfill(0, 0, split_x, 127, 2)
    for i=0,127 do
      line(
        split_x,
        i,
        (127/2 + split_width/2) * progress,
        0,
        2
      )
    end
  else
    split_x = 127 - split_x
    rectfill(split_x, 0, 127, 127, 4)
    for i=0,127 do
      line(
        split_x,
        127 - i,
        127 - (127/2 + split_width/2) * progress,
        127,
        4
      )
    end
  end
end

function _draw()
  cls()
  local t=t()
  rectfill(0,0,127,127,1)

  local progress_linear=min((t-p1_press_start)*2, 1)
  local progress=ease_out(progress_linear)

  draw_player_foe(p1_press_start, p1_press_stop, p1_foe, true)
  draw_player_foe(p2_press_start, p2_press_stop, p1_foe, false)

  local round_elapsed = flr((t - round_start) / 2)
end

function draw_player_foe(press_start, press_stop, foe, from_right)
  local t=t()
  local progress=0

  if press_start > -1 then
    local progress_linear=max(0, min(1, (t-press_start)*2))
    progress=ease_out(progress_linear)
  end

  if press_stop > -1 then
    local progress_linear=max(1 - ((t-press_stop)*2), 0)
    progress=ease_in(progress_linear)
  end

  draw_split(progress, from_right)

  local w = foe_width(foe)
  local x = 127 - (w + 10) * progress
  local y = 128 - 32

  if from_right then
    x = -w + (w + 10) * progress
    y = 2
  end


  if progress > 0 then
    draw_foe(foe, x, y)
  end

  -- draw_foe_frame(foe, 127/2 - w/2 + 1, 43)

end

function ease_in(t)
  return t * t * t * t * t
end

function ease_out(t)
  t = t - 1
  return 1 + t * t * t * t * t
end

-- the width of a foe in px
function foe_width(foe)
  return 8 * foes[foe][2]
end

function foe_height(foe)
  return 8 * 4
end

function draw_banner(x, bottom, progress, col)
  local height = 27
  if (bottom) then
    local y = 127 - height * progress
    rectfill(0, y, 127, y+3, 5)
    rectfill(0, y+3, 127, y+10, 6)
    rectfill(0, y+10, 127, y+height, col)
  else
    local y = - height + height * progress
    rectfill(0, y, 127, y+height-10, col)
    rectfill(0, y+height-10, 127, y+height-3, 6)
    rectfill(0, y+height-3, 127, y+height, 5)
  end
end

function draw_foe(foe, x, y)
  local w = foe_width(foe)
  local h = foe_height(foe)
  spr(foes[foe][1], x, y, w / 8, h / 8)
end

function draw_foe_frame(foe, x, y)
  local w = foe_width(foe)
  local h = foe_height(foe)
  local padding = 2
  rectfill(x - padding * 2, y, x + w - 1, y + h - 1 + padding * 2, 0)
  rect(x - padding * 2, y, x + w - 1, y + h - 1 + padding * 2, 7)
  draw_foe(foe, x - padding, y + padding)
  rectfill(x - padding * 2, y + h + padding * 2, x + w - 1, y + h + 6 + padding * 2, 0)
  print(foes[foe][3], x + 1 - padding * 2, y + h + 1 + padding * 2, 7)
end
