-- at which intervals should the screen switch to the
-- next image?
local INTERVAL = 4

-- enough time to load next image
local SWITCH_DELAY = 1

-- transition time in seconds.
-- set it to 0 switching instantaneously
local SWITCH_TIME = 1.0

assert(SWITCH_TIME + SWITCH_DELAY < INTERVAL,
    "INTERVAL must be longer than SWITCH_DELAY + SWITCHTIME")

gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

local function alphanumsort(o)
    local function padnum(d) return ("%03d%s"):format(#d, d) end
    table.sort(o, function(a,b)
        return tostring(a.path):gsub("%d+",padnum) < tostring(b.path):gsub("%d+",padnum)
    end)
    return o
end

local pictures = util.generator(function()
    local files = {}
    for name, _ in pairs(CONTENTS) do
	if name:match(".*jpg") or name:match(".*JPG") or name:match(".*png") then
	    obj = { path=name,
		prepare = function(self)
		    self.image = resource.load_image(self.path)
		end,
		draw = function(self, alpha)
		    util.draw_correct(self.image, 0, 0, WIDTH, HEIGHT, alpha)
		end,
		dispose = function(self)
		    self.image:dispose()
		end,
		permit_next_graphic = function(self)
		    return true
		end
	    }
	    files[#files+1] = obj
	elseif name:match(".*mp4") then
	    obj = {
		path=name,
		hit_end=false,
		prepare=function(self)
		    print("video prepare()")
		    self.video = util.videoplayer(self.path, {loop=false})
		end,
		draw = function(self,alpha)
		    if self.video:next() then
			--print("video draw()")
			util.draw_correct(self.video, 0, 0, WIDTH, HEIGHT, alpha)
			fade_start = sys.now()
		    else
			util.draw_correct(self.video, 0, 0, WIDTH, HEIGHT, alpha)
			self.hit_end=true
		    end
		end,
		dispose = function(self)
		    print("video dispose()")
		    self.video:dispose()
		end,
		permit_next_graphic = function(self)
		    return self.hit_end
		end
	    }
	    files[#files+1] = obj
	end
    end
    return alphanumsort(files) -- sort files by filename
end)
node.event("content_remove", function(filename)
	       for i in 1,#files do
		   doomed=files[i]
	       end
	       if doomed then
		   files.remove(doomed)
	       end
end)

local current_image, fade_start

local function next_image()
    print("next_image()")
    if current_image then
	if not current_image:permit_next_graphic() then
	    print("never mind")
	    return
	end
    elseif last_image and not last_image:permit_next_graphic() then
	return
    end

    local next_obj = pictures.next()
    print("now loading " .. next_obj.path)
    last_image = current_image
    next_obj:prepare()
    current_image = next_obj
    fade_start = sys.now()
end

util.set_interval(INTERVAL, next_image)
next_image()

function node.render()
    gl.clear(0,0,0,1)
    local delta = sys.now() - fade_start - SWITCH_DELAY
    if last_image and delta < 0 then
	last_image:draw(1)
    elseif last_image and delta < SWITCH_TIME then
	local progress = delta / SWITCH_TIME
	last_image:draw(1-progress)
	current_image:draw(progress)
    else
	if last_image then
            last_image:dispose()
            last_image = nil
	end
	current_image:draw(1)
    end
end
