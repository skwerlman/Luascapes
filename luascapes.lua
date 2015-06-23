#!/usr/bin/env lua
--[[
  luascapes.lua
  V0.0.2

  tiny, pure-lua ANSI escape code lib

  (c) 2014-2015 David Birnhak
  Released under the MIT License

  c/l:
  v0.0.2:
    added luascapes.lscape
      using basic functions made for ugly code
    removed all asserts in favor of returning nil,err
  v0.0.1:
    initial release

]]

-- should be used with something that supports ANSI (unlike print/io.write)
-- i use os.execute('echo ...')

local luascapes = {}

local esc = '033' -- '033' or 'e', for sh or bash, respectively (lua seems to like sh over bash)

luascapes.codes = {
  --formatting
  ['reset']='0',
  ['bold']='1',
  ['dim']='2',
  ['underline']='4',
  ['blink']='5',
  ['invert']='7',
  ['hide']='8',
  ['unbold']='21',
  ['undim']='22',
  ['ununderline']='24',
  ['unblink']='25',
  ['uninvert']='27',
  ['unhide']='28',
  --colors
  ['fgdefault']='39',
  ['fgblack']='30',
  ['fgred']='31',
  ['fggreen']='32',
  ['fgyellow']='33',
  ['fgblue']='34',
  ['fgmagenta']='35',
  ['fgcyan']='36',
  ['fglightgray']='37',
  ['fgdarkgray']='90',
  ['fglightred']='91',
  ['fglightgreen']='92',
  ['fglightyellow']='93',
  ['fglightblue']='94',
  ['fglightmagenta']='95',
  ['fglightcyan']='96',
  ['fgwhite']='97',
  ['bgdefault']='49',
  ['bgblack']='40',
  ['bgred']='41',
  ['bggreen']='42',
  ['bgyellow']='43',
  ['bgblue']='44',
  ['bgmagenta']='45',
  ['bgcyan']='46',
  ['bglightgray']='47',
  ['bgdarkgray']='100',
  ['bglightred']='101',
  ['bglightgreen']='102',
  ['bglightyellow']='103',
  ['bglightblue']='104',
  ['bglightmagenta']='105',
  ['bglightcyan']='106',
  ['bgwhite']='107',
  --cursor movement
  ['term']={ 
    ['cup']='<N>A',
    ['cdown']='<N>B',
    ['cforward']='<N>C',
    ['cbackward']='<N>D',
    ['setpos']='<N>;<N>H',
    ['setpos2']='<N>;<N>f', -- not as widely supported
    ['clear']='2J',
    ['erase']='K',
    -- save, restore cursor pos
    -- only for xterm, nxterm
    ['save']='s',
    ['restore']='u'
  }
}

-- used for color/formatting codes
function luascapes.code(...) -- assembles multiple color/formatting codes into a single sequence
  local sequence = '\\'..esc..'['
  for i,v in ipairs({...}) do
    if type(v)~='string' then
      return nil, 'Bad argument #'..tostring(i)..': expected string, got '..type(v)
    end
    if not luascapes.codes[v] then
      return '', 'Invalid or unsupported ANSI escape code ('..v..')'
    end
    sequence = sequence..(i == 1 and '' or ';')..luascapes.codes[v]
  end
  return sequence..'m'
end

-- used for other codes
function luascapes.term(code, ...) -- can only return one code per sequence
  if type(code)~='string' then
    return nil, 'Bad argument #1: expected string, got '..type(code)
  end
  if not luascapes.codes.term[code] then 
    return '', 'Invalid or unsupported ANSI escape code ('..code..')'
  end
  local sequence = '\\'..esc..'['..luascapes.codes.term[code]
  for i,v in ipairs({...}) do
    if type(v)~='string' then
      return nil, 'Bad argument #'..tostring(i+1)..': expected string, got '..type(v)
    end
    sequence = sequence:gsub('<N>', v, 1)
  end
  return sequence
end

-- given a string and codes, returns a formatted string terminated by a reset code
function luascapes.lscape(string, ...) -- returns '' instead of nil on errors b/c error-checking mid-string is dumb
  if type(string)~='string' then
    return nil, 'Bad argument #1: expected string, got '..type(string)
  end
  local fcode, err1 = luascapes.code(...)
  if err1 then return fcode, err1 end
  local rcode, err2 = luascapes.code('reset')
  if err2 then return rcode, err2 end
  return fcode..string..rcode
end

--[[ testing code; makes sure parsers work right
for code, def in pairs(luascapes.codes) do
  if code~='term' then
    local o=luascapes.code(code)
    os.execute('/usr/bin/env echo -en "'..o..'"')
    print(o)
    os.execute('/usr/bin/env echo -en "'..luascapes.code('reset')..luascapes.term('erase')..'"')
    local p=luascapes.lscape(code, code)
    os.execute('/usr/bin/env echo -e "'..p..luascapes.term('erase')..'"')
  else
    for scode, def in pairs(def) do
      local o=luascapes.term(scode, '1', '1')
      os.execute('/usr/bin/env echo -en "'..o..'"')
      print(o)
      os.execute('/usr/bin/env echo -e "'..luascapes.code('reset')..luascapes.term('erase')..'"')
    end
  end
  for _=1,100000000 do
  end
end
--]]

return luascapes
