print([[
--[[
 _______  _______  _______  _______  _        _______  ______   _       _________       
(  ____ )(  ____ )(  __   )(  ____ \( \      (  ___  )(  __  \ | \    /\\__   __/       
| (    )|| (    )|| (  )  || (    \/| (      | (   ) || (  \  )|  \  / /   ) (          
| (____)|| (____)|| | /   || |      | |      | (___) || |   ) ||  (_/ /    | |          
|  _____)|     __)| (/ /) || |      | |      |  ___  || |   | ||   _ (     | |          
| (      | (\ (   |   / | || |      | |      | (   ) || |   ) ||  ( \ \    | |          
| )      | ) \ \__|  (__) || (____/\| (____/\| )   ( || (__/  )|  /  \ \___) (___       
|/       |/   \__/(_______)(_______/(_______/|/     \|(______/ |_/    \/\_______/       
                                                                                        
 ______              _______  _______  __    _______ ______   _        ______   _______ 
(  ___ \ |\     /|  (  ____ \(  ____ )/  \  (  ____ Y ___  \ ( (    /|(  __  \ (  __   )
| (   ) )( \   / )  | (    \/| (    )|\/) ) | (    \|/   \  \|  \  ( || (  \  )| (  )  |
| (__/ /  \ (_) /   | |      | (____)|  | | | |        ___) /|   \ | || |   ) || | /   |
|  __ (    \   /    | | ____ |     __)  | | | |       (___ ( | (\ \) || |   | || (/ /) |
| (  \ \    ) (     | | \_  )| (\ (     | | | |           ) \| | \   || |   ) ||   / | |
| )___) )   | |     | (___) || ) \ \____) (_| (____/Y\___/  /| )  \  || (__/  )|  (__) |
|/ \___/    \_/     (_______)|/   \__/\____/(_______|______/ |/    )_)(______/ (_______)
                                                                                        
--]])                                                                         



-- Initalization
local user do
    user = {} do
        user.name = _USER_NAME or "Pr0kladkochki_user"
        user.role = "Pid0r1s"
        user.last_update = "interesting question"
        user.debug = false

        if not LPH_OBFUSCATED then
            LPH_ENCSTR = function (...) return ... end
            LPH_NO_VIRTUALIZE = function (...) return ... end
            LPH_CRASH = function (...) print('Triggered self-descruction and crash of VM') end
        end
    end
end

LPH_NO_VIRTUALIZE(function ()
    local ffi = require 'ffi';
    do
        local dependencies = {
            ['csgo_weapons'] = {
                name = 'gamesense/csgo_weapons',
                type = 'workshop',
                link = 'https://gamesense.pub/forums/viewtopic.php?id=18807'
            },
            ['base64'] = {
                name = 'gamesense/base64',
                type = 'workshop',
                link = 'https://gamesense.pub/forums/viewtopic.php?id=21619'
            },
            ['clipboard'] = {
                name = 'gamesense/clipboard',
                type = 'workshop',
                link = 'https://gamesense.pub/forums/viewtopic.php?id=28678'
            },
            ['surface'] = {
                name = 'gamesense/surface',
                type = 'workshop',
                link = 'https://gamesense.pub/forums/viewtopic.php?id=18793'
            }
        }

        if user.debug then
            dependencies['inspect'] = {
                name = 'gamesense/inspect',
                type = 'workshop',
                link = ''
            }
        end

        local located = true

        for gname, method in pairs(dependencies) do
            local success = pcall(require, method.name)

            if not success then
                if method.type == 'workshop' then
                    client.error_log(string.format('[-] Unable to locate %s library. You need to subscribe to it here %s', gname, method.link))
                elseif method.type == 'local' then
                    client.error_log(string.format('[-] Unable to locate %s library. You need to download it and put in gamesense folder. Link is %s', gname, method.link))
                end

                located = false
            end
        end

        if not located then
            return error('[~] Script was unable to start. You can investigate error above.')
        end
    end

    local vector = require 'vector'
    local csgo_weapons = require 'gamesense/csgo_weapons'
    local base64 = require 'gamesense/base64'
    local clipboard = require 'gamesense/clipboard'
    local surface = require 'gamesense/surface'
    local inspect do
        if user.debug then
            inspect = require 'gamesense/inspect'
        end
    end

    local c_math, c_logger, c_table, c_string, c_animations, c_tweening, c_grams do
        c_math = {} do
            c_math.min = (function (a, b)
                return a > b and b or a
            end)

            c_math.max = (function (a, b)
                return a > b and a or b
            end)

            c_math.abs = (function (a)
                return a > 0 and a or -a
            end)

            c_math.round = (function (a)
                return math.floor(a+0.5)
            end)

            c_math.normalize_yaw = (function (a)
                while a > 180 do
                    a = a - 360
                end

                while a < -180 do
                    a = a + 360
                end

                return a
            end)

            c_math.clamp = (function (v, min, max)
                if v > max then
                    return max
                end

                if v < min then
                    return min
                end

                return v
            end)

            c_math.random = (function (min, max)
                return client.random_int(min, max)
            end)

            c_math.randomf = (function (min, max)
                return min + (max-min)*math.random()
            end)

            c_math.lerp = (function (a, b, v)
                local delta = (b - a)

                if c_math.abs(delta) <= 0.095 then
                    return b
                end

                return a + delta*v
            end)

            c_math.extrapolate = (function (ent, origin, ticks)
                local tickinterval = globals.tickinterval()

                local sv_gravity = cvar.sv_gravity:get_float() * tickinterval
                local sv_jump_impulse = cvar.sv_jump_impulse:get_float() * tickinterval

                local p_origin, prev_origin = origin, origin

                local velocity = vector(entity.get_prop(ent, 'm_vecVelocity'))
                local gravity = velocity.z > 0 and -sv_gravity or sv_jump_impulse

                for i=1, ticks do
                    prev_origin = p_origin
                    p_origin = vector(
                        p_origin.x + (velocity.x * tickinterval),
                        p_origin.y + (velocity.y * tickinterval),
                        p_origin.z + (velocity.z+gravity) * tickinterval
                    )

                    local fraction = client.trace_line(-1,
                        prev_origin.x, prev_origin.y, prev_origin.z,
                        p_origin.x, p_origin.y, p_origin.z
                    )

                    if fraction <= 0.99 then
                        return prev_origin
                    end
                end

                return p_origin
            end)
        end

        c_logger = {} do
            c_logger.log = (function (format, ...)
                client.color_log(108, 181, 119, '[PR0KLADKI] \1\0')
                client.color_log(61, 212, 197, ('[%02d:%02d:%02d] \1\0'):format(client.system_time()))
                client.color_log(255, 255, 255, format:format(...))
            end)

            c_logger.log_error = (function (format, ...)
                client.color_log(108, 181, 119, '[PR0KLADKI] \1\0')
                client.color_log(61, 212, 197, ('[%02d:%02d:%02d] \1\0'):format(client.system_time()))
                client.color_log(255, 0, 255, format:format(...))
            end)

            c_logger.log_error_fatal = (function (format, ...)
                client.color_log(108, 181, 119, '[PR0KLADKI] \1\0')
                client.color_log(61, 212, 197, ('[%02d:%02d:%02d] \1\0'):format(client.system_time()))
                client.color_log(255, 0, 50, format:format(...))

                return error('Execution aborted due to fatal exception!')
            end)
        end

        c_table = {} do
            c_table.unpack_keywise = (function (keys, ...)
                local new_table = {}

                for i=1, #keys do
                    new_table[keys[i]] = ({...})[i]
                end

                return new_table
            end)

            c_table.combine_arrays = (function (...)
                local new_table = {}

                local arrays = {...}
                local cnt = 1

                for i=1, #arrays do
                    for _, value in pairs(arrays[i]) do
                        new_table[cnt] = value
                        cnt = cnt + 1
                    end
                end

                return new_table
            end)

            c_table.is_hotkey_active = (function (element)
                return ui.get(element[1]) and ui.get(element[2])
            end)

            c_table.contains = (function (tbl, value)
                local tbl_len = #tbl

                for i=1, tbl_len do
                    if tbl[i] == value then
                        return true
                    end
                end

                return false
            end)

            c_table.object_contains = (function (tbl, value)
                for key, tvalue in pairs(tbl) do
                    if tvalue == value then
                        return true
                    end
                end

                return false
            end)

            c_table.closest = (function (v, targets)
                local best, diff = targets[1], math.huge

                for i=1, #targets do
                    local tbl_val = targets[i]
                    local cur_diff = c_math.abs(tbl_val-v)

                    if cur_diff < diff then
                        best = tbl_val
                        diff = cur_diff
                    end
                end

                return best
            end)

            c_table.keys = (function (table)
                local keys = {}

                for key in next, table, nil do
                    keys[#keys+1] = key
                end

                return keys
            end)

            c_table.equals = (function (tbl1, tbl2)
                for k, v in pairs(tbl1) do
                    if v ~= tbl2[k] then
                        return false
                    end
                end

                for k, v in pairs(tbl2) do
                    if v ~= tbl1[k] then
                        return false
                    end
                end

                return true
            end)
        end

        c_string = {} do
            c_string.trim = (function (str)
                while str:sub(1, 1) == ' ' do
                    str = str:sub(2)
                end

                while str:sub(#str, #str) == ' ' do
                    str = str:sub(1, #str-1)
                end

                if #str == 0 or str == '' then
                    str = 'Unnamed'
                end

                return str
            end)

            c_string.split = (function (str, sep)
                local result = {}
                local start = str:find(sep)

                if not start then
                    return {str}
                end

                local pos = 1

                while start do
                    result[#result+1] = str:sub(pos, start)

                    pos = start+sep:len()

                    start = str:find(sep, pos)

                    if not start then
                        result[#result+1] = str:sub(pos)
                    end
                end

                return result
            end)
        end

        c_animations = {} do
            c_animations.data = {}

            function c_animations:new(key, increasing, speed, modifier, initial_value)
                self.data[key] = self.data[key] or {
                    method = 'lerp',
                    increasing = increasing,
                    speed = speed or 4,
                    modifier = modifier or 0,
                    value = initial_value or 0
                }

                return self.data[key]
            end

            function c_animations:sway(key, from, to, speed, iterations, initial_value)
                self.data[key] = self.data[key] or {
                    active = 0,
                    method = 'sway',
                    increasing = false,
                    start = c_math.min(from, to),
                    target = c_math.max(from, to),
                    speed = speed or 4,
                    iterations = iterations or 1,
                    value = initial_value or from
                }

                local this = self.data[key]

                this.start, this.target = c_math.min(from, to), c_math.max(from, to)
                this.speed, this.iterations = speed, iterations

                return this
            end

            function c_animations:spin(key, from, to, speed, iterations, initial_value)
                self.data[key] = self.data[key] or {
                    active = 0,
                    method = 'spin',
                    start = c_math.min(from, to),
                    target = c_math.max(from, to),
                    speed = speed or 4,
                    iterations = iterations or 1,
                    value = initial_value or from
                }

                local this = self.data[key]

                this.start, this.target = c_math.min(from, to), c_math.max(from, to)
                this.speed, this.iterations = speed, iterations

                return this
            end

            function c_animations:flick(key, from, to, speed, initial_value)
                self.data[key] = self.data[key] or {
                    active = 0,
                    method = 'flick',
                    start = c_math.min(from, to),
                    target = c_math.max(from, to),
                    speed = speed or 4,
                    value = initial_value or from
                }

                local this = self.data[key]

                this.start, this.target = c_math.min(from, to), c_math.max(from, to)
                this.speed = speed

                return this
            end

            function c_animations:frame()
                local frametime = globals.frametime()

                for key, state in pairs(self.data) do
                    if state.method == 'lerp' then
                        state.value = c_math.clamp(state.value + (state.increasing and 1 or -1) * state.speed * frametime, 0, 1)
                    end
                end
            end

            function c_animations:tick(tick)
                for key, state in pairs(self.data) do
                    if state.method == 'sway' then
                        local difference = tick - state.active

                        if difference > state.speed or c_math.abs(difference) > 64 then
                            for i=1, state.iterations do
                                if state.increasing then
                                    if state.value < state.target then
                                        state.value = state.value + 1
                                    else
                                        state.increasing = false
                                    end
                                else
                                    if state.value > state.start then
                                        state.value = state.value - 1
                                    else
                                        state.increasing = true
                                    end
                                end
                            end

                            state.active = tick
                        end
                    end

                    if state.method == 'spin' then
                        local difference = tick - state.active

                        if difference > state.speed or c_math.abs(difference) > 64 then
                            for i=1, state.iterations do
                                if state.value < state.target then
                                    state.value = state.value + 1
                                else
                                    state.value = state.start
                                end
                            end

                            state.active = tick
                        end
                    end

                    if state.method == 'flick' then
                        local difference = tick - state.active

                        if difference > state.speed or c_math.abs(difference) > 64 then
                            state.increasing = not state.increasing
                            state.value = state.increasing and state.start or state.target
                            state.active = tick
                        end
                    end
                end
            end
        end

        c_tweening = {} do
            local native_GetTimescale = vtable_bind('engine.dll', 'VEngineClient014', 91, 'float(__thiscall*)(void*)')

            local function solve(easings_fn, prev, new, clock, duration)
                local prev = easings_fn(clock, prev, new - prev, duration)

                if type(prev) == 'number' then
                    if math.abs(new - prev) <= .01 then
                        return new
                    end

                    local fmod = prev % 1

                    if fmod < .001 then
                        return math.floor(prev)
                    end

                    if fmod > .999 then
                        return math.ceil(prev)
                    end
                end

                return prev
            end

            local mt = {}; do
                local function update(self, duration, target, easings_fn)
                    if duration == nil and target == nil and easings_fn == nil then
                        return self.value
                    end

                    local value_type = type(self.value)
                    local target_type = type(target)

                    if target_type == 'boolean' then
                        target = target and 1 or 0
                        target_type = 'number'
                    end

                    assert(value_type == target_type, string.format('type mismatch, expected %s (received %s)', value_type, target_type))

                    if target ~= self.to then
                        self.clock = 0

                        self.from = self.value
                        self.to = target
                    end

                    local clock = globals.frametime() / native_GetTimescale()
                    local duration = duration or .15

                    if self.clock == duration then
                        return target
                    end

                    if clock <= 0 and clock >= duration then
                        self.clock = 0

                        self.from = target
                        self.to = target

                        self.value = target

                        return target
                    end

                    self.clock = math.min(self.clock + clock, duration)
                    self.value = solve(easings_fn or self.easings, self.from, self.to, self.clock, duration)

                    return self.value;
                end

                mt.__metatable = false
                mt.__call = update
                mt.__index = mt
            end

            function c_tweening:new(default, easings_fn)
                if type(default) == 'boolean' then
                    default = default and 1 or 0
                end

                local this = {}

                this.clock = 0
                this.value = default or 0

                this.easings = easings_fn or function(t, b, c, d)
                    return c * t / d + b
                end

                return setmetatable(this, mt)
            end
        end

        c_grams = {} do
            c_grams.update_gram = (function (gram, v, maxlen)
                while #gram > maxlen-1 do
                    table.remove(gram, 1)
                end

                table.insert(gram, v)
            end)

            c_grams.average = (function (gram)
                local sum, cnt = 0, 0

                for i=1, #gram do
                    sum = sum + gram[i]
                    cnt = cnt + 1
                end

                if cnt == 0 then
                    return 0
                end

                return sum / cnt
            end)
        end
    end

    -- constants

    local c_constant do
        c_constant = {} do
            c_constant.STATE_LIST = { 'Standing', 'Slow-motion', 'Moving', 'Crouching', 'Crouch moving', 'Air', 'Air & Crouch' }
            c_constant.DEFENSIVE_STATES = { 'On peek', 'Legit AA', 'Edge direction', 'Safe head', 'Triggered' }

            c_constant.fonts = {} do
                c_constant.fonts.lucida = surface.create_font('Lucida Console', 10, 400, 128)
            end

            c_constant.antiaim_presets = {} do
                c_constant.antiaim_presets['PR0KLADKI'] = {
                    ['Legit AA'] = {
                        pitch = 'Off',
                        yaw_base = 'Local view',
                        yaw_type = 'Left & Right',
                        left_offset = 180,
                        right_offset = 180,
                        
                        body_yaw_type = 'Jitter',
                        body_yaw_value = -1
                    },
                    ['Fake lag'] = {
                        pitch = 'Minimal',
                        yaw_base = 'At targets',
                        yaw_type = 'Left & Right',
                        left_offset = -19,
                        right_offset = 42,
                        yaw_delay = 5,
                        yaw_delay_second = 5,

                        yaw_modifier = 'Off',
                        modifier_offset = 0
                    },
                    ['Standing'] = {
                        pitch = 'Minimal',
                        yaw_base = 'At targets',
                        yaw_type = 'Left & Right',
                        left_offset = -24,
                        right_offset = 41,
                        yaw_delay = 2,
                        yaw_delay_second = 10,

                        yaw_modifier = 'Random',
                        modifier_offset = 0,
                        modifier_randomize = 5
                    },
                    ['Slow-motion'] = {
                        pitch = 'Minimal',
                        yaw_base = 'At targets',
                        yaw_type = 'Left & Right',
                        left_offset = -22,
                        right_offset = 44,
                        yaw_delay = 3,
                        yaw_delay_second = 9,

                        yaw_modifier = 'Off',
                        modifier_offset = 0,
                        modifier_randomize = 5
                    },
                    ['Moving'] = {
                        pitch = 'Minimal',
                        yaw_base = 'At targets',
                        yaw_type = 'Left & Right',
                        left_offset = -24,
                        right_offset = 37,
                        yaw_delay = 3,
                        yaw_delay_second = 12
                    },
                    ['Crouching'] = {
                        pitch = 'Minimal',
                        yaw_base = 'At targets',
                        yaw_type = 'Left & Right',
                        left_offset = -32,
                        right_offset = 46,
                        body_yaw_type = 'Jitter',
                        body_yaw_value = -1
                    },
                    ['Crouch moving'] = {
                        pitch = 'Minimal',
                        yaw_base = 'At targets',
                        yaw_type = 'Left & Right',
                        left_offset = -22,
                        right_offset = 44,
                        yaw_delay = 2,
                        yaw_delay_second = 9
                    },
                    ['Air'] = {
                        pitch = 'Minimal',
                        yaw_base = 'At targets',
                        yaw_type = 'Left & Right',
                        left_offset = -29,
                        right_offset = 35,
                        yaw_delay = 5,
                        yaw_delay_second = 11
                    },
                    ['Air & Crouch'] = {
                        pitch = 'Minimal',
                        yaw_base = 'At targets',
                        yaw_type = 'Left & Right',
                        left_offset = -18,
                        right_offset = 44,
                        yaw_delay = 3,
                        yaw_delay_second = 9
                    }
                }

                c_constant.antiaim_presets['Blossom'] = {
                    ['Legit AA'] = {
                        pitch = 'Off',
                        yaw_base = 'Local view',
                        yaw_type = 'Left & Right',
                        left_offset = 180,
                        right_offset = 180,
                        
                        body_yaw_type = 'Jitter',
                        body_yaw_value = -1
                    },
                    ['Fake lag'] = {
                        pitch = 'Minimal',
                        yaw_base = 'At targets',
                        yaw_type = 'Left & Right',
                        left_offset = -28,
                        right_offset = 35,
                        yaw_delay = 1,
                        yaw_delay_second = 2,

                        yaw_modifier = 'Off',
                        modifier_offset = 0
                    },
                    ['Standing'] = {
                        pitch = 'Minimal',
                        yaw_base = 'At targets',
                        yaw_type = 'Left & Right',
                        left_offset = -33,
                        right_offset = 41,
                        yaw_delay = 2,
                        yaw_delay_second = 2,

                        yaw_modifier = 'Random',
                        modifier_offset = 0,
                        modifier_randomize = 5
                    },
                    ['Slow-motion'] = {
                        pitch = 'Minimal',
                        yaw_base = 'At targets',
                        yaw_type = 'Left & Right',
                        left_offset = -38,
                        right_offset = 45,
                        yaw_delay = 3,
                        yaw_delay_second = 3,

                        yaw_modifier = 'Off',
                        modifier_offset = 0,
                        modifier_randomize = 5
                    },
                    ['Moving'] = {
                        pitch = 'Minimal',
                        yaw_base = 'At targets',
                        yaw_type = 'Left & Right',
                        left_offset = -25,
                        right_offset = 42,
                        yaw_delay = 2,
                        yaw_delay_second = 2
                    },
                    ['Crouching'] = {
                        pitch = 'Minimal',
                        yaw_base = 'At targets',
                        yaw_type = 'Left & Right',
                        left_offset = -30,
                        right_offset = 45,
                        yaw_delay = 2,
                        yaw_delay_second = 2
                    },
                    ['Crouch moving'] = {
                        pitch = 'Minimal',
                        yaw_base = 'At targets',
                        yaw_type = 'Left & Right',
                        left_offset = -30,
                        right_offset = 33,
                        yaw_delay = 2,
                        yaw_delay_second = 2
                    },
                    ['Air'] = {
                        pitch = 'Minimal',
                        yaw_base = 'At targets',
                        yaw_type = 'Left & Right',
                        left_offset = -18,
                        right_offset = 27,
                        yaw_delay = 2,
                        yaw_delay_second = 2
                    },
                    ['Air & Crouch'] = {
                        pitch = 'Minimal',
                        yaw_base = 'At targets',
                        yaw_type = 'Left & Right',
                        left_offset = -19,
                        right_offset = 47,
                        yaw_delay = 2,
                        yaw_delay_second = 2
                    }
                }
            end

            c_constant.defensive_presets = {} do
                c_constant.defensive_presets["Auto"] = {
                    ["Safe head"] = {
                        ["pitch"] = "Custom",
                        ["pitch_custom"] = 10,
                        ["yaw"] = "Delayed",
                        ["yaw_left"] = -135,
                        ["yaw_right"] = 135,
                        ["yaw_delay"] = 20
                    },
                    ["Triggered"] = {
                        ["pitch"] = "Up Switch",
                        ["pitch_custom"] = 10,
                        ["yaw"] = "Spinbot",
                        ["yaw_from"] = -150,
                        ["yaw_to"] = 150,
                        ["yaw_speed"] = 20
                    },
                    ["Edge direction"] = {
                        ["enable_on"] = {"Freestanding", "Manual yaw"},
                        ["pitch"] = "Custom",
                        ["pitch_custom"] = 10,
                        ["yaw"] = "Spinbot",
                        ["yaw_left"] = 0,
                        ["yaw_right"] = 0,
                        ["yaw_delay"] = 1,
                        ["yaw_from"] = -180,
                        ["yaw_to"] = 180,
                        ["yaw_speed"] = 20
                    },
                    ["Standing"] = {
                        ["pitch"] = "Custom",
                        ["pitch_custom"] = -45,
                        ["yaw"] = "Spinbot",
                        -- Delayed
                        ["yaw_left"] = 0,
                        ["yaw_right"] = 0,
                        ["yaw_delay"] = 1,
                        -- Spinbot
                        ["yaw_from"] = -180,
                        ["yaw_to"] = 180,
                        ["yaw_speed"] = 29,
                        -- Scissors
                        ["yaw_left_start"] = 0,
                        ["yaw_left_target"] = 0,
                        ["yaw_right_start"] = 0,
                        ["yaw_right_target"] = 0,
                        -- Randomize
                        ["yaw_randomize"] = 0
                    },
                    ["Crouching"] = {
                        ["pitch"] = "Custom",
                        ["pitch_custom"] = -45,
                        ["yaw"] = "Default",
                        -- Delayed
                        ["yaw_left"] = 0,
                        ["yaw_right"] = 0,
                        ["yaw_delay"] = 1,
                        -- Spinbot
                        ["yaw_from"] = -180,
                        ["yaw_to"] = 180,
                        ["yaw_speed"] = 29,
                        -- Scissors
                        ["yaw_left_start"] = 0,
                        ["yaw_left_target"] = 0,
                        ["yaw_right_start"] = 0,
                        ["yaw_right_target"] = 0,
                        -- Randomize
                        ["yaw_randomize"] = 0
                    },
                    ["Crouch moving"] = {
                        ["pitch"] = "Custom",
                        ["pitch_custom"] = -45,
                        ["yaw"] = "Delayed",
                        -- Delayed
                        ["yaw_left"] = -90,
                        ["yaw_right"] = 90,
                        ["yaw_delay"] = 1,
                        -- Spinbot
                        ["yaw_from"] = -180,
                        ["yaw_to"] = 180,
                        ["yaw_speed"] = 29,
                        -- Scissors
                        ["yaw_left_start"] = 0,
                        ["yaw_left_target"] = 0,
                        ["yaw_right_start"] = 0,
                        ["yaw_right_target"] = 0,
                        -- Randomize
                        ["yaw_randomize"] = 27
                    },
                    ["Air"] = {
                        ["pitch"] = "Custom",
                        ["pitch_custom"] = -45,
                        ["yaw"] = "Spinbot",
                        -- Delayed
                        ["yaw_left"] = 0,
                        ["yaw_right"] = 0,
                        ["yaw_delay"] = 1,
                        -- Spinbot
                        ["yaw_from"] = -180,
                        ["yaw_to"] = 180,
                        ["yaw_speed"] = 49,
                        -- Scissors
                        ["yaw_left_start"] = 0,
                        ["yaw_left_target"] = 0,
                        ["yaw_right_start"] = 0,
                        ["yaw_right_target"] = 0,
                        -- Randomize
                        ["yaw_randomize"] = 0
                    },
                    ["Air & Crouch"] = {
                        ["pitch"] = "Up",
                        ["pitch_custom"] = -45,
                        ["yaw"] = "Default",
                        -- Delayed
                        ["yaw_left"] = 0,
                        ["yaw_right"] = 0,
                        ["yaw_delay"] = 1,
                        -- Spinbot
                        ["yaw_from"] = -180,
                        ["yaw_to"] = 180,
                        ["yaw_speed"] = 29,
                        -- Scissors
                        ["yaw_left_start"] = 0,
                        ["yaw_left_target"] = 0,
                        ["yaw_right_start"] = 0,
                        ["yaw_right_target"] = 0,
                        -- Randomize
                        ["yaw_randomize"] = 0
                    },
                    ["On peek"] = {
                        ["pitch"] = "Up Switch",
                        ["pitch_custom"] = 10,
                        ["yaw"] = "Random",
                        ["yaw_left"] = 0,
                        ["yaw_right"] = -3,
                        ["yaw_delay"] = 1,
                        ["yaw_from"] = -150,
                        ["yaw_to"] = 150,
                        ["yaw_speed"] = 20,
                        ["yaw_randomize"] = 20
                    }
                }
            end
        end
    end

    local color do
        local create_color, create_color_object, Color do
            Color = {} do
                function Color:clone()
                    return create_color_object(
                        self.r, self.g, self.b, self.a
                    )
                end

                function Color:to_hex()
                    return ('%02X%02X%02X%02X'):format(self.r, self.g, self.b, self.a)
                end

                function Color:as_hex(hex_value)
                    local r, g, b, a = hex_value:match('(%x%x)(%x%x)(%x%x)(%x%x)')

                    return create_color_object(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16), tonumber(a, 16))
                end

                function Color:lerp(color_target, weight)
                    return create_color_object(
                        c_math.lerp(self.r, color_target.r, weight),
                        c_math.lerp(self.g, color_target.g, weight),
                        c_math.lerp(self.b, color_target.b, weight),
                        c_math.lerp(self.a, color_target.a, weight)
                    )
                end

                function Color:grayscale(ratio)
                    return create_color_object(
                        self.r * ratio,
                        self.g * ratio,
                        self.b * ratio,
                        self.a
                    )
                end

                function Color:alpha_modulate(alpha, modulate)
                    return create_color_object(
                        self.r,
                        self.g,
                        self.b,
                        modulate and self.a*alpha or alpha
                    )
                end

                function Color:unpack()
                    return self.r, self.g, self.b, self.a
                end
            end

            function create_color_object(self, ...)
                local args = {...}

                if type(self) == 'number' then
                    table.insert(args, 1, self)
                end

                if type(args[1]) == 'table' then
                    if args[1][1] then
                        args = args[1]
                    else
                        args = {args[1].r, args[1].g, args[1].b, args[1].a}
                    end
                end

                if type(args[1]) == 'string' then
                    return setmetatable({
                        r = 255, g = 255, b = 255, a = 255
                    }, {
                        __index = Color
                    }):as_hex(args[1])
                end

                return setmetatable({
                    r = args[1] or 255,
                    g = args[2] or 255,
                    b = args[3] or 255,
                    a = args[4] or 255
                }, {
                    __index = Color
                })
            end

            local stock_colors = {} do
                stock_colors.raw_green = create_color_object(0, 255, 0);
                stock_colors.raw_red = create_color_object(255, 0, 0);

                stock_colors.red = create_color_object(255, 0, 50);
                stock_colors.white = create_color_object();
                stock_colors.gray = create_color_object(200, 200, 200);
                stock_colors.green = create_color_object(143, 194, 21);
                stock_colors.sea = create_color_object(59, 208, 182);
                stock_colors.blue = create_color_object(95, 156, 204);
                stock_colors.pink = create_color_object(209, 101, 145);
                stock_colors.yellow = create_color_object(233, 213, 2);
                stock_colors.purplish = create_color_object(193, 144, 252);

                stock_colors.onshot = create_color_object(100, 148, 237, 255);
                stock_colors.freestanding = create_color_object(132, 195, 16, 255);
                stock_colors.edge = create_color_object(209, 159, 230, 255);
                stock_colors.fixik = create_color_object('00FFCBFF');

                stock_colors.string_to_color_array = (function (str)
                    local arr =  {}
                    local match, mend = str:find('\a')

                    if not match then
                        arr[#arr+1] = str
                    else
                        while match do
                            local prmatch = match
                            local prend = mend

                            match, mend = str:find('\a', match+1)

                            if match == nil then
                                arr[#arr+1] = str:sub(prend, #str)

                                break
                            else
                                arr[#arr+1] = str:sub(prmatch, match-1)
                            end
                        end
                    end

                    local cnt = 0
                    local out = {}

                    for i=1, #arr do
                        for hex_col, s in arr[i]:gmatch('\a(%x%x%x%x%x%x%x%x)(.+)') do
                            out[#out+1] = {
                                color = create_color(hex_col),
                                text = s
                            };

                            cnt = cnt + 1
                        end
                    end

                    if cnt == 0 then
                        out[#out+1] = {
                            color = create_color('FFFFFFFF'),
                            text = str
                        }
                    end

                    return out
                end)

                stock_colors.animated_text = (function (text, speed, color_start, color_end, alpha)
                    local first = color_start and create_color(color_start.r, color_start.g, color_start.b, alpha) or create_color(255, 200, 255, alpha)
                    local second = color_end and create_color(color_end.r, color_end.g, color_end.b, alpha) or create_color(100, 100, 100, alpha)

                    local res = ""

                    for idx = 1, #text + 1 do
                        local letter = text:sub(idx, idx)

                        local alpha1 = (idx - 1) / (#text - 1)
                        local m_speed = globals.realtime() * ((50 / 25) or 1.0)
                        local m_factor = m_speed % math.pi

                        local c_speed = speed or 1
                        local m_sin = math.sin(m_factor * c_speed + (alpha1 or 0))
                        local m_abs = math.abs(m_sin)
                        local clr = first:lerp(second, m_abs)

                        res = ("%s\a%s%s"):format(res, clr:to_hex(), letter)
                    end

                    return res
                end)
            end

            create_color = setmetatable(stock_colors, {
                __call = create_color_object
            })
        end

        color = create_color
    end


    local override = {} do
        local e_hotkey_mode = {
            [0] = "Always on",
            [1] = "On hotkey",
            [2] = "Toggle",
            [3] = "Off hotkey"
        }

        local data = { }

        local function get_value(ref)
            local value = { ui.get(ref) }
            local typeof = ui.type(ref)

            if typeof == "hotkey" then
                return { e_hotkey_mode[value[2]], value[3] }
            end

            return value
        end

        function override.get(ref, ...)
            local value = data[ref]

            if value == nil then
                return
            end

            return unpack(value)
        end

        function override.set(ref, ...)
            if data[ref] == nil then
                data[ref] = get_value(ref)
            end

            ui.set(ref, ...)
        end

        function override.unset(ref)
            if data[ref] == nil then
                return
            end

            ui.set(ref, unpack(data[ref]))
            data[ref] = nil
        end
    end

    local menu = {} do
        local items = { }
        local records = { }

        local callbacks = { }

        local function get_value(ref)
            local value = { pcall(ui.get, ref) }
            if not value[1] then return end

            return unpack(value, 2)
        end

        local function get_keys(value)
            if type(value[1]) == "table" then
                return c_table.keys(value[1])
            end

            return { }
        end

        local function update_items()
            for i = 1, #callbacks do
                callbacks[i]()
            end

            for i = 1, #items do
                local item = items[i]

                ui.set_visible(item.ref, item.is_visible)
                item.is_visible = false
            end
        end

        local c_item = { } do
            function c_item:new()
                return setmetatable({ }, self)
            end

            function c_item:init()
                local function callback(ref)
                    self:update_value(ref)
                    self:invoke_callback(ref)

                    update_items()
                end

                ui.set_callback(self.ref, callback)
            end

            function c_item:get()
                return unpack(self.value)
            end

            function c_item:set(...)
                local ref = self.ref

                ui.set(ref, ...)
                self:update_value(ref)
            end

            function c_item:have_key(key)
                return self.keys[key] ~= nil
            end

            function c_item:rawget()
                return ui.get(self.ref)
            end

            function c_item:reset()
                pcall(ui.set, self.ref, unpack(self.default))
            end

            function c_item:record(tab, name)
                if records[tab] == nil then
                    records[tab] = { }
                end

                self.is_recorded = true
                records[tab][name] = self

                return self
            end

            function c_item:save()
                if not self.is_recorded then
                    error("unable to save unrecorded item")
                    return
                end

                self.is_saved = true
                return self
            end

            function c_item:display()
                self.is_visible = true
            end

            function c_item:config_ignore()
                self.saveable = false
                return self
            end

            function c_item:set_callback(callback, run)
                if run then
                    callback(self.ref)
                end

                self.callbacks[#self.callbacks + 1] = callback
            end

            function c_item:update_value(ref)
                local value = { get_value(ref) }
                self.keys = get_keys(value)

                self.value = value
            end

            function c_item:invoke_callback(...)
                for i = 1, #self.callbacks do
                    self.callbacks[i](...)
                end
            end

            function c_item:get_ref()
                return self.ref
            end

            c_item.__index = c_item
        end

        function menu.new_item(fn, ...)
            local ref = fn(...)

            local value = { get_value(ref) }
            local typeof = ui.type(ref)

            local item = c_item:new()

            item.ref = ref
            item.name = select(3, ...)

            item.value = value
            item.default = value

            item.keys = get_keys(value)
            item.callbacks = { }

            item.is_saved = false
            item.is_visible = false
            item.is_recorded = false

            item.saveable = true

            if typeof == "button" then
                item.callbacks[#item.callbacks + 1] = select(4, ...)
            end

            item:init()
            items[#items + 1] = item

            return item
        end

        function menu.get_items()
            return items
        end

        function menu.get_records()
            return records
        end

        function menu.set_callback(callback)
            callbacks[#callbacks + 1] = callback
        end

        function menu.update()
            update_items()
        end
    end

    local config_system do
        config_system = { }

        local e_hotkey_mode = {
            [0] = "Always on",
            [1] = "On hotkey",
            [2] = "Toggle",
            [3] = "Off hotkey"
        }

        local function resolve_item_export(item)
            if not item.saveable then
                return
            end

            if ui.type(item.ref) == "label" then
                return
            end

            if ui.type(item.ref) == "hotkey" then
                local active, mode, key = item:rawget()

                return {e_hotkey_mode[mode], key}
            end

            return item.value
        end

        local function resolve_item_import(item, data)
            if ui.type(item.ref) == "label" then
                return true
            end

            if not item.saveable then
                return true
            end

            if data == nil then
                return false
            end

            item:set(unpack(data))

            return true
        end

        function config_system.export_to_str(...)
            local tabs = {...}
            local config_result = {}

            local records = menu:get_records()

            if #tabs ~= 0 then
                records = {}

                for i=1, #tabs do
                    records[tabs[i]] = menu:get_records()[tabs[i]]
                end
            end

            for tab, list in pairs(records) do
                config_result[tab] = {}

                for item_id, element in pairs(list) do
                    config_result[tab][item_id] = resolve_item_export(element)
                end
            end

            return base64.encode(json.stringify(config_result)) .. '_PR0KLADKI'
        end

        function config_system.import_from_str(str, ...)
            local tabs = {...}
            local PR0KLADKI_str = str:find("_PR0KLADKI")

            if PR0KLADKI_str then
                str = str:sub(1, PR0KLADKI_str-1)
            end

            local status, config = pcall(base64.decode, str)

            if not status then
                return false, "Failed to decode config"
            end

            status, config = pcall(json.parse, config)

            if not status then
                return false, "Failed to parse config"
            end

            local records = menu:get_records()

            if #tabs ~= 0 then
                records = {}

                for i=1, #tabs do
                    records[tabs[i]] = menu:get_records()[tabs[i]]
                end
            end

            for tab, list in pairs(records) do
                if config[tab] then
                    for item_id, element in pairs(list) do
                        if config[tab][item_id] then
                            resolve_item_import(element, config[tab][item_id])
                        end
                    end
                end
            end

            return true
        end

        function config_system:retrieve_local()
            local db_data = database.read('pr0kladki_config')
        
            if db_data ~= nil and db_data[1] ~= nil then
                self.import_from_str(db_data[1])
            end
        end

        function config_system:save_local()
            local config_output = self.export_to_str()

            database.write('pr0kladki_config', {
                config_output
            })

            c_logger.log('Local config saved.')
        end
    end

    local reference do
        reference = {} do
            reference.ragebot = {} do
                reference.ragebot.enabled = {ui.reference('RAGE', 'Aimbot', 'Enabled')}

                reference.ragebot.doubletap = {} do
                    reference.ragebot.doubletap.enable = {ui.reference('RAGE', 'Aimbot', 'Double tap')}
                    reference.ragebot.doubletap.fakelag = ui.reference('RAGE', 'Aimbot', 'Double tap fake lag limit')
                end

                reference.ragebot.force_bodyaim = ui.reference('RAGE', 'Aimbot', 'Force body aim')
                reference.ragebot.force_safepoint = ui.reference('RAGE', 'Aimbot', 'Force safe point')

                reference.ragebot.minimum_damage = ui.reference('RAGE', 'Aimbot', 'Minimum damage')
                reference.ragebot.minimum_damage_override = {ui.reference('RAGE', 'Aimbot', 'Minimum damage override')}

                reference.ragebot.quick_peek_assist = {ui.reference('RAGE', 'Other', 'Quick peek assist')}
                reference.ragebot.fakeduck = ui.reference('RAGE', 'Other', 'Duck peek assist')
            end

            reference.antiaim = {} do
                reference.antiaim.master = ui.reference('AA', 'Anti-aimbot angles', 'Enabled')

                reference.antiaim.roll = ui.reference('AA', 'Anti-aimbot angles', 'Roll')
                reference.antiaim.freestanding = {ui.reference('AA', 'Anti-aimbot angles', 'Freestanding')}

                reference.antiaim.pitch = c_table.unpack_keywise({'type', 'value'}, ui.reference('AA', 'Anti-aimbot angles', 'Pitch'))

                reference.antiaim.yaw = {} do
                    reference.antiaim.yaw.base = ui.reference('AA', 'Anti-aimbot angles', 'Yaw base')
                    reference.antiaim.yaw.yaw = c_table.unpack_keywise({'type', 'value'}, ui.reference('AA', 'Anti-aimbot angles', 'Yaw'))
                    reference.antiaim.yaw.jitter = c_table.unpack_keywise({'type', 'value'}, ui.reference('AA', 'Anti-aimbot angles', 'Yaw jitter'))
                    reference.antiaim.yaw.edge = ui.reference('AA', 'Anti-aimbot angles', 'Edge yaw')
                end

                reference.antiaim.body = {} do
                    reference.antiaim.body.yaw = c_table.unpack_keywise({'type', 'value'}, ui.reference('AA', 'Anti-aimbot angles', 'Body yaw'))
                    reference.antiaim.body.freestanding = ui.reference('AA', 'Anti-aimbot angles', 'Freestanding body yaw')
                end
            end

            reference.fakelag = {} do
                reference.fakelag.enable = {ui.reference('AA', 'Fake lag', 'Enabled')}
                reference.fakelag.amount = ui.reference('AA', 'Fake lag', 'Amount')
                reference.fakelag.variance = ui.reference('AA', 'Fake lag', 'Variance')
                reference.fakelag.limit = ui.reference('AA', 'Fake lag', 'Limit')
            end

            reference.misc = {} do
                reference.misc.draw_output = ui.reference('MISC', 'Miscellaneous', 'Draw console output')
                reference.misc.freestanding = ui.reference('AA', 'Anti-aimbot angles', 'Freestanding')

                reference.misc.pingspike = c_table.unpack_keywise({'bind', 'value'}, ui.reference('MISC', 'Miscellaneous', 'Ping spike'))
                reference.misc.slowmotion = {ui.reference('AA', 'Other', 'Slow motion')}
                reference.misc.onshot_antiaim = {ui.reference('AA', 'Other', 'On shot anti-aim')}
                reference.misc.leg_movement = ui.reference('AA', 'Other', 'Leg movement')
                reference.misc.fake_peek = {ui.reference('AA', 'Other', 'Fake peek')}

                reference.misc.grenade_toss = ui.reference('Misc', 'Miscellaneous', 'Super toss')
                reference.misc.grenade_release = {ui.reference('Misc', 'Miscellaneous', 'Automatic grenade release')}

                reference.misc.air_strafe = ui.reference('MISC', 'Movement', 'Air strafe')
            end
        end
    end

    local config = {} 

    config.navigation = {} do
        config.navigation.label = menu.new_item(ui.new_label, "AA", "Anti-aimbot angles", string.format('\v•  \rPR0KLADKI · %s · %s', user.name, user.role))

        config.navigation.tab = menu.new_item(ui.new_combobox, "AA", "Anti-aimbot angles", "Navigation: Tab", {
            "Anti-aimbot",
            "Defensive",
            "Visuals",
            "Miscellaneous",
            "Presets",
            "Configuration"
        }):config_ignore()
    end

    local ffi_helpers do
        ffi_helpers = {} do
            ffi_helpers.get_client_entity = vtable_bind('client.dll', 'VClientEntityList003', 3, 'void*(__thiscall*)(void***, int)')

            ffi_helpers.animstate = {} do
                if not pcall(ffi.typeof, 'bt_animstate_t') then
                    ffi.cdef[[
                        typedef struct {
                            char __0x108[0x108];
                            bool on_ground;
                            bool hit_in_ground_animation;
                        } bt_animstate_t, *pbt_animstate_t
                    ]]
                end

                ffi_helpers.animstate.offset = 0x9960

                ffi_helpers.animstate.get = function (self, ent)
                    local client_entity = ffi_helpers.get_client_entity(ent)

                    if not client_entity then
                        return
                    end

                    return ffi.cast('pbt_animstate_t*', ffi.cast('uintptr_t', client_entity) + self.offset)[0]
                end
            end

            ffi_helpers.animlayers = {} do
                if not pcall(ffi.typeof, 'bt_animlayer_t') then
                    ffi.cdef[[
                        typedef struct {
                            float   anim_time;
                            float   fade_out_time;
                            int     nil;
                            int     activty;
                            int     priority;
                            int     order;
                            int     sequence;
                            float   prev_cycle;
                            float   weight;
                            float   weight_delta_rate;
                            float   playback_rate;
                            float   cycle;
                            int     owner;
                            int     bits;
                        } bt_animlayer_t, *pbt_animlayer_t
                    ]]
                end

                ffi_helpers.animlayers.offset = ffi.cast('int*', ffi.cast('uintptr_t', client.find_signature('client.dll', '\x8B\x89\xCC\xCC\xCC\xCC\x8D\x0C\xD1')) + 2)[0]

                ffi_helpers.animlayers.get = function (self, ent)
                    local client_entity = ffi_helpers.get_client_entity(ent)

                    if not client_entity then
                        return
                    end

                    return ffi.cast('pbt_animlayer_t*', ffi.cast('uintptr_t', client_entity) + self.offset)[0]
                end
            end

            ffi_helpers.activity = {} do
                if not pcall(ffi.typeof, 'bt_get_sequence') then
                    ffi.cdef[[
                        typedef int(__fastcall* bt_get_sequence)(void* entity, void* studio_hdr, int sequence);
                    ]]
                end

                ffi_helpers.activity.offset = 0x2950 
                ffi_helpers.activity.location = ffi.cast('bt_get_sequence', client.find_signature('client.dll', '\x55\x8B\xEC\x53\x8B\x5D\x08\x56\x8B\xF1\x83'))

                ffi_helpers.activity.get = function (self, sequence, ent)
                    local client_entity = ffi_helpers.get_client_entity(ent)

                    if not client_entity then
                        return
                    end

                    local studio_hdr = ffi.cast('void**', ffi.cast('uintptr_t', client_entity) + self.offset)[0]

                    if not studio_hdr then
                        return;
                    end

                    return self.location(client_entity, studio_hdr, sequence);
                end
            end

            ffi_helpers.user_input = {} do
                if not pcall(ffi.typeof, 'bt_cusercmd_t') then
                    ffi.cdef[[
                        typedef struct {
                            struct bt_cusercmd_t (*cusercmd)();
                            int     command_number;
                            int     tick_count;
                            float   view[3];
                            float   aim[3];
                            float   move[3];
                            int     buttons;
                        } bt_cusercmd_t;
                    ]]
                end

                if not pcall(ffi.typeof, 'bt_get_usercmd') then
                    ffi.cdef[[
                        typedef bt_cusercmd_t*(__thiscall* bt_get_usercmd)(void* input, int, int command_number);
                    ]]
                end

                ffi_helpers.user_input.vtbl = ffi.cast('void***', ffi.cast('void**', ffi.cast('uintptr_t', client.find_signature('client.dll', '\xB9\xCC\xCC\xCC\xCC\x8B\x40\x38\xFF\xD0\x84\xC0\x0F\x85') or error('fipp')) + 1)[0])
                ffi_helpers.user_input.location = ffi.cast('bt_get_usercmd', ffi_helpers.user_input.vtbl[0][8])

                ffi_helpers.user_input.get_command = function (self, command_number)
                    return self.location(self.vtbl, 0, command_number)
                end
            end
        end
    end

    --- Player class
    local player do
        local create_player, BaseLocal do
            BaseLocal = {} do

                ---@param 
                function BaseLocal:reset(full)
                    if full then
                        self.entindex = -1
                        self.alive = false
                    end

                    self.onground = true
                    self.velocity = vector()
                    self.speed = 0.0
                    self.duckamount = 0.0
                    self.stamina = 80.0
                    self.velocity_modifier = 1.0
                    self.fakeyaw = 0.0
                    self.server_fakeyaw = 0.0
                    self.smooth_fakeamount = 0.0
                    self.fakeamount_gram = {}
                    self.state = 'Standing'
                    self.defensive_active = false
                    self.defensive_predict = false
                    self.use_needed = false
                    self.landing = false
                    self.peeking = false
                    self.freestanding_side = 'none'
                    self._shifting_enough = false
                end

                function BaseLocal:is_onground()
                    local animstate = ffi_helpers.animstate:get(self.entindex)

                    if not animstate then
                        return true
                    end

                    local ptr_addr = ffi.cast('uintptr_t', ffi.cast('void*', animstate))
                    local landed_on_ground_this_frame = ffi.cast('bool*', ptr_addr + 0x120)[0] --- @offset

                    return animstate.on_ground and not landed_on_ground_this_frame
                end

                function BaseLocal:get_velocity_modifier()
                    local velocity_modifier = entity.get_prop(self.entindex, 'm_flVelocityModifier')

                    if self.stamina > 0.01 and self.onground then
                        local flSpeedScale = c_math.clamp(1.0 - self.stamina * 0.01, 0.0, 1.0)

                        flSpeedScale = flSpeedScale * flSpeedScale

                        velocity_modifier = velocity_modifier * flSpeedScale
                    end

                    return velocity_modifier
                end

                --- Get player state
                ---@return string
                function BaseLocal:get_state()
                    if not self.onground then
                        if self.duckamount > 0.5 then
                            return 'Air & Crouch'
                        else
                            return 'Air'
                        end
                    end

                    if self.duckamount > 0.5 or ui.get(reference.ragebot.fakeduck) then
                        if self.speed > 4 then
                            return 'Crouch moving'
                        else
                            return 'Crouching'
                        end
                    end

                    local slowmotion_state = c_table.is_hotkey_active(reference.misc.slowmotion)

                    if slowmotion_state then
                        return 'Slow-motion'
                    end

                    if self.speed > 4 then
                        return 'Moving'
                    end

                    return 'Standing'
                end

                local tickbase_max = 0

                function BaseLocal:get_defensive()
                    local tickbase = entity.get_prop(self.entindex, 'm_nTickBase')

                    if c_math.abs(tickbase - tickbase_max) > 64 then
                        tickbase_max = 0
                    end

                    local defensive_ticks_left = 0;

                    if tickbase > tickbase_max then
                        tickbase_max = tickbase
                    elseif tickbase_max > tickbase then
                        defensive_ticks_left = c_math.min(14, c_math.max(0, tickbase_max-tickbase-1))
                    end

                    return defensive_ticks_left > 2
                end

                ---@param
                BaseLocal.is_use_needed = (function (self, wpn)
                    if wpn then
                        local wpn_classname = entity.get_classname(wpn)

                        if wpn_classname == 'CC4' then
                            return true
                        end
                    end

                    local my_origin = vector(entity.get_origin(self.entindex))
                    local team_num = entity.get_prop(self.entindex, 'm_iTeamNum')
                    local planted_ents = entity.get_all('CPlantedC4')

                    for i=1, #planted_ents do
                        local c4 = planted_ents[i]
                        local m_hDefuser = entity.get_prop(c4, 'm_hDefuser')
                        local c4_origin = vector(entity.get_origin(c4))

                        if m_hDefuser == self.entindex or team_num == 3 and c4_origin:dist(my_origin) < 87.5 then
                            return true
                        end
                    end

                    local hostage_ents = entity.get_all('CHostage')

                    for i=1, #hostage_ents do
                        local hostage = hostage_ents[i]
                        local hostage_origin = vector(entity.get_origin(hostage))

                        if hostage_origin:dist(my_origin) < 50 and team_num == 3 then
                            return true
                        end
                    end

                    local head_origin = vector(client.eye_position())
                    local angles = vector():init_from_angles(client.camera_angles())
                    local end_point = head_origin + angles * 128

                    ---@type number, number
                    local fraction, ent = client.trace_line(self.entindex, head_origin.x, head_origin.y, head_origin.z, end_point.x, end_point.y, end_point.z)

                    if ent ~= -1 and fraction ~= 1.0 then
                        local cname = entity.get_classname(ent)

                        if cname ~= nil and cname ~= 'CWorld' and cname ~= 'CCSPlayer' and cname ~= 'CFuncBrush' then
                            return true
                        end
                    end

                    return false
                end)

                function BaseLocal:threat_yaw()
                    local aa_threat = client.current_threat()

                    if not aa_threat then
                        return
                    end

                    local my_origin = vector(entity.get_origin(self.entindex))
                    local _, threat_yaw = my_origin:to(vector(entity.get_origin(aa_threat))):angles()

                    return threat_yaw
                end

                ---@param target number Target for yaw calculation
                ---@return string
                BaseLocal.get_side = (function (self, target)
                    local local_pos, enemy_pos = vector(entity.hitbox_position(self.entindex, 0)), vector(entity.hitbox_position(target, 0))

                    local _, yaw = (local_pos-enemy_pos):angles()
                    local l_dir, r_dir = vector():init_from_angles(0, yaw+90), vector():init_from_angles(0, yaw-90)
                    local l_pos, r_pos = local_pos + l_dir * 110, local_pos + r_dir * 110

                    local fraction = client.trace_line(target, enemy_pos.x, enemy_pos.y, enemy_pos.z, l_pos.x, l_pos.y, l_pos.z)
                    local fraction_s = client.trace_line(target, enemy_pos.x, enemy_pos.y, enemy_pos.z, r_pos.x, r_pos.y, r_pos.z)

                    if fraction > fraction_s then
                        return 'left'
                    elseif fraction_s > fraction then
                        return 'right'
                    elseif fraction == fraction_s then
                        return 'none'
                    end

                    return 'none'
                end)

                function BaseLocal:get_weapon_type(wpn)
                    if not wpn then
                        return false
                    end

                    local wpn_info = csgo_weapons(wpn)

                    if not wpn_info then
                        return false
                    end

                    return wpn_info.type
                end

                do
                    local defensive_tick = 0
                    local native_GetClientEntity = vtable_bind('client.dll', 'VClientEntityList003', 3, 'void*(__thiscall*)(void*, int)')

                    function BaseLocal:handle_defensive()
                        local lp = entity.get_local_player()
            
                        if lp and entity.is_alive(lp) then
                            local Entity = native_GetClientEntity(lp)
                            local m_flOldSimulationTime = ffi.cast("float*", ffi.cast("uintptr_t", Entity) + 0x26C)[0]
                            local m_flSimulationTime = entity.get_prop(lp, "m_flSimulationTime")
                
                            local delta = m_flOldSimulationTime - m_flSimulationTime
                
                            if delta > 0 then
                                defensive_tick = globals.tickcount() + toticks(delta - client.real_latency())
                            end
                        end

                        return globals.tickcount() <= defensive_tick - 2
                    end
                end
                    

                BaseLocal.set_peeking_state = (function (self, me)
                    local target, cross_target, last_dmg, best_yaw = nil, nil, 0, 362
                    local is_peeking = false

                    local enemy_list = entity.get_players(true)
                    local camera_angles = vector(client.camera_angles())
                    local stomach_origin = vector(entity.hitbox_position(me, 2))
                    local stomach_future = c_math.extrapolate(me, stomach_origin, 16)

                    for idx=1, #enemy_list do
                        local ent = enemy_list[idx]
                        local ent_wpn = entity.get_player_weapon(ent)

                        if ent_wpn then
                            local enemy_head = vector(entity.hitbox_position(ent, 2))
                            local entindex, damage = client.trace_bullet(ent, enemy_head.x, enemy_head.y, enemy_head.z, stomach_future.x, stomach_future.y, stomach_future.z)

                            if -1 == entindex then
                                damage = 0
                            end

                            if damage > 0 then
                                is_peeking = true
                            end

                            if damage > last_dmg then
                                target = ent
                                last_dmg = damage
                            end

                            local _, yaw = (stomach_origin-enemy_head):angles()
                            local base_diff = c_math.abs(camera_angles.y-yaw)

                            if base_diff < best_yaw then
                                cross_target = ent
                                best_yaw = base_diff
                            end
                        end
                    end

                    if not target then
                        target = cross_target
                    end

                    self.peeking = is_peeking
                    self.fs_side = target and self:get_side(target) or 'none'
                end)

                local get_curtime = function (n_offset)
                    return globals.curtime() - (n_offset * globals.tickinterval())
                end

                local weapon_ready = function (ent, weapon)
                    if not ent or not weapon then
                        return false
                    end

                    if get_curtime(16) < entity.get_prop(ent, 'm_flNextAttack') then
                        return false
                    end

                    if get_curtime(0) < entity.get_prop(weapon, 'm_flNextPrimaryAttack') then
                        return false
                    end

                    return true
                end

                function BaseLocal:get_double_tap()
                    return self._shifting_enough
                end

                function BaseLocal:run_command(cmd)
                    local me = entity.get_local_player()

                    if me then
                        local m_nTickBase = entity.get_prop(me, 'm_nTickBase')
                        local client_latency = client.latency()
                        local shift = math.floor(m_nTickBase - globals.tickcount() - 3 - toticks(client_latency) * .5 + .5 * (client_latency * 10))

                        local wanted = -14 + (ui.get(reference.ragebot.doubletap.fakelag) - 1) + 3 --error margin

                        self._shifting_enough = shift <= wanted
                    end
                end

                function BaseLocal:predict_command(cmd, me, wpn)
                    if not self.valid then
                        return self:reset(true)
                    end

                    self.entindex = me
                    self.alive = entity.is_alive(self.entindex)

                    if self.alive then
                        local animstate = ffi_helpers.animstate:get(me) or {}

                        self.onground = self:is_onground()
                        self.defensive_predict = self:handle_defensive()
                        self.velocity = vector(entity.get_prop(me, 'm_vecVelocity'))
                        self.speed = self.velocity:length()
                        self.duckamount = entity.get_prop(me, 'm_flDuckAmount')
                        self.stamina = entity.get_prop(me, 'm_flStamina')
                        self.velocity_modifier = self:get_velocity_modifier()
                        self.state = self:get_state()
                        self.landing = animstate.hit_in_ground_animation
                        self:set_peeking_state(me)
                    else
                        self:reset()
                    end
                end

                function BaseLocal:setup_command(cmd, me, wpn)
                    if not self.valid then
                        return self:reset(true)
                    end

                    self.entindex = me
                    self.alive = entity.is_alive(self.entindex)

                    if cmd.chokedcommands == 0 then
                        self.packets = self.packets + 1

                        c_grams.update_gram(self.fakeamount_gram, c_math.abs(self.fakeyaw), 8)

                        self.smooth_fakeamount = c_grams.average(self.fakeamount_gram)
                        self.server_fakeyaw = entity.get_prop(me, 'm_flPoseParameter', 11) * 120 - 60
                        self.weapon_type = self:get_weapon_type(wpn)
                        self.use_needed = self:is_use_needed(wpn)
                    end
                end

                function BaseLocal:finish_command(cmd, me, wpn)
                    local command = ffi_helpers.user_input:get_command(cmd.command_number)

                    if command then
                        if cmd.chokedcommands == 0 and self._last_yaw then
                            local cheat_dsy = c_math.normalize_yaw(self._last_yaw - command.view[1])

                            self.fakeyaw = -(cheat_dsy > 0 and cheat_dsy - 60 or cheat_dsy + 60)
                        elseif cmd.chokedcommands ~= 0 then
                            self._last_yaw = command.view[1]
                        end
                    end
                end

                function BaseLocal:net_update_end()
                    if not self.valid then
                        return self:reset(true)
                    end

                    if self.alive then
                        self.defensive_active = self:get_defensive()
                    end
                end

                function BaseLocal:paint_ui()
                    local me = entity.get_local_player()

                    self.valid = me ~= nil

                    if me then
                        self.entindex = me
                        self.alive = entity.is_alive(me)
                    end
                end
            end

            --- Create player object
            ---@return table
            create_player = function ()
                return setmetatable({
                    valid = false,
                    entindex = -1,
                    packets = 0,
                    onground = true,
                    velocity = vector(),
                    speed = 0.0,
                    duckamount = 0.0,
                    stamina = 80.0,
                    velocity_modifier = 1.0,
                    fakeyaw = 0.0,
                    server_fakeyaw = 0.0,
                    smooth_fakeamount = 0.0,
                    fakeamount_gram = {},
                    state = 'Standing',
                    defensive_active = false,
                    defensive_predict = false,
                    use_needed = false,
                    weapon_type = nil,
                    landing = false,
                    peeking = false,
                    freestanding_side = 'none',
                    air_exploit = false,
                    _shifting_enough = false
                }, {
                    __index = BaseLocal
                })
            end
        end

        player = create_player()
    end

    --- Fakelag
    local fakelag do
        config.fakelag = {} do
            config.fakelag.enable = menu.new_item(ui.new_checkbox, "AA", "Fake lag", "Custom fakelag")
                :record("fakelag", "enable")
                :save()

            config.fakelag.type = menu.new_item(ui.new_combobox, "AA", "Fake lag", "Custom fakelag: Type", {
                "Cycle",
                "Randomize"
            }):record("fakelag", "type"):save()

            config.fakelag.ticks = menu.new_item(ui.new_slider, "AA", "Fake lag", "Custom fakelag: Ticks", 1, 15, 15, true, "t", 1)
                :record("fakelag", "ticks")
                :save()
        end

        fakelag = {} do
            fakelag.choking = false
            fakelag.last_choke = 0
            fakelag.choke_count = 0
            fakelag.tick = 0
            fakelag.reset = false

            fakelag.setup_command = function (self, cmd, me, wpn)
                if config.fakelag.enable:get() then
                    local max_limit = 15
                    local fakeduck_active = ui.get(reference.ragebot.fakeduck)
                    local onshot_active = c_table.is_hotkey_active(reference.misc.onshot_antiaim)
                    local doubletap_active = c_table.is_hotkey_active(reference.ragebot.doubletap.enable)

                    local type = config.fakelag.type:get()
                    local limit = config.fakelag.ticks:get()

                    if type == 'Cycle' then
                        limit = c_math.clamp(limit - self.tick % 5, 1, 15)
                    elseif type == 'Randomize' then
                        limit = c_math.clamp(limit - c_math.random(0, 5), 1, 15)
                    end

                    if player.peeking then
                        limit = 15
                    end

                    if fakeduck_active then
                        max_limit = 15
                    end

                    override.set(reference.fakelag.enable[1], max_limit ~= 1)
                    override.set(reference.fakelag.amount, player.weapon_type == 'grenade' and 'Dynamic' or 'Maximum')
                    override.set(reference.fakelag.limit, max_limit)
                    override.set(reference.fakelag.variance, 100)

                    local exploits_active = doubletap_active or onshot_active

                    if not exploits_active and player.weapon_type ~= 'grenade' and not fakeduck_active then
                        if cmd.chokedcommands < limit then
                            cmd.allow_send_packet = false
                        else
                            self.tick = self.tick + 1

                            cmd.no_choke = true
                        end
                    end

                    self.reset = false
                elseif not self.reset then
                    override.unset(reference.fakelag.enable[1]) 
                    override.unset(reference.fakelag.amount)
                    override.unset(reference.fakelag.limit)
                    override.unset(reference.fakelag.variance)

                    self.reset = true
                end

                if cmd.chokedcommands == 0 then
                    self.last_choke = self.choke_count
                    self.choke_count = 0;
                else
                    self.choke_count = self.choke_count + 1;
                end

                self.choking = self.last_choke >= 2;
            end
        end
    end

    --- Anti-aimbot angles

    local antiaimbot do
        antiaimbot = {}

        config.antiaimbot = {} do
            -- Main
            config.antiaimbot.main_label = menu.new_item(ui.new_label, "AA", "Anti-aimbot angles", "\aFF0000FFMain")
                :config_ignore()

            config.antiaimbot.options = menu.new_item(ui.new_multiselect, "AA", "Anti-aimbot angles", "AA: Modifications", {
                "On use antiaim",
                "Fast ladder",
                "Dormant preset"
            }):record("antiaimbot", "options"):save()
            
            config.antiaimbot.preset = menu.new_item(ui.new_combobox, "AA", "Anti-aimbot angles", "AA: Preset", {
                "PR0KLADKI",
                "Blossom",
                "Constructor"
            }):record("antiaimbot", "preset"):save()

            -- Defensive
            config.antiaimbot.defensive_aa = menu.new_item(ui.new_checkbox, "AA", "Anti-aimbot angles", "Defensive AA")
                :record("antiaimbot", "defensive_aa")
                :save()

            config.antiaimbot.force_target_yaw = menu.new_item(ui.new_checkbox, "AA", "Anti-aimbot angles", "Defensive AA: Force target yaw")
                :record("antiaimbot", "force_target_yaw")
                :save()

            config.antiaimbot.defensive_target = menu.new_item(ui.new_multiselect, "AA", "Anti-aimbot angles", "Defensive AA: Target", {
                "Double tap",
                "On shot anti-aim"
            }):record("antiaimbot", "defensive_target"):save()

            config.antiaimbot.defensive_conditions = menu.new_item(ui.new_multiselect, "AA", "Anti-aimbot angles", "Force defensive: States", c_constant.STATE_LIST)
                :record("antiaimbot", "defensive_conditions")
                :save()
        
            config.antiaimbot.defensive_triggers = menu.new_item(ui.new_multiselect, "AA", "Anti-aimbot angles", "Defensive AA: Trigger", {
                "Flashed",
                "Damage received",
                "Reloading",
                "Weapon switch"
            }):record("antiaimbot", "defensive_triggers"):save()

            config.antiaimbot.defensive_preset = menu.new_item(ui.new_combobox, "AA", "Anti-aimbot angles", "Defensive AA: Preset", {
                "Auto",
                "Constructor"
            }):record("antiaimbot", "defensive_preset"):save()

            config.antiaimbot.defensive_conditions_auto = menu.new_item(ui.new_multiselect, "AA", "Anti-aimbot angles", "Defensive AA: Conditions\n AUTO", c_table.combine_arrays(c_constant.DEFENSIVE_STATES, c_constant.STATE_LIST))
                :record("antiaimbot", "defensive_conditions_auto")
                :save()

            -- Misc
            config.antiaimbot.misc_label = menu.new_item(ui.new_label, "AA", "Fake lag", "\aFF0000FFMiscellaneous")
                :config_ignore()

            config.antiaimbot.safe_head = menu.new_item(ui.new_checkbox, "AA", "Fake lag", "Safe head")
                :record("antiaimbot", "safe_head")
                :save()

            config.antiaimbot.safe_head_conditions = menu.new_item(ui.new_multiselect, "AA", "Fake lag", "Safe head: Conditions", {
                "Air knife",
                "Air zeus",
                "Air & Crouch",
                "Crouch moving",
                "Crouching",
                "Slow-motion",
                "Standing"
            }):record("antiaimbot", "safe_head_conditions"):save()

            config.antiaimbot.warmup_aa = menu.new_item(ui.new_checkbox, "AA", "Fake lag", "Warmup AA")
                :record("antiaimbot", "warmup_aa")
                :save()

            config.antiaimbot.warmup_aa_conditions = menu.new_item(ui.new_multiselect, "AA", "Fake lag", "Warmup AA: Conditions", {
                "Warmup",
                "Round end"
            }):record("antiaimbot", "warmup_aa_conditions"):save()

            config.antiaimbot.animation_breaker = menu.new_item(ui.new_checkbox, "AA", "Fake lag", "Animation breaker")
                :record("antiaimbot", "animation_breaker")
                :save()

            config.antiaimbot.animation_breaker_leg = menu.new_item(ui.new_combobox, "AA", "Fake lag", "Animation breaker: Leg movement", {
                "Off",
                "Frozen",
                "Walking",
                "Sliding",
                "Jitter"
            }):record("antiaimbot", "animation_breaker_leg"):save()

            
            config.antiaimbot.animation_breaker_air = menu.new_item(ui.new_combobox, "AA", "Fake lag", "Animation breaker: In air", {
                "Off",
                "Frozen",
                "Walking"
            }):record("antiaimbot", "animation_breaker_air"):save()

            config.antiaimbot.animation_breaker_other = menu.new_item(ui.new_multiselect, "AA", "Fake lag", "Animation breaker: Other", {
                "Slide on slow-motion",
                "Slide on crouching",
                "Quick peek legs",
                "Pitch zero on land"
            }):record("antiaimbot", "animation_breaker_other"):save()

            config.antiaimbot.air_exploit = menu.new_item(ui.new_checkbox, "AA", "Fake lag", "Air exploit")
                :record("antiaimbot", "air_exploit")
                :save()

            config.antiaimbot.air_exploit_hotkey = menu.new_item(ui.new_hotkey, "AA", "Fake lag", "\nair_exploit_hotkey", true)
                :record("antiaimbot", "air_exploit_hotkey")
                :save()

            config.antiaimbot.ideal_tick = menu.new_item(ui.new_checkbox, "AA", "Fake lag", "Ideal tick")
                :record("antiaimbot", "ideal_tick")
                :save()

            config.antiaimbot.ideal_tick_hotkey = menu.new_item(ui.new_hotkey, "AA", "Fake lag", "\nideal_tick_hotkey", true)
                :record("antiaimbot", "ideal_tick_hotkey")
                :save()
                
            config.antiaimbot.manual_yaw = menu.new_item(ui.new_checkbox, "AA", "Fake lag", "Manual yaw")
                :record("antiaimbot", "manual_yaw")
                :save()

            config.manuals = {
                menu.new_item(ui.new_hotkey, "AA", "Fake lag", "Bind: Left")
                    :record("manuals", "left")
                    :save(),
                menu.new_item(ui.new_hotkey, "AA", "Fake lag", "Bind: Right")
                    :record("manuals", "right")
                    :save(),
                menu.new_item(ui.new_hotkey, "AA", "Fake lag", "Bind: Backward")
                    :record("manuals", "backward")
                    :save(),
                menu.new_item(ui.new_hotkey, "AA", "Fake lag", "Bind: Forward")
                    :record("manuals", "forward")
                    :save(),
                menu.new_item(ui.new_hotkey, "AA", "Fake lag", "Bind: Reset")
                    :record("manuals", "reset")
                    :save()
            }

            config.antiaimbot.edge_yaw = menu.new_item(ui.new_hotkey, "AA", "Fake lag", "Bind: Edge yaw")
                :record("manuals", "edge")
                :save()

            config.antiaimbot.freestanding = menu.new_item(ui.new_hotkey, "AA", "Fake lag", "Bind: Freestanding")
                :record("manuals", "freestanding")
                :save()

            config.antiaimbot.manual_options = menu.new_item(ui.new_multiselect, "AA", "Fake lag", "Manual AA: Options", {
                "Jitter disabled",
            }):record("antiaimbot", "manual_options"):save()

            config.antiaimbot.fs_options = menu.new_item(ui.new_multiselect, "AA", "Fake lag", "Freestanding: Options", {
                "Jitter disabled",
            }):record("antiaimbot", "fs_options"):save()

            config.antiaimbot.freestanding_disabler_states = menu.new_item(ui.new_multiselect, "AA", "Fake lag", "Freestanding: Ignore", c_constant.STATE_LIST)
                :record("antiaimbot", "freestanding_disabler_states")
                :save()
        end

        do
            local create_antiaim, AntiAim do
                AntiAim = {} do
                    function AntiAim:reset()
                        override.unset(reference.antiaim.pitch.type)
                        override.unset(reference.antiaim.pitch.value)

                        override.unset(reference.antiaim.yaw.base)
                        override.unset(reference.antiaim.yaw.edge)

                        override.unset(reference.antiaim.freestanding[1])
                        override.unset(reference.antiaim.freestanding[2])

                        override.unset(reference.antiaim.yaw.yaw.type)
                        override.unset(reference.antiaim.yaw.yaw.value)

                        override.unset(reference.antiaim.yaw.jitter.type)
                        override.unset(reference.antiaim.yaw.jitter.value)

                        override.unset(reference.antiaim.body.yaw.type)
                        override.unset(reference.antiaim.body.yaw.value)

                        override.unset(reference.antiaim.body.freestanding)
                    end

                    function AntiAim:tick()
                        self.pitch = nil
                        self.pitch_custom = nil
                        self.yaw_base = nil
                        self.edge_yaw = nil
                        self.freestand = nil
                        self.yaw_type = nil
                        self.yaw_offset = nil
                        self.yaw_modifier = nil
                        self.modifier_offset = nil
                        self.left_limit = nil
                        self.right_limit = nil
                        self.body_yaw_type = nil
                        self.body_yaw_value = nil
                        self.inverter = nil
                        self.body_yaw_freestanding = nil
                    end

                    function AntiAim:run()
                        local pitch = self.pitch or 'Minimal';
                        local pitch_value = self.pitch_custom or 89

                        override.set(reference.antiaim.pitch.type, pitch)
                        override.set(reference.antiaim.pitch.value, pitch_value)

                        local yaw_base = self.yaw_base or 'At targets'

                        override.set(reference.antiaim.yaw.base, yaw_base)

                        local edge_yaw = self.edge_yaw or false

                        override.set(reference.antiaim.yaw.edge, edge_yaw)

                        local freestanding = self.freestand or false

                        override.set(reference.antiaim.freestanding[1], freestanding)

                        if freestanding then
                            override.set(reference.antiaim.freestanding[2], 'Always on', 0x0)
                        else
                            override.set(reference.antiaim.freestanding[2], 'On hotkey', 0x0)
                        end

                        local yaw_type = self.yaw_type or '180'
                        local yaw_offset = self.yaw_offset or 0

                        override.set(reference.antiaim.yaw.yaw.type, yaw_type)
                        override.set(reference.antiaim.yaw.yaw.value, yaw_offset)

                        local yaw_modifier = self.yaw_modifier or 'Off'
                        local modifier_offset = self.modifier_offset or 0

                        override.set(reference.antiaim.yaw.jitter.type, yaw_modifier)
                        override.set(reference.antiaim.yaw.jitter.value, modifier_offset)

                        local left_limit, right_limit = self.left_limit or 58, self.right_limit or 58

                        local body_yaw_type = self.body_yaw_type or 'Static'
                        local body_yaw_value = self.inverter and -left_limit or right_limit

                        if self.body_yaw_type then
                            body_yaw_type = self.body_yaw_type
                            body_yaw_value = self.body_yaw_value or 0
                        end

                        override.set(reference.antiaim.body.yaw.type, body_yaw_type)
                        override.set(reference.antiaim.body.yaw.value, c_math.clamp(body_yaw_value, -1, 1))

                        local body_yaw_freestanding = self.body_yaw_freestanding or false

                        override.set(reference.antiaim.body.freestanding, body_yaw_freestanding)
                    end
                end

                function create_antiaim(initial)
                    return setmetatable(initial or {

                    }, {
                        __index = AntiAim
                    })
                end
            end

            antiaimbot.constructor = {}
            antiaimbot.defensive_constructor = {}

            antiaimbot.features = {} do
                antiaimbot.features.running = false

                antiaimbot.features.state = {
                    legit_antiaim = false,
                    safe_head = false,
                    vanish_mode = false,
                    warmup_antiaim = false,
                    manual_antiaim = false,
                    freestanding = false
                }

                antiaimbot.features.fast_ladder = {} do
                    local time_on_ladder = 0
                    local move_time = 0

                    function antiaimbot.features.fast_ladder.ladder_yaw(me)
                        local vx, vy = entity.get_prop(me, 'm_vecLadderNormal')

                        return vx == 1.0 and 180 or vx == -1.0 and 0 or vy == 1.0 and -90 or 90
                    end

                    function antiaimbot.features.fast_ladder.ladder_move(cmd, target_yaw)
                        if target_yaw == 0 then
                            return cmd.forwardmove > 0, cmd.forwardmove < 0, cmd.sidemove == 0, cmd.sidemove < 0, cmd.sidemove > 0
                        end

                        if target_yaw == 180 or target_yaw == -180 then
                            return cmd.forwardmove < 0, cmd.forwardmove > 0, cmd.sidemove == 0, cmd.sidemove > 0, cmd.sidemove < 0
                        end

                        if target_yaw == 90 then
                            return cmd.sidemove > 0, cmd.sidemove < 0, cmd.forwardmove == 0, cmd.forwardmove > 0, cmd.forwardmove < 0
                        end

                        if target_yaw == -90 then
                            return cmd.sidemove > 0, cmd.sidemove > 0, cmd.forwardmove == 0, cmd.forwardmove < 0, cmd.forwardmove > 0
                        end
                    end

                    function antiaimbot.features.fast_ladder:run(enabled, cmd, me, wpn)
                        if not enabled then
                            time_on_ladder = 0
                            move_time = 0

                            return
                        end

                        local throw_time = entity.get_prop(wpn, 'm_fThrowTime')
                        local angles = vector(client.camera_angles())

                        local ascending, descending = cmd.forwardmove > 0, cmd.forwardmove < 0
                        local moving_none, moving_left, moving_right = cmd.sidemove == 0, cmd.sidemove < 0, cmd.sidemove > 0

                        if ascending or descending or not moving_none then
                            move_time = move_time + 1
                        else
                            move_time = 0
                        end

                        if time_on_ladder < 1 then
                            time_on_ladder = time_on_ladder + 1
                        end

                        if move_time < 4 or time_on_ladder < 1 then
                            return
                        end

                        if cmd.in_jump == 1 then
                            return
                        end

                        if not wpn or (not throw_time or throw_time == 0) then
                            --local target_yaw = self.ladder_yaw(me)
                            --local closest_yaw = c_table.closest(c_math.normalize_yaw(cmd.yaw-target_yaw), {-180, -90, 0, 90, 180})
    --
                            --ascending, descending, moving_none, moving_left, moving_right = self.ladder_move(cmd, closest_yaw)
    --
                            --if ascending then
                            --    if angles.x < 45 then
                            --        cmd.pitch = 89
                            --        cmd.in_moveright = 1
                            --        cmd.in_moveleft = 0
                            --        cmd.in_forward = 0
                            --        cmd.in_back = 1
    --
                            --        if moving_none then
                            --            target_yaw = target_yaw + 90
                            --        end
    --
                            --        if moving_left then
                            --            target_yaw = target_yaw + 150
                            --        end
    --
                            --        if moving_right then
                            --            target_yaw = target_yaw + 30
                            --        end
                            --    end
                            --elseif descending then
                            --    cmd.pitch = 89
                            --    cmd.in_moveleft = 1
                            --    cmd.in_moveright = 0
                            --    cmd.in_forward = 1
                            --    cmd.in_back = 0
    --
                            --    if moving_none then
                            --        target_yaw = target_yaw + 90
                            --    end
    --
                            --    if moving_right then
                            --        target_yaw = target_yaw + 150
                            --    end
    --
                            --    if moving_left then
                            --        target_yaw = target_yaw + 30
                            --    end
                            --elseif moving_left or moving_right then
                            --    cmd.in_forward = 1
                            --    cmd.in_moveleft = 0
                            --    cmd.in_moveright = 0
                            --    cmd.in_back = 0
    --
                            --    target_yaw = target_yaw + (moving_left and 90 or -90)
                            --end
    --
                            --cmd.yaw = c_math.normalize_yaw(target_yaw)

                            if cmd.forwardmove > 0 then
                                if cmd.pitch < 45 then
                                    cmd.pitch = 89
                                    cmd.in_moveright = 1
                                    cmd.in_moveleft = 0
                                    cmd.in_forward = 0
                                    cmd.in_back = 1
                
                                    if cmd.sidemove == 0 then
                                        cmd.yaw = cmd.yaw + 90
                                    end
                
                                    if cmd.sidemove < 0 then
                                        cmd.yaw = cmd.yaw + 150
                                    end
                
                                    if cmd.sidemove > 0 then
                                        cmd.yaw = cmd.yaw + 30
                                    end
                                end
                            elseif cmd.forwardmove < 0 then
                                cmd.pitch = 89
                                cmd.in_moveleft = 1
                                cmd.in_moveright = 0
                                cmd.in_forward = 1
                                cmd.in_back = 0
                
                                if cmd.sidemove == 0 then
                                    cmd.yaw = cmd.yaw + 90
                                end
                
                                if cmd.sidemove > 0 then
                                    cmd.yaw = cmd.yaw + 150
                                end
                
                                if cmd.sidemove < 0 then
                                    cmd.yaw = cmd.yaw + 30
                                end
                            end

                            return true
                        end
                    end
                end

                antiaimbot.features.legit_antiaim = {} do
                    local use_time = 0

                    function antiaimbot.features.legit_antiaim.run(instance, cmd, me, wpn)
                        antiaimbot.features.state.legit_antiaim = false

                        if antiaimbot.features.state.running then
                            return 'Priority surpassed'
                        end

                        if not c_table.contains(config.antiaimbot.options:get(), 'On use antiaim') then
                            return 'Not enabled'
                        end

                        if player.weapon_type == 'grenade' then
                            return 'Grenade in hands'
                        end

                        if cmd.in_use == 0 then
                            use_time = 0

                            return 'Not in use'
                        end

                        use_time = use_time + 1

                        if not player.use_needed and use_time > 2 then
                            local preset do
                                local preset_name = config.antiaimbot.preset:get()

                                if preset_name == 'Constructor' then
                                    preset = antiaimbot.constructor
                                else
                                    preset = c_constant.antiaim_presets[preset_name]
                                end
                            end

                            if preset then
                                cmd.in_use = 0

                                antiaimbot.main.run_preset(instance, preset['Legit AA'])

                                antiaimbot.features.state.legit_antiaim = true
                                antiaimbot.features.running = true

                                return 'Legit antiaim is active'
                            end

                            return 'No preset'
                        end

                        return 'Use is needed'
                    end
                end

                antiaimbot.features.manual_antiaim = {} do
                    function antiaimbot.features.manual_antiaim.run(instance, cmd, me, wpn)
                        antiaimbot.features.state.manual_antiaim = false
                        antiaimbot.features.state.freestanding = false

                        if antiaimbot.features.running then
                            return 'Priority surpassed'
                        end

                        if not config.antiaimbot.manual_yaw:get() then
                            antiaimbot.manual_antiaim.state = -1

                            return 'Not enabled'
                        end

                        local state = antiaimbot.manual_antiaim.state
                        local m_options = config.antiaimbot.manual_options:get()
                        local fs_options = config.antiaimbot.fs_options:get()
                        local ignore_freestanding = c_table.contains(config.antiaimbot.freestanding_disabler_states:get(), player.state)

                        if state ~= -1 then
                            instance.yaw_base = 'Local view'

                            instance.yaw_type = '180'
                            instance.yaw_offset = antiaimbot.manual_antiaim.convert[antiaimbot.manual_antiaim.state]

                            antiaimbot.features.state.manual_antiaim = true
                        else
                            instance.edge_yaw, instance.freestand = config.antiaimbot.edge_yaw:rawget(), config.antiaimbot.freestanding:rawget() and not ignore_freestanding

                            antiaimbot.features.state.freestanding = instance.freestand
                        end

                        local fs_detected = instance.freestand and c_table.contains(fs_options, 'Jitter disabled')

                        -- mb

                        if state ~= -1 and c_table.contains(m_options, 'Jitter disabled') or fs_detected then
                            instance.yaw_modifier = 'Off'
                            instance.modifier_offset = 0

                            if player.fs_side ~= 'none' then
                                instance.body_yaw_type = 'Static'
                                instance.body_yaw_value = player.fs_side == 'left' and 1 or -1
                            end

                            if fs_detected then
                                instance.yaw_type = '180'
                                instance.yaw_offset = 0
                            end
                        end

                        if not (antiaimbot.features.state.manual_antiaim or antiaimbot.features.state.freestanding) then
                            return 'Inactive'
                        end

                        antiaimbot.features.running = true

                        return 'Manual antiaim is active'
                    end
                end

                antiaimbot.features.warmup_antiaim = {} do
                    function antiaimbot.features.warmup_antiaim.run(instance, cmd, me, wpn)
                        antiaimbot.features.state.warmup_antiaim = false

                        if antiaimbot.features.running then
                            return 'Priority surpassed'
                        end

                        if not config.antiaimbot.warmup_aa:get() then
                            return 'Not enabled'
                        end

                        local game_rules = entity.get_game_rules()

                        if not game_rules then
                            return 'CGameRules is invalid'
                        end

                        local warmup_period do
                            local is_active = c_table.contains(config.antiaimbot.warmup_aa_conditions:get(), 'Warmup')
                            local is_warmup = entity.get_prop(game_rules, 'm_bWarmupPeriod') == 1

                            warmup_period = is_active and is_warmup
                        end

                        if not warmup_period then
                            local player_resource = entity.get_player_resource()

                            if player_resource then
                                local are_all_enemies_dead = true

                                for i=1, globals.maxplayers() do
                                    if entity.get_prop(player_resource, 'm_bConnected', i) == 1 then
                                        if entity.is_enemy(i) and entity.is_alive(i) then
                                            are_all_enemies_dead = false

                                            break
                                        end
                                    end
                                end

                                warmup_period = are_all_enemies_dead and globals.curtime() < (entity.get_prop(game_rules, 'm_flRestartRoundTime') or 0)
                            end
                        end

                        if warmup_period then
                            instance.pitch = 'Off'

                            instance.yaw_base = 'At targets'

                            instance.yaw_type = '180'
                            instance.yaw_offset = c_animations:spin('warmup_spin', -180, 180, 1, 32).value

                            instance.yaw_modifier = 'Off'
                            --instance.body_yaw_type = 'Static'
                            --instance.body_yaw_value = 1

                            antiaimbot.features.state.warmup_antiaim = true
                            antiaimbot.features.running = true

                            return 'Warmup AA is active'
                        end

                        return 'Conditions was not met'
                    end
                end

                antiaimbot.features.safe_head = {} do
                    local resolve_classname = {
                        ['CKnife'] = 'Air knife',
                        ['CWeaponTaser'] = 'Air zeus'
                    }

                    antiaimbot.features.safe_head.trace_thread = (function (me, threat)
                        if threat then
                            local my_origin = vector(entity.get_origin(me))
                            local my_head = vector(entity.hitbox_position(me, 0))

                            if entity.is_alive(threat) then
                                --local ent_eyes = vector(entity.hitbox_position(threat, 0))
                                local ent_origin = vector(entity.get_origin(threat))
                                --local forward_against_me = vector():init_from_angles((ent_eyes - my_head):angles())
                                --local head_distance = (my_head - my_origin):length2d()
                                --local target_eyes = my_head + forward_against_me * (head_distance * 2 + 10)

                                --local menux, dmg = client.trace_bullet(threat, target_eyes.x, target_eyes.y, target_eyes.z, my_head.x, my_head.y, my_head.z)

                                do
                                    local target = c_math.extrapolate(threat, vector(entity.hitbox_position(threat, 0)), 5)
                                    local entindex, damage = client.trace_bullet(threat, target.x, target.y, target.z, my_head.x, my_head.y, my_head.z + 6)

                                    if -1 == entindex then
                                        damage = 0
                                    end

                                    return my_origin.z - ent_origin.z > 5 and damage > 0
                                end
                            end
                        end

                        return false
                    end)

                    function antiaimbot.features.safe_head.run(instance, cmd, me, wpn)
                        antiaimbot.features.state.safe_head = false

                        if antiaimbot.features.running then
                            return 'Priority surpassed'
                        end

                        if not config.antiaimbot.safe_head:get() then
                            return 'Not enabled'
                        end

                        local is_enabled = c_table.contains(config.antiaimbot.safe_head_conditions:get(), player.state)
                        local is_safe_head = false
                        local threat = client.current_threat()

                        do
                            if player.state:match('Air') and threat then
                                if wpn then
                                    local weapon_classname = entity.get_classname(wpn)

                                    if c_table.contains(config.antiaimbot.safe_head_conditions:get(), resolve_classname[weapon_classname]) then
                                        is_safe_head = true
                                    end
                                end
                            end
                        end

                        if not is_safe_head then
                            is_safe_head = antiaimbot.features.safe_head.trace_thread(me, threat)
                        end

                        if is_enabled and is_safe_head then
                            instance.pitch = 'Minimal'

                            instance.yaw_type = '180'
                            instance.yaw_base = 'At targets'
                            --instance.yaw_offset = yaw_o
                            instance.yaw_offset = 0
                            instance.yaw_modifier = 'Off'

                            --instance.body_yaw_type = 'Static'
                            --instance.body_yaw_value = -1

                            antiaimbot.features.state.safe_head = true
                            antiaimbot.features.running = true

                            return 'Safe head is running'
                        end

                        if not is_enabled then
                            return 'Not active'
                        end

                        return 'Conditions was not met'
                    end
                end

                antiaimbot.features.vanish_mode = {} do
                    local vanish_weapons = {
                        ['CKnife'] = true,
                        ['CWeaponTaser'] = true,
                        ['CSmokeGrenade'] = true,
                        ['CDecoyGrenade'] = true,
                        ['CHEGrenade'] = true,
                        ['CMolotovGrenade'] = true,
                        ['CIncendiaryGrenade'] = true
                    }

                    function antiaimbot.features.vanish_mode.run(instance, cmd, me, wpn)
                        antiaimbot.features.state.vanish_mode = false

                        if antiaimbot.features.running then
                            return 'Priority surpassed'
                        end

                        if not c_table.contains(config.antiaimbot.options:get(), 'Dormant preset') then
                            return 'Not enabled'
                        end

                        local threat = client.current_threat();

                        if not threat or not entity.is_alive(threat) then
                            return 'Threat is invalid';
                        end

                        local threat_wpn = entity.get_player_weapon(threat);

                        if threat_wpn then
                            local wpn_classname = entity.get_classname(threat_wpn)
                            local can_hit
                            local esp_data = entity.get_esp_data(threat)

                            if esp_data then
                                can_hit = bit.band(esp_data.flags, 2048) ~= 0
                            end

                            if vanish_weapons[wpn_classname] or (entity.is_dormant(threat) and not can_hit) then
                                instance.pitch = 'Minimal'

                                instance.yaw_type = '180'
                                instance.yaw_base = 'At targets'
                                instance.yaw_offset = player.fakeyaw > 0 and 5 or -7
                                instance.yaw_modifier = 'Off'

                                -- < p >
                                instance.body_yaw_type = 'Jitter'
                                instance.body_yaw_value = -1

                                antiaimbot.features.state.vanish_mode = true
                                antiaimbot.features.running = true

                                return 'Vanish mode is running'
                            else
                                return 'Threat weapon invalid/Unsafe dormant state'
                            end
                        else
                            return 'Threat weapon is invalid'
                        end
                    end
                end

                antiaimbot.features.avoid_backstab = {} do
                    function antiaimbot.features.avoid_backstab.run(instance, cmd, me, wpn)
                        local my_origin = vector(entity.get_origin(me))

                        local player_list = entity.get_players(true)
                        local player_cnt = #player_list

                        local closest_dist, closest_yaw = math.huge, nil

                        for i=1, player_cnt do
                            local ent = player_list[i]
                            local weapon = entity.get_player_weapon(ent)
                            local player_origin = vector(entity.hitbox_position(ent, 2))
                            local distance = my_origin:dist(player_origin)
                            --local visible = client.visible(player_origin:unpack())

                            if distance < 350 and weapon ~= nil then
                                local weapon_info = csgo_weapons(weapon)

                                if weapon_info.is_melee_weapon then
                                    if distance < closest_dist then
                                        local _, yaw_to_target = (player_origin - my_origin):angles()

                                        closest_yaw = yaw_to_target
                                        closest_dist = distance
                                    end
                                end
                            end
                        end

                        if closest_yaw then
                            instance.yaw_type = 'Static'
                            instance.yaw_offset = c_math.normalize_yaw(closest_yaw)

                            return true, 'Avoid backstab is active'
                        end

                        return false, 'No target'
                    end
                end
            end

            -- refactor
            antiaimbot.defensive = {} do
                local presets = c_constant.defensive_presets['Auto']

                function antiaimbot.defensive.is_exploit_ready_and_active(wpn)
                    local fakeduck_active = ui.get(reference.ragebot.fakeduck)
                    local onshot_active = c_table.is_hotkey_active(reference.misc.onshot_antiaim)
                    local doubletap_active = c_table.is_hotkey_active(reference.ragebot.doubletap.enable)

                    if fakeduck_active or not (onshot_active or doubletap_active) or doubletap_active and not player:get_double_tap() then
                        return false
                    end

                    if wpn then
                        local wpn_info = csgo_weapons(wpn)

                        if wpn_info then
                            if wpn_info.is_revolver then
                                return false
                            end
                        end
                    end

                    return true
                end


                function antiaimbot.defensive.force(cmd, me, wpn)
                    if not config.antiaimbot.defensive_aa:get() then
                        return false
                    end

                    if not antiaimbot.defensive.is_exploit_ready_and_active(wpn) then
                        return false
                    end

                    local conditions_met = true do
                        local doubletap_active = c_table.is_hotkey_active(reference.ragebot.doubletap.enable)
                        local hideshots_active = c_table.is_hotkey_active(reference.misc.onshot_antiaim) and not doubletap_active
                        local defensive_target = config.antiaimbot.defensive_target:get()

                        if doubletap_active and not c_table.contains(defensive_target, "Double tap") then
                            conditions_met = false
                        elseif hideshots_active and not c_table.contains(defensive_target, "On shot anti-aim") then
                            conditions_met = false
                        end
                    end

                    if not conditions_met then
                        return false
                    end

                    local defensive_check = c_table.contains(config.antiaimbot.defensive_conditions:get(), player.state)

                    local defensive_triggers = config.antiaimbot.defensive_triggers:get()
                    local defensive_triggered

                    local animlayers = ffi_helpers.animlayers:get(me)

                    if not animlayers then
                        return false
                    end

                    local weapon_activity_number = ffi_helpers.activity:get(animlayers[1]['sequence'], me)
                    local flash_activity_number = ffi_helpers.activity:get(animlayers[9]['sequence'], me)
                    local is_reloading = animlayers[1]['weight'] ~= 0.0 and weapon_activity_number == 967
                    local is_flashed = animlayers[9]['weight'] > 0.1 and flash_activity_number == 960
                    local is_under_attack = animlayers[10]['weight'] > 0.1
                    local is_swapping_weapons = cmd.weaponselect > 0

                    if c_table.contains(defensive_triggers, 'Flashed') and is_flashed
                    or c_table.contains(defensive_triggers, 'Damage received') and is_under_attack
                    or c_table.contains(defensive_triggers, 'Reloading') and is_reloading
                    or c_table.contains(defensive_triggers, 'Weapon switch') and is_swapping_weapons then
                        defensive_triggered = true
                    end

                    if defensive_check or defensive_triggered then
                        cmd.force_defensive = 1

                        return true, defensive_triggered
                    end

                    return false
                end

                function antiaimbot.defensive.get_preset(wpn, forcing, triggered)
                    local is_auto = config.antiaimbot.defensive_preset:get() == 'Auto'
                    local preset_data = is_auto and presets or antiaimbot.defensive_constructor

                    if not preset_data then
                        return false
                    end
                    
                    local state_selected = antiaimbot.features.state.legit_antiaim and 'Legit AA' or player.state
                    local is_active = preset_data[state_selected] ~= nil

                    if player.peeking then
                        if (not is_active or preset_data[state_selected].global_set) and preset_data["On peek"] then
                            state_selected = 'On peek'
                            is_active = true
        
                            forcing = true
                        end
                    end

                    if not forcing then
                        return false
                    end

                    local custom_states = {
                        ['freestanding'] = {'Edge direction', 'Freestanding'},
                        ['manual_antiaim'] = {'Edge direction', 'Manual yaw'},
                        ['safe_head'] = {'Safe head'},
                        [ triggered ] = {'Triggered'}
                    }

                    for feature, data in next, custom_states, nil do
                        if feature == true or antiaimbot.features.state[feature] then
                            local state = data[1]
                            local preset_active = preset_data[state]

                            if preset_active and data[2] then
                                preset_active = preset_active and c_table.contains(preset_active.enable_on, data[2])
                            end

                            state_selected = state
                            is_active = preset_active ~= nil
                        end
                    end

                    if is_auto then
                        is_active = c_table.contains(config.antiaimbot.defensive_conditions_auto:get(), state_selected)
                    end

                    local this

                    if state_selected == 'Safe head' or state_selected == 'Edge direction' or state_selected == 'Triggered' then
                        this = presets[state_selected]
                    else
                        this = preset_data[state_selected]
                    end

                    if not this then
                        return false
                    end

                    return is_active, this, state_selected
                end

                local flicker = false
                local last_flick_at = 0

                local three_way = {
                    90,
                    180,
                    -90,
                    180,
                    90
                }

                local scissor_way = 0
                local last_scissor = 0

                function antiaimbot.defensive.get_scissor_offset(way, state)
                    local target_way = way % 6

                    local left do
                        local from = c_math.min(state.yaw_left_start, state.yaw_left_target)
                        local to = c_math.max(state.yaw_left_start, state.yaw_left_target)
                        local step = (to - from) / 12

                        left = from + step / 2 * target_way
                    end

                    local right do
                        local from = c_math.min(state.yaw_right_start, state.yaw_right_target)
                        local to = c_math.max(state.yaw_right_start, state.yaw_right_target)
                        local step = (to - from) / 12

                        right = from + step / 2 * target_way
                    end

                    return way % 2 == 0 and left or right
                end

                function antiaimbot.defensive:run(instance, cmd, me, wpn, forcing, triggered)
                    if antiaimbot.features.state.vanish_mode or antiaimbot.features.state.warmup_antiaim then
                        return false, 'Overrided by superior features'
                    end

                    if not antiaimbot.defensive.is_exploit_ready_and_active(wpn) then
                        return false, 'Exploit is invalid'
                    end

                    local is_active, this, state = self.get_preset(wpn, forcing or false, triggered or false)

                    if not is_active or not this then
                        return false, 'Preset is invalid'
                    end

                    local game_rules = entity.get_game_rules()

                    if game_rules and entity.get_prop(game_rules, 'm_bFreezePeriod') == 1 or cmd.in_use == 1 then
                        return false, 'Player state is invalid'
                    end

                    local pitch_mode = this.pitch
                    local yaw_mode = this.yaw

                    local pitch = ({
                        ['Up'] = -88,
                        ['Zero'] = 0,
                        ['Up Switch'] = c_math.random(-45, -65),
                        ['Down Switch'] = c_math.random(45, 65),
                        ['Random'] = c_math.random(-89, 89),
                        ['Custom'] = this.pitch_custom
                    })[pitch_mode]

                    local yaw = ({
                        ['Forward'] = c_math.normalize_yaw(180 + c_math.random(-30, 30)),
                        ['3-Way'] = c_math.normalize_yaw(three_way[player.packets % 5 + 1] + c_math.randomf(-15, 15)),
                        ['5-Way'] = c_math.normalize_yaw(({ 90, 135, 180, 225, 270 })[player.packets % 5 + 1] + c_math.randomf(-15, 15)),
                        ['Random'] = c_math.random(-180, 180)
                    })[yaw_mode]

                    if yaw_mode == 'Sideways' then
                        local sideways_y = c_animations:flick('sideways_y', -90, 90, 2)

                        yaw = c_math.normalize_yaw(sideways_y.value + client.random_int(-15, 15))
                    end

                    if yaw_mode == 'Spinbot' then
                        local randomize = this.yaw_randomize or 0
                        local spinbot_y = c_animations:spin(string.format('spinbot_y_%s', state), this.yaw_from, this.yaw_to, 1, this.yaw_speed)

                        yaw = c_math.normalize_yaw(spinbot_y.value + client.random_int(-randomize, randomize))
                    end

                    if yaw_mode == 'Delayed' then
                        local yaw_delay = this.yaw_delay or 1
                        local randomize = this.yaw_randomize or 0

                        if player.packets - last_flick_at >= yaw_delay then
                            flicker = not flicker

                            last_flick_at = player.packets
                        end

                        yaw = flicker and this.yaw_left or this.yaw_right

                        if randomize ~= 0 then
                            yaw = yaw + (yaw > 0 and 1 or -1) * client.random_int(0, randomize)
                        end
                    end

                    if yaw_mode == 'Scissors' then
                        local yaw_delay = this.yaw_delay or 1
                        local randomize = this.yaw_randomize or 0

                        if player.packets - last_scissor > yaw_delay then
                            scissor_way = scissor_way + 1
                            last_scissor = player.packets
                        end

                        yaw = self.get_scissor_offset(scissor_way, this) + client.random_int(0, randomize)
                    end

                    local _, view_angle_yaw = client.camera_angles()

                    view_angle_yaw = player:threat_yaw(me) or view_angle_yaw
                    view_angle_yaw = view_angle_yaw - 180

                    if globals.absoluteframetime() < globals.tickinterval() and not client.key_state(0x1) then
                        if forcing and config.antiaimbot.force_target_yaw:get() and state ~= 'On peek' and not antiaimbot.features.state.manual_antiaim then
                            instance.yaw_type = '180'
                            instance.yaw_offset = player.fakeyaw > 0 and 6 or -9

                            instance.body_yaw_type = 'Static'
                            instance.body_yaw_value = player.fs_side == 'left' and 1 or -1
                            instance.inverter = player.fs_side == 'right'
                        end

                        --if player.defensive_active then CHECKME DEFENSIVE
                        if player.defensive_predict then
                            if pitch_mode ~= 'Default' then
                                cmd.pitch = c_math.clamp(pitch, -89, 89)
                            end

                            if yaw_mode ~= 'Default' then
                                cmd.yaw = c_math.normalize_yaw(view_angle_yaw-yaw)
                            end

                            return true
                        else
                            return false, 'Defensive is inactive'
                        end
                    end

                    return false, 'Overrided by left mouse'
                end
            end

            antiaimbot.main = {} do
                local presets = c_constant.antiaim_presets
                local instance = create_antiaim()

                local antiaim_state = {
                    switch = false,
                    swap = false,
                    delay = 0,
                    last_switch = 0,
                    last_packets = 0,
                    step = 1
                }

                function antiaimbot.main.run_preset(instance, data)
                    local yaw_side = player.fakeyaw > 0 and 'left' or 'right'

                    instance.pitch = data.pitch
                    instance.pitch_custom = data.pitch_custom

                    instance.yaw_base = data.yaw_base

                    local yaw_type = data.yaw_type or '180'
                    local yaw = data.yaw_offset or 0

                    -- < yaw >
                    local can_force_body_yaw = true
                    local inverter = false
                    local yaw_modifier = data.yaw_modifier or 'Off'
                    local modifier_offset = data.modifier_offset or 0

                    if yaw_type ~= '180' then
                        if yaw_type == 'Left & Right' then
                            local left_offset = type(data.left_offset) == 'table' and client.random_int(data.left_offset[1], data.left_offset[2]) or data.left_offset
                            local right_offset = type(data.right_offset) == 'table' and client.random_int(data.right_offset[1], data.right_offset[2]) or data.right_offset

                            if data.yaw_delay ~= nil then
                                if player.packets - antiaim_state.last_packets >= antiaim_state.delay then
                                    antiaim_state.delay = client.random_int(c_math.min(data.yaw_delay, data.yaw_delay_second), c_math.max(data.yaw_delay, data.yaw_delay_second))
                                    antiaim_state.switch = not antiaim_state.switch
                                    antiaim_state.last_packets = player.packets
                                end

                                inverter = antiaim_state.switch
                                yaw_side = inverter and 'left' or 'right'
                                can_force_body_yaw = false
                            end

                            yaw_type = '180'
                            yaw = yaw_side == 'left' and left_offset or right_offset
                        end

                        if yaw_type == 'Flick' then
                            yaw_type = '180'
                            yaw = c_animations:flick(string.format('Flick%s', player.state), data.left_offset, data.right_offset, data.yaw_delay).value
                        end

                        if yaw_type == 'Sway' then
                            yaw_type = '180'
                            yaw = c_animations:sway(string.format('Sway%s', player.state), data.left_offset, data.right_offset, data.yaw_delay, data.yaw_speed).value
                        end

                        if yaw_type == 'Spin between' then
                            yaw_type = '180'
                            yaw = c_animations:spin(string.format('Spin%s', player.state), data.left_offset, data.right_offset, data.yaw_delay, data.yaw_speed).value
                        end
                    end

                    instance.yaw_type = yaw_type
                    instance.yaw_offset = c_math.normalize_yaw(yaw)

                    -- < yaw modifier >
                    local yaw_modifier_randomize = data.modifier_randomize

                    if yaw_modifier_randomize then
                        if yaw_modifier_randomize > 0 then
                            modifier_offset = client.random_int(modifier_offset-yaw_modifier_randomize, modifier_offset+yaw_modifier_randomize)
                        else
                            modifier_offset = client.random_int(modifier_offset+yaw_modifier_randomize, modifier_offset-yaw_modifier_randomize)
                        end
                    end

                    instance.yaw_modifier = yaw_modifier
                    instance.modifier_offset = c_math.normalize_yaw(modifier_offset)

                    -- < fake >
                    local left_limit = data.left_limit or 58
                    local right_limit = data.right_limit or 58

                    instance.left_limit = left_limit
                    instance.right_limit = right_limit
                    instance.inverter = inverter

                    if can_force_body_yaw then
                        instance.body_yaw_type = data.body_yaw_type
                        instance.body_yaw_value = data.body_yaw_value
                    end

                    instance.body_yaw_freestanding = data.body_yaw_freestanding
                end

                antiaimbot.main.debug = {}

                function antiaimbot.main:run(cmd, me, wpn)
                    instance:tick()

                    -- temp
                    antiaimbot.main.debug.player_exploit = player.air_exploit

                    if antiaimbot.air_exploit.run(
                        config.antiaimbot.air_exploit:get() and config.antiaimbot.air_exploit_hotkey:rawget(), cmd
                    ) then
                        return instance:run()
                    end

                    local player_state = player.state

                    local is_fakelagging = not (c_table.is_hotkey_active(reference.ragebot.doubletap.enable) or c_table.is_hotkey_active(reference.misc.onshot_antiaim))

                    if is_fakelagging or cmd.chokedcommands == 0 then
                        c_animations:tick(globals.tickcount())
                    end

                    local selected_preset = config.antiaimbot.preset:get() do
                        if selected_preset == 'Constructor' then
                            local preset_data = antiaimbot.constructor[player_state]
                            local fakelag_preset = antiaimbot.constructor['Fake lag']

                            if is_fakelagging and fakelag_preset then
                                preset_data = fakelag_preset
                            end

                            if preset_data then
                                self.run_preset(instance, preset_data)
                            end
                        else
                            local preset_data = presets[selected_preset][player_state]
                            local fakelag_preset = presets[selected_preset]['Fake lag']

                            if is_fakelagging and fakelag_preset then
                                preset_data = fakelag_preset
                            end

                            if preset_data then
                                self.run_preset(instance, preset_data)
                            end
                        end
                    end

                    antiaimbot.main.debug.preset = selected_preset

                    local move_type = entity.get_prop(me, 'm_MoveType')
                    local selected_options = config.antiaimbot.options:get()

                    local is_forcing, triggered_defensive = antiaimbot.defensive.force(cmd, me, wpn)

                    antiaimbot.main.debug.state = {
                        fakelag = is_fakelagging,
                        choking = fakelag.choking,
                        state = player_state
                    }

                    antiaimbot.main.debug.defensive = {
                        forcing = is_forcing,
                        triggered = triggered_defensive
                    }

                    if not antiaimbot.features.fast_ladder:run(
                        c_table.contains(selected_options, 'Fast ladder') and move_type == 9, cmd, me, wpn
                    ) and move_type ~= 9 then
                        antiaimbot.features.running = false

                        antiaimbot.main.debug.legit_antiaim = antiaimbot.features.legit_antiaim.run(instance, cmd, me, wpn)
                        antiaimbot.main.debug.manual_antiaim = antiaimbot.features.manual_antiaim.run(instance, cmd, me, wpn)
                        antiaimbot.main.debug.warmup_antiaim = antiaimbot.features.warmup_antiaim.run(instance, cmd, me, wpn)
                        antiaimbot.main.debug.safe_head = antiaimbot.features.safe_head.run(instance, cmd, me, wpn)
                        antiaimbot.main.debug.vanish_mode = antiaimbot.features.vanish_mode.run(instance, cmd, me, wpn)

                        local avoid_backstab = antiaimbot.features.avoid_backstab.run(instance, cmd, me, wpn)

                        antiaimbot.main.debug.avoid_backstab = avoid_backstab

                        if config.antiaimbot.defensive_aa:get() and not avoid_backstab then
                            antiaimbot.main.debug.defensive = {antiaimbot.defensive:run(instance, cmd, me, wpn, is_forcing, triggered_defensive or false)}
                        end
                    end

                    antiaimbot.ideal_tick.run()

                    instance:run()
                end

                function antiaimbot.main.get_instance()
                    return instance
                end
            end

            antiaimbot.animation_breaker = {} do
                antiaimbot.animation_breaker.anim_reset = false

                function antiaimbot.animation_breaker.run(me)
                    local leg_move = config.antiaimbot.animation_breaker_leg:get()
                    local animlayers = ffi_helpers.animlayers:get(me)

                    if not animlayers then
                        return
                    end

                    if leg_move ~= 'Off' and player.onground and (player.state == 'Moving' or player.state == 'Crouch moving') then
                        if leg_move == 'Frozen' then
                            entity.set_prop(me, 'm_flPoseParameter', 1, 0)
                            override.set(reference.misc.leg_movement, "Always slide")
                        elseif leg_move == 'Jitter' and player.state == 'Moving' then
                            entity.set_prop(me, 'm_flPoseParameter', client.random_float(0, 1), 0)
                            animlayers[12]['weight'] = client.random_float(0, 1)
                            override.set(reference.misc.leg_movement, "Always slide")
                        elseif leg_move == 'Walking' then
                            entity.set_prop(me, 'm_flPoseParameter', 0.5, 7)
                            override.set(reference.misc.leg_movement, "Never slide")
                        elseif leg_move == 'Sliding' and player.state == 'Moving' then
                            entity.set_prop(me, 'm_flPoseParameter', 0, 9)
                            entity.set_prop(me, 'm_flPoseParameter', 0, 10)
                            override.set(reference.misc.leg_movement, "Never slide")
                        else
                            override.unset(reference.misc.leg_movement)
                        end
                    else
                        override.unset(reference.misc.leg_movement)
                    end

                    local air_legs = config.antiaimbot.animation_breaker_air:get()
                    local move_type = entity.get_prop(me, 'm_MoveType')

                    if air_legs ~= 'Off' and not player.onground and not (move_type == 9 or move_type == 8) then
                        if air_legs == 'Frozen' then
                            entity.set_prop(me, 'm_flPoseParameter', 1, 6)
                        elseif air_legs == 'Walking' then
                            local cycle do
                                cycle = globals.realtime() * 0.7 % 2

                                if cycle > 1 then
                                    cycle = 1 - (cycle - 1)
                                end
                            end

                            animlayers[6]['weight'] = 1
                            animlayers[6]['cycle'] = cycle
                        end
                    end

                    local breaker_options = config.antiaimbot.animation_breaker_other:get()

                    if c_table.contains(breaker_options, 'Slide on slow-motion') and c_table.is_hotkey_active(reference.misc.slowmotion) then
                        entity.set_prop(me, 'm_flPoseParameter', 0, 9)
                    end

                    if c_table.contains(breaker_options, 'Slide on crouching') and (player.state == 'Crouching' or player.state == 'Crouch moving') then
                        entity.set_prop(me, 'm_flPoseParameter', 0, 8)
                    end

                    if c_table.contains(breaker_options, 'Pitch zero on land') and player.landing and player.onground then
                        entity.set_prop(me, 'm_flPoseParameter', 0.5, 12)
                    end
                end


                function antiaimbot.animation_breaker.post(cmd, me)
                    if c_table.contains(config.antiaimbot.animation_breaker_other:get(), 'Quick peek legs') and c_table.is_hotkey_active(reference.ragebot.quick_peek_assist) then
                        local move_type = entity.get_prop(me, 'm_MoveType')

                        if move_type == 2 then
                            local command = ffi_helpers.user_input:get_command(cmd.command_number)

                            if command then
                                command.buttons = bit.band(command.buttons, bit.bnot(8))
                                command.buttons = bit.band(command.buttons, bit.bnot(16))
                                command.buttons = bit.band(command.buttons, bit.bnot(512))
                                command.buttons = bit.band(command.buttons, bit.bnot(1024))
                            end
                        end
                    end
                end
            end

            antiaimbot.air_exploit = {} do
                local exploit_counter = 1

                function antiaimbot.air_exploit.run(enabled, cmd)
                    player.air_exploit = enabled

                    if not enabled then
                        if not antiaimbot.air_exploit.lag_reset then
                            override.unset(reference.ragebot.fakeduck)
                            antiaimbot.air_exploit.lag_reset = true
                        end

                        return
                    end

                    if player.onground or not c_table.is_hotkey_active(reference.ragebot.doubletap.enable) then
                        override.unset(reference.ragebot.fakeduck)

                        return
                    end

                    if globals.tickcount() % 2 == 1 then
                        exploit_counter = exploit_counter + 1
                    end

                    if exploit_counter > 2 then
                        override.set(reference.ragebot.fakeduck, "Always on")

                        exploit_counter = 1
                    else
                        override.set(reference.ragebot.fakeduck, "On hotkey", 0x0)
                    end

                    antiaimbot.air_exploit.lag_reset = false

                    return true
                end
            end

            antiaimbot.ideal_tick = {} do
                local ideal_tick_reset

                function antiaimbot.ideal_tick.run()
                    if config.antiaimbot.ideal_tick:get() and config.antiaimbot.ideal_tick_hotkey:get() then
                        override.set(reference.ragebot.quick_peek_assist[1], true)
                        override.set(reference.ragebot.quick_peek_assist[2], "Always on", 0x0)

                        override.set(reference.ragebot.enable[1], true)
                        override.set(reference.ragebot.enable[2], "Always on", 0x0)

                        antiaimbot.features.state.freestanding = true

                        ideal_tick_reset = true
                    else
                        if ideal_tick_reset then
                            override.unset(reference.ragebot.quick_peek_assist[1])
                            override.unset(reference.ragebot.quick_peek_assist[2])
        
                            override.unset(reference.ragebot.enable[1])
                            override.unset(reference.ragebot.enable[2])

                            ideal_tick_reset = false
                        end
                    end
                end
            end

            antiaimbot.manual_antiaim = {} do
                local list = {}

                antiaimbot.manual_antiaim.state = -1
                antiaimbot.manual_antiaim.MANUAL_LEFT = 1
                antiaimbot.manual_antiaim.MANUAL_RIGHT = 2
                antiaimbot.manual_antiaim.MANUAL_BACK = 3
                antiaimbot.manual_antiaim.MANUAL_FORWARD = 4

                antiaimbot.manual_antiaim.convert = {
                    [antiaimbot.manual_antiaim.MANUAL_LEFT] = -90,
                    [antiaimbot.manual_antiaim.MANUAL_RIGHT] = 90,
                    [antiaimbot.manual_antiaim.MANUAL_BACK] = 0,
                    [antiaimbot.manual_antiaim.MANUAL_FORWARD] = 180
                }

                for i=1, #config.manuals do
                    list[#list+1] = {
                        prev = false,
                        ref = config.manuals[i],

                        change = function (self, new_value)
                            if new_value then
                                antiaimbot.manual_antiaim.state = (antiaimbot.manual_antiaim.state == i or i == 5) and -1 or i
                            end
                        end,

                        update = function (self)
                            local new_value, mode = self.ref:rawget()

                            if new_value ~= self.prev then
                                self:change(mode == 2 and true or new_value)

                                self.prev = new_value
                            end
                        end
                    }
                end

                function antiaimbot.manual_antiaim.update()
                    for i=1, #list do
                        list[i]:update();
                    end
                end
            end

            function antiaimbot:predict_command(cmd, me, wpn)
                self.manual_antiaim.update()

                if not me then
                    return
                end

                if config.antiaimbot.animation_breaker:get() then
                    self.animation_breaker.run(me)

                    self.animation_breaker.anim_reset = false
                elseif not self.anim_reset then
                    override.unset(reference.misc.leg_movement)
                    self.animation_breaker.anim_reset = true
                end
            end

            function antiaimbot:setup_command(cmd, me, wpn)
                if me == nil then
                    return
                end

                self.main:run(cmd, me, wpn)
            end

            function antiaimbot:finish_command(cmd, me, wpn)
                if not me then
                    return
                end

                if config.antiaimbot.animation_breaker:get() then
                    self.animation_breaker.post(cmd, me);
                end
            end
        end
    end

    ---
    --- Anti-aimbot builder
    ---
    local antiaimbot_builder do
        config.builder = {} do
            config.builder.antiaim_state = menu.new_item(ui.new_combobox, "AA", "Anti-aimbot angles", "AA: Configured state", c_table.combine_arrays({"Global", "Fake lag"}, c_constant.STATE_LIST))
                :config_ignore()

            config.builder.defensive_state = menu.new_item(ui.new_combobox, "AA", "Anti-aimbot angles", "Defensive AA: Configured state", c_table.combine_arrays({"Global"}, c_constant.DEFENSIVE_STATES, c_constant.STATE_LIST))
                :config_ignore()
        end

        antiaimbot_builder = {} do
            antiaimbot_builder.settings = {} do
                local global_state_list = c_table.combine_arrays({'Global', 'Fake lag'}, c_constant.STATE_LIST)

                for i=1, #global_state_list do
                    local state = global_state_list[i]

                    antiaimbot_builder.settings[state] = {}

                    local this = antiaimbot_builder.settings[state]

                    if state ~= "Global" then
                        this.enabled = menu.new_item(ui.new_checkbox, "AA", "Anti-aimbot angles", table.concat { "Enabled", "\n", "AA", state })
                            :record("builder", table.concat { "AA", "::", state, "::Enabled" })
                            :save()
                    end

                    this.pitch = menu.new_item(ui.new_combobox, "AA", "Anti-aimbot angles", table.concat { state, ": Pitch", "\n", "AA", state }, {
                        "Off",
                        "Default",
                        "Up",
                        "Down",
                        "Minimal",
                        "Random",
                        "Custom"
                    }):record("builder", table.concat { "AA", "::", state, "::Pitch" }):save()

                    this.pitch_amount = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "\n", "Pitch custom", "AA", state }, -89, 89, 0, true, "°", 1)
                        :record("builder", table.concat { "AA", "::", state, "::PitchCustom" })
                        :save()

                    this.yaw_base = menu.new_item(ui.new_combobox, "AA", "Anti-aimbot angles", table.concat { state, ": Yaw base", "\n", "AA", state }, {
                        "Local view",
                        "At targets"
                    }):record("builder", table.concat { "AA", "::", state, "::YawBase" }):save()

                    this.yaw_type = menu.new_item(ui.new_combobox, "AA", "Anti-aimbot angles", table.concat { state, ": Yaw", "\n", "AA", state }, {
                        "Off",
                        "180",
                        "Spin",
                        "Static",
                        "180 Z",
                        "Crosshair",
                        "Left & Right",
                        "Flick",
                        "Sway",
                        "Spin between"
                    }):record("builder", table.concat { "AA", "::", state, "::YawType" }):save()

                    this.yaw_amount = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "\n", "Yaw custom", "AA", state }, -180, 180, 0, true, "°", 1)
                        :record("builder", table.concat { "AA", "::", state, "::YawCustom" })
                        :save()

                    this.yaw_left = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "Custom: Yaw left", "\n", "AA", state }, -180, 180, 0, true, "°", 1)
                        :record("builder", table.concat { "AA", "::", state, "::YawLeft" })
                        :save()

                    this.yaw_right = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "Custom: Yaw right", "\n", "AA", state }, -180, 180, 0, true, "°", 1)
                        :record("builder", table.concat { "AA", "::", state, "::YawRight" })
                        :save()

                    this.yaw_delayed_switch = menu.new_item(ui.new_checkbox, "AA", "Anti-aimbot angles", table.concat { state, ": Yaw delayed switch", "\n", "AA", state })
                        :record("builder", table.concat { "AA", "::", state, "::YawDelayedSwitch" })
                        :save()

                    this.yaw_switch_delay = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "Yaw delayed switch: Delay", "\n", "AA", state }, 1, 12, 6, true, "t", 1, {[0] = "Off"})
                        :record("builder", table.concat { "AA", "::", state, "::YawSwitchDelay" })
                        :save()

                    this.yaw_switch_delay_second = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "Yaw delayed switch: Delay second", "\n", "AA", state }, 1, 12, 6, true, "t", 1, {[0] = "Off"})
                        :record("builder", table.concat { "AA", "::", state, "::YawSwitchDelaySecond" })
                        :save()

                    this.yaw_delay = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "Custom: Yaw delay", "\n", "AA", state }, 1, 64, 5, true, "t", 1, {[0] = "Off"})
                        :record("builder", table.concat { "AA", "::", state, "::YawDelay" })
                        :save()

                    this.yaw_speed = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "Custom: Yaw speed", "\n", "AA", state }, 1, 64, 5, true, "t", 1, {[0] = "Off"})
                        :record("builder", table.concat { "AA", "::", state, "::YawSpeed" })
                        :save()

                    this.yaw_jitter = menu.new_item(ui.new_combobox, "AA", "Anti-aimbot angles", table.concat { state, ": Yaw Jitter", "\n", "AA", state }, {
                        "Off",
                        "Offset",
                        "Center",
                        "Random",
                        "Skitter"
                    }):record("builder", table.concat { "AA", "::", state, "::YawJitter" }):save()

                    this.jitter_value = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "\n", "Jitter value", "AA", state }, -180, 180, 0, true, "°", 1)
                        :record("builder", table.concat { "AA", "::", state, "::JitterValue" })
                        :save()

                    this.jitter_randomize = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "Yaw jitter: Randomize", "\n", "AA", state }, -180, 180, 0, true, "°", 1, {[0] = "Off"})
                        :record("builder", table.concat { "AA", "::", state, "::JitterRandomize" })
                        :save()

                    this.body_yaw = menu.new_item(ui.new_combobox, "AA", "Anti-aimbot angles", table.concat { state, ": Body yaw", "\n", "AA", state }, {
                        "Off",
                        "Opposite",
                        "Jitter",
                        "Static"
                    }):record("builder", table.concat { "AA", "::", state, "::BodyYaw" }):save()

                    this.body_value = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "\n", "Body value", "AA", state }, -180, 180, 0, true, "°", 1)
                        :record("builder", table.concat { "AA", "::", state, "::BodyValue" })
                        :save()
                end

                local function onStateChange()
                    antiaimbot.constructor = {}

                    local state_list = c_table.combine_arrays({'Fake lag'}, c_constant.STATE_LIST)

                    for i=1, #state_list do
                        local state = state_list[i]

                        antiaimbot.constructor[state] = {}

                        local this = antiaimbot.constructor[state]
                        local is_enabled = antiaimbot_builder.settings[state].enabled:get()

                        if not is_enabled and state == 'Fake lag' then
                            antiaimbot.constructor[state] = nil

                            goto continue
                        end

                        local menu_state = is_enabled and antiaimbot_builder.settings[state] or antiaimbot_builder.settings['Global']

                        this.pitch = menu_state.pitch:get()
                        this.pitch_custom = menu_state.pitch_amount:get()

                        this.yaw_base = menu_state.yaw_base:get()

                        local yaw_type = menu_state.yaw_type:get()

                        this.yaw_type = yaw_type

                        if yaw_type == 'Left & Right' then
                            local yaw_delay = menu_state.yaw_switch_delay:get()

                            this.yaw_delay = menu_state.yaw_delayed_switch:get() and yaw_delay or nil
                            this.yaw_delay_second = menu_state.yaw_switch_delay_second:get()
                            this.left_offset = menu_state.yaw_left:get()
                            this.right_offset = menu_state.yaw_right:get()
                        elseif yaw_type == 'Flick' or yaw_type == 'Sway' or yaw_type == 'Spin between' then
                            this.left_offset = menu_state.yaw_left:get()
                            this.right_offset = menu_state.yaw_right:get()
                            this.yaw_delay = menu_state.yaw_delay:get()
                            this.yaw_speed = menu_state.yaw_speed:get()
                        else
                            this.yaw_offset = menu_state.yaw_amount:get()
                        end

                        local jitter_type = menu_state.yaw_jitter:get()

                        this.yaw_modifier = jitter_type

                        this.modifier_offset = menu_state.jitter_value:get()
                        this.modifier_randomize = menu_state.jitter_randomize:get()

                        this.body_yaw_type = menu_state.body_yaw:get()
                        this.body_yaw_value = menu_state.body_value:get()

                        ::continue::
                    end

                    antiaimbot.constructor['Legit AA'] = {
                        pitch = 'Off',
                        yaw_base = 'Local view',
                        yaw_type = 'Left & Right',
                        left_offset = 165,
                        right_offset = -165,

                        yaw_delay = 1,
                        yaw_delay_second = 6
                    }
                end


                local builder_keys = menu.get_records()["builder"]

                for key, element in pairs(builder_keys) do
                    element:set_callback(onStateChange)
                end

                onStateChange()
            end

            antiaimbot_builder.defensive_settings = {} do
                local defensive_state_list = c_table.combine_arrays({'Global'}, c_constant.DEFENSIVE_STATES, c_constant.STATE_LIST)

                for i=1, #defensive_state_list do
                    local state = defensive_state_list[i]

                    antiaimbot_builder.defensive_settings[state] = {}

                    local this = antiaimbot_builder.defensive_settings[state]

                    this.enabled = menu.new_item(ui.new_checkbox, "AA", "Anti-aimbot angles", table.concat { "Enabled", "\n", "DEF", state })
                        :record("defensive", table.concat { "DEF", "::", state, "::Enabled" })
                        :save()

                    if state == "Edge direction" then
                        this.enable_on = menu.new_item(ui.new_multiselect, "AA", "Anti-aimbot angles", table.concat { state,  ": Target", "\n", "DEF" }, {"Freestanding", "Manual yaw"})
                            :record("defensive", table.concat { "DEF", "::", state, "::Target" })
                            :save()
                    end

                    if state == "Safe head" or state == "Edge direction" or state == "Triggered" then
                        goto ignore
                    end

                    this.pitch = menu.new_item(ui.new_combobox, "AA", "Anti-aimbot angles", table.concat { state,  ": Pitch", "\n", "DEF" }, {
                        "Default",
                        "Up",
                        "Zero",
                        "Up Switch",
                        "Down Switch",
                        "Random",
                        "Custom"
                    }):record("defensive", table.concat { "DEF", "::", state, "::Pitch" }):save()

                    this.pitch_custom = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "\n", "Pitch custom", "DEF", state }, -89, 89, 89, true, "°", 1)
                        :record("defensive", table.concat { "DEF", "::", state, "::PitchCustom" })
                        :save()

                    this.yaw = menu.new_item(ui.new_combobox, "AA", "Anti-aimbot angles", table.concat { state,  ": Yaw", "\n", "DEF" }, {
                        "Default",
                        "Forward",
                        "Sideways",
                        "Delayed",
                        "Scissors",
                        "Spinbot",
                        "3-Way",
                        "5-Way",
                        "Random"
                    }):record("defensive", table.concat { "DEF", "::", state, "::Yaw" }):save()

                    this.yaw_from = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "Custom: From", "\n", "DEF", state }, -180, 180, 0, true, "°", 1)
                        :record("defensive", table.concat { "DEF", "::", state, "::YawFrom" })
                        :save()
                    this.yaw_to = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "Custom: To", "\n", "DEF", state }, -180, 180, 0, true, "°", 1)
                        :record("defensive", table.concat { "DEF", "::", state, "::YawTo" })
                        :save()
                    this.yaw_speed = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "Custom: Speed", "\n", "DEF", state }, 1, 64, 1, true, "t", 1)
                        :record("defensive", table.concat { "DEF", "::", state, "::YawSpeed" })
                        :save()

                    this.yaw_left = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "Custom: Left", "\n", "DEF", state }, -180, 180, 0, true, "°", 1)
                        :record("defensive", table.concat { "DEF", "::", state, "::YawLeft" })
                        :save()
                    this.yaw_right = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "Custom: Right", "\n", "DEF", state }, -180, 180, 0, true, "°", 1)
                        :record("defensive", table.concat { "DEF", "::", state, "::YawRight" })
                        :save()

                    this.yaw_left_start = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "Custom: Left start", "\n", "DEF", state }, -180, 180, 0, true, "°", 1)
                        :record("defensive", table.concat { "DEF", "::", state, "::YawLeftStart" })
                        :save()
                    this.yaw_left_target = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "Custom: Left target", "\n", "DEF", state }, -180, 180, 0, true, "°", 1)
                        :record("defensive", table.concat { "DEF", "::", state, "::YawLeftTarget" })
                        :save()

                    this.yaw_right_start = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "Custom: Right start", "\n", "DEF", state }, -180, 180, 0, true, "°", 1)
                        :record("defensive", table.concat { "DEF", "::", state, "::YawRightStart" })
                        :save()
                    this.yaw_right_target = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "Custom: Right target", "\n", "DEF", state }, -180, 180, 0, true, "°", 1)
                        :record("defensive", table.concat { "DEF", "::", state, "::YawRightTarget" })
                        :save()

                    this.yaw_delay = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "Custom: Delay", "\n", "DEF", state }, 1, 8, 6, true, "t", 1)
                        :record("defensive", table.concat { "DEF", "::", state, "::YawDelay" })
                        :save()
                    this.yaw_randomize = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", table.concat { "Custom: Randomize", "\n", "DEF", state }, 0, 180, 0, true, "°", 1, { [0] = "Off" })
                        :record("defensive", table.concat { "DEF", "::", state, "::YawRandomize" })
                        :save()

                    ::ignore::
                end


                local function onStateChange()
                    antiaimbot.defensive_constructor = {}

                    for i=1, #defensive_state_list do
                        local state = defensive_state_list[i]

                        antiaimbot.defensive_constructor[state] = {}

                        local this = antiaimbot.defensive_constructor[state]
                        local is_enabled = antiaimbot_builder.defensive_settings[state].enabled:get()
                        local is_global = false

                        if not is_enabled then
                            local global_state = antiaimbot_builder.defensive_settings['Global']

                            if not global_state.enabled:get() then
                                antiaimbot.defensive_constructor[state] = nil

                                goto continue
                            else
                                is_global = true
                            end
                        end

                        local menu_state = antiaimbot_builder.defensive_settings[state]

                        if is_global then
                            menu_state = antiaimbot_builder.defensive_settings['Global']
                        end

                        if is_global then
                            this.enable_on = {'Freestanding', 'Manual yaw'}
                            this.global_set = true
                        else
                            if state == 'Edge direction' then
                                this.enable_on = menu_state.enable_on:get()
                            end
                        end

                        if state == 'Safe head' or state == 'Edge direction' or state == 'Triggered' then
                            goto continue
                        end

                        this.pitch = menu_state.pitch:get()
                        this.pitch_custom = menu_state.pitch_custom:get()

                        this.yaw = menu_state.yaw:get()

                        this.yaw_left = menu_state.yaw_left:get()
                        this.yaw_right = menu_state.yaw_right:get()
                        this.yaw_delay = menu_state.yaw_delay:get()

                        this.yaw_from = menu_state.yaw_from:get()
                        this.yaw_to = menu_state.yaw_to:get()
                        this.yaw_speed = menu_state.yaw_speed:get()

                        this.yaw_left_start = menu_state.yaw_left_start:get()
                        this.yaw_left_target = menu_state.yaw_left_target:get()

                        this.yaw_right_start = menu_state.yaw_right_start:get()
                        this.yaw_right_target = menu_state.yaw_right_target:get()

                        this.yaw_randomize = menu_state.yaw_randomize:get()

                        ::continue::
                    end
                end

                local builder_keys = menu.get_records()["defensive"]

                for key, element in pairs(builder_keys) do
                    element:set_callback(onStateChange)
                end

                onStateChange()
            end
        end
    end

    ---
    --- Visuals
    ---
    local visuals do
        config.visuals = {} do
            config.visuals.indicators = menu.new_item(ui.new_checkbox, "AA", "Anti-aimbot angles", "Indicators")
                :record("visuals", "indicators")
                :save()

            config.visuals.indicator_color = menu.new_item(ui.new_color_picker, "AA", "Anti-aimbot angles", "\nindicator_color")
                :record("visuals", "indicator_color")
                :save()

            config.visuals.indicator_style = menu.new_item(ui.new_combobox, "AA", "Anti-aimbot angles", "Indicators: Style", {
                "Modern",
                "Legacy",
                "Renewed"
            }):record("visuals", "indicator_style"):save()

            config.visuals.indicator_renewed_color = menu.new_item(ui.new_color_picker, "AA", "Anti-aimbot angles", "Indicators: Renewed")
                :record("visuals", "indicator_renewed_color")
                :save()

            config.visuals.indicator_vertical_offset = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", "Indicators: Vertical offset", 20, 100, 10, true, "px")
                :record("visuals", "indicator_vertical_offset")
                :save()

            config.visuals.indicator_options = menu.new_item(ui.new_multiselect, "AA", "Anti-aimbot angles", "Indicators: Settings", {
                "Velocity modifier",
                "Adjust while scoped",
                "Alter alpha while scoped",
                "Alter alpha on grenade"
            }):record("visuals", "indicator_options"):save()

            config.visuals.damage_marker = menu.new_item(ui.new_checkbox, "AA", "Anti-aimbot angles", "Damage marker")
                :record("visuals", "damage_marker")
                :save()

            config.visuals.damage_marker_color = menu.new_item(ui.new_color_picker, "AA", "Anti-aimbot angles", "\ndamage_marker")
                :record("visuals", "damage_marker_color")
                :save()

            config.visuals.r8_indicator = menu.new_item(ui.new_checkbox, "AA", "Anti-aimbot angles", "R8 Indicator")
                :record("visuals", "r8_indicator")
                :save()

            config.visuals.r8_indicator_color = menu.new_item(ui.new_color_picker, "AA", "Anti-aimbot angles", "\nr8_indicator")
                :record("visuals", "r8_indicator_color")
                :save()

            config.visuals.manual_arrows = menu.new_item(ui.new_checkbox, "AA", "Anti-aimbot angles", "Manual arrows")
                :record("visuals", "manual_arrows")
                :save()

            config.visuals.manual_arrows_color = menu.new_item(ui.new_color_picker, "AA", "Anti-aimbot angles", "\nmanual_arrows", 77, 77, 77, 255)
                :record("visuals", "manual_arrows_color")
                :save()

            config.visuals.manual_arrows_accent = menu.new_item(ui.new_color_picker, "AA", "Anti-aimbot angles", "Manual arrows: Accent")
                :record("visuals", "manual_arrows_accent")
                :save()

            config.visuals.manual_arrows_style = menu.new_item(ui.new_combobox, "AA", "Anti-aimbot angles", "Manual arrows: Style", {
                "Triangles",
                "Symbols #1",
                "Symbols #2",
                "Symbols #3"
            }):record("visuals", "manual_arrows_style"):save()

            config.visuals.manual_arrows_options = menu.new_item(ui.new_multiselect, "AA", "Anti-aimbot angles", "Manual arrows: Settings", {
                "Hide while scoped"
            }):record("visuals", "manual_arrows_options"):save()

            config.visuals.manual_arrows_size = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", "Manual arrows: Size", 5, 100, 10, true, "px")
                :record("visuals", "manual_arrows_size")
                :save()

            config.visuals.manual_arrows_offset = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", "Manual arrows: Offset", 10, 100, 35, true, "px")
                :record("visuals", "manual_arrows_offset")
                :save()
        end

        visuals = {} do
            local screen_size = vector(client.screen_size())
            local screen_center = screen_size * 0.5

            local state_name = player.state

            local smooth_charge = c_tweening:new(0)
            local smooth_scope = c_tweening:new(0)
            local smooth_state = c_tweening:new(1.0)

            local indicator_global = c_tweening:new(0)
            local indicator_grenade = c_tweening:new(1.0)

            visuals.modern = {} do
                local list = {
                    {
                        name = 'VELOCITY: %d%%',
                        format = function ()
                            return player.velocity_modifier * 100
                        end,
                        active = function ()
                            return c_table.contains(config.visuals.indicator_options:get(), 'Velocity modifier') and player.velocity_modifier ~= 1.0
                        end,
                        color = function ()
                            return color.yellow:lerp(color.gray, player.velocity_modifier)
                        end,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = 'SAFE HEAD',
                        active = function ()
                            return antiaimbot.features.state.safe_head
                        end,
                        color = color.fixik,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = 'DOUBLETAP',
                        active = function ()
                            return c_table.is_hotkey_active(reference.ragebot.doubletap.enable)
                        end,
                        color = function ()
                            return color.red:lerp(color.white, smooth_charge())
                        end,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = 'ONSHOT',
                        active = function ()
                            return c_table.is_hotkey_active(reference.misc.onshot_antiaim)
                        end,
                        color = color.onshot,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = 'DUCK',
                        active = function ()
                            return ui.get(reference.ragebot.fakeduck) and not player.air_exploit
                        end,
                        color = function (accent, me)
                            return color.white:lerp(color.gray, 1 - player.duckamount)
                        end,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = 'DAMAGE: %d',
                        format = function ()
                            return ui.get(reference.ragebot.minimum_damage_override[3])
                        end,
                        active = function ()
                            return c_table.is_hotkey_active(reference.ragebot.minimum_damage_override)
                        end,
                        color = color.white,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = 'FREESTAND',
                        active = function ()
                            return c_table.is_hotkey_active(reference.antiaim.freestanding)
                        end,
                        color = color.freestanding,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = 'EDGE',
                        active = function ()
                            return ui.get(reference.antiaim.yaw.edge)
                        end,
                        color = color.edge,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = 'BAIM',
                        active = function ()
                            return ui.get(reference.ragebot.force_bodyaim)
                        end,
                        color = color.raw_red,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = 'SP',
                        active = function ()
                            return ui.get(reference.ragebot.force_safepoint)
                        end,
                        color = color.raw_green,
                        animation = c_tweening:new(0)
                    }
                }

                visuals.modern.draw = (function (global_alpha, grenade_alpha)
                    local ctx_alpha = global_alpha * grenade_alpha

                    local indicator_offset = config.visuals.indicator_vertical_offset:get()
                    local indicator_position = screen_center + vector(0, indicator_offset)

                    -- local scope_animation = smooth_scope()

                    -- < label >
                    local indicator_accent = color(config.visuals.indicator_color:get())

                    local indicator_label = 'PR0KLADKI'

                    renderer.text(indicator_position.x , indicator_position.y, 255, 255, 255, 255*ctx_alpha, '-', 0, indicator_label)

                    indicator_position = indicator_position + vector(0, 11)

                    local indicator_body_yaw = c_math.clamp(player.smooth_fakeamount*0.0172, 0.0, 1.0)

                    renderer.rectangle(indicator_position.x + 1, indicator_position.y, 46, 5, 0, 0, 0, 255*ctx_alpha)
                    renderer.gradient(indicator_position.x + 2, indicator_position.y + 1, math.floor(indicator_body_yaw*43), 3,
                        indicator_accent.r, indicator_accent.g, indicator_accent.b, 255*ctx_alpha,
                        indicator_accent.r, indicator_accent.g, indicator_accent.b, 15*ctx_alpha,
                    true)

                    indicator_position = indicator_position + vector(0, 5)

                    for i=1, #list do
                        local indicator = list[i]
                        local indicator_animation = indicator.animation(0.15, ({indicator.active()})[1] or false)

                        if indicator_animation > 0.01 then
                            local indicator_text = indicator.name:format(indicator.format and indicator.format() or '')
                            local indicator_color do
                                if type(indicator.color) == 'table' then
                                    --- @type table
                                    indicator_color = indicator.color
                                elseif type(indicator.color) == 'function' then
                                    indicator_color = indicator.color()
                                else
                                    indicator_accent = indicator_accent:clone()
                                end
                            end

                            renderer.text(indicator_position.x, indicator_position.y, indicator_color.r, indicator_color.g, indicator_color.b, indicator_color.a*indicator_animation*ctx_alpha, '-', 0, indicator_text)

                            indicator_position = indicator_position + vector(0, 9) * indicator_animation
                        end
                    end
                end)
            end

            visuals.legacy = {} do
                local list = {
                    {
                        name = "velocity %d%%",
                        format = function()
                            return player.velocity_modifier * 100
                        end,
                        active = function()
                            return c_table.contains(config.visuals.indicator_options:get(), "Velocity modifier") and player.velocity_modifier ~= 1.0
                        end,
                        color = color.pink,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = "safe head",
                        active = function()
                            return antiaimbot.features.state.safe_head
                        end,
                        color = color.fixik,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = "shifting (dt)",
                        active = function()
                            return c_table.is_hotkey_active(reference.ragebot.doubletap.enable)
                        end,
                        color = function()
                            return color.red:lerp(color.white, smooth_charge())
                        end,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = "onshot",
                        active = function()
                            return c_table.is_hotkey_active(reference.misc.onshot_antiaim)
                        end,
                        color = color.purplish,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = "ducking",
                        active = function()
                            return ui.get(reference.ragebot.fakeduck) and not player.air_exploit
                        end,
                        color = function(accent, me)
                            return color.white:lerp(color.gray, 1 - player.duckamount)
                        end,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = "damage (%d)",
                        format = function()
                            return ui.get(reference.ragebot.minimum_damage_override[3])
                        end,
                        active = function()
                            return c_table.is_hotkey_active(reference.ragebot.minimum_damage_override)
                        end,
                        color = color.white,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = "onlybaim",
                        active = function()
                            return ui.get(reference.ragebot.force_bodyaim)
                        end,
                        color = color.pink,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = "freestanding",
                        active = function()
                            return c_table.is_hotkey_active(reference.antiaim.freestanding)
                        end,
                        color = color("9DB0FBCA"),
                        animation = c_tweening:new(0)
                    },
                    {
                        name = "edging",
                        active = function()
                            return ui.get(reference.antiaim.yaw.edge)
                        end,
                        color = color.pink,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = "safety",
                        active = function()
                            return ui.get(reference.ragebot.force_safepoint)
                        end,
                        color = color.blue,
                        animation = c_tweening:new(0)
                    }
                }

                visuals.legacy.draw = (function (global_alpha, grenade_alpha)
                    local ctx_alpha = global_alpha * grenade_alpha

                    local indicator_offset = config.visuals.indicator_vertical_offset:get()
                    local indicator_position = screen_center + vector(0, indicator_offset)

                    local scope_animation = smooth_scope()

                    -- < label >
                    local indicator_accent = color(config.visuals.indicator_color:get())

                    local left_color, right_color do
                        if player.fakeyaw > 0 then
                            left_color = color.white
                            right_color = indicator_accent
                        else
                            left_color = indicator_accent
                            right_color = color.white
                        end
                    end

                    local indicator_label_t = {
                        {'PR0KLADKI', left_color:alpha_modulate(ctx_alpha, true)},
                        {'.', color.white:alpha_modulate(ctx_alpha, true)},
                        {'EBET', right_color:alpha_modulate(ctx_alpha, true)}
                    }
                    local indicator_label = ''

                    for i=1, 3 do
                        indicator_label = string.format('%s\a%s%s', indicator_label, indicator_label_t[i][2]:to_hex(), indicator_label_t[i][1])
                    end

                    local indicator_label_size = vector(renderer.measure_text('b', 'PR0KLADKI'))
                    local scope_offset = indicator_label_size.x * 0.5 * scope_animation + scope_animation * 4

                    renderer.text(indicator_position.x + scope_offset - indicator_label_size.x * 0.5 + 1, indicator_position.y - indicator_label_size.y * 0.5, 255, 255, 255, 255, 'b', 0, indicator_label)

                    indicator_position = indicator_position + vector(0, indicator_label_size.y)

                    local indicator_body_yaw = c_math.clamp(player.smooth_fakeamount*0.0172, 0.0, 1.0)
                    local indicator_dsy = string.format('%d%%', indicator_body_yaw*100)
                    local indicator_dsy_size = vector(renderer.measure_text('-', indicator_dsy))

                    local scope_offset_dsy = indicator_dsy_size.x * 0.5 * scope_animation + scope_animation * 3

                    renderer.text(indicator_position.x + scope_offset_dsy - indicator_dsy_size.x*0.5, indicator_position.y - indicator_dsy_size.y*0.5, indicator_accent.r, indicator_accent.g, indicator_accent.b, 255*ctx_alpha, '-', 0, indicator_dsy)

                    indicator_position = indicator_position + vector(0, indicator_dsy_size.y + 1)

                    for i=1, #list do
                        local indicator = list[i]
                        local indicator_animation = indicator.animation(0.15, ({indicator.active()})[1] or false)

                        if indicator_animation > 0.01 then
                            local indicator_text = indicator.name:format(indicator.format and indicator.format() or '')
                            local indicator_color do
                                if type(indicator.color) == 'table' then
                                    indicator_color = indicator.color
                                elseif type(indicator.color) == 'function' then
                                    indicator_color = indicator.color(indicator_accent)
                                else
                                    indicator_accent = indicator_accent:clone()
                                end
                            end

                            local text_size = vector(renderer.measure_text('', indicator_text))
                            local _scope_offset = text_size.x*scope_animation*0.5 + scope_animation * 3

                            renderer.text(indicator_position.x + _scope_offset - text_size.x*0.5 + 1, indicator_position.y - text_size.y*0.5, indicator_color.r, indicator_color.g, indicator_color.b, indicator_color.a * indicator_animation*ctx_alpha, '', 0, indicator_text)

                            indicator_position = indicator_position + vector(0, text_size.y) * indicator_animation
                        end
                    end
                end)
            end

            visuals.renewed = {} do
                visuals.renewed.states = {
                    ['Air'] = 'AIR',
                    ['Air & Crouch'] = 'AIR+',
                    ['Crouching'] = 'CROUCHING',
                    ['Crouch moving'] = 'CROUCHING'
                }
                local list = {
                    {
                        name = "%s",
                        format = function()
                            return state_name:upper()
                        end,
                        active = function()
                            return true
                        end,
                        color = function(accent, accent_second)
                            return accent:lerp(accent_second, smooth_state())
                        end,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = "%d%%",
                        format = function()
                            return player.velocity_modifier * 100
                        end,
                        active = function()
                            return c_table.contains(config.visuals.indicator_options:get(), "Velocity modifier") and player.velocity_modifier ~= 1.0
                        end,
                        color = function(accent)
                            return color.red:lerp(accent, player.velocity_modifier)
                        end,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = "DMG",
                        active = function()
                            return c_table.is_hotkey_active(reference.ragebot.minimum_damage_override)
                        end,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = "DT",
                        active = function()
                            return c_table.is_hotkey_active(reference.ragebot.doubletap.enable)
                        end,
                        color = function(accent)
                            return color.red:lerp(accent, smooth_charge())
                        end,
                        render_addition = function(pos, accent, ctx)
                            renderer.circle_outline(
                                pos.x + 1,
                                pos.y,
                                accent.r,
                                accent.g,
                                accent.b,
                                255 * ctx,
                                3,
                                180,
                                smooth_charge(),
                                1
                            )
                        end,
                        offset_x = function(scope)
                            return smooth_charge() * -4 * scope + scope * 1
                        end,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = "FREESTAND",
                        active = function()
                            return c_table.is_hotkey_active(reference.antiaim.freestanding)
                        end,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = "OSAA",
                        active = function()
                            return c_table.is_hotkey_active(reference.misc.onshot_antiaim)
                        end,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = "EDGE",
                        active = function()
                            return ui.get(reference.antiaim.yaw.edge)
                        end,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = "BAIM",
                        active = function()
                            return ui.get(reference.ragebot.force_bodyaim)
                        end,
                        animation = c_tweening:new(0)
                    },
                    {
                        name = "SP",
                        active = function()
                            return ui.get(reference.ragebot.force_safepoint)
                        end,
                        animation = c_tweening:new(0)
                    }
                }

                visuals.renewed.draw = (function (global_alpha, grenade_alpha)
                    local ctx_alpha = global_alpha * grenade_alpha

                    local indicator_offset = config.visuals.indicator_vertical_offset:get()
                    local indicator_position = screen_center + vector(0, indicator_offset)

                    local scope_animation = smooth_scope()
                    local rev_scope_animation = 1 - scope_animation

                    -- < label >
                    local indicator_accent = color(config.visuals.indicator_color:get())
                    local indicator_renewed = color(config.visuals.indicator_renewed_color:get())

                    local indicator_label = color.animated_text('PR0KLADKI', 1, indicator_renewed, indicator_accent, ctx_alpha*255)
                    local indicator_label_size = vector(renderer.measure_text('b', 'PR0KLADKI'))

                    local scope_offset = indicator_label_size.x * 0.5 * scope_animation + scope_animation * 3

                    renderer.text(indicator_position.x + scope_offset - indicator_label_size.x * 0.5, indicator_position.y - indicator_label_size.y * 0.5, 255, 255, 255, ctx_alpha*255, 'b', 0, indicator_label)

                    indicator_position = indicator_position + vector(0, indicator_label_size.y - 1)

                    for i=1, #list do
                        local indicator = list[i]
                        local indicator_animation = indicator.animation(0.15, ({indicator.active()})[1] or false)

                        if indicator_animation > 0.01 then
                            local indicator_text = indicator.name:format(indicator.format and indicator.format() or '')
                            local indicator_color do
                                if type(indicator.color) == 'table' then
                                    --- @type table
                                    indicator_color = indicator.color
                                elseif type(indicator.color) == 'function' then
                                    indicator_color = indicator.color(indicator_accent, indicator_renewed)
                                else
                                    indicator_color = indicator_accent:clone()
                                end
                            end

                            local text_size = vector(renderer.measure_text('-', indicator_text))
                            local _x_offset = indicator.offset_x or 0

                            if type(_x_offset) == 'function' then
                                _x_offset = _x_offset(rev_scope_animation)
                            end

                            local _scope_offset = text_size.x*scope_animation*0.5 + scope_animation * 3

                            renderer.text(indicator_position.x + _scope_offset - text_size.x * 0.5 - 1 + _x_offset, indicator_position.y - text_size.y * 0.5, indicator_color.r, indicator_color.g, indicator_color.b, 255 * indicator_animation*ctx_alpha, '-', 0, indicator_text)

                            if indicator.render_addition then
                                indicator.render_addition(vector(indicator_position.x + text_size.x + _scope_offset + _x_offset, indicator_position.y), indicator_accent, indicator_animation*ctx_alpha)
                            end

                            indicator_position = indicator_position + vector(0, text_size.y) * indicator_animation
                        end
                    end
                end)
            end

            local previous_state = player.state

            visuals.draw_indicators = (function (self)
                if not player.alive then
                    return
                end

                local me = player.entindex
                local indicator_options = config.visuals.indicator_options:get()
                local is_scoped = entity.get_prop(me, 'm_bIsScoped') == 1

                smooth_scope(0.1, c_table.contains(indicator_options, 'Adjust while scoped') and is_scoped)

                local exploits_charged = player:get_double_tap()

                smooth_charge(0.1, exploits_charged or false)

                local player_state = self.renewed.states[player.state] or player.state

                if antiaimbot.features.state.safe_head then
                    player_state = 'SAFE'
                end

                if previous_state ~= player_state then
                    smooth_state(0.15, 1)

                    if smooth_state() == 1.0 then
                        state_name = player_state

                        previous_state = player_state
                    end
                else
                    smooth_state(0.15, 0)
                end

                local indicator_state = indicator_global(0.15, config.visuals.indicators:get())
                local grenade_b = c_table.contains(indicator_options, 'Alter alpha on grenade') and player.weapon_type == 'grenade' or c_table.contains(indicator_options, 'Alter alpha while scoped') and is_scoped
                local grenade_state = indicator_grenade(0.15, grenade_b and 0.5 or 1.0)

                if indicator_state > 0.01 then
                    local indicator_type = config.visuals.indicator_style:get();

                    if indicator_type == 'Modern' then
                        self.modern.draw(indicator_state, grenade_state);
                    elseif indicator_type == 'Legacy' then
                        self.legacy.draw(indicator_state, grenade_state);
                    elseif indicator_type == 'Renewed' then
                        self.renewed.draw(indicator_state, grenade_state);
                    end
                end
            end)

            visuals.markers = {} do
                local marker_points = { 0, 5, 2, 13, 14, 7, 8 }
                local list = {}

                function visuals.markers.receive(event)
                    local userid, attacker = client.userid_to_entindex(event.userid), client.userid_to_entindex(event.attacker)

                    if not userid or not attacker or userid == attacker or attacker ~= player.entindex then
                        return
                    end

                    local hitbox = marker_points[event.hitgroup] or 3
                    local found_existing = false

                    for i=1, #list do
                        local marker = list[i]

                        if marker[1] == userid and marker[3]-globals.realtime() > 1 then
                            marker[5] = marker[5] + (event.dmg_health or 0)

                            found_existing = true
                        end
                    end

                    if not found_existing then
                        list[#list+1] = {
                            userid;
                            {c_tweening:new(0.01), c_tweening:new(0)},
                            globals.realtime() + 2,
                            {config.visuals.damage_marker_color:get()},
                            event.dmg_health or 0,
                            {entity.hitbox_position(userid, hitbox)}
                        }
                    end
                end

                visuals.markers.draw = (function ()
                    local realtime = globals.realtime();

                    for i, marker in ipairs(list) do
                        local time_diff = marker[3] - realtime;
                        local anim = marker[2][1](0.2, time_diff > 0 or marker[2][2]() ~= marker[5]);

                        if anim < 0.01 then
                            table.remove(list, i);
                        else
                            local anim_dmg = marker[2][2](1.5, marker[5]);
                            local screen_x, screen_y = renderer.world_to_screen(marker[6][1], marker[6][2], marker[6][3] + 60 - (time_diff * 40));

                            if screen_x then
                                renderer.text(screen_x, screen_y, marker[4][1], marker[4][2], marker[4][3], marker[4][4]*anim, 'bc', 0, math.floor(anim_dmg));
                            end
                        end
                    end
                end)
            end

            visuals.draw_markers = (function (self)
                if config.visuals.damage_marker:get() then
                    self.markers.draw()
                end
            end)

            visuals.r8_indicator = {} do
                local r8_main = c_tweening:new(0)
                local r8_process = c_tweening:new(0)

                visuals.r8_indicator.draw = (function ()
                    if not player.alive then
                        return
                    end

                    local wpn = entity.get_player_weapon(player.entindex)

                    if not wpn then
                        return
                    end

                    local wpn_info = csgo_weapons(wpn)

                    local main_alpha = r8_main(0.15, config.visuals.r8_indicator:get() and wpn_info and wpn_info.is_revolver)

                    if main_alpha < 0.01 then
                        return
                    end

                    local time = globals.curtime()


                    local m_flFireReady = entity.get_prop(wpn, 'm_flPostponeFireReadyTime')

                    if m_flFireReady > 0 and m_flFireReady < globals.curtime() then
                        if m_flFireReady + globals.tickinterval() * 14 > globals.curtime() then
                            time = m_flFireReady + globals.tickinterval() * 14
                        end
                    end

                    local r8_pct = (time - globals.curtime()) * 4.571428571 -- ( 1 / 0.21875 )

                    local circle_anim = r8_process(0.15, r8_pct) * main_alpha
                    local circle_color = color(config.visuals.r8_indicator_color:get())

                    if entity.get_prop(player.entindex, 'm_flNextAttack') - globals.curtime() >= 0 or entity.get_prop(wpn, 'm_flNextPrimaryAttack') - globals.curtime() >= 0 then
                        r8_process(0.001, 1)
                        circle_anim = 1
                    end

                    renderer.circle_outline(screen_center.x + 25, screen_center.y, 0, 0, 0, 120*main_alpha, 8.2, 0, 1, 5)
                    renderer.circle_outline(screen_center.x + 25, screen_center.y, circle_color.r, circle_color.g, circle_color.b, 255*main_alpha, 7.2, 0, (1 - circle_anim)*main_alpha, 3)
                end)
            end

            visuals.draw_r8_indicator = (function (self)
                if config.visuals.r8_indicator:get() then
                    self.r8_indicator.draw()
                end
            end)

            visuals.manual_arrows = {} do
                local arrows = {
                    main = c_tweening:new(0),
                    left = c_tweening:new(0),
                    right = c_tweening:new(0)
                }

                local arrow_svg3 = (function ()
                    return renderer.load_svg('<svg width="44" height="51" viewBox="0 0 44 51" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M4.80057 0.42733L42.2181 23.2222C43.9803 24.2955 43.9775 26.8231 42.2135 27.893L4.81149 50.5757C2.3411 52.0739 -0.515033 49.3119 0.956021 46.8473L12.8323 26.9498C13.344 26.0926 13.345 25.0295 12.8351 24.1714L0.937543 4.14816C-0.528614 1.68041 2.33319 -1.07609 4.80057 0.42733Z" fill="white"/><path d="M4.80057 0.42733L42.2181 23.2222C43.9803 24.2955 43.9775 26.8231 42.2135 27.893L4.81149 50.5757C2.3411 52.0739 -0.515033 49.3119 0.956021 46.8473L12.8323 26.9498C13.344 26.0926 13.345 25.0295 12.8351 24.1714L0.937543 4.14816C-0.528614 1.68041 2.33319 -1.07609 4.80057 0.42733Z" fill="white"/></svg>', 8, 11);
                end)()

                visuals.manual_arrows.draw = (function ()
                    if not player.alive then
                        return
                    end

                    local arrow_options = config.visuals.manual_arrows_options:get()
                    local scope_check = true

                    if c_table.contains(arrow_options, 'Hide while scoped') then
                        scope_check = smooth_scope() < 1
                    end

                    local main = arrows.main(0.15, antiaimbot.manual_antiaim.state ~= -1 and config.visuals.manual_arrows:get() and scope_check)

                    if main > 0.01 then
                        local manual_color_bg = color(config.visuals.manual_arrows_color:get())
                        local manual_color = color(config.visuals.manual_arrows_accent:get())

                        local manual_size = config.visuals.manual_arrows_size:get()
                        local manual_offset = config.visuals.manual_arrows_offset:get()

                        local manual_style = config.visuals.manual_arrows_style:get()

                        local left_modifier = arrows.left(0.15, antiaimbot.manual_antiaim.state == antiaimbot.manual_antiaim.MANUAL_LEFT or antiaimbot.manual_antiaim.state == antiaimbot.manual_antiaim.MANUAL_BACK)
                        local base_position_left = vector(screen_center.x - manual_offset, screen_center.y + 1)

                        local arrow_weight = 8
                        local arrow_height = 11

                        if manual_style == 'Triangles' then
                            renderer.triangle(
                                base_position_left.x - manual_size, base_position_left.y,
                                base_position_left.x, base_position_left.y - manual_size * 0.5,
                                base_position_left.x, base_position_left.y + manual_size * 0.5,
                                manual_color_bg.r, manual_color_bg.g, manual_color_bg.b, manual_color_bg.a * main
                            )

                            renderer.triangle(
                                base_position_left.x - manual_size, base_position_left.y,
                                base_position_left.x, base_position_left.y - manual_size * 0.5,
                                base_position_left.x, base_position_left.y + manual_size * 0.5,
                                manual_color.r, manual_color.g, manual_color.b, 255 * left_modifier * main
                            )
                        elseif manual_style == 'Symbols #1' then
                            renderer.text(base_position_left.x+1, base_position_left.y-4, manual_color_bg.r, manual_color_bg.g, manual_color_bg.b, manual_color_bg.a * main, 'cb+', 0, '‹')
                            renderer.text(base_position_left.x+1, base_position_left.y-4, manual_color.r, manual_color.g, manual_color.b, 255 * left_modifier * main, 'cb+', 0, '‹')
                        elseif manual_style == 'Symbols #2' then
                            renderer.text(base_position_left.x, base_position_left.y-2, manual_color_bg.r, manual_color_bg.g, manual_color_bg.b, manual_color_bg.a * main, 'cb', 0, '⯇')
                            renderer.text(base_position_left.x, base_position_left.y-2, manual_color.r, manual_color.g, manual_color.b, 255 * left_modifier * main, 'cb', 0, '⯇')
                        elseif manual_style == 'Symbols #3' then
                            renderer.texture(arrow_svg3, base_position_left.x+1+arrow_weight/2, base_position_left.y-arrow_height/2+1, -arrow_weight, arrow_height, manual_color_bg.r, manual_color_bg.g, manual_color_bg.b, manual_color_bg.a * main, 'f')
                            renderer.texture(arrow_svg3, base_position_left.x+arrow_weight/2, base_position_left.y-arrow_height/2, -arrow_weight, arrow_height, manual_color.r, manual_color.g, manual_color.b, 255 * left_modifier * main, 'f')
                        end

                        --renderer.rectangle(base_position_left.x, base_position_left.y, 1, 100, 255, 255, 255, 255)

                        local right_modifier = arrows.right(0.15, antiaimbot.manual_antiaim.state == antiaimbot.manual_antiaim.MANUAL_RIGHT or antiaimbot.manual_antiaim.state == antiaimbot.manual_antiaim.MANUAL_BACK)
                        local base_position_right = vector(screen_center.x + manual_offset, screen_center.y + 1)

                        if manual_style == 'Triangles' then
                            renderer.triangle(
                                base_position_right.x + manual_size, base_position_right.y,
                                base_position_right.x, base_position_right.y - manual_size * 0.5,
                                base_position_right.x, base_position_right.y + manual_size * 0.5,
                                manual_color_bg.r, manual_color_bg.g, manual_color_bg.b, manual_color_bg.a * main
                            )

                            renderer.triangle(
                                base_position_right.x + manual_size, base_position_right.y,
                                base_position_right.x, base_position_right.y - manual_size * 0.5,
                                base_position_right.x, base_position_right.y + manual_size * 0.5,
                                manual_color.r, manual_color.g, manual_color.b, 255 * right_modifier * main
                            )
                        elseif manual_style == 'Symbols #1' then
                            renderer.text(base_position_right.x, base_position_right.y-4, manual_color_bg.r, manual_color_bg.g, manual_color_bg.b, manual_color_bg.a * main, 'cb+', 0, '›')
                            renderer.text(base_position_right.x, base_position_right.y-4, manual_color.r, manual_color.g, manual_color.b, 255 * right_modifier * main, 'cb+', 0, '›')
                        elseif manual_style == 'Symbols #2' then
                            renderer.text(base_position_right.x, base_position_right.y-2, manual_color_bg.r, manual_color_bg.g, manual_color_bg.b, manual_color_bg.a * main, 'cb', 0, '⯈')
                            renderer.text(base_position_right.x, base_position_right.y-2, manual_color.r, manual_color.g, manual_color.b, 255 * right_modifier * main, 'cb', 0, '⯈')
                        elseif manual_style == 'Symbols #3' then
                            renderer.texture(arrow_svg3, base_position_right.x-arrow_weight/2+2, base_position_right.y-arrow_height/2+1, arrow_weight, arrow_height, manual_color_bg.r, manual_color_bg.g, manual_color_bg.b, manual_color_bg.a * main, 'f')
                            renderer.texture(arrow_svg3, base_position_right.x-arrow_weight/2+1, base_position_right.y-arrow_height/2, arrow_weight, arrow_height, manual_color.r, manual_color.g, manual_color.b, 255 * right_modifier * main, 'f')
                        end

                        --renderer.rectangle(base_position_right.x, base_position_right.y, 1, 100, 255, 255, 255, 255)
                    end
                end)
            end

            visuals.draw_manual_arrows = (function (self)
                self.manual_arrows.draw()
            end)

            visuals.draw_forced_watermark = (function ()
                screen_size = vector(client.screen_size())
                screen_center = screen_size * 0.5

                if user.debug then
                    local str = inspect(antiaimbot.main.debug):gsub('\t', ('\x20'):rep(4))

                    renderer.text(50, screen_size.y / 4 + 100, 255, 255, 255, 255, '', 0, str)
                end

                if config.visuals.indicators:get() then
                    return
                end

                renderer.text(screen_center.x, screen_size.y - 20, 255, 255, 255, 255, 'c', 0, 'PR0KLADKI')
            end)

            function visuals:player_hurt(event)
                if not player.alive then
                    return
                end

                self.markers.receive(event)
            end

            function visuals:paint()
                self:draw_indicators()
                self:draw_r8_indicator()
                self:draw_manual_arrows()
                self:draw_markers()
            end

            function visuals:paint_ui()
                self:draw_forced_watermark()
            end
        end
    end

    ---
    --- Miscellaneous
    ---
    local miscellaneous do
        config.miscellaneous = {} do
            config.miscellaneous.clantag = menu.new_item(ui.new_checkbox, "AA", "Anti-aimbot angles", "Clantag")
                :record("miscellaneous", "clantag")
                :save()

            config.miscellaneous.cheat_tweaks = menu.new_item(ui.new_checkbox, "AA", "Anti-aimbot angles", "Cheat tweaks")
                :record("miscellaneous", "cheat_tweaks")
                :save()

            config.miscellaneous.cheat_tweaks_list = menu.new_item(ui.new_multiselect, "AA", "Anti-aimbot angles", "Cheat tweaks: List", {
                "Uncharge helper",
                "Super toss on grenade release",
                "Allow crouch on fakeduck"
            }):record("miscellaneous", "cheat_tweaks_list"):save()

            config.miscellaneous.automatic_tp = menu.new_item(ui.new_checkbox, "AA", "Anti-aimbot angles", "Automatic teleport")
                :record("miscellaneous", "automatic_tp")
                :save()

            config.miscellaneous.automatic_tp_weapons = menu.new_item(ui.new_multiselect, "AA", "Anti-aimbot angles", "Automatic teleport: Weapons", {
                "Auto",
                "Scout",
                "AWP",
                "Pistols",
                "Taser",
                "Knife"
            }):record("miscellaneous", "automatic_tp"):save()

            config.miscellaneous.automatic_tp_delay = menu.new_item(ui.new_slider, "AA", "Anti-aimbot angles", "Automatic teleport", 1, 6, 2, true, "t", 1)
                :record("miscellaneous", "automatic_tp_delay")
                :save()
                
            config.miscellaneous.trashtalk = menu.new_item(ui.new_checkbox, "AA", "Anti-aimbot angles", "Trashtalk")
                :record("miscellaneous", "trashtalk")
                :save()
            
            config.miscellaneous.custom_output = menu.new_item(ui.new_checkbox, "AA", "Anti-aimbot angles", "Custom output")
                :record("miscellaneous", "custom_output")
                :save()
                
            config.miscellaneous.event_logger = menu.new_item(ui.new_checkbox, "AA", "Anti-aimbot angles", "Event logger")
                :record("miscellaneous", "event_logger")
                :save()
                
            config.miscellaneous.console_filter = menu.new_item(ui.new_checkbox, "AA", "Anti-aimbot angles", "Console filter")
                :record("miscellaneous", "console_filter")
                :save()
        end

        miscellaneous = {} do
            miscellaneous.clantag = {} do
                function miscellaneous.clantag.reset()
                    for i=1, 64 do
                        client.set_clan_tag('')
                    end        
                end

                function miscellaneous.clantag.build_tag(text)
                    local prefix = '\t'
                    local suffix = '\t'

                    local temp = {}
                    local len = #text

                    if len < 2 then
                        temp[#temp+1] = text
                        return temp
                    end

                    for i = 1, 8 do
                        temp[#temp+1] = string.format('%s%s%s', prefix, text, suffix)
                    end

                    for i = 1, len do
                        local part = text:sub(i, len)
                        temp[#temp+1] = string.format('%s%s%s', prefix, part, suffix)
                    end

                    temp[#temp+1] = string.format('%s%s', prefix, suffix)

                    for i = c_math.min(2, len), len do
                        local part = text:sub(1, i)
                        temp[#temp+1] = string.format('%s%s%s', prefix, part, suffix)
                    end

                    for i = 1, 4 do
                        temp[#temp+1] = string.format('%s%s%s', prefix, text, suffix)
                    end

                    return temp
                end

                local text = 'PR0KLADKI'
                local cache = ''
                local chars = miscellaneous.clantag.build_tag(text)
                local restored = false

                function miscellaneous.clantag:run()
                    if not config.miscellaneous.clantag:get() then
                        if not restored then
                            client.set_clan_tag('')

                            restored = true
                        end

                        return
                    end

                    restored = false

                    local latency_out = client.latency()
                    local lock, game_rules = false, entity.get_game_rules()

                    if game_rules ~= nil then
                        local game_phase = entity.get_prop(game_rules, 'm_gamePhase')

                        lock = game_phase == 4 or game_phase == 5
                    end

                    local latency = latency_out / globals.tickinterval()
                    local predicted = globals.tickcount() + latency

                    local idx = c_math.round(predicted * 0.0625) % #chars + 1

                    local target_text = lock and string.format('%s\t', text) or chars[idx]

                    if target_text == cache then
                        return
                    end

                    client.set_clan_tag(target_text)

                    cache = target_text
                end
            end

            miscellaneous.tweaks = {} do
                miscellaneous.tweaks.dt_reset = false

                local single_fire = {40, 9, 64, 27, 29, 35}

                function miscellaneous.tweaks.uncharge_helper(me, wpn)
                    local tickbase_diff = entity.get_prop(me, 'm_nTickBase') - globals.tickcount()
                    local doubletap_active = c_table.is_hotkey_active(reference.ragebot.doubletap.enable) and not ui.get(reference.ragebot.fakeduck)

                    local wpn_info = csgo_weapons(wpn)

                    if not wpn_info then
                        return
                    end

                    local last_shot_time = entity.get_prop(wpn, 'm_fLastShotTime')

                    if not last_shot_time then
                        return
                    end

                    if not doubletap_active then
                        return
                    end

                    local single_fire_weapon = c_table.contains(single_fire, wpn_info.idx)
                    local value = single_fire_weapon and 1.50 or 0.50
                    local in_attack = globals.curtime() - last_shot_time <= value

                    if wpn_info.is_revolver then
                        local threat = client.current_threat()

                        if threat and not player:get_double_tap() and not player.onground and bit.band(entity.get_esp_data(threat).flags, 2048) == 2048 then
                            override.set(reference.ragebot.enabled[2], 'On hotkey', 0x0)
                        else
                            override.set(reference.ragebot.enabled[2], 'Always on')
                        end
                    else
                        if tickbase_diff > 0 and not player:get_double_tap() then
                            if in_attack then
                                override.set(reference.ragebot.enabled[2], 'Always on')
                            else
                                override.set(reference.ragebot.enabled[2], 'On hotkey', 0x0)
                            end

                        --local threat = client.current_threat()
                        --
                        --if threat and not player:get_double_tap() and not player.onground and bit.band(entity.get_esp_data(threat).flags, 2048) == 2048 then
                        --    reference.ragebot.enabled[2]:override('On hotkey', 0x0)
                        else
                            override.set(reference.ragebot.enabled[2], 'Always on')
                        end
                    end

                    return true
                end

                miscellaneous.tweaks.st_reset = false

                function miscellaneous.tweaks.super_toss()
                    local grenade_release_held = c_table.is_hotkey_active(reference.misc.grenade_release)

                    if grenade_release_held then
                        override.set(reference.misc.grenade_toss, true)

                        miscellaneous.tweaks.st_reset = true
                    else
                        override.unset(reference.misc.grenade_toss)
                    end
                end

                miscellaneous.tweaks.fd_reset = false

                function miscellaneous.tweaks.fakeduck_helper(cmd)
                    local state = false

                    if cmd.in_duck == 1 then
                        if player.duckamount > 0.8 then
                            state = true
                        end
                    end

                    local active, mode = ui.get(reference.ragebot.fakeduck)

                    if active and state then
                        local mode_new = 'Off hotkey'

                        if mode == 2 or mode == 3 then
                            mode_new = 'On hotkey'
                        end

                        override.set(reference.ragebot.fakeduck, mode_new)
                        miscellaneous.tweaks.fd_reset = false
                    elseif not state then
                        if not miscellaneous.tweaks.fd_reset then
                            override.unset(reference.ragebot.fakeduck)
                            miscellaneous.tweaks.fd_reset = true
                        end
                    end
                end
            end

            miscellaneous.automatic_tp = {} do
                local weapon_index = {
                    ['Auto Snipers'] = { 38, 11 },
                    ['Pistols'] = { 4, 63, 36, 3, 1, 64, 2, 30, 61, 32 },
                    ['Scout'] = { 40 },
                    ['AWP'] = { 9 },
                    ['Taser'] = { 31 }
                }

                local delay = 0
                local time = 0
                local last_full = 0

                miscellaneous.automatic_tp.reset = false

                miscellaneous.automatic_tp.trace_thread = (function (me, threat)
                    local player_resource = entity.get_player_resource()

                    if not player_resource then
                        return false
                    end

                    local ping = entity.get_prop(player_resource, 'm_iPing', threat)
                    local ticks_to_extrapolate = math.max(5, toticks( ( ping * (ping <= 10 and 2 or 1.75) ) * 0.001 ))

                    local hitbox_position = vector(entity.hitbox_position(threat, 5))
                    local local_hitbox_position = vector(entity.hitbox_position(me, 4))

                    local entindex, damage = client.trace_bullet(threat, hitbox_position.x, hitbox_position.y, hitbox_position.z, c_math.extrapolate(me, local_hitbox_position, ticks_to_extrapolate):unpack())

                    return (damage and damage > 0 or false) and (entindex and entity.get_classname(entindex) ~= 'CWorld' or false)
                end)

                function miscellaneous.automatic_tp.run(me, wpn)
                    if player.onground or player.speed < 100 or not player:get_double_tap() then
                        return globals.realtime()-last_full < 0.4
                    end

                    local threat = client.current_threat()

                    if not threat or entity.is_dormant(threat) then
                        return
                    end

                    if not wpn then
                        return
                    end

                    local wpn_info = csgo_weapons(wpn)

                    if not wpn_info then
                        return
                    end

                    local active_weapon_id = wpn_info.idx

                    local should_run, found_knife = false, false

                    for _, weapon in ipairs(config.miscellaneous.automatic_tp_weapons:get()) do
                        local curr = weapon_index[weapon]

                        if curr then
                            for __, id in ipairs(curr) do
                                if id == active_weapon_id then
                                    should_run = true
                                    break
                                end
                            end
                        else
                            if weapon == 'Knife' then
                                found_knife = true
                            end
                        end
                    end

                    if not should_run and found_knife then
                        should_run = wpn_info.is_melee_weapon
                    end

                    if not should_run then
                        return
                    end

                    local should_teleport = miscellaneous.automatic_tp.trace_thread(me, threat)

                    if should_teleport and time < globals.realtime() then
                        if delay == config.miscellaneous.automatic_tp_delay:get() then
                            time = globals.realtime() + 0.5

                            override.set(reference.ragebot.doubletap.enable.hotkey, 'On hotkey', 0x0)
                            miscellaneous.automatic_tp.reset = true

                            delay = 0
                        end

                        delay = delay + 1
                    elseif time-globals.realtime() > 0.5 and miscellaneous.automatic_tp.reset then
                        override.unset(reference.ragebot.doubletap.enable.hotkey)

                        miscellaneous.automatic_tp.reset = false
                    end

                    last_full = globals.realtime()

                    return true
                end
            end

            miscellaneous.trashtalk = {} do
                local counter = 0
                local list = {
                    ['head'] = {
                        'клиент обслужен. следующий',
                        'где твой хэдшот, бро? а, точно, у меня',
                        'заряда хватит на всех, тебя уже вычеркнул',
                        'сори за спойлер, но ты мертв',
                        'глаза опустил, как и твою хп-планку',
                        'че так тихо? а, ты уже в спеке',
                        'не вставай. это не просьба, а факт',
                    },
                    ['body'] = {
                        'живот подставил ну ты и лох',
                        'в ноги стрелял? нет, просто ты упал',
                        'дыши, если что ой, прости, нечем',
                        'издеваюсь? нет, просто тренируюсь',
                        'скоро приедет скорая  в виде моего напарника тебе в спину',
                        'счет 1:0  в мою пользу, если что',
                    },
                    ['taser'] = {
                        'бззз бззз. теле',
                        'заряжен? теперь точно нет',
                    },
                    ['inferno'] = {
                        'с днем рождения! вот торт',
                        'греешься? вечно тебе мало',
                        'огонь очищает. особенно хп-бар',
                    },
                    ['hegrenade'] = {
                        'ловлю фраг / и твои конечности',
                        'сюрприз из гранатного нектара',
                        'угадай, что летит? правильно, твоя смерть',
                    },
                    ['death'] = {
                        'я лишь зарядку потратил  а ты всё',
                        'ну вот и встретились. на экране "Спектор"',
                    },
                    ['revenge'] = {
                        'увидимся... в killcam',
                        'я это запомню и исправлю через 5 секунд',
                    }
                }
                local active = false

                local attacker_index = -1

                function miscellaneous.trashtalk.run(type)
                    if not config.miscellaneous.trashtalk:get() then
                        return
                    end

                    local game_rules = entity.get_game_rules()
                    local is_warmup = entity.get_prop(game_rules, 'm_bWarmupPeriod') == 1

                    if is_warmup then
                        return
                    end

                    local phrase_list = list[type]

                    if not phrase_list or active then
                        return
                    end

                    local delay = 0
                    local phrase = phrase_list[counter % #phrase_list + 1]
                    local active_pool = c_string.split(phrase, ' / ')

                    active = true

                    for i=1, #active_pool do
                        local phrase_piece = active_pool[i]
                        local size = phrase_piece:len()
                        local new_delay = delay + size * 0.07

                        client.delay_call(new_delay, function ()
                            client.exec(string.format('say "%s";', phrase_piece))

                            if i == #active_pool then
                                active = false
                            end
                        end)

                        delay = new_delay
                    end

                    counter = counter + 1
                end

                function miscellaneous.trashtalk:on_kill(event)
                    if not config.miscellaneous.trashtalk:get() then
                        return
                    end

                    if list[event.weapon] then
                        self.run(event.weapon)
                    else
                        self.run(event.headshot and 'head' or 'body')
                    end
                end

                function miscellaneous.trashtalk:on_death(event)
                    self.run('death')
                end

                function miscellaneous.trashtalk:on_player_death(event)
                    if event.userid == attacker_index then
                        self.run('revenge')
                        attacker_index = -1
                    end
                end
            end

            miscellaneous.custom_output = {} do
                local list = {}

                miscellaneous.custom_output.paint_ui = (function (ctx)
                    if #list == 0 then
                        return
                    end

                    local hs = select(2, surface.get_text_size(c_constant.fonts.lucida , 'A'))
                    local x, y, size = 8, 5, hs

                    for i=1, #list do
                        local notify = list[i]

                        if notify then
                            notify.m_time = notify.m_time - globals.frametime()

                            if notify.m_time <= 0.0 then
                                table.remove(list, i)
                            end
                        end
                    end

                    if #list == 0 then
                        return
                    end

                    while #list > 8 do
                        table.remove(list, 1)
                    end

                    for i=1, #list do
                        local notify = list[i]
                        local left = notify.m_time
                        local ncolor = notify.m_color

                        if left < 0.5 then
                            local fl = c_math.clamp(left, 0.0, 0.5)

                            ncolor.a = fl * 255.0

                            if i == 1 and fl < 0.2 then
                                y = y - size * (1.0 - fl * 5)
                            end
                        else
                            ncolor.a = 255
                        end

                        local txt = notify.m_text
                        local slist = color.string_to_color_array(string.format('\a%s%s', ncolor:to_hex(), txt))

                        local w_o = 0

                        for j=1, #slist do
                            local obj = slist[j]

                            obj.text = obj.text:gsub('\1', '')

                            local this_w = surface.get_text_size(c_constant.fonts.lucida, obj.text)

                            surface.draw_text(x + w_o, y, obj.color.r, obj.color.g, obj.color.b, ncolor.a, c_constant.fonts.lucida, obj.text)

                            w_o = w_o + this_w
                        end

                        y = y + size
                    end
                end)

                local skip_line

                function miscellaneous.custom_output.output(output)
                    local text_to_draw = output.text

                    local clr = color(output.r, output.g, output.b, output.a)

                    if text_to_draw:find('\0') then
                        text_to_draw = text_to_draw:sub(1, #text_to_draw-1)
                    end

                    if skip_line then
                        if list[#list] then
                            list[#list].m_text = string.format('%s%s', list[#list].m_text, string.format('\a%s%s', clr:to_hex(), text_to_draw))
                        else
                            list[#list+1] = {
                                m_text = text_to_draw,
                                m_color = clr,
                                m_time = 8.0
                            }
                        end

                        skip_line = false
                    else
                        for str in text_to_draw:gmatch('([^\n]+)') do
                            list[#list+1] = {
                                m_text = str,
                                m_color = clr,
                                m_time = 8.0
                            }
                        end
                    end

                    local has_ignore_newline = output.text:find('\0')

                    if has_ignore_newline ~= nil then
                        skip_line = true
                    end
                end
            end

            miscellaneous.event_logger = {} do
                local cache = {}
                local hitgroups = {
                    'body',
                    'head',
                    'chest',
                    'stomach',
                    'left arm',
                    'right arm',
                    'left leg',
                    'right leg',
                    'neck',
                    '?',
                    'gear'
                }

                function miscellaneous.event_logger.aim_fire(event)
                    local this = {
                        tick = event.tick,
                        timestamp = client.timestamp(),
                        wanted_damage = event.damage,
                        wanted_hit_chance = event.hit_chance,
                        wanted_hitgroup = event.hitgroup
                    }

                    cache[event.id] = this
                end

                function miscellaneous.event_logger.aim_hit(event)
                    local cached = cache[event.id]

                    if not cached then
                        return
                    end

                    local options = {}

                    local backtrack = globals.tickcount() - cached.tick

                    if backtrack ~= 0 then
                        options[#options+1] = string.format('bt: %d tick%s (%i ms)', backtrack, c_math.abs(backtrack) == 1 and '' or 's', c_math.round(backtrack*globals.tickinterval()*1000))
                    end

                    local register_delay = client.timestamp() - cached.timestamp

                    if register_delay ~= 0 then
                        options[#options+1] = string.format('delay: %i ms', register_delay)
                    end

                    local name = entity.get_player_name(event.target)
                    local hitgroup = hitgroups[event.hitgroup + 1] or '?'
                    local target_hitgroup = hitgroups[cached.wanted_hitgroup + 1] or '?'
                    local damage = event.damage
                    local health = entity.get_prop(event.target, 'm_iHealth')
                    local hit_chance = event.hit_chance
                    local logger_text = string.format('Hit %s\'s %s for %d%s damage (%s, %d remaining%s)',
                        name,
                        hitgroup,
                        tonumber(damage),
                        cached.wanted_damage ~= damage and string.format('(%d)', cached.wanted_damage) or '',
                        target_hitgroup ~= hitgroup and string.format('aimed: %s(%d%%)', target_hitgroup, hit_chance) or string.format('th: %d%%', hit_chance),
                        health,
                        #options > 0 and string.format(', %s', table.concat(options, ', ')) or ''
                    )

                    if config.miscellaneous.event_logger:get() then
                        print(logger_text)
                    end
                end

                function miscellaneous.event_logger.aim_miss(event)
                    local cached = cache[event.id]

                    if not cached then
                        return
                    end

                    local options = {}

                    local backtrack = globals.tickcount() - cached.tick

                    if backtrack ~= 0 then
                        options[#options+1] = string.format('bt: %d tick%s (%i ms)', backtrack, c_math.abs(backtrack) == 1 and '' or 's', c_math.round(backtrack*globals.tickinterval()*1000))
                    end

                    local register_delay = client.timestamp() - cached.timestamp

                    if register_delay ~= 0 then
                        options[#options+1] = string.format('delay: %i ms', register_delay)
                    end

                    local name = entity.get_player_name(event.target)
                    local hitgroup = hitgroups[event.hitgroup + 1] or '?'
                    local reason = event.reason
                    local damage = cached.wanted_damage
                    local hit_chance = event.hit_chance
                    local logger_text = string.format('Missed %s\'s %s due to %s (td: %d, th: %d%%%s)',
                        name,
                        hitgroup,
                        reason,
                        tonumber(damage),
                        hit_chance,
                        #options > 0 and string.format(', %s', table.concat(options, ', ')) or ''
                    )

                    if config.miscellaneous.event_logger:get() then
                        print(logger_text)
                    end
                end

                local hurt_weapons = {
                    ['knife'] = 'Knifed';
                    ['hegrenade'] = 'Naded';
                    ['inferno'] = 'Burned';
                }

                function miscellaneous.event_logger.player_hurt(event)
                    local attacker = client.userid_to_entindex(event.attacker)

                    if not attacker or attacker ~= entity.get_local_player() then
                        return
                    end

                    local target = client.userid_to_entindex(event.userid)

                    if not target then
                        return
                    end

                    local wpn_type = hurt_weapons[event.weapon]

                    if not wpn_type then
                        return
                    end

                    local name = entity.get_player_name(target)
                    local damage = event.dmg_health

                    local logger_text = string.format('%s %s for %d damage',
                        wpn_type,
                        name,
                        tonumber(damage)
                    )

                    if config.miscellaneous.event_logger:get() then
                        print(logger_text)
                    end
                end
            end

            function miscellaneous:setup_command(cmd, me, wpn)
                local cheat_tweaks = config.miscellaneous.cheat_tweaks:get()
                local tweak_list = config.miscellaneous.cheat_tweaks_list:get()

                if cheat_tweaks and c_table.contains(tweak_list, 'Uncharge helper') or player.air_exploit then
                    self.tweaks.dt_reset = true

                    if not self.tweaks.uncharge_helper(me, wpn) then
                        override.set(reference.ragebot.enabled[2], "Always on")
                    end
                elseif self.tweaks.dt_reset then
                    override.unset(reference.ragebot.enabled[2])
                    self.tweaks.dt_reset = false
                end

                if cheat_tweaks and c_table.contains(tweak_list, 'Allow crouch on fakeduck') then
                    self.tweaks.fakeduck_helper(cmd)
                else
                    if self.tweaks.fd_reset then
                        override.unset(reference.ragebot.fakeduck)
                        self.tweaks.fd_reset = false
                    end
                end

                if not player.air_exploit and not cheat_tweaks then
                    if self.tweaks.fd_reset then
                        override.unset(reference.ragebot.fakeduck)
                        self.tweaks.fd_reset = false
                    end
                end

                if not cheat_tweaks then
                    if self.tweaks.dt_reset then
                        override.unset(reference.ragebot.doubletap.enable)
                        self.tweaks.dt_reset = false
                    end
                end

                if config.miscellaneous.automatic_tp:get() then
                    if not self.automatic_tp.run(me, wpn) and self.automatic_tp.reset then
                        override.unset(reference.ragebot.doubletap.enable.hotkey)
                        self.automatic_tp.reset = false
                    end
                elseif self.automatic_tp.reset then
                    override.unset(reference.ragebot.doubletap.enable.hotkey)
                    self.automatic_tp.reset = false
                end
            end

            function miscellaneous:aim_fire(event)
                self.event_logger.aim_fire(event)
            end

            function miscellaneous:aim_hit(event)
                self.event_logger.aim_hit(event)
            end

            function miscellaneous:aim_miss(event)
                self.event_logger.aim_miss(event)
            end

            function miscellaneous:player_death(event)
                local attacker = client.userid_to_entindex(event.attacker)
                local userid = client.userid_to_entindex(event.userid)

                if not attacker or not userid then
                    return
                end

                if attacker == player.entindex then
                    if userid ~= player.entindex then
                        self.trashtalk:on_kill(event)
                    end
                elseif userid == player.entindex then
                    self.trashtalk:on_death(event)
                else
                    self.trashtalk:on_player_death(event)
                end
            end

            function miscellaneous:player_hurt(event)
                self.event_logger.player_hurt(event)
            end

            function miscellaneous:net_update_end()
                self.clantag:run()
            end

            function miscellaneous:paint_ui()
                local tweaks = config.miscellaneous.cheat_tweaks:get()
                local tweak_list = config.miscellaneous.cheat_tweaks_list:get()

                if tweaks and c_table.contains(tweak_list, 'Super toss on grenade release') then
                    self.tweaks.super_toss()
                elseif miscellaneous.tweaks.st_reset then
                    override.unset(reference.misc.grenade_toss)
                    miscellaneous.tweaks.st_reset = false
                end

                --- ЭХХХ костыль на костыле
                do
                    if not player.valid then
                        if tweaks and c_table.contains(tweak_list, 'Uncharge helper') then
                            self.tweaks.dt_reset = true
                            override.set(reference.ragebot.enabled[2], "Always on")
                        elseif self.tweaks.dt_reset then
                            override.unset(reference.ragebot.enabled[2])
                            self.tweaks.dt_reset = false
                        end
                    end
                end

                self.custom_output.paint_ui()
            end

            function miscellaneous.output_raw(output)
                miscellaneous.custom_output.output(output)
            end

            config.miscellaneous.custom_output:set_callback(function (element)
                local enabled = ui.get(element)

                if enabled and not miscellaneous._output_set then
                    client.set_event_callback('output', miscellaneous.output_raw)

                    miscellaneous._output_set = true
                elseif not enabled and miscellaneous._output_set then
                    client.unset_event_callback('output', miscellaneous.output_raw)

                    miscellaneous._output_set = false
                end

                if enabled then
                    override.set(reference.misc.draw_output, false)
                else
                    override.unset(reference.misc.draw_output)
                end
            end, true)

            config.miscellaneous.console_filter:set_callback(function (element)
                local enabled = ui.get(element)

                if enabled then
                    client.exec('con_filter_enable 1;con_filter_text "\a";')
                else
                    client.exec('con_filter_enable 0;con_filter_text "";')
                end
            end, true)
        end
    end

    ---
    --- Settings
    ---
    local settings do
        config.settings = {} do
            config.settings.import = menu.new_item(ui.new_button, "AA", "Anti-aimbot angles", "Configuration: Import", function () end)
                :config_ignore()
            config.settings.export = menu.new_item(ui.new_button, "AA", "Anti-aimbot angles", "Configuration: Export", function () end)
                :config_ignore()
            config.settings.EBATEL = menu.new_item(ui.new_button, "AA", "Anti-aimbot angles", "Configuration: EBATEL", function () end)
                :config_ignore()
        end

        settings = {} do
            function settings.import()
                local success, err = config_system.import_from_str(clipboard.get())

                if not success then
                    return c_logger.log_error('Failed to load config due to [%s]', err)
                end

                c_logger.log('Config loaded.')
            end

            function settings.export()
                local config_text = config_system.export_to_str()

                clipboard.set(config_text)
                c_logger.log('Config exported.')
            end

            function settings.EBATEL()
                local success, err = config_system.import_from_str("eyJidWlsZGVyIjp7IkFBOjpTdGFuZGluZzo6Sml0dGVyVmFsdWUiOlswXSwiQUE6OlN0YW5kaW5nOjpZYXdCYXNlIjpbIkxvY2FsIHZpZXciXSwiQUE6OkFpciAmIENyb3VjaDo6WWF3U3dpdGNoRGVsYXlTZWNvbmQiOls2XSwiQUE6OkFpciAmIENyb3VjaDo6UGl0Y2hDdXN0b20iOlswXSwiQUE6Ok1vdmluZzo6UGl0Y2giOlsiT2ZmIl0sIkFBOjpGYWtlIGxhZzo6WWF3QmFzZSI6WyJMb2NhbCB2aWV3Il0sIkFBOjpDcm91Y2hpbmc6OkppdHRlclJhbmRvbWl6ZSI6WzBdLCJBQTo6U2xvdy1tb3Rpb246Ollhd0RlbGF5ZWRTd2l0Y2giOltmYWxzZV0sIkFBOjpBaXI6Ollhd0Jhc2UiOlsiTG9jYWwgdmlldyJdLCJBQTo6RmFrZSBsYWc6OkJvZHlWYWx1ZSI6WzBdLCJBQTo6U3RhbmRpbmc6OkVuYWJsZWQiOltmYWxzZV0sIkFBOjpGYWtlIGxhZzo6WWF3Sml0dGVyIjpbIk9mZiJdLCJBQTo6QWlyOjpZYXdTcGVlZCI6WzVdLCJBQTo6U3RhbmRpbmc6Ollhd1JpZ2h0IjpbMF0sIkFBOjpHbG9iYWw6Ollhd0N1c3RvbSI6WzBdLCJBQTo6U3RhbmRpbmc6OlBpdGNoIjpbIk9mZiJdLCJBQTo6U3RhbmRpbmc6Ollhd0RlbGF5ZWRTd2l0Y2giOltmYWxzZV0sIkFBOjpHbG9iYWw6Ollhd1N3aXRjaERlbGF5U2Vjb25kIjpbNl0sIkFBOjpDcm91Y2hpbmc6Ollhd0xlZnQiOlswXSwiQUE6OkNyb3VjaGluZzo6WWF3VHlwZSI6WyJPZmYiXSwiQUE6OkNyb3VjaCBtb3Zpbmc6OkppdHRlclZhbHVlIjpbMF0sIkFBOjpGYWtlIGxhZzo6Sml0dGVyVmFsdWUiOlswXSwiQUE6Ok1vdmluZzo6Qm9keVlhdyI6WyJPZmYiXSwiQUE6OkNyb3VjaCBtb3Zpbmc6Ollhd1NwZWVkIjpbNV0sIkFBOjpBaXI6Ollhd0RlbGF5ZWRTd2l0Y2giOltmYWxzZV0sIkFBOjpDcm91Y2ggbW92aW5nOjpCb2R5WWF3IjpbIk9mZiJdLCJBQTo6R2xvYmFsOjpZYXdKaXR0ZXIiOlsiT2ZmIl0sIkFBOjpBaXI6Ollhd0RlbGF5IjpbNV0sIkFBOjpDcm91Y2hpbmc6OkVuYWJsZWQiOltmYWxzZV0sIkFBOjpNb3Zpbmc6Ollhd0N1c3RvbSI6WzBdLCJBQTo6RmFrZSBsYWc6OlBpdGNoIjpbIk9mZiJdLCJBQTo6U3RhbmRpbmc6OkJvZHlZYXciOlsiT2ZmIl0sIkFBOjpGYWtlIGxhZzo6WWF3TGVmdCI6WzBdLCJBQTo6U2xvdy1tb3Rpb246Ollhd0N1c3RvbSI6WzBdLCJBQTo6RmFrZSBsYWc6Ollhd1JpZ2h0IjpbMF0sIkFBOjpBaXIgJiBDcm91Y2g6Ollhd1R5cGUiOlsiT2ZmIl0sIkFBOjpBaXI6OlBpdGNoQ3VzdG9tIjpbMF0sIkFBOjpDcm91Y2ggbW92aW5nOjpZYXdMZWZ0IjpbMF0sIkFBOjpDcm91Y2ggbW92aW5nOjpZYXdTd2l0Y2hEZWxheVNlY29uZCI6WzZdLCJBQTo6TW92aW5nOjpZYXdSaWdodCI6WzBdLCJBQTo6TW92aW5nOjpKaXR0ZXJWYWx1ZSI6WzBdLCJBQTo6QWlyOjpCb2R5WWF3IjpbIk9mZiJdLCJBQTo6U2xvdy1tb3Rpb246Ollhd0xlZnQiOlswXSwiQUE6OlNsb3ctbW90aW9uOjpZYXdEZWxheSI6WzVdLCJBQTo6QWlyOjpZYXdUeXBlIjpbIk9mZiJdLCJBQTo6U3RhbmRpbmc6Ollhd0ppdHRlciI6WyJPZmYiXSwiQUE6OlN0YW5kaW5nOjpZYXdEZWxheSI6WzVdLCJBQTo6QWlyOjpKaXR0ZXJWYWx1ZSI6WzBdLCJBQTo6QWlyICYgQ3JvdWNoOjpZYXdTcGVlZCI6WzVdLCJBQTo6QWlyOjpFbmFibGVkIjpbZmFsc2VdLCJBQTo6RmFrZSBsYWc6OkVuYWJsZWQiOltmYWxzZV0sIkFBOjpTdGFuZGluZzo6WWF3U3dpdGNoRGVsYXkiOls2XSwiQUE6OkZha2UgbGFnOjpCb2R5WWF3IjpbIk9mZiJdLCJBQTo6Q3JvdWNoaW5nOjpQaXRjaCI6WyJPZmYiXSwiQUE6OkNyb3VjaGluZzo6WWF3U3dpdGNoRGVsYXkiOls2XSwiQUE6OkFpciAmIENyb3VjaDo6Sml0dGVyUmFuZG9taXplIjpbMF0sIkFBOjpNb3Zpbmc6Ollhd1N3aXRjaERlbGF5IjpbNl0sIkFBOjpHbG9iYWw6Ollhd1N3aXRjaERlbGF5IjpbNl0sIkFBOjpDcm91Y2ggbW92aW5nOjpKaXR0ZXJSYW5kb21pemUiOlswXSwiQUE6OkNyb3VjaGluZzo6WWF3RGVsYXkiOls1XSwiQUE6OkNyb3VjaGluZzo6UGl0Y2hDdXN0b20iOlswXSwiQUE6OkNyb3VjaCBtb3Zpbmc6OlBpdGNoIjpbIk9mZiJdLCJBQTo6U2xvdy1tb3Rpb246Ollhd1NwZWVkIjpbNV0sIkFBOjpBaXIgJiBDcm91Y2g6Ollhd0N1c3RvbSI6WzBdLCJBQTo6U3RhbmRpbmc6Ollhd0xlZnQiOlswXSwiQUE6OlN0YW5kaW5nOjpCb2R5VmFsdWUiOlswXSwiQUE6Okdsb2JhbDo6Qm9keVZhbHVlIjpbMF0sIkFBOjpDcm91Y2hpbmc6Ollhd0Jhc2UiOlsiTG9jYWwgdmlldyJdLCJBQTo6U2xvdy1tb3Rpb246Ollhd0Jhc2UiOlsiTG9jYWwgdmlldyJdLCJBQTo6RmFrZSBsYWc6Ollhd0RlbGF5ZWRTd2l0Y2giOltmYWxzZV0sIkFBOjpTbG93LW1vdGlvbjo6Sml0dGVyVmFsdWUiOlswXSwiQUE6OkZha2UgbGFnOjpQaXRjaEN1c3RvbSI6WzBdLCJBQTo6Q3JvdWNoIG1vdmluZzo6WWF3UmlnaHQiOlswXSwiQUE6OkZha2UgbGFnOjpZYXdTd2l0Y2hEZWxheSI6WzZdLCJBQTo6RmFrZSBsYWc6Ollhd1R5cGUiOlsiT2ZmIl0sIkFBOjpDcm91Y2ggbW92aW5nOjpZYXdDdXN0b20iOlswXSwiQUE6OkFpciAmIENyb3VjaDo6Qm9keVZhbHVlIjpbMF0sIkFBOjpHbG9iYWw6OlBpdGNoIjpbIk9mZiJdLCJBQTo6QWlyICYgQ3JvdWNoOjpZYXdTd2l0Y2hEZWxheSI6WzZdLCJBQTo6R2xvYmFsOjpCb2R5WWF3IjpbIk9mZiJdLCJBQTo6TW92aW5nOjpZYXdEZWxheSI6WzVdLCJBQTo6Q3JvdWNoaW5nOjpCb2R5VmFsdWUiOlswXSwiQUE6OkNyb3VjaCBtb3Zpbmc6Ollhd0Jhc2UiOlsiTG9jYWwgdmlldyJdLCJBQTo6Q3JvdWNoIG1vdmluZzo6WWF3VHlwZSI6WyJPZmYiXSwiQUE6OlNsb3ctbW90aW9uOjpQaXRjaEN1c3RvbSI6WzBdLCJBQTo6U2xvdy1tb3Rpb246Ollhd1N3aXRjaERlbGF5U2Vjb25kIjpbNl0sIkFBOjpDcm91Y2ggbW92aW5nOjpZYXdEZWxheSI6WzVdLCJBQTo6Q3JvdWNoIG1vdmluZzo6WWF3U3dpdGNoRGVsYXkiOls2XSwiQUE6OkFpcjo6Sml0dGVyUmFuZG9taXplIjpbMF0sIkFBOjpBaXI6Ollhd1N3aXRjaERlbGF5U2Vjb25kIjpbNl0sIkFBOjpNb3Zpbmc6Ollhd0Jhc2UiOlsiTG9jYWwgdmlldyJdLCJBQTo6R2xvYmFsOjpQaXRjaEN1c3RvbSI6WzBdLCJBQTo6RmFrZSBsYWc6OkppdHRlclJhbmRvbWl6ZSI6WzBdLCJBQTo6Q3JvdWNoIG1vdmluZzo6Qm9keVZhbHVlIjpbMF0sIkFBOjpTbG93LW1vdGlvbjo6UGl0Y2giOlsiT2ZmIl0sIkFBOjpDcm91Y2hpbmc6Ollhd0N1c3RvbSI6WzBdLCJBQTo6U2xvdy1tb3Rpb246OkppdHRlclJhbmRvbWl6ZSI6WzBdLCJBQTo6R2xvYmFsOjpZYXdSaWdodCI6WzBdLCJBQTo6Q3JvdWNoaW5nOjpZYXdTcGVlZCI6WzVdLCJBQTo6TW92aW5nOjpFbmFibGVkIjpbZmFsc2VdLCJBQTo6U3RhbmRpbmc6Ollhd1NwZWVkIjpbNV0sIkFBOjpDcm91Y2hpbmc6OkppdHRlclZhbHVlIjpbMF0sIkFBOjpDcm91Y2ggbW92aW5nOjpZYXdKaXR0ZXIiOlsiT2ZmIl0sIkFBOjpBaXI6Ollhd0xlZnQiOlswXSwiQUE6OkFpciAmIENyb3VjaDo6WWF3RGVsYXkiOls1XSwiQUE6Okdsb2JhbDo6WWF3TGVmdCI6WzBdLCJBQTo6U3RhbmRpbmc6OkppdHRlclJhbmRvbWl6ZSI6WzBdLCJBQTo6U2xvdy1tb3Rpb246Ollhd0ppdHRlciI6WyJPZmYiXSwiQUE6Ok1vdmluZzo6WWF3U3BlZWQiOls1XSwiQUE6Okdsb2JhbDo6WWF3VHlwZSI6WyJPZmYiXSwiQUE6OkFpciAmIENyb3VjaDo6WWF3Sml0dGVyIjpbIk9mZiJdLCJBQTo6TW92aW5nOjpQaXRjaEN1c3RvbSI6WzBdLCJBQTo6U2xvdy1tb3Rpb246OkVuYWJsZWQiOltmYWxzZV0sIkFBOjpDcm91Y2hpbmc6Ollhd1N3aXRjaERlbGF5U2Vjb25kIjpbNl0sIkFBOjpGYWtlIGxhZzo6WWF3RGVsYXkiOls1XSwiQUE6Ok1vdmluZzo6WWF3TGVmdCI6WzBdLCJBQTo6Q3JvdWNoIG1vdmluZzo6RW5hYmxlZCI6W2ZhbHNlXSwiQUE6OkFpcjo6WWF3UmlnaHQiOlswXSwiQUE6OlNsb3ctbW90aW9uOjpCb2R5WWF3IjpbIk9mZiJdLCJBQTo6QWlyOjpQaXRjaCI6WyJPZmYiXSwiQUE6Ok1vdmluZzo6WWF3VHlwZSI6WyJPZmYiXSwiQUE6OlNsb3ctbW90aW9uOjpCb2R5VmFsdWUiOlswXSwiQUE6Ok1vdmluZzo6Qm9keVZhbHVlIjpbMF0sIkFBOjpTdGFuZGluZzo6WWF3U3dpdGNoRGVsYXlTZWNvbmQiOls2XSwiQUE6Ok1vdmluZzo6WWF3RGVsYXllZFN3aXRjaCI6W2ZhbHNlXSwiQUE6OkZha2UgbGFnOjpZYXdDdXN0b20iOlswXSwiQUE6Okdsb2JhbDo6WWF3RGVsYXllZFN3aXRjaCI6W2ZhbHNlXSwiQUE6OkZha2UgbGFnOjpZYXdTd2l0Y2hEZWxheVNlY29uZCI6WzZdLCJBQTo6QWlyICYgQ3JvdWNoOjpZYXdCYXNlIjpbIkxvY2FsIHZpZXciXSwiQUE6Ok1vdmluZzo6WWF3U3dpdGNoRGVsYXlTZWNvbmQiOls2XSwiQUE6OlN0YW5kaW5nOjpZYXdDdXN0b20iOlswXSwiQUE6OlN0YW5kaW5nOjpZYXdUeXBlIjpbIk9mZiJdLCJBQTo6U2xvdy1tb3Rpb246Ollhd1JpZ2h0IjpbMF0sIkFBOjpDcm91Y2hpbmc6Ollhd1JpZ2h0IjpbMF0sIkFBOjpHbG9iYWw6OkppdHRlclZhbHVlIjpbMF0sIkFBOjpTdGFuZGluZzo6UGl0Y2hDdXN0b20iOlswXSwiQUE6Ok1vdmluZzo6WWF3Sml0dGVyIjpbIk9mZiJdLCJBQTo6R2xvYmFsOjpZYXdCYXNlIjpbIkxvY2FsIHZpZXciXSwiQUE6OkNyb3VjaGluZzo6WWF3RGVsYXllZFN3aXRjaCI6W2ZhbHNlXSwiQUE6OlNsb3ctbW90aW9uOjpZYXdUeXBlIjpbIk9mZiJdLCJBQTo6QWlyICYgQ3JvdWNoOjpFbmFibGVkIjpbZmFsc2VdLCJBQTo6Q3JvdWNoIG1vdmluZzo6WWF3RGVsYXllZFN3aXRjaCI6W2ZhbHNlXSwiQUE6Okdsb2JhbDo6WWF3U3BlZWQiOls1XSwiQUE6OkFpciAmIENyb3VjaDo6WWF3RGVsYXllZFN3aXRjaCI6W2ZhbHNlXSwiQUE6OkFpciAmIENyb3VjaDo6Qm9keVlhdyI6WyJPZmYiXSwiQUE6Okdsb2JhbDo6WWF3RGVsYXkiOls1XSwiQUE6OkFpciAmIENyb3VjaDo6Sml0dGVyVmFsdWUiOlswXSwiQUE6Ok1vdmluZzo6Sml0dGVyUmFuZG9taXplIjpbMF0sIkFBOjpDcm91Y2ggbW92aW5nOjpQaXRjaEN1c3RvbSI6WzBdLCJBQTo6QWlyICYgQ3JvdWNoOjpQaXRjaCI6WyJPZmYiXSwiQUE6OkFpcjo6WWF3Sml0dGVyIjpbIk9mZiJdLCJBQTo6Q3JvdWNoaW5nOjpCb2R5WWF3IjpbIk9mZiJdLCJBQTo6QWlyOjpZYXdTd2l0Y2hEZWxheSI6WzZdLCJBQTo6QWlyICYgQ3JvdWNoOjpZYXdMZWZ0IjpbMF0sIkFBOjpBaXI6Ollhd0N1c3RvbSI6WzBdLCJBQTo6Q3JvdWNoaW5nOjpZYXdKaXR0ZXIiOlsiT2ZmIl0sIkFBOjpBaXI6OkJvZHlWYWx1ZSI6WzBdLCJBQTo6RmFrZSBsYWc6Ollhd1NwZWVkIjpbNV0sIkFBOjpHbG9iYWw6OkppdHRlclJhbmRvbWl6ZSI6WzBdLCJBQTo6U2xvdy1tb3Rpb246Ollhd1N3aXRjaERlbGF5IjpbNl0sIkFBOjpBaXIgJiBDcm91Y2g6Ollhd1JpZ2h0IjpbMF19LCJ2aXN1YWxzIjp7ImluZGljYXRvcl92ZXJ0aWNhbF9vZmZzZXQiOlsyMF0sIm1hbnVhbF9hcnJvd3NfYWNjZW50IjpbMjU1LDAsMCwyNTVdLCJkYW1hZ2VfbWFya2VyIjpbdHJ1ZV0sImluZGljYXRvcnMiOlt0cnVlXSwicjhfaW5kaWNhdG9yX2NvbG9yIjpbMjU1LDAsMCwyNTVdLCJpbmRpY2F0b3Jfb3B0aW9ucyI6W1siVmVsb2NpdHkgbW9kaWZpZXIiLCJBZGp1c3Qgd2hpbGUgc2NvcGVkIiwiQWx0ZXIgYWxwaGEgd2hpbGUgc2NvcGVkIiwiQWx0ZXIgYWxwaGEgb24gZ3JlbmFkZSJdXSwiaW5kaWNhdG9yX2NvbG9yIjpbMjU1LDI1NSwyNTUsMjU1XSwicjhfaW5kaWNhdG9yIjpbZmFsc2VdLCJtYW51YWxfYXJyb3dzX29wdGlvbnMiOlt7fV0sIm1hbnVhbF9hcnJvd3Nfc2l6ZSI6WzEwXSwiaW5kaWNhdG9yX3N0eWxlIjpbIlJlbmV3ZWQiXSwibWFudWFsX2Fycm93c19vZmZzZXQiOlszNV0sIm1hbnVhbF9hcnJvd3NfY29sb3IiOls3Nyw3Nyw3NywyNTVdLCJtYW51YWxfYXJyb3dzIjpbZmFsc2VdLCJtYW51YWxfYXJyb3dzX3N0eWxlIjpbIlRyaWFuZ2xlcyJdLCJkYW1hZ2VfbWFya2VyX2NvbG9yIjpbMjU1LDAsMCwyNTVdLCJpbmRpY2F0b3JfcmVuZXdlZF9jb2xvciI6WzEzNywxMzcsMTM3LDI1NV19LCJhbnRpYWltYm90Ijp7ImRlZmVuc2l2ZV9jb25kaXRpb25zX2F1dG8iOltbIk9uIHBlZWsiLCJMZWdpdCBBQSIsIkVkZ2UgZGlyZWN0aW9uIiwiU2FmZSBoZWFkIiwiVHJpZ2dlcmVkIiwiU3RhbmRpbmciLCJTbG93LW1vdGlvbiIsIk1vdmluZyIsIkNyb3VjaGluZyIsIkNyb3VjaCBtb3ZpbmciLCJBaXIiLCJBaXIgJiBDcm91Y2giXV0sImlkZWFsX3RpY2siOltmYWxzZV0sIm1hbnVhbF95YXciOlt0cnVlXSwiYW5pbWF0aW9uX2JyZWFrZXJfYWlyIjpbIldhbGtpbmciXSwic2FmZV9oZWFkX2NvbmRpdGlvbnMiOltbIkFpciBrbmlmZSIsIkFpciB6ZXVzIiwiQWlyICYgQ3JvdWNoIiwiQ3JvdWNoIG1vdmluZyIsIkNyb3VjaGluZyIsIlNsb3ctbW90aW9uIiwiU3RhbmRpbmciXV0sInNhZmVfaGVhZCI6W3RydWVdLCJvcHRpb25zIjpbWyJPbiB1c2UgYW50aWFpbSIsIkZhc3QgbGFkZGVyIiwiRG9ybWFudCBwcmVzZXQiXV0sIndhcm11cF9hYV9jb25kaXRpb25zIjpbWyJXYXJtdXAiLCJSb3VuZCBlbmQiXV0sImFuaW1hdGlvbl9icmVha2VyX2xlZyI6WyJXYWxraW5nIl0sIm1hbnVhbF9vcHRpb25zIjpbWyJKaXR0ZXIgZGlzYWJsZWQiXV0sImZyZWVzdGFuZGluZ19kaXNhYmxlcl9zdGF0ZXMiOltbIkFpciIsIkFpciAmIENyb3VjaCJdXSwid2FybXVwX2FhIjpbdHJ1ZV0sImFuaW1hdGlvbl9icmVha2VyX290aGVyIjpbWyJRdWljayBwZWVrIGxlZ3MiLCJQaXRjaCB6ZXJvIG9uIGxhbmQiXV0sImFuaW1hdGlvbl9icmVha2VyIjpbdHJ1ZV0sImRlZmVuc2l2ZV9hYSI6W3RydWVdLCJhaXJfZXhwbG9pdCI6W2ZhbHNlXSwiZGVmZW5zaXZlX2NvbmRpdGlvbnMiOltbIkNyb3VjaGluZyIsIkNyb3VjaCBtb3ZpbmciLCJBaXIiLCJBaXIgJiBDcm91Y2giXV0sImlkZWFsX3RpY2tfaG90a2V5IjpbIk9uIGhvdGtleSJdLCJwcmVzZXQiOlsiQmxvc3NvbSJdLCJkZWZlbnNpdmVfdGFyZ2V0IjpbWyJEb3VibGUgdGFwIl1dLCJhaXJfZXhwbG9pdF9ob3RrZXkiOlsiT24gaG90a2V5Il0sImZzX29wdGlvbnMiOltbIkppdHRlciBkaXNhYmxlZCJdXSwiZGVmZW5zaXZlX3ByZXNldCI6WyJBdXRvIl0sImRlZmVuc2l2ZV90cmlnZ2VycyI6W1siRmxhc2hlZCIsIkRhbWFnZSByZWNlaXZlZCIsIlJlbG9hZGluZyIsIldlYXBvbiBzd2l0Y2giXV0sImZvcmNlX3RhcmdldF95YXciOlt0cnVlXX0sIm1pc2NlbGxhbmVvdXMiOnsiY2hlYXRfdHdlYWtzX2xpc3QiOltbIlVuY2hhcmdlIGhlbHBlciIsIlN1cGVyIHRvc3Mgb24gZ3JlbmFkZSByZWxlYXNlIiwiQWxsb3cgY3JvdWNoIG9uIGZha2VkdWNrIl1dLCJhdXRvbWF0aWNfdHAiOlt7fV0sImNsYW50YWciOltmYWxzZV0sInRyYXNodGFsayI6W2ZhbHNlXSwiY29uc29sZV9maWx0ZXIiOlt0cnVlXSwiYXV0b21hdGljX3RwX2RlbGF5IjpbMl0sImN1c3RvbV9vdXRwdXQiOlt0cnVlXSwiZXZlbnRfbG9nZ2VyIjpbdHJ1ZV0sImNoZWF0X3R3ZWFrcyI6W3RydWVdfSwiZGVmZW5zaXZlIjp7IkRFRjo6QWlyOjpQaXRjaCI6WyJEZWZhdWx0Il0sIkRFRjo6T24gcGVlazo6UGl0Y2giOlsiRGVmYXVsdCJdLCJERUY6Ok9uIHBlZWs6Ollhd1JhbmRvbWl6ZSI6WzBdLCJERUY6OkNyb3VjaCBtb3Zpbmc6Ollhd0xlZnRTdGFydCI6WzBdLCJERUY6OlNsb3ctbW90aW9uOjpQaXRjaCI6WyJEZWZhdWx0Il0sIkRFRjo6R2xvYmFsOjpZYXdTcGVlZCI6WzFdLCJERUY6Okdsb2JhbDo6WWF3UmFuZG9taXplIjpbMF0sIkRFRjo6TW92aW5nOjpQaXRjaCI6WyJEZWZhdWx0Il0sIkRFRjo6TGVnaXQgQUE6OlBpdGNoQ3VzdG9tIjpbODldLCJERUY6OlN0YW5kaW5nOjpZYXdSYW5kb21pemUiOlswXSwiREVGOjpDcm91Y2hpbmc6Ollhd0RlbGF5IjpbNl0sIkRFRjo6U2xvdy1tb3Rpb246Ollhd1NwZWVkIjpbMV0sIkRFRjo6R2xvYmFsOjpQaXRjaCI6WyJEZWZhdWx0Il0sIkRFRjo6RWRnZSBkaXJlY3Rpb246OkVuYWJsZWQiOltmYWxzZV0sIkRFRjo6TW92aW5nOjpZYXdMZWZ0IjpbMF0sIkRFRjo6TW92aW5nOjpZYXdUbyI6WzBdLCJERUY6OkFpciAmIENyb3VjaDo6WWF3TGVmdFRhcmdldCI6WzBdLCJERUY6OkxlZ2l0IEFBOjpQaXRjaCI6WyJEZWZhdWx0Il0sIkRFRjo6Q3JvdWNoaW5nOjpQaXRjaCI6WyJEZWZhdWx0Il0sIkRFRjo6Q3JvdWNoaW5nOjpZYXdUbyI6WzBdLCJERUY6OlNsb3ctbW90aW9uOjpZYXdSaWdodFRhcmdldCI6WzBdLCJERUY6OkNyb3VjaGluZzo6WWF3IjpbIkRlZmF1bHQiXSwiREVGOjpTbG93LW1vdGlvbjo6RW5hYmxlZCI6W2ZhbHNlXSwiREVGOjpNb3Zpbmc6Ollhd0xlZnRTdGFydCI6WzBdLCJERUY6Ok9uIHBlZWs6OlBpdGNoQ3VzdG9tIjpbODldLCJERUY6OkFpcjo6UGl0Y2hDdXN0b20iOls4OV0sIkRFRjo6R2xvYmFsOjpZYXdSaWdodFRhcmdldCI6WzBdLCJERUY6OlN0YW5kaW5nOjpQaXRjaCI6WyJEZWZhdWx0Il0sIkRFRjo6U2xvdy1tb3Rpb246Ollhd0xlZnRUYXJnZXQiOlswXSwiREVGOjpBaXI6Ollhd1JhbmRvbWl6ZSI6WzBdLCJERUY6Okdsb2JhbDo6WWF3UmlnaHRTdGFydCI6WzBdLCJERUY6OlN0YW5kaW5nOjpZYXdGcm9tIjpbMF0sIkRFRjo6TW92aW5nOjpZYXdSaWdodFN0YXJ0IjpbMF0sIkRFRjo6TW92aW5nOjpZYXdMZWZ0VGFyZ2V0IjpbMF0sIkRFRjo6QWlyICYgQ3JvdWNoOjpZYXdSaWdodFRhcmdldCI6WzBdLCJERUY6Okdsb2JhbDo6WWF3TGVmdFRhcmdldCI6WzBdLCJERUY6OkFpciAmIENyb3VjaDo6RW5hYmxlZCI6W2ZhbHNlXSwiREVGOjpHbG9iYWw6Ollhd0xlZnQiOlswXSwiREVGOjpDcm91Y2ggbW92aW5nOjpQaXRjaEN1c3RvbSI6Wzg5XSwiREVGOjpBaXIgJiBDcm91Y2g6Ollhd1JhbmRvbWl6ZSI6WzBdLCJERUY6Okdsb2JhbDo6WWF3UmlnaHQiOlswXSwiREVGOjpNb3Zpbmc6Ollhd0Zyb20iOlswXSwiREVGOjpDcm91Y2ggbW92aW5nOjpZYXdTcGVlZCI6WzFdLCJERUY6OkNyb3VjaGluZzo6WWF3UmlnaHRTdGFydCI6WzBdLCJERUY6OlNsb3ctbW90aW9uOjpZYXdGcm9tIjpbMF0sIkRFRjo6U2FmZSBoZWFkOjpFbmFibGVkIjpbZmFsc2VdLCJERUY6OlRyaWdnZXJlZDo6RW5hYmxlZCI6W2ZhbHNlXSwiREVGOjpMZWdpdCBBQTo6WWF3UmFuZG9taXplIjpbMF0sIkRFRjo6R2xvYmFsOjpQaXRjaEN1c3RvbSI6Wzg5XSwiREVGOjpBaXIgJiBDcm91Y2g6OlBpdGNoQ3VzdG9tIjpbODldLCJERUY6OkxlZ2l0IEFBOjpZYXdTcGVlZCI6WzFdLCJERUY6Ok1vdmluZzo6WWF3UmlnaHQiOlswXSwiREVGOjpBaXIgJiBDcm91Y2g6Ollhd0Zyb20iOlswXSwiREVGOjpNb3Zpbmc6OlBpdGNoQ3VzdG9tIjpbODldLCJERUY6OkFpcjo6WWF3TGVmdFN0YXJ0IjpbMF0sIkRFRjo6Q3JvdWNoIG1vdmluZzo6WWF3UmlnaHQiOlswXSwiREVGOjpNb3Zpbmc6Ollhd0RlbGF5IjpbNl0sIkRFRjo6QWlyICYgQ3JvdWNoOjpZYXciOlsiRGVmYXVsdCJdLCJERUY6OkxlZ2l0IEFBOjpZYXdMZWZ0IjpbMF0sIkRFRjo6R2xvYmFsOjpZYXciOlsiRGVmYXVsdCJdLCJERUY6OlN0YW5kaW5nOjpZYXdMZWZ0IjpbMF0sIkRFRjo6QWlyOjpZYXdSaWdodFN0YXJ0IjpbMF0sIkRFRjo6Q3JvdWNoaW5nOjpZYXdMZWZ0IjpbMF0sIkRFRjo6QWlyOjpFbmFibGVkIjpbZmFsc2VdLCJERUY6OkFpcjo6WWF3UmlnaHRUYXJnZXQiOlswXSwiREVGOjpDcm91Y2hpbmc6Ollhd1JhbmRvbWl6ZSI6WzBdLCJERUY6OlN0YW5kaW5nOjpZYXdSaWdodCI6WzBdLCJERUY6Ok9uIHBlZWs6Ollhd1JpZ2h0IjpbMF0sIkRFRjo6TGVnaXQgQUE6OkVuYWJsZWQiOltmYWxzZV0sIkRFRjo6U2xvdy1tb3Rpb246Ollhd0xlZnRTdGFydCI6WzBdLCJERUY6OkFpciAmIENyb3VjaDo6WWF3VG8iOlswXSwiREVGOjpPbiBwZWVrOjpZYXdMZWZ0VGFyZ2V0IjpbMF0sIkRFRjo6U2xvdy1tb3Rpb246Ollhd1JhbmRvbWl6ZSI6WzBdLCJERUY6Ok9uIHBlZWs6Ollhd1NwZWVkIjpbMV0sIkRFRjo6U3RhbmRpbmc6OkVuYWJsZWQiOltmYWxzZV0sIkRFRjo6U3RhbmRpbmc6OllhdyI6WyJEZWZhdWx0Il0sIkRFRjo6QWlyOjpZYXciOlsiRGVmYXVsdCJdLCJERUY6OkFpciAmIENyb3VjaDo6WWF3RGVsYXkiOls2XSwiREVGOjpMZWdpdCBBQTo6WWF3RnJvbSI6WzBdLCJERUY6OkNyb3VjaCBtb3Zpbmc6Ollhd0RlbGF5IjpbNl0sIkRFRjo6QWlyOjpZYXdGcm9tIjpbMF0sIkRFRjo6U2xvdy1tb3Rpb246OlBpdGNoQ3VzdG9tIjpbODldLCJERUY6OlNsb3ctbW90aW9uOjpZYXdSaWdodFN0YXJ0IjpbMF0sIkRFRjo6Q3JvdWNoaW5nOjpFbmFibGVkIjpbZmFsc2VdLCJERUY6Ok9uIHBlZWs6OllhdyI6WyJEZWZhdWx0Il0sIkRFRjo6U3RhbmRpbmc6Ollhd1JpZ2h0U3RhcnQiOlswXSwiREVGOjpPbiBwZWVrOjpFbmFibGVkIjpbZmFsc2VdLCJERUY6OkxlZ2l0IEFBOjpZYXdEZWxheSI6WzZdLCJERUY6OkFpcjo6WWF3VG8iOlswXSwiREVGOjpTdGFuZGluZzo6WWF3TGVmdFN0YXJ0IjpbMF0sIkRFRjo6Q3JvdWNoIG1vdmluZzo6WWF3UmlnaHRUYXJnZXQiOlswXSwiREVGOjpHbG9iYWw6Ollhd0RlbGF5IjpbNl0sIkRFRjo6Q3JvdWNoIG1vdmluZzo6WWF3IjpbIkRlZmF1bHQiXSwiREVGOjpNb3Zpbmc6OkVuYWJsZWQiOltmYWxzZV0sIkRFRjo6Q3JvdWNoaW5nOjpZYXdSaWdodFRhcmdldCI6WzBdLCJERUY6OkNyb3VjaGluZzo6WWF3U3BlZWQiOlsxXSwiREVGOjpBaXI6Ollhd1NwZWVkIjpbMV0sIkRFRjo6RWRnZSBkaXJlY3Rpb246OlRhcmdldCI6W3t9XSwiREVGOjpNb3Zpbmc6Ollhd1JhbmRvbWl6ZSI6WzBdLCJERUY6OlN0YW5kaW5nOjpQaXRjaEN1c3RvbSI6Wzg5XSwiREVGOjpNb3Zpbmc6Ollhd1NwZWVkIjpbMV0sIkRFRjo6U3RhbmRpbmc6Ollhd0xlZnRUYXJnZXQiOlswXSwiREVGOjpNb3Zpbmc6Ollhd1JpZ2h0VGFyZ2V0IjpbMF0sIkRFRjo6T24gcGVlazo6WWF3TGVmdFN0YXJ0IjpbMF0sIkRFRjo6Q3JvdWNoaW5nOjpZYXdSaWdodCI6WzBdLCJERUY6OkNyb3VjaGluZzo6UGl0Y2hDdXN0b20iOls4OV0sIkRFRjo6QWlyICYgQ3JvdWNoOjpZYXdSaWdodFN0YXJ0IjpbMF0sIkRFRjo6Q3JvdWNoIG1vdmluZzo6UGl0Y2giOlsiRGVmYXVsdCJdLCJERUY6OkxlZ2l0IEFBOjpZYXdUbyI6WzBdLCJERUY6OkxlZ2l0IEFBOjpZYXdSaWdodFRhcmdldCI6WzBdLCJERUY6OlN0YW5kaW5nOjpZYXdSaWdodFRhcmdldCI6WzBdLCJERUY6Okdsb2JhbDo6WWF3RnJvbSI6WzBdLCJERUY6Okdsb2JhbDo6WWF3TGVmdFN0YXJ0IjpbMF0sIkRFRjo6U2xvdy1tb3Rpb246Ollhd0RlbGF5IjpbNl0sIkRFRjo6Q3JvdWNoIG1vdmluZzo6WWF3UmFuZG9taXplIjpbMF0sIkRFRjo6TGVnaXQgQUE6Ollhd0xlZnRUYXJnZXQiOlswXSwiREVGOjpBaXIgJiBDcm91Y2g6Ollhd0xlZnQiOlswXSwiREVGOjpPbiBwZWVrOjpZYXdGcm9tIjpbMF0sIkRFRjo6TGVnaXQgQUE6Ollhd0xlZnRTdGFydCI6WzBdLCJERUY6Ok9uIHBlZWs6Ollhd1RvIjpbMF0sIkRFRjo6Q3JvdWNoaW5nOjpZYXdMZWZ0VGFyZ2V0IjpbMF0sIkRFRjo6Q3JvdWNoIG1vdmluZzo6WWF3VG8iOlswXSwiREVGOjpTbG93LW1vdGlvbjo6WWF3IjpbIkRlZmF1bHQiXSwiREVGOjpDcm91Y2ggbW92aW5nOjpZYXdGcm9tIjpbMF0sIkRFRjo6U2xvdy1tb3Rpb246Ollhd1RvIjpbMF0sIkRFRjo6T24gcGVlazo6WWF3RGVsYXkiOls2XSwiREVGOjpNb3Zpbmc6OllhdyI6WyJEZWZhdWx0Il0sIkRFRjo6U2xvdy1tb3Rpb246Ollhd0xlZnQiOlswXSwiREVGOjpHbG9iYWw6Ollhd1RvIjpbMF0sIkRFRjo6Q3JvdWNoIG1vdmluZzo6WWF3UmlnaHRTdGFydCI6WzBdLCJERUY6OkNyb3VjaGluZzo6WWF3RnJvbSI6WzBdLCJERUY6OkFpciAmIENyb3VjaDo6WWF3U3BlZWQiOlsxXSwiREVGOjpTbG93LW1vdGlvbjo6WWF3UmlnaHQiOlswXSwiREVGOjpDcm91Y2ggbW92aW5nOjpZYXdMZWZ0VGFyZ2V0IjpbMF0sIkRFRjo6T24gcGVlazo6WWF3TGVmdCI6WzBdLCJERUY6OkxlZ2l0IEFBOjpZYXdSaWdodFN0YXJ0IjpbMF0sIkRFRjo6T24gcGVlazo6WWF3UmlnaHRTdGFydCI6WzBdLCJERUY6OkNyb3VjaGluZzo6WWF3TGVmdFN0YXJ0IjpbMF0sIkRFRjo6QWlyICYgQ3JvdWNoOjpZYXdMZWZ0U3RhcnQiOlswXSwiREVGOjpHbG9iYWw6OkVuYWJsZWQiOltmYWxzZV0sIkRFRjo6QWlyOjpZYXdEZWxheSI6WzZdLCJERUY6OkNyb3VjaCBtb3Zpbmc6Ollhd0xlZnQiOlswXSwiREVGOjpBaXIgJiBDcm91Y2g6Ollhd1JpZ2h0IjpbMF0sIkRFRjo6TGVnaXQgQUE6OllhdyI6WyJEZWZhdWx0Il0sIkRFRjo6QWlyOjpZYXdMZWZ0VGFyZ2V0IjpbMF0sIkRFRjo6U3RhbmRpbmc6Ollhd1RvIjpbMF0sIkRFRjo6QWlyOjpZYXdSaWdodCI6WzBdLCJERUY6OkFpcjo6WWF3TGVmdCI6WzBdLCJERUY6OkNyb3VjaCBtb3Zpbmc6OkVuYWJsZWQiOltmYWxzZV0sIkRFRjo6T24gcGVlazo6WWF3UmlnaHRUYXJnZXQiOlswXSwiREVGOjpTdGFuZGluZzo6WWF3U3BlZWQiOlsxXSwiREVGOjpTdGFuZGluZzo6WWF3RGVsYXkiOls2XSwiREVGOjpMZWdpdCBBQTo6WWF3UmlnaHQiOlswXSwiREVGOjpBaXIgJiBDcm91Y2g6OlBpdGNoIjpbIkRlZmF1bHQiXX0sIm1hbnVhbHMiOnsicmlnaHQiOlsiT24gaG90a2V5Il0sImxlZnQiOlsiT24gaG90a2V5Il0sImJhY2t3YXJkIjpbIk9uIGhvdGtleSJdLCJlZGdlIjpbIk9uIGhvdGtleSJdLCJmb3J3YXJkIjpbIk9uIGhvdGtleSJdLCJyZXNldCI6WyJPbiBob3RrZXkiXSwiZnJlZXN0YW5kaW5nIjpbIk9uIGhvdGtleSJdfSwiZmFrZWxhZyI6eyJlbmFibGUiOlt0cnVlXSwidGlja3MiOlsxNF0sInR5cGUiOlsiUmFuZG9taXplIl19fQ==_PR0KLADKI");

                if not success then
                    return c_logger.log_error('Failed to load builtin config due to [%s]', err)
                end

                c_logger.log('EBATEL config loaded.')
            end

            config.settings.import:set_callback(settings.import)
            config.settings.export:set_callback(settings.export)
            config.settings.EBATEL:set_callback(settings.EBATEL)
        end
    end

    ---
    --- Antiaim presets
    ---
    local antiaim_presets do
        config.presets = {} do
            config.presets.list = menu.new_item(ui.new_listbox, "AA", "Anti-aimbot angles", "Presets: List", {})
                :config_ignore()
            config.presets.name = menu.new_item(ui.new_textbox, "AA", "Anti-aimbot angles", "Preset: Name")
                :config_ignore()

            config.presets.load = menu.new_item(ui.new_button, "AA", "Anti-aimbot angles", "Preset: Load", function () end)
                :config_ignore()
            config.presets.save = menu.new_item(ui.new_button, "AA", "Anti-aimbot angles", "Preset: Save", function () end)
                :config_ignore()
            config.presets.remove = menu.new_item(ui.new_button, "AA", "Anti-aimbot angles", "Preset: Remove", function () end)
                :config_ignore()
            config.presets.import = menu.new_item(ui.new_button, "AA", "Anti-aimbot angles", "Preset: Import", function () end)
                :config_ignore()
            config.presets.export = menu.new_item(ui.new_button, "AA", "Anti-aimbot angles", "Preset: Export", function () end)
                :config_ignore()
        end


        antiaim_presets = {} do
            local database_name = 'PR0KLADKI_presets'
            local list = {}

            local create_preset, Preset do
                Preset = {} do
                    function Preset:load()
                        local success, err = config_system.import_from_str(self.data, "builder", "defensive")

                        if not success then
                            c_logger.log_error('Failed to load cfg [%s]', err)

                            return false
                        end
                    end

                    function Preset:import()
                        local data = clipboard.get()
                        local success, err = config_system.import_from_str(self.data, "builder", "defensive")

                        if not success then
                            c_logger.log_error('Failed to import cfg [%s]', err)

                            return false
                        end

                        self.data = data

                        return true
                    end

                    function Preset:export()
                        clipboard.set(self.data)
                    end

                    function Preset:save()
                        local result = config_system.export_to_str("builder", "defensive")
                        self.data = result
                    end

                    function Preset:to_database()
                        return {
                            name = self.name,
                            data = self.data
                        }
                    end

                    function create_preset(preset)
                        return setmetatable({
                            name = preset.name,
                            data = preset.data
                        }, {
                            __index = Preset
                        })
                    end
                end
            end

            function antiaim_presets.update_list()
                local list_names = {}
                local list_len = #list

                for i=1, list_len do
                    local preset = list[i]

                    list_names[i] = preset.name
                end

                if #list_names == 0 then
                    list_names[1] = 'No presets here! Create one'
                end

                ui.update(config.presets.list:get_ref(), list_names)
            end

            function antiaim_presets.lookup(name)
                local search = c_string.trim(name)
                local list_len = #list

                for i=1, list_len do
                    local preset = list[i]

                    if preset.name == search then
                        return preset, i - 1
                    end
                end
            end

            function antiaim_presets.create(name)
                local target = c_string.trim(name)

                local success, result = pcall(function (...)
                    return ('%s_pr0kladki'):format(config_system.export_to_str("builder", "defensive"))
                end)

                if not success then
                    c_logger.log_error('Preset failed to create [%s]', result)

                    return
                end

                list[#list+1] = create_preset({
                    name = target,
                    data = result
                })

                antiaim_presets.update_list()
                antiaim_presets.flush()
            end

            function antiaim_presets.list_name_changed()
                if #list == 0 then
                    return
                end

                local selected_id = config.presets.list:rawget() or 0
                local selected = list[selected_id + 1]

                if selected == nil then
                    selected = list[#list]
                end

                config.presets.name:set(selected.name)
            end

            function antiaim_presets.delete(target)
                local list_len = #list

                for i=1, list_len do
                    local preset = list[i]

                    if preset.name == target.name then
                        c_logger.log('Removed preset [%s]', preset.name)

                        table.remove(list, i)

                        break
                    end
                end

                antiaim_presets.update_list()
                antiaim_presets.flush()
                antiaim_presets.list_name_changed()
            end

            function antiaim_presets.initialize()
                local database_list = database.read(database_name)

                if database_list == nil then
                    database_list = {}
                end

                local list_len = #database_list

                for i=1, list_len do
                    local preset = database_list[i]

                    list[i] = create_preset(preset)
                end

                antiaim_presets.update_list()
                antiaim_presets.list_name_changed()
            end

            function antiaim_presets.flush()
                local database_list = {}

                local list_len = #list

                for i=1, list_len do
                    database_list[i] = list[i]:to_database()
                end

                c_logger.log('Presets db saved.')

                database.write(database_name, database_list)
            end

            antiaim_presets.methods = {} do
                function antiaim_presets.methods.load()
                    local name = config.presets.name:rawget()
                    local preset, id = antiaim_presets.lookup(name)

                    if preset == nil then
                        c_logger.log_error('No preset selected!');

                        return
                    end

                    c_logger.log('Loading preset "%s"', name)

                    preset:load()
                    config.presets.list:set(id)
                end

                function antiaim_presets.methods.save()
                    local name = config.presets.name:rawget()
                    local preset, id = antiaim_presets.lookup(name)

                    if preset == nil then
                        c_logger.log_error('Creating preset "%s"', name);

                        antiaim_presets.create(name)
                        config.presets.list:set(#list-1)

                        return
                    end

                    c_logger.log('Saving preset "%s"', name)

                    preset:save()
                    config.presets.list:set(id)

                    antiaim_presets.flush()
                end

                function antiaim_presets.methods.export()
                    local name = config.presets.name:rawget()
                    local preset, id = antiaim_presets.lookup(name)

                    if preset == nil then
                        c_logger.log_error('No preset selected!');

                        return
                    end

                    c_logger.log('Exporting preset "%s"', name)

                    preset:export()
                    config.presets.list:set(id)
                end

                function antiaim_presets.methods.import()
                    local name = config.presets.name:rawget()
                    local preset, id = antiaim_presets.lookup(name)
                    local new_one = false

                    if preset == nil then
                        antiaim_presets.create(name)

                        preset, id = antiaim_presets.lookup(name)
                        new_one = true;
                    end

                    if preset then
                        if preset:import() then
                            c_logger.log('Preset imported [%s].', name)
                        end

                        if new_one then
                            antiaim_presets.flush()
                        end

                        config.presets.list:set(id)
                    end
                end

                function antiaim_presets.methods.remove()
                    local name = config.presets.name:rawget()
                    local preset = antiaim_presets.lookup(name)

                    if preset == nil then
                        return
                    else
                        antiaim_presets.delete(preset)
                    end
                end
            end

            config.presets.load:set_callback(antiaim_presets.methods.load)
            config.presets.save:set_callback(antiaim_presets.methods.save)
            config.presets.export:set_callback(antiaim_presets.methods.export)
            config.presets.import:set_callback(antiaim_presets.methods.import)
            config.presets.remove:set_callback(antiaim_presets.methods.remove)

            config.presets.list:set_callback(function ()
                antiaim_presets.list_name_changed()
            end)

            antiaim_presets.initialize()
        end
    end

    ---
    --- Menu state
    ---
    local menu_state = {} do
        function menu_state.visibility(shutdown)
            local should_show_aa = shutdown
            --local should_show_fl = not config.fakelag.enable:get() or shutdown
            local should_show_fl = config.navigation.tab:get() ~= "Anti-aimbot" or shutdown

            if should_show_fl and not shutdown then
                should_show_fl = not config.fakelag.enable:get()
            end

            if should_show_aa then
                override.unset(reference.antiaim.master)
            else
                override.set(reference.antiaim.master, true)
            end

            ui.set_visible(reference.antiaim.master, should_show_aa)

            ui.set_visible(reference.antiaim.roll, should_show_aa)
            ui.set_visible(reference.antiaim.freestanding[1], should_show_aa)
            ui.set_visible(reference.antiaim.freestanding[2], should_show_aa)
            ui.set_visible(reference.antiaim.yaw.edge, should_show_aa)

            ui.set_visible(reference.antiaim.pitch.type, should_show_aa)
            ui.set_visible(reference.antiaim.pitch.value, should_show_aa and ui.get(reference.antiaim.pitch.type) == 'Custom')

            ui.set_visible(reference.antiaim.yaw.base, should_show_aa)

            ui.set_visible(reference.antiaim.yaw.yaw.type, should_show_aa)

            local should_show_yaw_value = ui.get(reference.antiaim.yaw.yaw.type) ~= 'Off'

            ui.set_visible(reference.antiaim.yaw.yaw.value, should_show_aa and should_show_yaw_value)

            ui.set_visible(reference.antiaim.yaw.jitter.type, should_show_aa)

            local should_show_yaw_jitter = ui.get(reference.antiaim.yaw.jitter.type) ~= 'Off'

            ui.set_visible(reference.antiaim.yaw.jitter.value, should_show_aa and should_show_yaw_jitter)

            ui.set_visible(reference.antiaim.body.yaw.type, should_show_aa)

            local body_yaw = ui.get(reference.antiaim.body.yaw.type)
            local should_show_body_yaw = body_yaw ~= 'Disabled' and body_yaw ~= 'Opposite'

            ui.set_visible(reference.antiaim.body.yaw.value, should_show_aa and should_show_body_yaw)

            ui.set_visible(reference.antiaim.body.freestanding, should_show_aa)

            ui.set_visible(reference.fakelag.amount, should_show_fl)
            ui.set_visible(reference.fakelag.enable[1], should_show_fl)
            ui.set_visible(reference.fakelag.enable[2], should_show_fl)
            ui.set_visible(reference.fakelag.limit, should_show_fl)
            ui.set_visible(reference.fakelag.variance, should_show_fl)

            --local should_show_other = config.navigation.tab:get() ~= "Anti-aimbot" or shutdown

            --ui.set_visible(reference.misc.slowmotion[1], should_show_other)
            --ui.set_visible(reference.misc.slowmotion[2], should_show_other)
            --ui.set_visible(reference.misc.leg_movement, should_show_other)
            --ui.set_visible(reference.misc.onshot_antiaim[1], should_show_other)
            --ui.set_visible(reference.misc.onshot_antiaim[2], should_show_other)
            --ui.set_visible(reference.misc.fake_peek[1], should_show_other)
            --ui.set_visible(reference.misc.fake_peek[2], should_show_other)
        end

        do
            local transform = function (text)
                local cache = {}

                for w in string.gmatch(text, '.[\128-\191]*') do
                    cache[#cache + 1] = {
                        w = w,
                        n = 0,
                        d = false,
                        p = {0}
                    }
                end

                return cache
            end

            local linear = function (t, d, s)
                t[1] = c_math.clamp(t[ 1 ] + (globals.frametime() * s * (d and 1 or -1)), 0, 1)
                return t[1]
            end

            local label = transform(string.format('PR0KLADKI : %s', user.role))
            local menu_color = ui.reference("MISC", "Settings", "Menu color")

            menu_state.label = (function ()
                local result = {}
                local sidebar, accent = { 150, 176, 186, 255 }, { ui.get(menu_color) }
                local realtime = globals.realtime()
        
                for i, v in ipairs(label) do
                    if realtime >= v.n then
                        v.d = not v.d
                        v.n = realtime + client.random_float(1, 3)
                    end
        
                    local alpha = linear(v.p, v.d, 1)
                    local r, g, b, a = color(sidebar[1], sidebar[2], sidebar[3], sidebar[4]):lerp(color(accent[1], accent[2], accent[3], accent[4]), math.min(alpha + 0.5, 1)):unpack()
        
                    result[ #result + 1 ] = string.format('\a%02x%02x%02x%02x%s', r, g, b, 200 * alpha + 55, v.w)
                end
        
                config.navigation.label:set(table.concat(result))
            end)
        end
    end

    ---
    --- Callbacks
    ---
    local callbacks, events = {}, {} do
        function callbacks.start()
            c_logger.log('Welcome back, %s!', user.name)

            client.delay_call(0.25, function ()
                config.builder.antiaim_state:set('Standing')
                antiaim_presets.initialize()
                config_system:retrieve_local()
            end)
        end

        function callbacks.menu()
            config.navigation.label:display()
            config.navigation.tab:display()

            local tab = config.navigation.tab:get()
        
            if tab == "Anti-aimbot" then
                config.antiaimbot.main_label:display() do
                    config.antiaimbot.options:display()
                    config.antiaimbot.preset:display()

                    local preset = config.antiaimbot.preset:get()

                    if preset == "Constructor" then
                        config.builder.antiaim_state:display()

                        local state = config.builder.antiaim_state:get()
                        local list = antiaimbot_builder.settings[state]
                        local show = true

                        if list.enabled then
                            list.enabled:display()

                            show = list.enabled:get()
                        end

                        if show then
                            list.pitch:display()

                            if list.pitch:get() == "Custom" then
                                list.pitch_custom:display()
                            end

                            list.yaw_base:display()
                            list.yaw_type:display()

                            local yaw_type = list.yaw_type:get()
                            local delayed_switch = false

                            if yaw_type == "Left & Right" or yaw_type == "Flick" or yaw_type == "Sway" or yaw_type == "Spin between" then
                                list.yaw_left:display()
                                list.yaw_right:display()

                                if yaw_type == "Left & Right" then
                                    list.yaw_delayed_switch:display()

                                    if list.yaw_delayed_switch:get() then
                                        delayed_switch = true

                                        list.yaw_switch_delay:display()
                                        list.yaw_switch_delay_second:display()
                                    end
                                else
                                    list.yaw_delay:display()
                                    list.yaw_speed:display()
                                end
                            elseif yaw_type ~= "Off" then
                                list.yaw_amount:display()
                            end

                            list.yaw_jitter:display()

                            if list.yaw_jitter:get() ~= "Off" then
                                list.jitter_value:display()
                                list.jitter_randomize:display()
                            end

                            if not delayed_switch then
                                list.body_yaw:display()

                                if list.body_yaw:get() ~= "Off" then
                                    list.body_value:display()
                                end
                            end
                        end
                    end
                end

                config.antiaimbot.misc_label:display() do
                    config.antiaimbot.safe_head:display()

                    if config.antiaimbot.safe_head:get() then
                        config.antiaimbot.safe_head_conditions:display()
                    end

                    config.antiaimbot.warmup_aa:display()
    
                    if config.antiaimbot.warmup_aa:get() then
                        config.antiaimbot.warmup_aa_conditions:display()
                    end

                    config.antiaimbot.animation_breaker:display()

                    if config.antiaimbot.animation_breaker:get() then
                        config.antiaimbot.animation_breaker_leg:display()
                        config.antiaimbot.animation_breaker_air:display()
                        config.antiaimbot.animation_breaker_other:display()
                    end

                    config.antiaimbot.air_exploit:display()

                    if config.antiaimbot.air_exploit:get() then
                        config.antiaimbot.air_exploit_hotkey:display()
                    end

                    config.antiaimbot.manual_yaw:display()

                    if config.antiaimbot.manual_yaw:get() then
                        for i=1, #config.manuals do
                            config.manuals[i]:display()
                        end

                        config.antiaimbot.edge_yaw:display()
                        config.antiaimbot.freestanding:display()
                        config.antiaimbot.manual_options:display()
                        config.antiaimbot.fs_options:display()
                        config.antiaimbot.freestanding_disabler_states:display()
                    end
                end
            else
                -- Fake lag
                do
                    config.fakelag.enable:display()

                    if config.fakelag.enable:get() then
                        config.fakelag.type:display()
                        config.fakelag.ticks:display()
                    end
                end
            end

            if tab == "Defensive" then
                config.antiaimbot.defensive_aa:display()

                if config.antiaimbot.defensive_aa:get() then
                    config.antiaimbot.force_target_yaw:display()
                    config.antiaimbot.defensive_target:display()
                    config.antiaimbot.defensive_conditions:display()
                    config.antiaimbot.defensive_triggers:display()
                    config.antiaimbot.defensive_preset:display()

                    local preset = config.antiaimbot.defensive_preset:get()

                    if preset == "Auto" then
                        config.antiaimbot.defensive_conditions_auto:display()
                    elseif preset == "Constructor" then
                        config.builder.defensive_state:display()

                        local state = config.builder.defensive_state:get()
                        local list = antiaimbot_builder.defensive_settings[state]

                        list.enabled:display()

                        if list.enabled:get() and not (state == "Safe head" or state == "Edge direction" or state == "Triggered") then
                            list.pitch:display()

                            if list.pitch:get() == "Custom" then
                                list.pitch_custom:display()
                            end

                            list.yaw:display()

                            local yaw = list.yaw:get()

                            if yaw == "Delayed" then
                                list.yaw_left:display()
                                list.yaw_right:display()
                                list.yaw_delay:display()
                            end

                            if yaw == "Spinbot" then
                                list.yaw_from:display()
                                list.yaw_to:display()
                                list.yaw_speed:display()
                            end

                            if yaw == "Scissors" then
                                list.yaw_left_start:display()
                                list.yaw_left_target:display()

                                list.yaw_right_start:display()
                                list.yaw_right_target:display()
                            end

                            if yaw == "Scissors" or yaw == "Delayed" then
                                list.yaw_delay:display()
                            end

                            if yaw == "Scissors" or yaw == "Delayed" or yaw == "Spinbot" then
                                list.yaw_randomize:display()
                            end
                        end
                    end
                end
            end

            if tab == "Visuals" then
                config.visuals.indicators:display()

                if config.visuals.indicators:get() then
                    config.visuals.indicator_color:display()
                    config.visuals.indicator_style:display()

                    if config.visuals.indicator_style:get() == "Renewed" then
                        config.visuals.indicator_renewed_color:display()
                    end

                    config.visuals.indicator_vertical_offset:display()
                    config.visuals.indicator_options:display()
                end

                config.visuals.damage_marker:display()

                if config.visuals.damage_marker:get() then
                    config.visuals.damage_marker_color:display()
                end

                config.visuals.r8_indicator:display()

                if config.visuals.r8_indicator:get() then
                    config.visuals.r8_indicator_color:display()
                end

                config.visuals.manual_arrows:display()

                if config.visuals.manual_arrows:get() then
                    config.visuals.manual_arrows_color:display()
                    config.visuals.manual_arrows_accent:display()
                    config.visuals.manual_arrows_style:display()
                    config.visuals.manual_arrows_options:display()
                    
                    if config.visuals.manual_arrows_style:get() == "Triangles" then
                        config.visuals.manual_arrows_size:display()
                    end

                    config.visuals.manual_arrows_offset:display()
                end
            end

            if tab == "Miscellaneous" then
                config.miscellaneous.clantag:display()

                config.miscellaneous.cheat_tweaks:display()

                if config.miscellaneous.cheat_tweaks:get() then
                    config.miscellaneous.cheat_tweaks_list:display()
                end

                config.miscellaneous.automatic_tp:display()

                if config.miscellaneous.automatic_tp:get() then
                    config.miscellaneous.automatic_tp_weapons:display()
                    config.miscellaneous.automatic_tp_delay:display()
                end

                config.miscellaneous.trashtalk:display()
                config.miscellaneous.custom_output:display()
                config.miscellaneous.event_logger:display()
                config.miscellaneous.console_filter:display()
            end

            if tab == "Presets" then
                config.presets.list:display()
                config.presets.name:display()

                config.presets.load:display()
                config.presets.save:display()
                config.presets.remove:display()
                config.presets.import:display()
                config.presets.export:display()
            end

            if tab == "Configuration" then
                config.settings.import:display()
                config.settings.export:display()
                config.settings.EBATEL:display()
            end
        end

        function callbacks.paint(ctx)
            visuals:paint()
        end

        function callbacks.paint_ui(ctx)
            if ui.is_menu_open() then
                menu_state.visibility()
                menu_state.label()
            end

            c_animations:frame()

            player:paint_ui()
            visuals:paint_ui()
            miscellaneous:paint_ui()
        end

        function callbacks.predict_command(cmd)
            local me = entity.get_local_player()
            local wpn = me and entity.get_player_weapon(me) or nil

            player:predict_command(cmd, me)
            antiaimbot:predict_command(cmd, me, wpn)
        end

        function callbacks.setup_command(cmd)
            local me = entity.get_local_player()
            local wpn = me and entity.get_player_weapon(me) or nil

            player:setup_command(cmd, me, wpn)
            fakelag:setup_command(cmd, me, wpn)
            antiaimbot:setup_command(cmd, me, wpn)
            miscellaneous:setup_command(cmd, me, wpn)
        end

        function callbacks.run_command(cmd)
            player:run_command(cmd)
        end

        function callbacks.finish_command(cmd)
            local me = entity.get_local_player()
            local wpn = me and entity.get_player_weapon(me) or nil

            antiaimbot:finish_command(cmd, me, wpn)
            player:finish_command(cmd, me, wpn)
        end

        function callbacks.net_update_end()
            player:net_update_end()
            miscellaneous:net_update_end()
        end

        function callbacks.console_input(text)
            if text == 'bt_debug' then
                user.debug = not user.debug

                return true
            end
        end

        function callbacks.shutdown()
            miscellaneous.clantag.reset()

            antiaimbot.main.get_instance():reset()
            antiaim_presets:flush()

            config_system:save_local()

            client.exec('con_filter_enable 0;con_filter_text "";')

            override.unset(reference.ragebot.fakeduck)

            override.unset(reference.fakelag.enable)
            override.unset(reference.fakelag.amount)
            override.unset(reference.fakelag.limit)
            override.unset(reference.fakelag.variance)

            override.unset(reference.misc.draw_output)

            override.unset(reference.misc.air_strafe)

            menu_state.visibility(true)

            c_logger.log('Shutting down...')
        end

        --- Events
        function events.aim_fire(event)
            miscellaneous:aim_fire(event)
        end

        function events.aim_hit(event)
            miscellaneous:aim_hit(event)
        end

        function events.aim_miss(event)
            miscellaneous:aim_miss(event)
        end

        function events.player_hurt(event)
            miscellaneous:player_hurt(event)
            visuals:player_hurt(event)
        end

        function events.player_death(event)
            miscellaneous:player_death(event)
        end
    end


    ---
    --- Start up
    ---
    do
        callbacks.start()

        menu.set_callback(callbacks.menu)
        menu.update()

        client.set_event_callback('paint', callbacks.paint)
        client.set_event_callback('paint_ui', callbacks.paint_ui)
        client.set_event_callback('predict_command', callbacks.predict_command)
        client.set_event_callback('setup_command', callbacks.setup_command)
        client.set_event_callback('run_command', callbacks.run_command)
        client.set_event_callback('finish_command', callbacks.finish_command)

        client.set_event_callback('net_update_end', callbacks.net_update_end)
        client.set_event_callback('console_input', callbacks.console_input)
        client.set_event_callback('shutdown', callbacks.shutdown)

        --- Events
        client.set_event_callback('aim_fire', events.aim_fire)
        client.set_event_callback('aim_hit', events.aim_hit)
        client.set_event_callback('aim_miss', events.aim_miss)

        client.set_event_callback('player_hurt', events.player_hurt)
        client.set_event_callback('player_death', events.player_death)
    end
end)()








local pr0kladki = "best"

local ffi = require('ffi')
local bit = require("bit")
local vector = require('vector')
local table_new = require('table.new')
local json = require("json")
local clipboard = require("gamesense/clipboard")
local color = require("gamesense/color")
local pui = require('gamesense/pui')
local base64 = require('gamesense/base64')
local clipboard = require('gamesense/clipboard')
local c_entity = require ('gamesense/entity')
local http = require ('gamesense/http')
local vector = require "vector"
local steamworks = require('gamesense/steamworks')
local surface = require 'gamesense/surface'

local ent_c = {}
ent_c.get_client_entity = vtable_bind('client.dll', 'VClientEntityList003', 3, 'void*(__thiscall*)(void*, int)')

local animation_layer_t = ffi.typeof([[
    struct {
        char pad0[0x18];
        uint32_t m_nSequence;
        float m_flPrevCycle;
        float m_flWeight;
        float m_flWeightDeltaRate;
        float m_flPlaybackRate;
        float m_flCycle;
        void* entity;
        char pad1[0x4];
    }**
]])

local offsets = {
    animlayer = 0x2990
}

local function get_animlayer(ent, layer)
    local ent_ptr = ffi.cast('void***', ent_c.get_client_entity(ent or entity.get_local_player()))
    local animlayer_ptr = ffi.cast('char*', ent_ptr) + offsets.animlayer
    local entity_animlayer = ffi.cast(animation_layer_t, animlayer_ptr)[0][layer]
    return entity_animlayer
end

local function normalize(value, min, max)
    return (value - min) / (max - min)
end

local function bin_value(value, num_bits)
    local scale_factor = 2 ^ num_bits
    local scaled_value = math.floor(value * scale_factor + 0.5)
    local bits = {}
    for i = num_bits, 1, -1 do
        local bit_value = 2 ^ (i - 1)
        if scaled_value >= bit_value then
            bits[i] = 1
            scaled_value = scaled_value - bit_value
        else
            bits[i] = 0
        end
    end
    return bits
end

local function insert_first_index(tbl, value, maxSize)
    if #tbl >= maxSize then
        table.remove(tbl)
    end
    table.insert(tbl, 1, value)
end

local function average(t)
    t = t or {}
    local sum = 0
    for _, v in pairs(t) do
        sum = sum + v
    end
    return sum / #t
end


local animlayer_average_t = {}
local animlayer_rec_t = {}
local velocity_rec_t = {}

local function get_animlayer_rec(ent)
    animlayer_rec_t[ent] = animlayer_rec_t[ent] or 0
    return animlayer_rec_t[ent]
end

local function get_velocity_rec(ent)
    velocity_rec_t[ent] = velocity_rec_t[ent] or 0
    return velocity_rec_t[ent]
end


-- local mul, binary_size = 1000000000, 20



local function table_contains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

local RESOLVER_CONST = {
    MAX_DESYNC_DELTA = 58,
    JITTER_DETECTION_THRESHOLD = 30,
    MAX_HISTORY_SIZE = 64
}

local DESYNC_CONST = {
    MAX_DESYNC_DELTA = 58,
    JITTER_DETECTION_THRESHOLD = 40,
    MIN_DESYNC_RANGE = 15,
    MAX_DESYNC_RANGE = 58,
    HISTORY_SIZE = 10,
    CONFIDENCE_DECAY = 0.1,
    CONFIDENCE_BOOST = 0.2,
    LERP_FACTOR = 0.3
}


local function calculate_std_dev(history)
    if #history < 2 then return 0 end
    local sum, sum_sq = 0, 0
    for _, v in ipairs(history) do
        sum = sum + v
        sum_sq = sum_sq + v * v
    end
    local mean = sum / #history
    return math.sqrt((sum_sq / #history) - (mean * mean))
end


local function get_choke(enemy)
    local sim_time = entity.get_prop(enemy, "m_flSimulationTime") or 0
    local data = resolver_data[enemy] or {}
    local last_sim_time = data.last_sim_time or 0
    local choke = last_sim_time > 0 and math.floor((sim_time - last_sim_time) / globals.tickinterval()) or 0
    data.last_sim_time = sim_time
    resolver_data[enemy] = data
    return choke
end

local function init_brute_data(player)
    if not brute_data[player] then
        brute_data[player] = {
            state = "IDLE",
            yaw_index = 1,
            body_yaw_index = 1,
            pitch_index = 1,
            misses = 0,
            last_shot_time = 0,
            end_tick = 0
        }
    end
end

local function get_closest_point(A, B, P)
    local a_to_p = { P[1] - A[1], P[2] - A[2] }
    local a_to_b = { B[1] - A[1], B[2] - A[2] }
    local atb2 = a_to_b[1]^2 + a_to_b[2]^2
    local atp_dot_atb = a_to_p[1]*a_to_b[1] + a_to_p[2]*a_to_b[2]
    local t = atp_dot_atb / atb2
    return { A[1] + a_to_b[1]*t, A[2] + a_to_b[2]*t }
end

local function adaptive_adjust(player, current_yaw)
    local data = brute_data[player]
    if not data then return current_yaw end
    local desync = entity.get_prop(player, "m_flPoseParameter", 11) * 120 - 60
    local adjustment = desync > 0 and math.random(-5, 5) or -math.random(-5, 5)
    return normalize_angle(current_yaw + adjustment)
end

local function normalize_angle(angle)
    while angle > 180 do angle = angle - 360 end
    while angle < -180 do angle = angle + 360 end
    return angle
end

debug_info = debug_info or {}

resolver_data = {}

math.clamp = function(value, min_val, max_val)
    return math.max(min_val, math.min(max_val, value))
end

local adaptive_resolver = {
    players = {},
    angle_sets = {
        standard = {0, 58, -58, 29, -29, 15, -15, 45, -45},
        extended = {0, 58, -58, 29, -29, 15, -15, 45, -45, 35, -35, 19, -19, 60, -60}
    },
    miss_memory = {},
    hit_memory = {},
    current_mode = "standard",
    last_update = 0,
    update_interval = 0.1,
    learning_rate = 0.2,
    confidence_threshold = 0.6,
    auto_switch_threshold = 3,
    debug_mode = true,
    pattern_threshold = 3,
    angle_switch_misses = 5,
    miss_cooldown = 0.05,
    angle_variation = 5
}

local adaptive_modes = {"dynamic", "beta", "static"}
local adaptive_mode_index = 1

local resolver_stats = {
    total_hits = 0,
    total_misses = 0
}

function has_value(tab, val)
    if type(tab) ~= "table" then return false end
    for _, value in ipairs(tab) do
        if value == val then return true end
    end
    return false
end

function log_debug(message)
    if adaptive_resolver.debug_mode then
        client.color_log(255, 255, 255, "[PR0KLADKI Logs] " .. tostring(message))
    end
end

local state_scores = {
    standing = 1.0,
    crouching = 0.9,
    in_air = 1.2,
    walking = 1.1,
    slow_walk = 0.95
}

function math.lerp(start, end_pos, time)
    if start == end_pos then return end_pos end
    local frametime = globals.frametime() * 170
    time = time * math.min(frametime, (1 / 45) * 100)
    local val = start + (end_pos - start) * globals.frametime() * time
    return math.abs(val - end_pos) < 0.01 and end_pos or val
end


local math_util = {
    clamp = function(value, min_val, max_val)
        return math.max(min_val, math.min(max_val, value))
    end,
    angle_diff = function(a, b)
        local diff = math.abs(((a - b) + 180) % 360 - 180)
        return diff > 180 and 360 - diff or diff
    end,
    normalize_angle = function(angle)
        while angle > 180 do
            angle = angle - 360
        end
        while angle < -180 do
            angle = angle + 360
        end
        return angle
    end
}

local ui_colors = {
    accent = { r = 255, g = 215, b = 0, a = 255 },
    success = { r = 0, g = 255, b = 0, a = 255 },
    warning = { r = 255, g = 165, b = 0, a = 255 },
    neutral = { r = 255, g = 255, b = 255, a = 255 },
    highlight = { r = 0, g = 255, b = 255, a = 255 }
}

local brute_data = {}

local brute_angles = {
    yaw = {0, 10, -10, 20, -20, 30, -30, 40, -40, 50, -50, 60, -60, 75, -75, 90, -90, 105, -105, 120, -120, 135, -135, 150, -150, 165, -165, 180},
    body_yaw = {0, 10, -10, 20, -20, 30, -30, 45, -45, 60, -60, 75, -75},
    pitch = {89, 84, 79, 74, 69, 64, 94, 99, 104, 109, -89, -84, -79, -74, -69, -64, -94, -99, -104, -109}
}

local function contains(t, value)
    for _, v in ipairs(t) do
        if v == value then return true end
    end
    return false
end

client.exec("Play ambient/tones/elev1")

ui.new_label("LUA", "B", "           \aFFD700FF⚡\aFFD700FF \a778899FF B A L E N C I A G A R E S O L V E R\a778899FF \aFFD700FF⚡\aFFD700FF")
ui.new_label("LUA", "B", "                    ⇙               ⇘")


-- Helper function to clamp color values to valid range
local function clamp_color(value)
    if value == nil or value ~= value then return 0 end -- Handle nil and NaN
    if value == math.huge or value == -math.huge then return 0 end -- Handle infinity
    value = math.floor(value + 0.5) -- Round to nearest integer
    if value < 0 then return 0 end
    if value > 255 then return 255 end
    return value
end

local function get_rainbow_color(time)
    local r = clamp_color(math.sin(time) * 127 + 128)
    local g = clamp_color(math.sin(time + 2) * 126 + 128)
    local b = clamp_color(math.sin(time + 4) * 121 + 120)
    return string.format("\a%02X%02X%02XFF", r, g, b)
end

local label_original = ui.new_label("LUA", "B", "         \a909090FFOFF      \aFFFFFFFF↪\aFFFFFFFF       \a808080FFBest resolver ever\a808080FF")
client.set_event_callback("paint_ui", function()
    local time = globals.realtime() * 4
    local color_code = get_rainbow_color(time)
    local banner_text = string.format("         \a909090FFOFF      \aFFFFFFFF↪\aFFFFFFFF       \a808080FF%s9MICE\a808080FF", color_code)
    ui.set(label_original, banner_text)
end)



local label_enabled_default = ui.new_label("LUA", "B", "           \a90EE90FFACTIVE\a90EE90FF      \aFFFFFFFF✔\aFFFFFFFF       \a808080FFKAI ANGEL\a808080FF")
--local label_enabled_aggressive = ui.new_label("LUA", "B", "           \a90EE90FFACTIVE\a90EE90FF      \aFFFFFFFF✔\aFFFFFFFF       \a808080FFAggressive\a808080FF")
--local label_enabled_adaptive = ui.new_label("LUA", "B", "           \a90EE90FFACTIVE\a90EE90FF      \aFFFFFFFF✔\aFFFFFFFF       \a808080FFAdaptive\a808080FF")
local label_enabled_custom = ui.new_label("LUA", "B", "           \a90EE90FFACTIVE\a90EE90FF      \aFFFFFFFF✔\aFFFFFFFF       \a808080FFCustom\a808080FF")
ui.new_label("LUA", "B", "                                        ")


-- local imp_exp_2 = ui.new_label("CONFIG", "Presets", "\a909090FF ---------------- T 3 M P 3 S T ----------------")
-- local ui_display_stats = ui.new_checkbox("LUA", "B", " ›  Enemy \a778899FFStats \aFF0000FF[dev]")
-- local ui_toggle_logs = ui.new_checkbox("LUA", "B", " ›  Enable \a778899FFLogs")
local darkmode_enabled = ui.new_checkbox("LUA", "A", "\a778899FF \aD3D3D3FFEnable \a778899FFDark Menu \a90909025", true)
-- local ui_trashtalk_enable = ui.new_checkbox("CONFIG", "LUA", " ›  Enable \a778899FFTrasktalk ")
-- local imp_exp_3 = ui.new_label("Rage", "Other", "\a909090FF ---------------- T 3 M P 3 S T ----------------")

-- local label_z3r0 = ui.new_label("Rage", "Other", "\a90909040-- Dont turn it on is already enabled !", false)

math.randomseed(client.random_int(1, 1000000))

local trashtalk_enabled = ui.new_checkbox("LUA", "A", "\a778899FF \aD3D3D3FFEnable \a778899FFAnti 1 \a90909025")

local ui_new_logs_enable = ui.new_checkbox("LUA", "A", "\a778899FF \aD3D3D3FFEnable \a778899FFInfo \a90909025")

local fixed_opacity_percent = 45
local current_alpha = 0

local function get_screen_size()
    return client.screen_size()
end

client.set_event_callback("paint", function()
    local screen_w, screen_h = get_screen_size()
    local r, g, b = 0, 0, 0
    local target_alpha = 0

    if ui.get(darkmode_enabled) and ui.is_menu_open() then
        target_alpha = (fixed_opacity_percent / 100) * 255
    end

    current_alpha = current_alpha + (target_alpha - current_alpha) * 0.1
    local alpha_to_use = math.floor(current_alpha + 0.5)

    renderer.rectangle(0, 0, screen_w, screen_h, r, g, b, alpha_to_use)
end)

local ui_resolver_enabled = ui.new_checkbox("LUA", "B", " ›  Enable \a778899F PR0KLADKI \aD3D3D3FFResolver", true)
local ui_mode_select = ui.new_combobox("LUA", "B", "Preset", {"Default", "Custom"})
local ui_show_settings = ui.new_checkbox("LUA", "B", "Show settings ❓")

client.set_event_callback("paint", function()
    if not ui.get(ui_resolver_enabled) then return end



    renderer.text(10, 10, 255, 255, 255, 255, "", 0, resolver_text)
end)

local ui_elements = {
    tst_prediction_factor = ui.new_checkbox("LUA", "B", " Base Prediction", 0, 200, 50, true, "%", 1, { [150] = "Fast Mode Max" }, true),
    prediction_factor = ui.new_slider("LUA", "B", "\a909090FFPrediction Aggressiveness", 0, 200, 50, true, "%", 1, { [150] = "Fast Mode Max" }),
    fast_mode = ui.new_checkbox("LUA", "B", "\aD0B0FFFF Fast Predict\aFFFFFFFF \a90909025«\affef00FF⁂\a90909025»"),
    manual_predict = ui.new_checkbox("LUA", "B", "\a9f9f9fFF Manual Prediction"),
    manual_states = ui.new_multiselect("LUA", "B", "\a9f9f9f90Manual Predict States", {"\a9f9f9fFFStanding", "\a9f9f9fFFCrouching", "\a9f9f9fFFIn-Air", "\a9f9f9fFFWalking", "\a9f9f9fFFSlow Walk"}),
    predict_standing = ui.new_slider("LUA", "B", "\a9f9f9f75Standing Prediction", 0, 200, 50, true, "%"),
    predict_crouching = ui.new_slider("LUA", "B", "\a9f9f9f75Crouching Prediction", 0, 200, 50, true, "%"),
    predict_air = ui.new_slider("LUA", "B", "\a9f9f9f75In-Air Prediction", 0, 200, 50, true, "%"),
    predict_walking = ui.new_slider("LUA", "B", "\a9f9f9f75Walking Prediction", 0, 200, 50, true, "%"),
    predict_slowwalk = ui.new_slider("LUA", "B", "\a9f9f9f75Slow Walk Prediction", 0, 200, 50, true, "%"),
    ui_smart_yaw_correction = ui.new_checkbox("LUA", "B", "\aD0B0FFFF Correction \a90909025«\affef00FF⁂\a90909025»"),
--    anti_aim_correction = ui.new_checkbox("LUA", "B", "\aD0B0FFFF⭙ Aim Correction \a90909025«\affef00FF⁂\a90909025»"),
--    anti_aim_correction_value = ui.new_slider("LUA", "B", "\a909090FFCorrection \aD3D3D3FFValue", -120, 120, 58, true, "°"),
--    yaw_diff_threshold = ui.new_slider("LUA", "B", "\a909090FFYaw Diff \aD3D3D3FFThreshold", 0, 180, 60, true, "°"),
    desync_detection = ui.new_checkbox("LUA", "B", "\ac7d667FF⛕ Desync Detection"),
--    desync_range = ui.new_slider("LUA", "B", "\a909090FFDesync Range\a909090FF", 0, 60, 45, true, "°"),
    headshot_priority = ui.new_checkbox("LUA", "B", "\a67d77cFF Headshot Priority \a90909025«\a90909035hc\a90909025»"),
    head_height_adjust = ui.new_slider("LUA", "B", "\a909090FFHead Height Adjust\a909090FF", 0, 100, 50, true, "u"),
--    defensive_resolver = ui.new_checkbox("LUA", "B", "\a67d77cFF Air Defensive Type Logic \a90909025«\affef00FF⁎\a90909025»", false),
--    hit_chance_bind = ui.new_hotkey("LUA", "B", "Toggle Hit Chance Override", false),
    smart_head_aim = ui.new_checkbox("LUA", "B", "\a67d77cFF Smart \aD3D3D3FFHead Aim \a90909025«\affef00FF⁑\a90909025»"),
    smart_head_hp_threshold = ui.new_slider("LUA", "B", "\a909090FFPlayer HP Threshold \a909090FFfor Head Aim", 0, 100, 20, true, "HP"),
    smart_body_aim = ui.new_checkbox("LUA", "B", "\a67d77cFF Smart \aD3D3D3FFBody Aim"),
    smart_body_lethal = ui.new_checkbox("LUA", "B", "\a909090FF Force Body Aim if Lethal"),
    smart_body_hp_threshold = ui.new_slider("LUA", "B", "\a909090FFEnemy HP Threshold for Body Aim\a909090FF", 0, 100, 50, true, "HP"),
    t3mp3st_mode = ui.new_checkbox("LUA", "B", "\a80CFFFFF-- ⚡ [Features] ⚡ --\aFFFFFFFF", true),
--    t3mp3st_mode_two = ui.new_label("LUA", "B", "\a80CFFFFF-- ⚡ FEATUREs ⚡ --\aFFFFFFFF"),
--    neural_mode = ui.new_checkbox("LUA", "B", "\aDC143CFF Neural Mode \a778899FF AI \a90909025«\aFF0000FF‼\a90909025»"),
--    neural_priority = ui.new_combobox("LUA", "B", "Neural Priority", {"Yaw", "Position", "Desync"}),
    enhanced_defensive_fix = ui.new_checkbox("LUA", "B", "\a67d77cFF Enhanced Defensive Fix\a67d77cFF \a90909025«\affef00FF⁎\a90909025»"),
    a_brute = ui.new_checkbox("LUA", "B", "\aD0B0FFFF Basic Brute\a909090FF"),
    brute_duration = ui.new_slider("LUA", "B", "\a909090FFBrute Duration", 1, 20, 5, true, "t"),
--    adaptive_auto_switch = ui.new_checkbox("LUA", "B", "\a67d77cFF Adaptive Auto Switch Angles \a90909025«\a90909020dont work\a90909025»"),
--    adaptive_learning_rate = ui.new_slider("LUA", "B", "\a909090FFAdaptive Learning Rate", 0, 100, 20, true, "%"),
    alternative_jitter = ui.new_checkbox("LUA", "B", "\aD0B0FFFF Alternative \aD3D3D3FFDetect Jitter"),
--    jitter_detection = ui.new_checkbox("LUA", "B", "\aD0B0FFFF Manual Jitter Detection\aFFFFFFFF"),
--    resolver_correction = ui.new_checkbox("LUA", "B", "\ac7d667FF Resolver Correction\ac7d667FF"),
--    resolver_correction_intensity = ui.new_slider("LUA", "B", "\a5b5b5bFFResolver Correction Intensity\a5b5b5bFF", 0, 100, 50, true, "%"), -- чучуть мб бесполезно !!!!!!! пахахах, нет
--    mode_select = ui.new_combobox("LUA", "B", "\a5b5b5bFFSelect Mode\a5b5b5bFF", {"\a67d77cFFLow Ping\a67d77cFF", "\ad66767FFHigh Ping\ad66767FF", "\ac7d667FFBalanced\ac7d667FF"}),
--    jitter_threshold = ui.new_slider("LUA", "B", "\a909090FFJitter Detection Threshold\a909090FF", 5, 30, 15, true, "σ"),
--    jitter_yaw_adjust = ui.new_slider("LUA", "B", "\a909090FFJitter Yaw Adjustment\a909090FF", -60, 60, 30, true, "°"),
--    jitter_lby_threshold = ui.new_slider("LUA", "B", "\a909090FFJitter LBY Stability Threshold\a909090FF", 5, 30, 10, true, "σ"),
--    flick_detection = ui.new_checkbox("LUA", "B", "\aD0B0FFFF Flick Detection\aFFFFFFFF \a90909025«\affef00FF⁎\a90909025»"),
--    flick_velocity_threshold = ui.new_slider("LUA", "B", "\a5b5b5bFFFlick Velocity Threshold\a5b5b5bFF", 300, 700, 500, true, "°/s"),
--    flick_reaction_time = ui.new_slider("LUA", "B", "\a5b5b5bFFFlick Reaction Time\a5b5b5bFF", 50, 200, 100, true, "ms"),
--    flick_prediction_boost = ui.new_slider("LUA", "B", "\a5b5b5bFFFlick Prediction Boost\a5b5b5bFF", 0, 50, 15, true, "%"),
--    flick_yaw_correction = ui.new_slider("LUA", "B", "\a5b5b5bFFFlick Yaw Correction\a5b5b5bFF", 0, 30, 10, true, "°"),
--    flick_mode = ui.new_combobox("LUA", "B", "Flick Mode", {"Fake Flicks", "Defensive Flicks"}),
--    fuck = ui.new_label("PLAYERS", "Adjustments", "\a90909055════════════════════════════════"),
--    dynamic_hit_chance_label = ui.new_label("PLAYERS", "Adjustments", "\aB0B0FFFFDynamic\aFFFFFFFF minimum hit chance:"),
--    confidence_threshold = ui.new_slider("PLAYERS", "Adjustments", "\a909090FFConfidence Threshold for Shooting\a909090FF", 0, 100, 0, true, "%"),
--    low_confidence_delay_label = ui.new_label("PLAYERS", "Adjustments", "\aB0B0FFFFDynamic\aFFFFFFFF shot delay:"),
--    low_confidence_delay = ui.new_slider("PLAYERS", "Adjustments", "\a909090FFDelay on Low Confidence\a909090FF", 0, 500, 0, true, "ms"),
--    fuck_two = ui.new_label("PLAYERS", "Adjustments", "\a90909055════════════════════════════════"),
    experimental_mode = ui.new_checkbox("LUA", "B", "\aFF0000FF-- [EXPERIMENTAL MODE] --\aFFFFFFFF", true),
    experimental_mode_two = ui.new_label("LUA", "B", "\aFF0000FF-- ExpERImENtAL --\aFFFFFFFF"),
    dt_peek_fix = ui.new_checkbox("LUA", "B", "\a67d77cFFDefensive \a67d77cFFFix\a67d77cFF"),
    resolver_correction = ui.new_checkbox("LUA", "B", "\ac7d667FFPing Correction\ac7d667FF"), -- 
    resolver_correction_intensity = ui.new_slider("LUA", "B", "\a5b5b5bFFResolver Correction Intensity\a5b5b5bFF", 0, 100, 50, true, "%"), -- чучуть мб бесполезно !!!!!!! пахахах, нет
    mode_select = ui.new_combobox("LUA", "B", "\a5b5b5bFFSelect Mode\a5b5b5bFF", {"\a67d77cFFLow Ping\a67d77cFF", "\ad66767FFHigh Ping\ad66767FF", "\ac7d667FFBalanced\ac7d667FF"}),
--    alternative_predict = ui.new_checkbox("LUA", "B", "Additional Prediction\aFF0000FF -- dont use --"),
--    spread_compensation = ui.new_checkbox("LUA", "B", "\aD0B0FFFFSpread Compensation\aFFFFFFFF \a90909025«\a90909020dont work\a90909025»"),
--    simple_mode = ui.new_checkbox("LUA", "B", "\aD0B0FFFFSimple Mode\aFFFFFFFF"),
--    indicators = ui.new_checkbox("LUA", "B", "\a3f7534FFIndicators\a3f7534FF \a90909025«\a90909020dont work\a90909025»"),
--    neural_visualization = ui.new_checkbox("LUA", "B", "\a3f7534FFNeural Visualization\a3f7534FF \a90909025«\a90909020dont work\a90909025»"),
    fakelag_optimization = ui.new_checkbox("LUA", "B", "\ac7d667FFFakelag Optimization\ac7d667FF"),
    dormant_aimbot = ui.new_checkbox("LUA", "B", "\ac7d667FFDormant Aimbot\ac7d667FF"),
    dormant_min_damage = ui.new_slider("LUA", "B", "\a5b5b5bFFDormant Minimum Damage\a5b5b5bFF", 0, 100, 54, true, "damage"),
--    dormant_indicator = ui.new_checkbox("LUA", "B", "\a5b5b5bFFDormant Indicator\a5b5b5bFF"),
    jump_scout_opt = ui.new_checkbox("LUA", "B", "\ac7d667FFJump Scout Optimization\ac7d667FF"),
--    adaptive_prediction = ui.new_checkbox("LUA", "B", "\ac7d667FFAdaptive Prediction Switch\ac7d667FF"),
--    dynamic_hit_chance = ui.new_checkbox("LUA", "B", "\ac7d667FFDynamic Hit Chance Adjustment\ac7d667FF \a90909025«\a90909020dont work\a90909025»"),
--    flick_compensation = ui.new_checkbox("LUA", "B", "\ac7d667FFFlick Compensation\ac7d667FF"),
--    hit_chance_override = ui.new_slider("LUA", "B", "\ac7d667FFHit Chance Override\ac7d667FF \a90909025«\a90909020dont work\a90909025»", 0, 100, 37, false, "%"),
    unsafe_crage_air = ui.new_checkbox("LUA", "B", "\ad66767FFUnsafe Chrage in Air\aD3D3D3FF"),
--    precision_mode = ui.new_checkbox("LUA", "B", "\ad66767FFPrecision\ad66767FF \a90909025«\a90909020dont work\a90909025»"),
--    persist_mode = ui.new_checkbox("LUA", "B", "\ad66767FFPersist Mode\ad66767FF \a90909025«\a90909020dont work\a90909025»"),
    experimental_mode_two_1 = ui.new_label("LUA", "B", "\aFF0000FF-- devS --\aFFFFFFFF"),
    velocity_scale = ui.new_slider("LUA", "B", "\ad66767FFVelocity Scale\ad66767FF", 0, 150, 100, true, "%"),
    gravity_factor = ui.new_slider("LUA", "B", "\ad66767FFGravity Factor\ad66767FF", 0, 200, 100, true, "%"),
--    potuznometr = ui.new_slider("LUA", "B", "\aFF0000FFПОТУЖНОМЕТР \aFF0000FF \a90909025«\a90909020dont work\a90909025»", 0, 100, 54, true, "%")
}


 -- local imp_exp_1 = ui.new_label("CONFIG", "Presets", "\a909090FF ---------------- P R E S E T S ----------------")
local config_menu = {
    import = ui.new_button("LUA", "A", "\a909090FF Import Config ", function() end),
    export = ui.new_button("LUA", "A", "\a909090FF Export Config ", function() end)
}



local ui_clear_resolver_memory = ui.new_button("PLAYERS", "Adjustments", "\a909090FF Clear Resolver Memory ", function()

    resolver_data = {}
    adaptive_resolver.players = {}
    adaptive_resolver.miss_memory = {}
    adaptive_resolver.hit_memory = {}
    resolver_stats.total_hits = 0
    resolver_stats.total_misses = 0
    resolved_target = nil
    persist_target = nil
    debug_info = {}
    hit = {}
    missed = {}
    resolver_player_data = setmetatable({}, { __mode = "v" })
    resolver_stats = {
        total_hits = 0,
        total_misses = 0,
        hits_by_method = {},
        misses_by_method = {},
        misses_by_reason = {
            spread = 0,
            prediction = 0,
            lagcomp = 0,
            defensive_low_delta = 0,
            defensive_jitter = 0,
            defensive_spin = 0,
            defensive_lc_break = 0,
            defensive_other = 0,
            resolver = 0,
            connection = 0,
            unregister_shot = 0
        }
    }
    resolver_aa_memory = setmetatable({}, { __mode = "kv" })
    resolver_anim_cache = setmetatable({}, { __mode = "k" })
    resolver_miss_memory = setmetatable({}, { __mode = "kv" })
    resolver_last_shot_id = {}
    resolver_target_player = nil

    -- бля ну это ваще пиздец хахаах
--[[
    for _, enemy in ipairs(entity.get_players(true)) do
        plist.set(enemy, "Force body yaw", false)
        plist.set(enemy, "Override preferred hitbox", nil)
    end
    ]]--
    client.color_log(0, 255, 0, "[PR0KLADKI] All resolver memory and player data cleared successfully")
end)

local function export_config()
    local config = {}
    for key, element in pairs(ui_elements) do
        config[key] = ui.get(element)
    end
    local json_str = json.stringify(config)
    clipboard.set(json_str)
    client.color_log(0, 255, 0, "[PR0KLADKI] Настройки экспортированы в буфер обмена")
end


local function import_config()
    local json_str = clipboard.get()
    if not json_str or json_str == "" then
        client.color_log(255, 120, 120, "[PR0KLADKI] Clipboard cleared.")
        return
    end
    local status, config = pcall(json.parse, json_str)
    if not status or type(config) ~= "table" then
        client.color_log(255, 120, 120, "[] Import error: Wrong preset format")
        return
    end
    for key, value in pairs(config) do
        if ui_elements[key] then
            local success, err = pcall(ui.set, ui_elements[key], value)
            if not success then
                client.color_log(255, 120, 120, "[PR0KLADKI] Error " .. key .. ": " .. err)
            end
        end
    end
    client.color_log(0, 255, 0, "[PR0KLADKI] Imported from Clipboard")
end


ui.set_callback(config_menu.import, import_config)
ui.set_callback(config_menu.export, export_config)


local timer, display_time, is_displaying, random_text = 0, 2, false, ""
local was_menu_open = true
local menu_closed_once = false

local motion = { base_speed = 6, _list = {} }
motion.new = function(name, new_value, speed, init)
    speed = speed or motion.base_speed
    motion._list[name] = motion._list[name] or (init or 0)
    motion._list[name] = math.lerp(motion._list[name], new_value, speed)
    return motion._list[name]
end


local clantag_frames = {
    "p",
    "Pr",
    "pr0",
    "Pr0k",
    "Pr0kl",
    "Pr0kla",
    "Pr0klad",
    "Pr0kladk",
    "Pr0kladki",
    "Pr0kladki b",
    "Pr0kladki bU",
    "Pr0kladki Bus",
    "Pr0kladki bust",
    "Pr0kladki bust1",
    "Pr0kladki bustI",
    "Pr0kladki bustit",
    "Pr0kladki bustit",
    "Pr0kladki bustit",
    "Pr0kladki bustit",
    "Pr0kladki bustit",
    "Pr0kladki busti",
    "Pr0kladki bust",
    "Pr0kladki bus",
    "Pr0kladki bu",
    "Pr0kladki b",
    "Pr0kladki",
    "Pr0kladk",
    "Pr0klad",
    "Pr0kl",
    "Pr0k",
    "Pr0",
    "pr",
    "p",
    ""
}

local clantag_frame_delay = 0.2
local clantag_cycle_pause = 0.2

local function animate_clantag(frame_index)
	if frame_index <= #clantag_frames then
		client.set_clan_tag(clantag_frames[frame_index])
		client.delay_call(clantag_frame_delay, animate_clantag, frame_index + 1)
	else
		client.delay_call(clantag_cycle_pause, animate_clantag, 1)
	end
end

animate_clantag(1)


local function toggle_console(times, delay)
    if times > 0 then
        client.exec("toggleconsole")
        client.delay_call(delay / 1000, function()
            toggle_console(times - 1, delay)
        end)
    end
end



local local_player = entity.get_local_player()
local player_name = local_player and entity.get_player_name(local_player) or "Tal'darim'4ick"
ui.new_label("LUA", "B", "Welcome, \a778899FF" .. player_name .. "!!")
--ui.new_label("LUA", "B", "                                 ")


local enemy_data = {}


local function detect_jitter(yaws)
    if #yaws < 6 then return "No" end
    local direction_changes = 0
    local max_diff = 0
    for i = 3, #yaws do
        local diff1 = yaws[i-1] - yaws[i-2]
        local diff2 = yaws[i] - yaws[i-1]
        if diff1 * diff2 < 0 and math.abs(diff2) > 20 then
            direction_changes = direction_changes + 1
            max_diff = math.max(max_diff, math.abs(diff2))
        end
    end
    return direction_changes >= 2 and "Yes (" .. math.floor(max_diff) .. "°)" or "No"
end

local function detect_flick(yaws)
    if #yaws < 2 then return "No" end
    for i = 2, #yaws do
        local diff = math.abs(yaws[i] - yaws[i-1])
        if diff > 60 then
            return "Yes (" .. math.floor(diff) .. "°)"
        end
    end
    return "No"
end

local function detect_static(positions, yaws)
    if #positions < 30 or #yaws < 30 then return "No" end
    local start_idx = #positions - 29
    local min_x, max_x = positions[start_idx].x, positions[start_idx].x
    local min_y, max_y = positions[start_idx].y, positions[start_idx].y
    local min_z, max_z = positions[start_idx].z, positions[start_idx].z
    local min_yaw, max_yaw = yaws[start_idx], yaws[start_idx]
    for i = start_idx + 1, #positions do
        min_x = math.min(min_x, positions[i].x)
        max_x = math.max(max_x, positions[i].x)
        min_y = math.min(min_y, positions[i].y)
        max_y = math.max(max_y, positions[i].y)
        min_z = math.min(min_z, positions[i].z)
        max_z = math.max(max_z, positions[i].z)
        min_yaw = math.min(min_yaw, yaws[i])
        max_yaw = math.max(max_yaw, yaws[i])
    end
    local pos_diff = math.max(max_x - min_x, max_y - min_y, max_z - min_z)
    local yaw_diff = math.abs(max_yaw - min_yaw)
    return pos_diff < 2.5 and yaw_diff < 2.5 and "Yes" or "No"
end

local function detect_fakelag(sim_times)
    if #sim_times < 2 then return "No" end
    local dt = sim_times[#sim_times] - sim_times[#sim_times - 1]
    local expected_dt = globals.tickinterval()
    local choked = math.floor(dt / expected_dt) - 1
    if choked > 0 then
        return "Yes (" .. choked .. " ticks)"
    else
        return "No"
    end
end

local function detect_afk(positions, yaws, velocities)
    if #positions < 200 or #yaws < 200 or #velocities < 200 then return "No" end
    local start_idx = #positions - 199
    local min_x, max_x = positions[start_idx].x, positions[start_idx].x
    local min_y, max_y = positions[start_idx].y, positions[start_idx].y
    local min_z, max_z = positions[start_idx].z, positions[start_idx].z
    local min_yaw, max_yaw = yaws[start_idx], yaws[start_idx]
    local total_speed = 0
    for i = start_idx + 1, #positions do
        min_x = math.min(min_x, positions[i].x)
        max_x = math.max(max_x, positions[i].x)
        min_y = math.min(min_y, positions[i].y)
        max_y = math.max(max_y, positions[i].y)
        min_z = math.min(min_z, positions[i].z)
        max_z = math.max(max_z, positions[i].z)
        min_yaw = math.min(min_yaw, yaws[i])
        max_yaw = math.max(max_yaw, yaws[i])
        total_speed = total_speed + velocities[i]
    end
    local pos_diff = math.max(max_x - min_x, max_y - min_y, max_z - min_z)
    local yaw_diff = math.abs(max_yaw - min_yaw)
    local avg_speed = total_speed / 200
    return pos_diff < 0.5 and yaw_diff < 0.5 and avg_speed < 1 and "Yes" or "No"
end

local function update_choke_history(enemy, choke)
    local data = resolver_data[enemy] or {}
    data.choke_history = data.choke_history or {}
    table.insert(data.choke_history, choke)
    if #data.choke_history > 10 then
        table.remove(data.choke_history, 1)
    end
    resolver_data[enemy] = data
    return data.choke_history
end

local function get_adaptive_choke(enemy)
    local choke_history = update_choke_history(enemy, get_choke(enemy))
    if #choke_history < 3 then return choke_history[#choke_history] or 0 end
    local sum = 0
    for _, v in ipairs(choke_history) do sum = sum + v end
    local avg_choke = sum / #choke_history
    local std_dev = calculate_std_dev(choke_history)
    return math.clamp(avg_choke + std_dev, 0, 17)
end

local function update_enemy_data()
    local enemies = entity.get_players(true)
    for _, enemy in ipairs(enemies) do
        if not entity.is_alive(enemy) then
            enemy_data[enemy] = nil
            goto continue
        end
        local ent = enemy
        if not enemy_data[ent] then
            enemy_data[ent] = {
                positions = {},
                yaws = {},
                pitches = {},
                velocities = {},
                sim_times = {},
                sim_time_history = {}
            }
        end
        local data = enemy_data[ent]
        local x, y, z = entity.get_prop(ent, "m_vecOrigin")
        if x then
            table.insert(data.positions, {x = x, y = y, z = z})
            local pitch, yaw = entity.get_prop(ent, "m_angEyeAngles")
            table.insert(data.yaws, yaw or 0)
            table.insert(data.pitches, pitch or 0)
            local vel_x = entity.get_prop(ent, "m_vecVelocity[0]") or 0
            local vel_y = entity.get_prop(ent, "m_vecVelocity[1]") or 0
            local vel_z = entity.get_prop(ent, "m_vecVelocity[2]") or 0
            local speed = math.sqrt(vel_x^2 + vel_y^2 + vel_z^2)
            table.insert(data.velocities, speed)
            local sim_time = entity.get_prop(ent, "m_flSimulationTime") or 0
            table.insert(data.sim_times, sim_time)
            table.insert(data.sim_time_history, sim_time)
            if #data.sim_time_history > 10 then
                table.remove(data.sim_time_history, 1)
            end
            if #data.positions > 200 then
                table.remove(data.positions, 1)
                table.remove(data.yaws, 1)
                table.remove(data.pitches, 1)
                table.remove(data.velocities, 1)
                table.remove(data.sim_times, 1)
            end
        end
        ::continue::
    end
end

--
client.set_event_callback("player_connect_full", function(e)
    local ent = client.userid_to_entindex(e.userid)
    if ent == entity.get_local_player() then
        enemy_data = {}
    end
end)

client.set_event_callback("player_death", function(e)
    local ent = client.userid_to_entindex(e.userid)
    if enemy_data[ent] then
        enemy_data[ent] = nil
    end
end)




local smileys = {
    "•̀ ω •́",
    "(＠＾０＾)",
    "＾-＾",
    "(^_^)",
    "(*^_^*)",
    "＾-＾",
    ";P",
    "^3^",
    "(✿◠‿◠)",
    "(✿◡‿◡)",
    "（⊙ｏ⊙）",
    "(‾◡◝)",
    "(◕‿◕)"
}

local sad_smileys = {
    "•̀ ω •́",
    "(＠＾０＾)",
    "＾-＾",
    "(^_^)",
    "(*^_^*)",
    "＾-＾",
    ";P",
    "^3^",
    "(✿◠‿◠)",
    "(✿◡‿◡)",
    "（⊙ｏ⊙）",
    "(‾◡◝)",
    "(◕‿◕)"
}


local function init_random_seed()
    local success, result = pcall(function() return os.time() end)
    if success and result then
        math.randomseed(result)
    else
        math.randomseed(client.unix_time())
    end
end
init_random_seed()


local version_smiley = smileys[math.random(1, #smileys)]
local coder_smiley = smileys[math.random(1, #smileys)]
local support_smiley = smileys[math.random(1, #smileys)]
local tst_smiley = sad_smileys[math.random(1, #sad_smileys)]

ui.new_label("LUA", "B", "                                        ")
ui.new_label("LUA", "B", "⚙ Version:\a90EE90FF v1.4 \a90909040" .. coder_smiley)
ui.new_label("LUA", "B", "                                        ")
ui.new_label("LUA", "B", "✨ Coder:\aDC143CFF Gr1c3nd0 \a90909040" .. support_smiley) -- ; \aDC143CFFАгент \a90909040

local function init_random_seed()
    math.randomseed(client.unix_time())
end
init_random_seed()

do
    local ffi = require("ffi")
    local vector = require("vector")
    local pui = require("gamesense/pui")
    local color = require("gamesense/color")
    local entity = require("gamesense/entity")

    local screen = {}
    screen.size = vector(client.screen_size())
    screen.center = screen.size * 0.5

    local colors = {
        gamesense = {
            ["Ping"] = color(151, 237, 142, 255),
            ["DT"] = color(255, 255, 255, 255),
            ["FD"] = color(255, 255, 255, 255),
            ["Fake Lag"] = color(227, 125, 125, 255),
            ["Safe Point"] = color(255, 255, 255, 255),
            ["BAim"] = color(255, 255, 255, 255),
            ["HC Chance"] = color(185, 185, 255, 255),
            ["MinDMG"] = color(255, 255, 255, 255),
            ["FS"] = color(255, 255, 255, 255)
        }
    }

    local utils = {}
    utils.lerp = function(start, end_pos, time)
        if start == end_pos then return end_pos end
        local frametime = globals.frametime() * (1 / globals.frametime())
        time = time * frametime
        local val = start + ((end_pos - start) * time)
        if math.abs(val - end_pos) < 0.25 then return end_pos end
        return val
    end

    local refs2 = {
        ping = pui.reference("Misc", "Miscellaneous", "Ping spike"),
        dt = pui.reference("RAGE", "Aimbot", "Double tap"),
        fd = pui.reference("RAGE", "Other", "Duck peek assist"),
        safe = pui.reference("RAGE", "Aimbot", "Force safe point"),
        baim = pui.reference("RAGE", "Aimbot", "Force body aim"),
        hc = pui.reference("RAGE", "Aimbot", "Minimum hit chance"),
        dmg = pui.reference("RAGE", "Aimbot", "Minimum damage"),
        mdmg = pui.reference("RAGE", "Aimbot", "Minimum damage Override"),
        mdmg2 = select(2, pui.reference("RAGE", "Aimbot", "Minimum damage Override")),
        thirdperson = pui.reference("VISUALS", "Effects", "Force third person (alive)")
    }

    local hotkeys = {
        fs = pui.reference("AA", "Anti-aimbot angles", "Freestanding"),
        edge_yaw = pui.reference("AA", "Anti-aimbot angles", "Edge yaw"),
        fd = pui.reference("RAGE", "Other", "Duck peek assist"),
        osaa = pui.reference("AA", "Other", "On shot anti-aim"),
        slow = pui.reference("AA", "Other", "Slow motion"),
        fake_peek = pui.reference("AA", "Other", "Fake peek"),
        min_dmg = pui.reference("RAGE", "Aimbot", "Minimum damage Override"),
    }

    local lp = {
        entity = entity.get_local_player(),
        exploit = nil
    }

    local gamesense_menu = pui.group("LUA", "A")
    local gamesense_enabled = gamesense_menu:checkbox("\a778899FF \aD3D3D3FFEnable \a778899FFCustom Indicators \a90909025", nil, true)
    local gamesense_follow = gamesense_menu:checkbox("\a778899FF \aD3D3D3FFEnable \a778899FFThird person \a90909025", nil, false)

    local dependencies1 = {

    {menu =  gamesense_follow, depend = {{gamesense_enabled, true}}},

}


for _, dep in ipairs(dependencies1) do
    pui.traverse(dep.menu, function(ref, path)
        ref:depend(unpack(dep.depend))
    end)
end

    local xy = {}
    for i = 1, 9 do
        xy[i] = {35, screen.size.y * 0.759}
    end

    local function disable_default_hotkeys(enabled)
        for _, hotkey in pairs(hotkeys) do
            hotkey:set_hotkey(enabled and nil or hotkey:get_hotkey())
        end
    end

    gamesense_enabled:set_callback(function(self)
        disable_default_hotkeys(self:get())
    end)

    disable_default_hotkeys(gamesense_enabled:get())

    local function render_gamesense_indicators()
        if not gamesense_enabled:get() then
            return
        end

        client.set_event_callback("indicator", function()
            return {}
        end)

        if not lp.entity or not entity.is_alive(lp.entity) then
            return
        end

        lp.exploit = refs2.dt:get() and refs2.dt:get_hotkey() and "dt" or refs2.fd:get() and refs2.fd:get_hotkey() and "fd" or refs2.ping:get() and refs2.ping:get_hotkey() and "osaa" or nil

        local elements = {
            {"Ping", refs2.ping:get() and refs2.ping:get_hotkey()},
            {"DT", lp.exploit == "dt"},
            {"FD", lp.exploit == "fd"},
            {"Fake Lag", lp.exploit == "osaa"},
            {"Safe Point", refs2.safe:get()},
            {"BAim", refs2.baim:get()},
            {"HC Chance", true, ": " .. refs2.hc:get()},
            {"MinDMG", refs2.mdmg:get() and refs2.mdmg:get_hotkey(), ": " .. (refs2.mdmg:get() and refs2.mdmg2:get() or refs2.dmg:get())},
            {"FS", hotkeys.fs:get() and hotkeys.fs:get_hotkey()}
        }

        local stomach_x, stomach_y, stomach_z = entity.hitbox_position(lp.entity, 3)
        local xx, yy = renderer.world_to_screen(stomach_x, stomach_y, stomach_z)

        local y_add = 0
        for i, t in pairs(elements) do
            if t[2] then
                local c = colors.gamesense[t[1]]
                local text = t[1] .. (t[3] or "")
                local measure = vector(renderer.measure_text("+d", text))
                local x1 = 29 + (measure.x / 2)
                local y1 = (screen.size.y * 0.654) - y_add - 2

                if gamesense_follow:get() and refs2.thirdperson:get() and refs2.thirdperson:get_hotkey() and xx and yy then
                    xy[i][1] = utils.lerp(xy[i][1], xx - 250, 0.03)
                    xy[i][2] = utils.lerp(xy[i][2], (yy - y_add) - 2, 0.03)
                else
                    xy[i][1] = utils.lerp(xy[i][1], x1, 0.3)
                    xy[i][2] = utils.lerp(xy[i][2], y1, 0.3)
                end

                renderer.gradient(xy[i][1], xy[i][2], x1, measure.y + 4, 0, 0, 0, 25, 0, 0, 0, 0, true)
                renderer.gradient(xy[i][1], xy[i][2], -x1, measure.y + 4, 0, 0, 0, 25, 0, 0, 0, 0, true)
                renderer.text(xy[i][1] - (measure.x / 2), xy[i][2] + 2, c.r, c.g, c.b, c.a, "+d", 0, text)

                y_add = y_add + (measure.y * 1.42)
            end
        end
    end

    client.set_event_callback("paint", render_gamesense_indicators)
end


local function hsv_to_rgb(h, s, v)
    local r, g, b

    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    i = i % 6

    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end

    return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end


local my_label = ui.new_label("LUA", "A", "Last update: ??.??.??")

local speed = 1
local color1 = {255, 0, 255}
local color2 = {0, 128, 255}


local function lerp(a, b, t)
    return a + (b - a) * t
end


local function getGradientColor(x, width)
    local time = globals.realtime() * speed
    local offset = (time % 2) / 2  -- 0 to 1 цикл
    local pos = (x / width + offset) % 1

    local r = lerp(color1[1], color2[1], pos)
    local g = lerp(color1[2], color2[2], pos)
    local b = lerp(color1[3], color2[3], pos)

    return clamp_color(r), clamp_color(g), clamp_color(b)
end


client.set_event_callback("paint_ui", function()
    local text = " Last update: 14 .11.25"
    local prefix = "\aD3D3D399 Last Update: "
    local gradient_part = "14.11.25"
    local width = 8
    local final_text = prefix
    local gradient_count = 0

    for i = 1, #gradient_part do
        local char = gradient_part:sub(i, i) == " " and "\x20" or gradient_part:sub(i, i)
        if char:match("[%d%.]") then

            gradient_count = gradient_count + 1
            local r, g, b = getGradientColor(gradient_count, width)
            final_text = final_text .. string.format("\a%02X%02X%02XFF%s", r, g, b, char)
        end
    end

    ui.set(my_label, final_text)
end)

local start_time = client.unix_time()


local function get_elapsed_time()
    local elapsed_seconds = client.unix_time() - start_time
    local hours = math.floor(elapsed_seconds / 3600)
    local minutes = math.floor((elapsed_seconds - hours * 3600) / 60)
    local seconds = math.floor(elapsed_seconds - hours * 3600 - minutes * 60)
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end


local speed = 1
local color1 = {255, 0, 255}  -- я
local color2 = {0, 128, 255}


local function lerp(a, b, t)
    return a + (b - a) * t
end


local function getGradientColor(x, width)
    local time = globals.realtime() * speed
    local offset = (time % 2) / 2
    local pos = (x / width + offset) % 1
    local r = lerp(color1[1], color2[1], pos)
    local g = lerp(color1[2], color2[2], pos)
    local b = lerp(color1[3], color2[3], pos)
    return clamp_color(r), clamp_color(g), clamp_color(b)
end


local tab, container = "LUA", "A"
local session_label = ui.new_label(tab, container, "Your Session Time: 00:00:00")


client.set_event_callback("paint_ui", function()
    if not ui.is_menu_open() then
        ui.set(session_label, "Your Session Time: 00:00:00")
        return
    end

    local time_text = get_elapsed_time()
    local prefix = "\aD3D3D399 Your Session Time: "
    local width = #time_text
    local final_text = prefix

    for i = 1, width do
        local char = time_text:sub(i, i) == " " and "\x20" or time_text:sub(i, i)
        local r, g, b = getGradientColor(i, width)
        final_text = final_text .. string.format("\a%02X%02X%02XFF%s", r, g, b, char)
    end

    ui.set(session_label, final_text)
end)

local inv_label = ui.new_label("LUA", "B", "   ")



local function table_contains(tab, val)
    if type(tab) ~= "table" then return false end
    for _, value in ipairs(tab) do
        if value == val then return true end
    end
    return false
end


local utils = {}
utils.lerp = function(start, end_pos, time, ampl)
    if (start == end_pos) then return end_pos end
    ampl = ampl or (1 / globals.frametime())
    local frametime = globals.frametime() * ampl
    time = time * frametime
    local val = start + ((end_pos - start) * time)
    if (math.abs(val - end_pos) < 0.25) then return end_pos end
    return val
end

utils.to_hex = function(color, cut)
    if not color then return "000000FF" end
    local r = clamp_color(color.r or 0)
    local g = clamp_color(color.g or 0)
    local b = clamp_color(color.b or 0)
    local a = clamp_color(color.a or 255)
    return string.format("%02X%02X%02X" .. ((cut and "") or "%02X"), r, g, b, a)
end

utils.sine_yaw = function(tick, min, max)
    local amplitude = (max - min) / 2
    local center = (max + min) / 20
    return center + (amplitude * math.sin(tick * 0.05))
end

utils.rectangle = function(x, y, w, h, r, g, b, a, radius)
    radius = math.min(radius, w / 2, h / 2)
    local radius_2 = radius * 2
    renderer.rectangle(x + radius, y, w - radius_2, h, r, g, b, a)
    renderer.rectangle(x, y + radius, radius, h - radius_2, r, g, b, a)
    renderer.rectangle((x + w) - radius, y + radius, radius, h - radius_2, r, g, b, a)
    renderer.circle(x + radius, y + radius, r, g, b, a, radius, 180, 0.25)
    renderer.circle(x + radius, (y + h) - radius, r, g, b, a, radius, 270, 0.25)
    renderer.circle((x + w) - radius, y + radius, r, g, b, a, radius, 90, 0.25)
    renderer.circle((x + w) - radius, (y + h) - radius, r, g, b, a, radius, 0, 0.25)
end


local screen = {}
screen.size = vector(client.screen_size())
screen.center = vector(client.screen_size()) * 0.5



local colors = {}
colors.watermark = {
    Text = color(160, 120, 220, 185), --  фиол
    Background = color(0, 0, 0, 77) 
}


local gradient = {}
gradient.animated_gradient_text = function(text, colors, speed, a)
    local output = ""
    local length = #text
    if length == 0 then return output end
    local time_offset = (utils.sine_yaw(globals.realtime() * speed, 5, 20) * speed) % 1
    a = a or 1.0
    for i = 1, length do
        local t = (((i - 1) / (length - 1)) + time_offset) % 1
        local color = color.linear_gradient(colors, t)
        color:alpha_modulate(utils.sine_yaw(((globals.framecount() / i) % 3) * (0.92 - (i % 5)), 100, 255))
        local r = clamp_color(color.r or 0)
        local g = clamp_color(color.g or 0)
        local b = clamp_color(color.b or 0)
        local alpha = clamp_color((color.a or 255) * a)
        output = output .. string.format("\a%02x%02x%02x%02x", r, g, b, alpha) .. text:sub(i, i)
    end
    return output
end
gradient.table = {
    {color(244, 244, 244, 255), 0},
    {color(115, 115, 115, 255), 0.5},
    {color(233, 233, 233, 255), 1}
}

local default_elements = {
    ui_elements.prediction_factor,
    ui_elements.fast_mode,
    ui_elements.trashtalk_enabled,
    ui_elements.smart_head_aim,
    ui_elements.smart_head_hp_threshold,
}

local aggressive_elements = {
    ui_elements.prediction_factor,
    ui_elements.fast_mode,
    ui_elements.headshot_priority,
    ui_elements.head_height_adjust,
    ui_elements.flick_prediction_boost,
--    ui_elements.confidence_threshold,
    ui_elements.enhanced_defensive_fix,
--    ui_elements.low_confidence_delay,
    ui_elements.resolver_correction,
    ui_elements.resolver_correction_intensity,
    ui_elements.mode_select,
}

local adaptive_elements = {
    ui_elements.tst_prediction_factor,
    ui_elements.prediction_factor,
    ui_elements.fast_mode,
    ui_elements.flick_prediction_boost,
    ui_elements.resolver_correction_intensity,
    ui_elements.mode_select,
}

local dependencies = {
    [ui_elements.resolver_correction] = {
        ui_elements.resolver_correction_intensity,
        ui_elements.mode_select,
    },
    [ui_elements.tst_prediction_factor] = { ui_elements.prediction_factor },
    [ui_elements.manual_predict] = {
        ui_elements.manual_states,
        ui_elements.predict_standing,
        ui_elements.predict_crouching,
        ui_elements.predict_air,
        ui_elements.predict_walking,
        ui_elements.predict_slowwalk,
    },
    [ui_elements.dormant_aimbot] = { ui_elements.dormant_min_damage },
    [ui_elements.desync_detection] = { ui_elements.desync_range },
    [ui_elements.headshot_priority] = { ui_elements.head_height_adjust },
    [ui_elements.smart_body_aim] = {
        ui_elements.smart_body_hp_threshold,
        ui_elements.smart_body_lethal,
    },
    [ui_elements.smart_head_aim] = { ui_elements.smart_head_hp_threshold },
    [ui_elements.a_brute] = { ui_elements.brute_duration },

}


local function update_ui_visibility()
    local is_enabled = ui.get(ui_resolver_enabled)
    local mode = ui.get(ui_mode_select)
    local show_settings = ui.get(ui_show_settings)


    for _, element in pairs(ui_elements) do
        if element then
            ui.set_visible(element, false)
        end
    end


    for checkbox, elements in pairs(dependencies) do
        for _, element in ipairs(elements) do
            if element then
                ui.set_visible(element, false)
            end
        end
    end


    ui.set_visible(label_original, not is_enabled)
    ui.set_visible(label_enabled_default, is_enabled and mode == "Default")
    ui.set_visible(label_enabled_custom, is_enabled and mode == "Custom")
    -- ui.set_visible(label_enabled_aggressive, is_enabled and mode == "Aggressive")
    -- ui.set_visible(label_enabled_adaptive, is_enabled and mode == "Adaptive")


    ui.set_visible(ui_resolver_enabled, true)
    ui.set_visible(ui_mode_select, true)
    ui.set_visible(ui_show_settings, is_enabled and mode ~= "Custom")

    if is_enabled then
        if mode == "Default" then

            ui.set(ui_elements.prediction_factor, 108)
            ui.set(ui_elements.smart_head_hp_threshold, 25)
            ui.set(ui_elements.ui_smart_yaw_correction, true)
            ui.set(ui_elements.desync_detection, true)
            ui.set(ui_elements.enhanced_defensive_fix, true)

--            ui.set(ui_elements.confidence_threshold, 10)
--            ui.set(ui_elements.low_confidence_delay, 5)



            if show_settings then
                for _, element in ipairs(default_elements) do
                    ui.set_visible(element, true)
                end
            end




        elseif mode == "Custom" then

            for _, element in pairs(ui_elements) do
                if element and element ~= ui_elements.t3mp3st_mode and element ~= ui_elements.experimental_mode then
                    ui.set_visible(element, true)
                end
            end



            for checkbox, dep_elements in pairs(dependencies) do
                local checkbox_enabled = ui.get(checkbox)
                for _, dep_element in ipairs(dep_elements) do
                    if dep_element then
                        ui.set_visible(dep_element, checkbox_enabled)
                    end
                end
            end
        end
    end
end


ui.set_callback(ui_resolver_enabled, update_ui_visibility)
ui.set_callback(ui_mode_select, update_ui_visibility)
ui.set_callback(ui_show_settings, update_ui_visibility)

for checkbox, elements in pairs(dependencies) do
    ui.set_callback(checkbox, function()
        if ui.get(ui_mode_select) == "Custom" then
            local is_enabled = ui.get(checkbox)
            for _, element in ipairs(elements) do
                if element then
                    ui.set_visible(element, is_enabled)
                end
            end
        end
    end)
end


client.delay_call(0.1, update_ui_visibility)





local function get_bullet_speed(weapon_id) return 2500 end
local function get_weapon_damage(weapon_id) return 30 end
local function lerp(a, b, t) return a + (b - a) * t end
local function get_player_state(enemy)
    local vz = entity.get_prop(enemy, "m_vecVelocity[2]") or 0
    local speed = math.sqrt((entity.get_prop(enemy, "m_vecVelocity[0]") or 0)^2 + (entity.get_prop(enemy, "m_vecVelocity[1]") or 0)^2)
    if vz ~= 0 then return "in_air" end
    if speed < 10 then return "standing" end
    if speed < 50 then return "slow_walk" end
    return "walking"
end
local function detect_jitter_pattern(history) return #history > 2 and math_util.angle_diff(history[#history-1], history[#history]) > 40 end
local function detect_desync_pattern(history) return 0 end
local function get_lower_body_yaw(enemy) return entity.get_prop(enemy, "m_flLowerBodyYawTarget") or 0 end
local function get_real_yaw_from_animations(enemy) return entity.get_prop(enemy, "m_angEyeAngles[1]") or 0 end
local function get_animation_state(enemy) return "standing" end
local function detect_fakelag(enemy) return false end
local function trace_to_lby(enemy, lby) return false end
local function should_use_lby(enemy, lby, eye_yaw, state, last_update) return false end
local function is_shooting(enemy) return false end
local function is_player_jumping(enemy) return (entity.get_prop(enemy, "m_vecVelocity[2]") or 0) ~= 0 end
local function std_dev(t) return 0 end
local function enhanced_defensive_fix(enemy, yaw) return yaw end
local function flick_compensation(enemy, yaw) return yaw end
local function compensate_spread(weapon_id, state, x, y, z, distance) return x, y, z end
local function is_fast_firing_weapon(weapon_id) return false end


local function update_enemy_data_fix(enemy)
    resolver_data[enemy] = resolver_data[enemy] or {
        yaw_history = {},
        lby_history = {},
        eye_angles_history = {},
        miss_count = 0,
        hit_count = 0,
        confidence = 50,
        last_yaw = 0,
        last_seen = globals.realtime()
    }
    local data = resolver_data[enemy]
    local eye_angles = entity.get_prop(enemy, "m_angEyeAngles[1]") or 0
    table.insert(data.eye_angles_history, { y = eye_angles })
    if #data.eye_angles_history > RESOLVER_CONST.MAX_HISTORY_SIZE then
        table.remove(data.eye_angles_history, 1)
    end
    data.last_seen = globals.realtime()
    return true
end
local function handle_entities() end


local function calculate_anim_freshness(enemy)
    local sim_time = entity.get_prop(enemy, "m_flSimulationTime") or 0
    if sim_time == 0 then return 0, 0 end
    local tick_rate = globals.tickinterval()
    local latency = client.latency()
    local choke = get_adaptive_choke(enemy)
    local server_time = globals.curtime() - latency
    local freshness_ticks = (server_time - sim_time) / tick_rate
    local max_acceptable_freshness = 16 + choke + math.floor(latency / (tick_rate * 2))
    local freshness_factor = math.clamp(1 - (freshness_ticks / max_acceptable_freshness), 0, 1)
    return freshness_factor, freshness_ticks
end


local function extrapolate_yaw_from_anim_history(enemy, data)
    if not data.anim_history or #data.anim_history < 2 then
        return entity.get_prop(enemy, "m_flPoseParameter", 11) or 0
    end

    local filtered_history = {}
    for _, anim in ipairs(data.anim_history) do
        if globals.curtime() - anim.sim_time < 1.0 then
            table.insert(filtered_history, anim)
        end
    end
    if #filtered_history < 2 then
        return (entity.get_prop(enemy, "m_flPoseParameter", 11) or 0) * 360 - 180
    end

    local recent_anims = {filtered_history[#filtered_history], filtered_history[#filtered_history-1]}
    local yaw_trend = normalize_angle(recent_anims[1].pose_yaw - recent_anims[2].pose_yaw)
    local time_diff = recent_anims[1].sim_time - recent_anims[2].sim_time
    if time_diff <= 0 then return recent_anims[1].pose_yaw end
    local yaw_rate = yaw_trend / time_diff
    local extrapolation_time = globals.tickinterval() * get_adaptive_choke(enemy)
    local jitter_factor = detect_jitter_pattern(data.yaw_history or {}) and 0.5 or 1.0 -- vменьшаеnmcz при джиттере
    return normalize_angle(recent_anims[1].pose_yaw + yaw_rate * extrapolation_time * jitter_factor)
end

-- !
local function apply_brute_angles(player)
    local data = brute_data[player]
    if not data or data.state ~= "BRUTEFORCE" or globals.tickcount() > data.end_tick then
        data.state = "IDLE"
        return
    end

    local yaw = adaptive_adjust(player, brute_angles.yaw[data.yaw_index])
    local body_yaw = brute_angles.body_yaw[data.body_yaw_index]
    local pitch = brute_angles.pitch[data.pitch_index]
    data.yaw_index = (data.yaw_index % #brute_angles.yaw) + 1
    data.body_yaw_index = (data.body_yaw_index % #brute_angles.body_yaw) + 1
    data.pitch_index = (data.pitch_index % #brute_angles.pitch) + 1

    plist.set(player, "Force body yaw", true)
    plist.set(player, "Force body yaw value", math.clamp(body_yaw, -60, 60))
    if ui.get(ui_new_logs_enable) then
        client.color_log(255, 165, 0, string.format(
            "[PR0KLADKI] Brute: Enemy=%s, Yaw=%.1f, BodyYaw=%.1f, Pitch=%.1f",
            entity.get_player_name(player), yaw, body_yaw, pitch
        ))
    end
end

local function AlternativePredictPosition(enemy, time_delta)
    local x = entity.get_prop(enemy, "m_vecOrigin[0]") or 0
    local y = entity.get_prop(enemy, "m_vecOrigin[1]") or 0
    local z = entity.get_prop(enemy, "m_vecOrigin[2]") or 0
    local vx = entity.get_prop(enemy, "m_vecVelocity[0]") or 0
    local vy = entity.get_prop(enemy, "m_vecVelocity[1]") or 0
    local vz = entity.get_prop(enemy, "m_vecVelocity[2]") or 0

    return {
        x = x + vx * time_delta,
        y = y + vy * time_delta,
        z = z + vz * time_delta
    }
end

local function AlternativeDetectJitterPattern(enemy, data)
    if not data.yaw_history or #data.yaw_history < 3 then
        return "unknown", 0
    end

    local angle_switches = 0
    local jitter_amount = 0
    local pose_yaw = entity.get_prop(enemy, "m_flPoseParameter", 11) or 0
    pose_yaw = (pose_yaw * 360) - 180
    local pose_history = data.pose_history or {}
    table.insert(pose_history, pose_yaw)
    if #pose_history > 10 then table.remove(pose_history, 1) end
    data.pose_history = pose_history

    for i = 1, #data.yaw_history - 1 do
        local diff = math_util.angle_diff(data.yaw_history[i], data.yaw_history[i + 1])
        local pose_diff = i <= #pose_history - 1 and math.abs(math_util.angle_diff(pose_history[i], pose_history[i + 1])) or 0
        if diff > RESOLVER_CONST.JITTER_DETECTION_THRESHOLD and pose_diff < 30 then
            angle_switches = angle_switches + 1
            jitter_amount = math.max(jitter_amount, diff)
        end
    end

    local pattern_type = "unknown"
    if angle_switches >= 2 then
        pattern_type = "random"
    elseif angle_switches == 1 then
        pattern_type = "switch"
    elseif angle_switches == 0 then
        pattern_type = "static"
    end

    if pattern_type == "random" then
        jitter_amount = math.min(jitter_amount * 0.5, RESOLVER_CONST.MAX_DESYNC_DELTA)
    elseif pattern_type == "switch" then
        jitter_amount = math.min(jitter_amount, RESOLVER_CONST.MAX_DESYNC_DELTA)
    else
        jitter_amount = math.min(jitter_amount * 0.8, RESOLVER_CONST.MAX_DESYNC_DELTA)
    end

    return pattern_type, jitter_amount
end


local function smart_yaw_correction(enemy, final_yaw, data, yaw_diff, is_jittering, is_visible)
    if not ui.get(ui_elements.ui_smart_yaw_correction) then
        return final_yaw
    end

    local latency = client.latency()
    local tick_rate = globals.tickinterval()
    local state = get_player_state(enemy)
    local correction_yaw = 0
    local correction_intensity = 1.0
    local anim_state = get_animation_state(enemy)
    local is_fakelagging = detect_fakelag(enemy)
    local lby_stability = std_dev(data.lby_history)


    local yaw_diff_threshold = ui.get(ui_elements.yaw_diff_threshold) or 60
    local desync_range = ui.get(ui_elements.desync_range) or 45
    local auto_desync = ui.get(ui_elements.adaptive_auto_switch)


    local desync_side = data.desync_side or 0
    local detected_desync_range = desync_range
    if auto_desync then
        desync_side, detected_desync_range = detect_desync_pattern(data.yaw_history, data.lby_history)
        data.desync_side = desync_side
        data.desync_range = detected_desync_range
        if desync_side ~= 0 then
            desync_range = detected_desync_range
            log_debug(string.format("Auto desync detection for %s: side=%d, range=%.1f",
                entity.get_player_name(enemy), desync_side, desync_range))
        end
    end


    if latency > 0.1 then
        yaw_diff_threshold = yaw_diff_threshold * 1.2
    elseif latency < 0.05 then
        yaw_diff_threshold = yaw_diff_threshold * 0.8
    end
    if is_jittering then
        yaw_diff_threshold = yaw_diff_threshold * 0.7
    end
    if state == "standing" and not is_fakelagging then
        yaw_diff_threshold = yaw_diff_threshold * 0.9
    elseif state == "in_air" then
        yaw_diff_threshold = yaw_diff_threshold * 1.3
    elseif state == "crouching" then
        yaw_diff_threshold = yaw_diff_threshold * 0.95
    end
    yaw_diff_threshold = math.clamp(yaw_diff_threshold, 30, 90) --


    if is_fakelagging then
        desync_range = desync_range * 1.3
    elseif is_visible then
        desync_range = desync_range * 0.8
    end
    if data.miss_count > 2 then
        desync_range = desync_range * (1 + data.miss_count * 0.1)
    end
    if state == "crouching" then
        desync_range = desync_range * 0.9
    elseif state == "running" then
        desync_range = desync_range * 1.1
    end
    desync_range = math.clamp(desync_range, DESYNC_CONST.MIN_DESYNC_RANGE, DESYNC_CONST.MAX_DESYNC_DELTA)

    if latency > 0.1 then
        correction_intensity = correction_intensity * 1.2
    elseif latency < 0.05 then
        correction_intensity = correction_intensity * 0.8
    end
    if anim_state == "crouching" then
        correction_intensity = correction_intensity * 1.1
    elseif anim_state == "running" then
        correction_intensity = correction_intensity * 0.9
    end


    if is_jittering and ui.get(ui_elements.jitter_detection) then
        correction_intensity = correction_intensity * 1.3
        correction_yaw = ui.get(ui_elements.jitter_yaw_adjust) * (desync_side > 0 and 1 or -1)
        if not desync_side then
            correction_yaw = math.random(-desync_range, desync_range)
        end
        data.confidence = math.max(40, data.confidence - 10)
        data.aa_pattern = "jitter"
        log_debug(string.format("Jitter correction for %s: yaw=%.1f, intensity=%.2f",
            entity.get_player_name(enemy), correction_yaw, correction_intensity))
    end
    if yaw_diff > yaw_diff_threshold or desync_side ~= 0 then
        correction_yaw = desync_range * desync_side
        correction_intensity = correction_intensity * (1 + (data.miss_count * 0.1))
        data.confidence = math.min(100, data.confidence + DESYNC_CONST.CONFIDENCE_BOOST * 100)
        log_debug(string.format("Desync correction for %s: yaw=%.1f, side=%d, range=%.1f, intensity=%.2f",
            entity.get_player_name(enemy), correction_yaw, desync_side, desync_range, correction_intensity))
    end
    if state == "standing" and not is_fakelagging and lby_stability < ui.get(ui_elements.jitter_lby_threshold) then
        local lby = get_lower_body_yaw(enemy)
        correction_yaw = lby - final_yaw
        correction_intensity = correction_intensity * 1.2
        data.confidence = math.min(100, data.confidence + 15)
        log_debug(string.format("Standing LBY correction for %s: yaw=%.1f, lby_stability=%.1f, intensity=%.2f",
            entity.get_player_name(enemy), correction_yaw, lby_stability, correction_intensity))
    elseif state == "running" then
        correction_yaw = 5
        data.confidence = math.max(50, data.confidence - 5)
    elseif state == "crouching" then
        correction_yaw = -5
        correction_intensity = correction_intensity * 1.1
    end




    local adjusted_yaw = math.lerp(final_yaw, normalize_angle(final_yaw + (correction_yaw * correction_intensity)), DESYNC_CONST.LERP_FACTOR)
    adjusted_yaw = math.clamp(adjusted_yaw, -DESYNC_CONST.MAX_DESYNC_DELTA, DESYNC_CONST.MAX_DESYNC_DELTA)


    if data.confidence < ui.get(ui_elements.confidence_threshold) and is_visible then
        adjusted_yaw = normalize_angle(adjusted_yaw + math.random(-10, 10))
        log_debug(string.format("Low confidence correction for %s: random adjust, final_yaw=%.1f",
            entity.get_player_name(enemy), adjusted_yaw))
    end


    data.last_yaw = adjusted_yaw
    resolver_data[enemy] = data

    log_debug(string.format("Smart Yaw Correction for %s: final_yaw=%.1f, threshold=%.1f, desync_range=%.1f, confidence=%.1f",
        entity.get_player_name(enemy), adjusted_yaw, yaw_diff_threshold, desync_range, data.confidence))

    return adjusted_yaw
end
-- тест фейклаг
local function predict_fakelag_position(enemy, pred_x, pred_y, pred_z)
    local data = resolver_data[enemy] or {}
    local is_fakelag, pattern, choke, avg_choke = detect_fakelag(enemy)
    if not is_fakelag or not data.fakelag_history or #data.fakelag_history < 5 then
        return pred_x, pred_y, pred_z
    end

    local vx = entity.get_prop(enemy, "m_vecVelocity[0]") or 0
    local vy = entity.get_prop(enemy, "m_vecVelocity[1]") or 0
    local vz = entity.get_prop(enemy, "m_vecVelocity[2]") or 0
    local tick_rate = globals.tickinterval()
    local latency = client.latency()


    local choke_time = 0
    if pattern == "adaptive" then

        choke_time = avg_choke * tick_rate
    elseif pattern == "high" then
        choke_time = math.min(choke, 15) * tick_rate
    elseif pattern == "low" then
        choke_time = math.min(choke, 5) * tick_rate
    end


    choke_time = choke_time + latency
    local new_x = pred_x + vx * choke_time
    local new_y = pred_y + vy * choke_time
    local new_z = pred_z + vz * choke_time - (800 * choke_time^2) / 2


    local current_head_x, current_head_y, current_head_z = entity.hitbox_position(enemy, 0)
    local speed = math.sqrt(vx^2 + vy^2)
    local clamp_range = 40 + math.clamp(speed / 5, 0, 30) + math.clamp(latency * 150, 0, 20)
    new_x = math.clamp(new_x, current_head_x - clamp_range, current_head_x + clamp_range)
    new_y = math.clamp(new_y, current_head_y - clamp_range, current_head_y + clamp_range)
    new_z = math.clamp(new_z, current_head_z - clamp_range, current_head_z + clamp_range)

    return new_x, new_y, new_z
end

-- боди нпхуй
local function calculate_body_hitbox_offset(enemy, final_yaw)
    local pose_yaw = entity.get_prop(enemy, "m_flPoseParameter", 11) or 0
    pose_yaw = (pose_yaw * 360) - 180
    local desync_side = resolver_data[enemy].desync_side or 0
    local desync_amount = math.clamp(ui.get(ui_elements.desync_range) or 58, 0, 58)
    local state = get_player_state(enemy)


    local offset_distance = 4.5
    if state == "crouching" then
        offset_distance = 3.5
    elseif state == "in_air" then
        offset_distance = 5.0
    end


    local body_offset = vector(0, 0, 0)
    if desync_side ~= 0 then
        local yaw_rad = math.rad(normalize_angle(pose_yaw + desync_side * desync_amount))
        body_offset.x = math.cos(yaw_rad) * offset_distance
        body_offset.y = math.sin(yaw_rad) * offset_distance

        if state == "crouching" then
            body_offset.z = -2.0
        elseif state == "in_air" then
            body_offset.z = 1.0
        end
    end

    return body_offset
end

local function apply_body_hitbox_correction(enemy, pred_x, pred_y, pred_z, final_yaw)
    local offset = calculate_body_hitbox_offset(enemy, final_yaw)
    if offset.x == 0 and offset.y == 0 and offset.z == 0 then
        return pred_x, pred_y, pred_z
    end
    return pred_x + offset.x, pred_y + offset.y, pred_z + offset.z
end

local function n3r4z1m_resolver()
    if not ui.get(ui_resolver_enabled) then return end
    local latency = client.latency()
    if latency > 0.2 then
        client.color_log(255, 0, 0, string.format("[PR0KLADKI] Warning: High latency (%.0fms) may cause issues", latency * 1000))
        return
    end
    local success, err = pcall(function()
        local local_player = entity.get_local_player()
        if not local_player or not entity.is_alive(local_player) then return end


        local local_x, local_y, local_z = entity.get_prop(local_player, "m_vecOrigin")
        local weapon = entity.get_player_weapon(local_player)
        if not weapon then return end
        local weapon_id = entity.get_prop(weapon, "m_iItemDefinitionIndex")
        local bullet_speed = get_bullet_speed(weapon_id)
        local weapon_damage = get_weapon_damage(weapon_id)
        local is_scout = weapon_id == 40
        local optimize_jump_scout = ui.get(ui_elements.jump_scout_opt) and is_scout
        local enemies = entity.get_players(true)
        local local_hp = entity.get_prop(local_player, "m_iHealth")
        local max_enemies = 5 

        debug_info = {}
        handle_entities()

        if not resolved_target or not entity.is_alive(resolved_target) then
            resolved_target = nil
            for _, enemy in ipairs(enemies) do
                if resolver_data[enemy] and (resolver_data[enemy].hit_count > 0 or resolver_data[enemy].miss_count < 3) then
                    resolved_target = enemy
                    client.color_log(255, 255, 255, "[PR0KLADKI] пидор: " .. entity.get_player_name(enemy))
                    break
                end
            end
            if not resolved_target and #enemies > 0 then
                resolved_target = enemies[1]
                client.color_log(255, 255, 255, "[PR0KLADKI] Resolved target: " .. entity.get_player_name(enemies[1]))
            end
        end

        if resolved_target then
            enemies = {resolved_target}
        end

        for _, enemy in ipairs(enemies) do
            if entity.is_alive(enemy) then
                local should_process = update_enemy_data_fix(enemy)
                if should_process then
                    local data = resolver_data[enemy]
                    local eye_yaw = entity.get_prop(enemy, "m_angEyeAngles[1]") or 0
                    local lby = get_lower_body_yaw(enemy)
                    local final_yaw = get_real_yaw_from_animations(enemy)
                    local mode = ui.get(ui_mode_select)

                    if mode == "Custom" then
                        if ui.get(ui_elements.alternative_jitter) then
                            local jitter_pattern, jitter_amount = AlternativeDetectJitterPattern(enemy, data)
                            if jitter_pattern ~= "unknown" then
                                if jitter_pattern == "random" then
                                    final_yaw = math_util.normalize_angle(final_yaw + (math.random(-1, 1) * jitter_amount))
                                elseif jitter_pattern == "switch" then
                                    final_yaw = math_util.normalize_angle(final_yaw + (data.desync_side or 1) * jitter_amount)
                                end
                                data.aa_pattern = "jitter_" .. jitter_pattern

                            end
                        end
                    end

                    plist.set(enemy, "Force body yaw", true)
                    plist.set(enemy, "Force body yaw value", math_util.clamp(final_yaw, -60, 60))
                end
            end
        end
    end)
    if not success then
        client.color_log(255, 255, 255, "[PR0KLADKI] Critical error in resolver: ", err)
    end
end


client.set_event_callback("setup_command", n3r4z1m_resolver)


local shots = {
    hit = {},
    missed = { 0, 0, 0, 0, 0 }, -- 1 сприд, 2 пред еррор, 3 пинг (смерть), 4- хз, 5 тотально
    total = 0
}


local function lerp(a, b, t)
    return a + (b - a) * t
end


local function get_gradient_color(x, width)
    local speed = 1
    local color1 = {255, 0, 255}
    local color2 = {0, 128, 255}
    local time = globals.realtime() * speed
    local offset = (time % 2) / 2
    local pos = (x / width + offset) % 1

    local r = lerp(color1[1], color2[1], pos)
    local g = lerp(color1[2], color2[2], pos)
    local b = lerp(color1[3], color2[3], pos)

    return math.floor(r), math.floor(g), math.floor(b)
end


local function get_stats_gradient_color(x, width)
    local speed = 0.75
    local color1 = {255, 255, 255}
    local color2 = {80, 80, 80}
    local time = globals.realtime() * speed
    local offset = (time % 2) / 2
    local pos = (x / width * 0.4 + offset) % 1

    local r = lerp(color1[1], color2[1], pos)
    local g = lerp(color1[2], color2[2], pos)
    local b = lerp(color1[3], color2[3], pos)

    return math.floor(r), math.floor(g), math.floor(b)
end


local function calculate_distance(pos1, pos2)
    local dx = pos2.x - pos1.x
    local dy = pos2.y - pos1.y
    local dz = pos2.z - pos1.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end




local function get_current_target()
    local local_player = entity.get_local_player()
    if not local_player or not entity.is_alive(local_player) then
        return nil
    end

    local local_pos = vector(entity.get_origin(local_player))
    local enemies = entity.get_players(true) -- Только враги
    local closest_enemy = nil
    local min_distance = math.huge

    for i = 1, #enemies do
        local enemy = enemies[i]
        if entity.is_alive(enemy) then
            local enemy_pos = vector(entity.get_origin(enemy))
            local distance = calculate_distance(local_pos, enemy_pos)
            if distance < min_distance then
                min_distance = distance
                closest_enemy = enemy
            end
        end
    end

    return closest_enemy
end
-- !nachalo
-- GLory 2
local color = require("gamesense/color")


local function utils_sine_yaw(tick, min, max)
    local amplitude = (max - min) / 2
    local center = (max + min) / 2
    return center + (amplitude * math.sin(tick * 0.05))
end

local function utils_lerp(start, end_pos, time, ampl)
    if (start == end_pos) then return end_pos end
    ampl = ampl or (1 / globals.frametime())
    local frametime = globals.frametime() * ampl
    time = time * frametime
    local val = start + ((end_pos - start) * time)
    if (math.abs(val - end_pos) < 0.25) then return end_pos end
    return val
end


local gradient_table = {
    {color(244, 244, 244, 255), 0},
    {color(115, 115, 115, 255), 0.5},
    {color(233, 233, 233, 255), 1}
}
local stats_alpha = 0


local function draw_rounded_rectangle(x, y, w, h, r, g, b, a, radius)
    radius = math.min(radius, w / 2, h / 2)
    local radius_2 = radius * 2
    renderer.rectangle(x + radius, y, w - radius_2, h, r, g, b, a)
    renderer.rectangle(x, y + radius, radius, h - radius_2, r, g, b, a)
    renderer.rectangle((x + w) - radius, y + radius, radius, h - radius_2, r, g, b, a)
    renderer.circle(x + radius, y + radius, r, g, b, a, radius, 180, 0.25)
    renderer.circle(x + radius, (y + h) - radius, r, g, b, a, radius, 270, 0.25)
    renderer.circle((x + w) - radius, y + radius, r, g, b, a, radius, 90, 0.25)
    renderer.circle((x + w) - radius, (y + h) - radius, r, g, b, a, radius, 0, 0.25)
end
client.set_event_callback("paint", function()

    local show = ui.get(ui_new_logs_enable)
    local target_alpha = show and 1 or 0
    stats_alpha = utils_lerp(stats_alpha, target_alpha, 0.03)


    if stats_alpha <= 0.01 then return end


    shots.missed[5] = shots.missed[1] + shots.missed[2] + shots.missed[4]


    local screen_w, screen_h = client.screen_size()


    local total_shots = #shots.hit + shots.missed[5]
    local hits = #shots.hit
    local misses = shots.missed[5]
    local hit_rate = total_shots > 0 and string.format("%.1f", (hits / total_shots) * 100) or "0.0"
    local current_target = get_current_target()
    local target_name = current_target and entity.get_player_name(current_target) or "No target"
    local stats_text = string.format("Shots: %d  |  Hits: %d  |  Misses: %d  |  Hit Rate: %s%%  |  Close Target: %s",
        total_shots, hits, misses, hit_rate, target_name)

    local title = "PR0KLADKI" -- ‹ Ĭɱmŏŗŧàɫ ›
    local title_width = renderer.measure_text("b", title)
    local title_x = screen_w / 2 - title_width / 2
    local title_y = screen_h / 2 + 493

    local stats_width = renderer.measure_text("", stats_text)
    local stats_x = screen_w / 2 - stats_width / 2
    local stats_y = screen_h / 2 + 513


    local padding = -15
    local background_width = math.max(title_width, stats_width) + padding * -1
    local background_height = 22
    local background_x = screen_w / 2 - background_width / 2
    local background_y = title_y - padding


    draw_rounded_rectangle(background_x, background_y, background_width, background_height, 0, 0, 0, math.floor(100 * stats_alpha), 20)


    local x_offset = title_x
    for i = 1, #title do
        local char = title:sub(i, i)
        local time_offset = (utils_sine_yaw(globals.realtime() * 10, 6, 3) * 1.5) % 1
        local t = #title > 1 and (((i - 1) / (#title - 1)) + time_offset) % 1 or time_offset
        local col = color.linear_gradient(gradient_table, t)
        local r, g, b = col.r, col.g, col.b
        local a = math.floor(col.a * stats_alpha)
        renderer.text(x_offset, title_y, r, g, b, a, "b", 0, char)
        x_offset = x_offset + renderer.measure_text("b", char)
    end


    local stats_x_offset = stats_x
    for i = 1, #stats_text do
        local char = stats_text:sub(i, i)
        local time_offset = (utils_sine_yaw(globals.realtime() * 6, 8, 3) * 1.5) % 1
        local t = #stats_text > 1 and (((i - 1) / (#stats_text - 1)) + time_offset) % 1 or time_offset
        local col = color.linear_gradient(gradient_table, t)
        local r, g, b = col.r, col.g, col.b
        local a = math.floor(col.a * stats_alpha)
        renderer.text(stats_x_offset, stats_y, r, g, b, a, "", 0, char)
        stats_x_offset = stats_x_offset + renderer.measure_text("", char)
    end
end)

client.set_event_callback("aim_hit", function(shot)
    table.insert(shots.hit, {
        entity.get_player_name(shot.target),
        shot.hit_chance,
        shot.damage,
        ({ "generic", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "unknown", "gear" })[shot.hitgroup + 1] or "unknown"
    })
end)

client.set_event_callback("aim_miss", function(shot)
    if shot.reason == "spread" then shots.missed[1] = shots.missed[1] + 1 end
    if shot.reason == "prediction error" then shots.missed[2] = shots.missed[2] + 1 end
    if shot.reason == "death" then shots.missed[3] = shots.missed[3] + 1 end
    if shot.reason == "?" then shots.missed[4] = shots.missed[4] + 1 end
end)


client.set_event_callback("player_connect_full", function(e)
    if client.userid_to_entindex(e.userid) == entity.get_local_player() then
        shots.missed[1] = 0
        shots.missed[2] = 0
        shots.missed[3] = 0
        shots.missed[4] = 0
        for k in pairs(shots.hit) do shots.hit[k] = nil end
    end
end)


client.set_event_callback("console_input", function(inp)
    if inp:sub(1, 12) == "print_misses" then
        client.color_log(180, 180, 180, string.format("spread: %d\nprediction errors: %d\ndeath: %d\nunknown: %d", shots.missed[1], shots.missed[2], shots.missed[3], shots.missed[4]))
        return true
    end
    if inp:sub(1, 10) == "print_hits" then
        for i=1, #shots.hit do
            local curr = shots.hit[i]
            client.color_log(180, 180, 180, string.format("[%d] %s's %s - hc:%d%%, dmg:%d", i, curr[1], curr[4], curr[2], curr[3]))
        end
        return true
    end
end)



local function get_player_state(enemy)
    local vx = entity.get_prop(enemy, "m_vecVelocity[0]") or 0
    local vy = entity.get_prop(enemy, "m_vecVelocity[1]") or 0
    local vz = entity.get_prop(enemy, "m_vecVelocity[2]") or 0
    local speed = math.sqrt(vx^2 + vy^2)
    local flags = entity.get_prop(enemy, "m_fFlags") or 0
    if bit.band(flags, 1) == 0 then return "in_air" end
    if speed < 10 then return "standing" end
    if speed < 135 then return "slow_walk" end
    return "walking"
end

local function table_contains(tab, val)
    for _, v in ipairs(tab) do
        if v == val then return true end
    end
    return false
end

local function is_player_jumping(enemy)
    local flags = entity.get_prop(enemy, "m_fFlags") or 0
    return bit.band(flags, 1) == 0
end

local function n3r4z1m_resolver()
    if not ui.get(ui_resolver_enabled) then return end

    local success, err = pcall(function()
        local local_player = entity.get_local_player()
        if not local_player or not entity.is_alive(local_player) then return end

        if ui.get(ui_elements.hit_chance_bind) then
            hit_chance_enabled = not hit_chance_enabled
            client.color_log(255, 255, 255, hit_chance_enabled and "[] Hit Chance Override Enabled" or "[PR0KLADKI] Hit Chance Override Disabled")
        end

       debug_info = {}
       handle_entities()  -- не используеться вроде

        local local_x, local_y, local_z = entity.get_prop(local_player, "m_vecOrigin")
        local weapon = entity.get_player_weapon(local_player)
        if not weapon then return end
        local weapon_id = entity.get_prop(weapon, "m_iItemDefinitionIndex")
        local bullet_speed = get_bullet_speed(weapon_id)
        local weapon_damage = get_weapon_damage(weapon_id)
        local is_scout = weapon_id == 40
        local optimize_jump_scout = ui.get(ui_elements.jump_scout_opt) and is_scout
        local enemies = entity.get_players(true)
        local local_hp = entity.get_prop(local_player, "m_iHealth")

        debug_info = {}
        handle_entities()


local ent_c = {}
ent_c.get_client_entity = vtable_bind('client.dll', 'VClientEntityList003', 3, 'void*(__thiscall*)(void*, int)')




local function update_manual_predict_visibility()
    local manual_enabled = ui.get(ui_elements.manual_predict)
    local selected_states = ui.get(ui_elements.manual_states)
    ui.set_visible(ui_elements.manual_states, manual_enabled)
    ui.set_visible(ui_elements.predict_standing, manual_enabled and table_contains(selected_states, "Standing"))
    ui.set_visible(ui_elements.predict_crouching, manual_enabled and table_contains(selected_states, "Crouching"))
    ui.set_visible(ui_elements.predict_air, manual_enabled and table_contains(selected_states, "In-Air"))
    ui.set_visible(ui_elements.predict_walking, manual_enabled and table_contains(selected_states, "Walking"))
    ui.set_visible(ui_elements.predict_slowwalk, manual_enabled and table_contains(selected_states, "Slow Walk"))
end
ui.set_callback(ui_elements.manual_predict, update_manual_predict_visibility)
ui.set_callback(ui_elements.manual_states, update_manual_predict_visibility)

local function update_jitter_visibility()
    local jitter_enabled = ui.get(ui_elements.jitter_detection)
    ui.set_visible(ui_elements.jitter_threshold, jitter_enabled)
    ui.set_visible(ui_elements.jitter_yaw_adjust, jitter_enabled)
    ui.set_visible(ui_elements.jitter_lby_threshold, jitter_enabled)
end
ui.set_callback(ui_elements.jitter_detection, update_jitter_visibility)



local function update_t3mp3st_visibility()
    local t3mp3st_enabled = ui.get(ui_elements.t3mp3st_mode)

    ui.set_visible(ui_elements.enhanced_defensive_fix, t3mp3st_enabled)

    ui.set_visible(ui_elements.low_confidence_delay_label, t3mp3st_enabled)

end
ui.set_callback(ui_elements.t3mp3st_mode, update_t3mp3st_visibility)


local function update_experimental_visibility()
    local experimental_enabled = ui.get(ui_elements.experimental_mode)
    ui.set_visible(ui_elements.velocity_scale, experimental_enabled)
    ui.set_visible(ui_elements.gravity_factor, experimental_enabled)
--    ui.set_visible(ui_elements.flick_detection, experimental_enabled)
--    ui.set_visible(ui_elements.flick_velocity_threshold, experimental_enabled and ui.get(ui_elements.flick_detection))
--    ui.set_visible(ui_elements.flick_reaction_time, experimental_enabled and ui.get(ui_elements.flick_detection))
--    ui.set_visible(ui_elements.flick_prediction_boost, experimental_enabled and ui.get(ui_elements.flick_detection))
--    ui.set_visible(ui_elements.flick_yaw_correction, experimental_enabled and ui.get(ui_elements.flick_detection))
--    ui.set_visible(ui_elements.flick_mode, experimental_enabled and ui.get(ui_elements.flick_detection))
    ui.set_visible(ui_elements.fakelag_optimization, experimental_enabled)
    ui.set_visible(ui_elements.dormant_aimbot, experimental_enabled)
    ui.set_visible(ui_elements.dormant_min_damage, experimental_enabled and ui.get(ui_elements.dormant_aimbot))
    ui.set_visible(ui_elements.predict_beta, experimental_enabled)
    ui.set_visible(ui_elements.resolver_correction, experimental_enabled)
    ui.set_visible(ui_elements.resolver_correction_intensity, experimental_enabled and ui.get(ui_elements.resolver_correction))
    ui.set_visible(ui_elements.mode_select, experimental_enabled)
    ui.set_visible(ui_elements.jump_scout_opt, experimental_enabled)



end
ui.set_callback(ui_elements.experimental_mode, update_experimental_visibility)
--ui.set_callback(ui_elements.flick_detection, update_experimental_visibility)
ui.set_callback(ui_elements.resolver_correction, update_experimental_visibility)


update_manual_predict_visibility()
update_jitter_visibility()
update_dormant_aimbot_visibility()
update_experimental_visibility()
update_t3mp3st_visibility()



local resolver_data = {}
local debug_info = {}

local persist_target = nil
local resolved_target = nil
local hit_chance_enabled = false
local adaptive_mode_index = 1
local adaptive_modes = {"static", "dynamic", "beta"}

local resolver_data = resolver_data or {}
resolver_data[enemy] = {
    brute_data = {},
    avg_speed = 0,
    last_yaw = entity.get_prop(enemy, "m_angEyeAngles[1]") or 0,
    last_time = globals.realtime(),
    last_non_flick_time = globals.realtime(),
    last_sim_time = entity.get_prop(enemy, "m_flSimulationTime") or 0,
    yaw_history = {},
    pose_history = {},
    desync_side = 0,
    flick_detected = false,
    angular_velocities = {},
    miss_count = 0,
    hit_count = 0,
    last_seen = globals.realtime(),
    miss_history = {},
    aa_pattern = "unknown",
    is_dormant = not is_fully_visible,
    last_velocity = {x = 0, y = 0, z = 0},
    last_lby_update = globals.curtime(),
    lby_history = {},
    confidence = 100,
    pose_error = false
}

local function get_player_movement_state(enemy)
    local forward_pose = entity.get_prop(enemy, "m_flPoseParameter", 0) or 0
    local strafe_pose = entity.get_prop(enemy, "m_flPoseParameter", 1) or 0
    local speed = math.sqrt((entity.get_prop(enemy, "m_vecVelocity[0]") or 0)^2 + (entity.get_prop(enemy, "m_vecVelocity[1]") or 0)^2)

    if speed < 10 then
        return "standing"
    elseif forward_pose > 0.7 then
        return "running_forward"
    elseif forward_pose < -0.7 then
        return "running_backward"
    elseif strafe_pose > 0.5 then
        return "strafing_right"
    elseif strafe_pose < -0.5 then
        return "strafing_left"
    elseif speed > 100 then
        return "running"
    else
        return "walking"
    end
end

local function get_bullet_speed(weapon_id)
    local bullet_speeds = {
        [7] = 2500, [9] = 3000, [16] = 2500, [40] = 2500, [11] = 2000, [4] = 2250
    }
    return bullet_speeds[weapon_id] or 2500
end

local function get_weapon_damage(weapon_id)
    local damages = {
        [7] = 36, [9] = 115, [16] = 33, [40] = 88, [11] = 28, [4] = 30
    }
    return damages[weapon_id] or 30
end

local function is_fast_firing_weapon(weapon_id)
    local fast_firing = { [11] = true, [32] = true }
    return fast_firing[weapon_id] or false
end

local function is_player_jumping(player)
    local flags = entity.get_prop(player, "m_fFlags")
    return bit.band(flags, 1) == 0
end

local function normalize_angle(angle)
    while angle > 180 do angle = angle - 360 end
    while angle < -180 do angle = angle + 360 end
    return angle
end

local function angle_difference(a, b)
    local diff = normalize_angle(a - b)
    return math.abs(diff)
end

local function lerp(a, b, t) return a + (b - a) * t end
local function clamp(x, min, max) return math.max(min, math.min(x, max)) end

local function std_dev(values)
    if #values < 2 then return 0 end
    local mean = 0
    for i = 1, #values do mean = mean + values[i] end
    mean = mean / #values
    local sum_sq_diff = 0
    for i = 1, #values do sum_sq_diff = sum_sq_diff + (values[i] - mean)^2 end
    return math.sqrt(sum_sq_diff / (#values - 1))
end

local function get_player_state(player)
    local flags = entity.get_prop(player, "m_fFlags")
    local vx = entity.get_prop(player, "m_vecVelocity[0]") or 0
    local vy = entity.get_prop(player, "m_vecVelocity[1]") or 0
    local speed = math.sqrt(vx^2 + vy^2)
    if bit.band(flags, 1) == 0 then return "in_air"
    elseif bit.band(flags, 4) ~= 0 then return "crouching"
    elseif speed < 10 then return "standing"
    elseif speed < 100 then return "slow_walk"
    else return "walking" end
end

local function get_animation_state(enemy)
    local anim_layer = entity.get_prop(enemy, "m_AnimOverlay", 1) or 0
    local weight = entity.get_prop(enemy, "m_flWeight", 1) or 0
    if weight > 0 then
        if anim_layer == 3 then return "walking"
        elseif anim_layer == 4 then return "running"
        elseif anim_layer == 6 then return "crouching"
        end
    end
    return "standing"
end

local function detect_jitter_pattern(yaw_history)
    if #yaw_history < 5 then return false end
    local diffs = {}
    for i = 2, #yaw_history do
        table.insert(diffs, angle_difference(yaw_history[i], yaw_history[i-1]))
    end
    local avg_diff = 0
    for _, diff in ipairs(diffs) do avg_diff = avg_diff + diff end
    avg_diff = avg_diff / #diffs
    local std = std_dev(diffs)
    return std > ui.get(ui_elements.jitter_threshold) and math.abs(avg_diff) < 30
end

local function detect_desync_pattern(yaw_history, lby_history)
    if #yaw_history < DESYNC_CONST.HISTORY_SIZE then
        return 0, DESYNC_CONST.MIN_DESYNC_RANGE
    end


    local yaw_std_dev = calculate_std_dev(yaw_history)
    local lby_std_dev = calculate_std_dev(lby_history)
    local desync_side = 0
    local desync_range = DESYNC_CONST.MIN_DESYNC_RANGE


    if yaw_std_dev > DESYNC_CONST.JITTER_DETECTION_THRESHOLD then

        desync_side = yaw_history[#yaw_history] > yaw_history[#yaw_history - 1] and 1 or -1
        desync_range = math.min(yaw_std_dev * 0.8, DESYNC_CONST.MAX_DESYNC_RANGE)
        log_debug(string.format("Jitter detected: std_dev=%.1f, range=%.1f, side=%d", yaw_std_dev, desync_range, desync_side))
    elseif lby_std_dev < 10 and math.abs(yaw_history[#yaw_history] - lby_history[#lby_history]) > 30 then

        desync_side = yaw_history[#yaw_history] > lby_history[#lby_history] and 1 or -1
        desync_range = math.clamp(math.abs(yaw_history[#yaw_history] - lby_history[#lby_history]), DESYNC_CONST.MIN_DESYNC_RANGE, DESYNC_CONST.MAX_DESYNC_RANGE)
        log_debug(string.format("Static desync: lby_std_dev=%.1f, range=%.1f, side=%d", lby_std_dev, desync_range, desync_side))
    else

        local max_diff = 0
        for i = 2, #yaw_history do
            local diff = math.abs(math_util.angle_diff(yaw_history[i], yaw_history[i-1]))
            max_diff = math.max(max_diff, diff)
        end
        if max_diff > 30 then
            desync_side = yaw_history[#yaw_history] > yaw_history[#yaw_history - 1] and 1 or -1
            desync_range = math.min(max_diff * 0.7, DESYNC_CONST.MAX_DESYNC_RANGE)
            log_debug(string.format("Wide desync: max_diff=%.1f, range=%.1f, side=%d", max_diff, desync_range, desync_side))
        end
    end

    return desync_side, desync_range
end

local function get_real_yaw_from_animations(enemy)
    local pose_param = entity.get_prop(enemy, "m_flPoseParameter", 11)
    local data = resolver_data[enemy] or {}
    if pose_param == nil or type(pose_param) ~= "number" then
        data.pose_error = true
        resolver_data[enemy] = data
        return entity.get_prop(enemy, "m_angEyeAngles[1]") or 0
    end
    data.pose_error = false
    resolver_data[enemy] = data
    return pose_param * 120 - 60
end

local function get_lower_body_yaw(enemy)
    local lby = entity.get_prop(enemy, "m_flLowerBodyYawTarget")
    return lby or 0
end

local function should_use_lby(enemy, lby, eye_yaw, state, last_lby_update)
    local current_time = globals.curtime()
    local lby_diff = angle_difference(lby, eye_yaw)
    if state == "standing" and (current_time - last_lby_update >= 1.1 or math.abs(lby_diff) > 60) then
        return true
    end
    return false
end

local function is_shooting(enemy)
    local weapon = entity.get_player_weapon(enemy)
    if weapon then
        local last_shot_time = entity.get_prop(weapon, "m_fLastShotTime") or 0
        return globals.curtime() - last_shot_time < 0.1
    end
    return false
end

local function detect_fakelag(enemy)
    local data = enemy_data[enemy] or {}
    local sim_times = data.sim_times or {}
    if #sim_times < 2 then return false end
    local dt = sim_times[#sim_times] - sim_times[#sim_times - 1]
    local expected_dt = globals.tickinterval()
    local choked = math.floor(dt / expected_dt) - 1
    return choked > 1
end

local function can_see_through_wall(local_player, enemy)
    local lx, ly, lz = client.eye_position()
    local ex, ey, ez = entity.hitbox_position(enemy, 0)
    local fraction = client.trace_line(local_player, lx, ly, lz, ex, ey, ez)
    return fraction < 1.0
end

local function trace_to_lby(enemy, predicted_yaw)
    local local_player = entity.get_local_player()
    local lx, ly, lz = client.eye_position()
    local ex, ey, ez = entity.get_origin(enemy)
    local angle_rad = math.rad(predicted_yaw)
    local offset_x = ex + math.cos(angle_rad) * 50
    local offset_y = ey + math.sin(angle_rad) * 50
    local fraction, hit_entity = client.trace_line(local_player, lx, ly, lz, offset_x, offset_y, ez)
    return fraction < 1.0 and hit_entity == enemy
end


local weapon_spreads = {
    [7] = {standing = 0.2, walking = 0.6, slow_walk = 0.4, in_air = 0.8, crouching = 0.1},
    [9] = {standing = 0.05, walking = 0.2, slow_walk = 0.15, in_air = 0.3, crouching = 0.02},
    [16] = {standing = 0.2, walking = 0.5, slow_walk = 0.3, in_air = 0.7, crouching = 0.1},
    [40] = {standing = 0.1, walking = 0.3, slow_walk = 0.2, in_air = 0.4, crouching = 0.05},
    [11] = {standing = 0.3, walking = 0.8, slow_walk = 0.6, in_air = 1.0, crouching = 0.2},
    [4] = {standing = 0.2, walking = 0.6, slow_walk = 0.4, in_air = 0.8, crouching = 0.1}
}

local function compensate_spread(weapon_id, player_state, pred_x, pred_y, pred_z, distance)
    if not ui.get(ui_elements.spread_compensation) then return pred_x, pred_y, pred_z end
    local spread_data = weapon_spreads[weapon_id] or {standing = 0.2, walking = 0.6, slow_walk = 0.4, in_air = 0.8, crouching = 0.1}
    local base_spread = spread_data[player_state] or spread_data.standing
    local distance_factor = math.min(1.0, distance / 1000)
    local spread_factor = base_spread * (1 - distance_factor * 0.5) * 0.5
    local offset_x = math.random(-spread_factor, spread_factor)
    local offset_y = math.random(-spread_factor, spread_factor)
    local max_offset = 2.0
    offset_x = clamp(offset_x, -max_offset, max_offset)
    offset_y = clamp(offset_y, -max_offset, max_offset)
    return pred_x + offset_x, pred_y + offset_y, pred_z
end

local function enhanced_defensive_fix(enemy, final_yaw)
    if not ui.get(ui_elements.enhanced_defensive_fix) then return final_yaw end
    local data = resolver_data[enemy] or {}
    local sim_time = entity.get_prop(enemy, "m_flSimulationTime") or 0
    local cur_time = globals.curtime()
    local tick_interval = globals.tickinterval()
    local anim_freshness = sim_time > 0 and (cur_time - sim_time) / tick_interval or 0


    if anim_freshness > 3 then
        data.confidence = math.max(30, data.confidence - 5)
        return final_yaw
    end


    local pose_yaw = entity.get_prop(enemy, "m_flPoseParameter", 11) or 0
    pose_yaw = (pose_yaw * 360) - 180
    local lby = get_lower_body_yaw(enemy)
    local eye_yaw = entity.get_prop(enemy, "m_angEyeAngles[1]") or 0
    local lby_diff = math_util.angle_diff(lby, eye_yaw)
    local pose_diff = math_util.angle_diff(pose_yaw, eye_yaw)

    if detect_fakelag(enemy) and not is_shooting(enemy) then
        if math.abs(lby_diff) > 35 or math.abs(pose_diff) > 35 then
            final_yaw = normalize_angle(pose_yaw)
            data.confidence = math.max(60, data.confidence - 3)
        end
    end


    if ui.get(ui_elements.fakelag_optimization) then
        local choke = get_choke(enemy)
        if choke > 2 then
            local desync_side = detect_desync_pattern(data.yaw_history) or data.desync_side or 0
            final_yaw = normalize_angle(final_yaw + (desync_side * 58 * (1 - anim_freshness / 3)))
            data.confidence = math.max(50, data.confidence - 2)
        end
    end

    resolver_data[enemy] = data
    return final_yaw
end

-- region dormat '!' [tts]
local function dormant_aimbot(cmd)
    if not ui.get(ui_elements.dormant_aimbot) then return end
    local lp = entity.get_local_player()
    if not lp or not entity.is_alive(lp) then return end

    local weapon = entity.get_player_weapon(lp)
    if not weapon then return end
    local weapon_id = entity.get_prop(weapon, "m_iItemDefinitionIndex")
    local bullet_speed = get_bullet_speed(weapon_id)
    local eyepos = vector(client.eye_position())
    local simtime = entity.get_prop(lp, "m_flSimulationTime")
    local weapon_data = weapons(weapon)
    local scoped = entity.get_prop(lp, "m_bIsScoped") == 1
    local onground = bit.band(entity.get_prop(lp, 'm_fFlags'), bit.lshift(1, 0))
    local can_shoot = simtime > math.max(entity.get_prop(lp, "m_flNextAttack"), entity.get_prop(weapon, "m_flNextPrimaryAttack"))
    local ent = native_GetClientEntity(weapon)
    local inaccuracy = ent and native_IsWeapon(ent) and native_GetInaccuracy(ent) or 0

    for player = 1, globals.maxplayers() do
        if entity.is_dormant(player) and entity.is_enemy(player) and entity.get_prop(entity.get_player_resource(), "m_bConnected", player) == 1 then
            local _, _, _, _, alpha_multiplier = entity.get_bounding_box(player)
            if alpha_multiplier > 0.795 then
                local pred_x, pred_y, pred_z = choose_prediction(player, eyepos.x, eyepos.y, eyepos.z, bullet_speed, false)
                local ent, dmg = client.trace_bullet(lp, eyepos.x, eyepos.y, eyepos.z, pred_x, pred_y, pred_z, true)
                local can_hit = dmg > ui.get(ui_elements.dormant_min_damage) and not client_visible(pred_x, pred_y, pred_z)

                if can_hit and can_shoot and inaccuracy < 0.009 then
                    local data = resolver_data[player] or { confidence = 100, last_yaw = 0 }
                    local safe_hitbox = (data.confidence > 50 and ui.get(ui_elements.smart_head_aim)) and "Head" or "Chest"
                    plist.set(player, "Override preferred hitbox", safe_hitbox)
                    plist.set(player, "Force body yaw", true)
                    plist.set(player, "Force body yaw value", clamp(data.last_yaw or 0, -60, 60))

                    modify_velocity(cmd, (scoped and weapon_data.max_player_speed_alt or weapon_data.max_player_speed) * 0.33)
                    if not scoped and weapon_data.type == "sniperrifle" and cmd.in_jump == 0 and onground == 1 then
                        cmd.in_attack2 = 1
                    end

                    local pitch, yaw = eyepos:to(vector(pred_x, pred_y, pred_z)):angles()
                    cmd.pitch = pitch
                    cmd.yaw = yaw
                    cmd.in_attack = 1

                    if ui.get(ui_new_logs_enable) then
                        client.color_log(255, 165, 0, string.format(
                            "[PR0KLADKI] Dormant Shot: %s, Dmg=%d, Alpha=%.3f, Inacc=%.3f, Hitbox=%s",
                            entity.get_player_name(player), dmg, alpha_multiplier, inaccuracy, safe_hitbox
                        ))
                    end
                end
            end
        end
    end
end

client.set_event_callback("setup_command", dormant_aimbot)

local function update_enemy_data_fix(enemy)
    local local_player = entity.get_local_player()
    if not local_player or not entity.is_alive(local_player) then return false end

    local lx, ly, lz = client.eye_position()
    local ex, ey, ez = entity.hitbox_position(enemy, 0)
    local fraction = client.trace_line(local_player, lx, ly, lz, ex, ey, ez)
    local is_partially_visible = fraction < 1.0 and fraction > 0.0
    local is_fully_visible = entity.get_prop(enemy, "m_bSpotted") == 1

    if is_partially_visible or is_fully_visible or (ui.get(ui_elements.dormant_aimbot) and enemy == resolved_target and can_see_through_wall(local_player, enemy)) then
        if not resolver_data[enemy] then
            resolver_data[enemy] = {
                avg_speed = 0,
                last_yaw = entity.get_prop(enemy, "m_angEyeAngles[1]") or 0,
                last_time = globals.realtime(),
                last_non_flick_time = globals.realtime(),
                last_sim_time = entity.get_prop(enemy, "m_flSimulationTime") or 0,
                yaw_history = {},
                desync_side = 0,
                pose_history = {},
                sim_time_history = {},
                flick_detected = false,
                angular_velocities = {},
                miss_count = 0,
                hit_count = 0,
                last_seen = globals.realtime(),
                miss_history = {},
                aa_pattern = "unknown",
                is_dormant = not is_fully_visible,
                last_velocity = {x = 0, y = 0, z = 0},
                last_lby_update = globals.curtime(),
                lby_history = {},
                confidence = 100,
                pose_error = false
            }
        else
            resolver_data[enemy].last_seen = globals.realtime()
            resolver_data[enemy].is_dormant = not is_fully_visible
        end


        local sim_time = entity.get_prop(enemy, "m_flSimulationTime") or 0
        resolver_data[enemy].sim_time_history = resolver_data[enemy].sim_time_history or {}
        table.insert(resolver_data[enemy].sim_time_history, sim_time)
        if #resolver_data[enemy].sim_time_history > 10 then
            table.remove(resolver_data[enemy].sim_time_history, 1)
        end

        return true
    end

    if resolver_data[enemy] and (globals.realtime() - resolver_data[enemy].last_seen < 3.0) then
        resolver_data[enemy].is_dormant = true
        return true
    end
    return false
end


local function detect_fakelag(enemy)
    local choke = get_choke(enemy)
    local sim_time = entity.get_prop(enemy, "m_flSimulationTime") or 0
    local data = resolver_data[enemy] or {}
    local is_fakelag = choke > 2 and sim_time > 0
    if is_fakelag and ui.get(ui_new_logs_enable) then
        client.color_log(255, 200, 0, string.format(
            "[PR0KLADKI] Fakelag: Enemy=%s, Choke=%d ticks",
            entity.get_player_name(enemy), choke
        ))
    end
    return is_fakelag
end


local function AlternativePredictPosition(enemy, time_delta)
    local x = entity.get_prop(enemy, "m_vecOrigin[0]") or 0
    local y = entity.get_prop(enemy, "m_vecOrigin[1]") or 0
    local z = entity.get_prop(enemy, "m_vecOrigin[2]") or 0
    local vx = entity.get_prop(enemy, "m_vecVelocity[0]") or 0
    local vy = entity.get_prop(enemy, "m_vecVelocity[1]") or 0
    local vz = entity.get_prop(enemy, "m_vecVelocity[2]") or 0

    return {
        x = x + vx * time_delta,
        y = y + vy * time_delta,
        z = z + vz * time_delta
    }
end



local function base_predict_position(enemy, local_x, local_y, local_z, bullet_speed, is_jump_scout, prediction_mode)
    local x, y, z = entity.get_prop(enemy, "m_vecOrigin")
    local vx = entity.get_prop(enemy, "m_vecVelocity[0]") or 0
    local vy = entity.get_prop(enemy, "m_vecVelocity[1]") or 0
    local vz = entity.get_prop(enemy, "m_vecVelocity[2]") or 0
    local speed = math.sqrt(vx^2 + vy^2)
    local distance = math.sqrt((x - local_x)^2 + (y - local_y)^2 + (z - local_z)^2)
    local travel_time = distance / bullet_speed
    local latency = client.latency()
    local tick_rate = globals.tickinterval()
    local sim_time = entity.get_prop(enemy, "m_flSimulationTime") or 0
    local server_time = globals.curtime() - latency -- серверное время
    local time_diff = math.max(0, server_time - sim_time)
    local data = resolver_data[enemy] or { velocity_history = {}, anim_history = {}, confidence = 100, miss_count = 0 }

    table.insert(data.velocity_history, { vx = vx, vy = vy, vz = vz, time = sim_time })
    if #data.velocity_history > 20 then table.remove(data.velocity_history, 1) end
    local pose_yaw = entity.get_prop(enemy, "m_flPoseParameter", 11) or 0
    pose_yaw = (pose_yaw * 360) - 180
    table.insert(data.anim_history, { pose_yaw = pose_yaw, sim_time = sim_time })
    if #data.anim_history > 20 then table.remove(data.anim_history, 1) end
    resolver_data[enemy] = data


    local adaptive_choke = get_adaptive_choke(enemy)
    local ticks_ahead = math.ceil((travel_time + latency + time_diff + adaptive_choke * tick_rate) / tick_rate)
    ticks_ahead = math.clamp(ticks_ahead, 1, 16) -- ограничение


    local prediction_factor = 1.0
    local state = get_player_state(enemy)
    local state_factor = state_scores[state] or 1.0
    local ping_factor = math.clamp(latency / 0.06, 0.5, 2.5) -- усиленная чувствительность к пингу (мб ошибка это делать)
    local loss = globals.packet_loss and globals.packet_loss() or 0
    local loss_factor = math.clamp(1 + (loss / 15), 1.0, 1.5) -- учёт потерь пакетов
    local anim_freshness = sim_time > 0 and (globals.curtime() - sim_time) / tick_rate or 0
    local freshness_factor = math.clamp(1 - (anim_freshness / 9), 0.5, 1.0) -- свежесть анимаций (9)
    local jitter_factor = detect_jitter_pattern(data.yaw_history or {}) and 0.7 or 1.0
    local fakelag_factor = detect_fakelag(enemy) and 1.3 or 1.0

    -- анализ траектории (смена направления или остановка)
    local direction_change_factor = 1.0
    local accel_factor = 1.0
    if #data.velocity_history >= 4 then
        local curr_vel = data.velocity_history[#data.velocity_history]
        local last_vel = data.velocity_history[#data.velocity_history-1]
        local prev_vel = data.velocity_history[#data.velocity_history-2]
        local angle_diff = math.abs(math.deg(math.atan2(curr_vel.vy, curr_vel.vx) - math.atan2(last_vel.vy, last_vel.vx)))
        local speed_diff = math.abs(speed - math.sqrt(last_vel.vx^2 + last_vel.vy^2))
        if angle_diff > 45 or speed_diff > 100 then
            direction_change_factor = 0.6
        end

        local accel_x = (curr_vel.vx - last_vel.vx) / (curr_vel.time - last_vel.time + 0.001)
        local accel_y = (curr_vel.vy - last_vel.vy) / (curr_vel.time - last_vel.time + 0.001)
        local accel = math.sqrt(accel_x^2 + accel_y^2)
        accel_factor = math.clamp(1 + (accel / 2000), 0.8, 1.3) -- ускорение
    end

    -- fast predict
    if prediction_mode == "simple" then
        prediction_factor = 0.5
    elseif prediction_mode == "beta" then
        prediction_factor = ping_factor * fakelag_factor * 1.2
    else
        prediction_factor = ui.get(ui_elements.prediction_factor) / 100
        if ui.get(ui_elements.fast_mode) then
            local speed_factor = math.clamp(speed / 150, 0.7, 1.7)
            local confidence_factor = math.clamp(data.confidence / 100, 0.5, 1.0)
            local miss_penalty = math.clamp(1 - (data.miss_count or 0) * 0.1, 0.5, 1.0)
            local anim_stability = calculate_std_dev(data.anim_history, function(anim) return anim.pose_yaw end) or 0
            local anim_factor = math.clamp(1 - (anim_stability / 60), 0.6, 1.0)

            prediction_factor = prediction_factor * speed_factor * ping_factor * loss_factor * freshness_factor * jitter_factor * state_factor * direction_change_factor * accel_factor * confidence_factor * miss_penalty * anim_factor
            prediction_factor = math.clamp(prediction_factor, 0.7, ui.get(ui_elements.fast_mode_aggressiveness or 200) / 100)
        end
    end


    local pred_x = x
    local pred_y = y
    local pred_z = z
    local friction = 5.0
    local max_speed = 250
    local sim_ticks = math.floor(ticks_ahead)
    local remaining_time = (ticks_ahead - sim_ticks) * tick_rate

    for i = 1, sim_ticks do
        local vel_magnitude = math.sqrt(vx^2 + vy^2)
        if vel_magnitude > 0 then
            local friction_loss = math.min(vel_magnitude, friction * tick_rate * prediction_factor)
            vx = vx * (1 - friction_loss / vel_magnitude)
            vy = vy * (1 - friction_loss / vel_magnitude)
        end
        pred_x = pred_x + vx * tick_rate * prediction_factor
        pred_y = pred_y + vy * tick_rate * prediction_factor
        pred_z = pred_z + vz * tick_rate * prediction_factor
        if is_jump_scout and is_player_jumping(enemy) then
            vz = vz - 800 * tick_rate
            pred_z = pred_z + vz * tick_rate * prediction_factor
        end
        vx = math.clamp(vx, -max_speed, max_speed)
        vy = math.clamp(vy, -max_speed, max_speed)
    end

    pred_x = pred_x + vx * remaining_time * prediction_factor
    pred_y = pred_y + vy * remaining_time * prediction_factor
    pred_z = pred_z + vz * remaining_time * prediction_factor


    local local_player = entity.get_local_player()
    if local_player then
        local fraction, hit_entity = client.trace_line(local_player, x, y, z, pred_x, pred_y, pred_z)
        if fraction < 1.0 and hit_entity == 0 then
            local reduced_factor = prediction_factor * 0.5
            pred_x = x + vx * ticks_ahead * tick_rate * reduced_factor
            pred_y = y + vy * ticks_ahead * tick_rate * reduced_factor
            pred_z = z + vz * ticks_ahead * tick_rate * reduced_factor
            if ui.get(ui_new_logs_enable) then
                client.color_log(255, 100, 100, string.format(
                    "[PR0KLADKI] Fast Predict: Collision detected for %s, reduced factor to %.2f",
                    entity.get_player_name(enemy), reduced_factor
                ))
            end
        end
    end

    -- адаптивное ограничение !
    local current_head_x, current_head_y, current_head_z = entity.hitbox_position(enemy, 0)
    local clamp_range = 40 + math.clamp(speed / 4, 0, 50) + math.clamp(latency * 250, 0, 40)
    if ui.get(ui_elements.fast_mode) then
        clamp_range = clamp_range * 1.3
    end
    pred_x = math.clamp(pred_x, current_head_x - clamp_range, current_head_x + clamp_range)
    pred_y = math.clamp(pred_y, current_head_y - clamp_range, current_head_y + clamp_range)
    pred_z = math.clamp(pred_z, current_head_z - clamp_range, current_head_z + clamp_range)

    if ui.get(ui_elements.dormant_aimbot) and resolver_data[enemy].is_dormant then
        pred_x, pred_y, pred_z = AlternativePredictPosition(enemy, globals.tickinterval() * 16)
        if ui.get(ui_elements.a_brute) and brute_data[enemy] and brute_data[enemy].state == "BRUTEFORCE" then
            apply_brute_angles(enemy)
        end
    end

    if ui.get(ui_new_logs_enable) then
        client.color_log(255, 165, 0, string.format(
            "[PR0KLADKI] Fast Predict: Enemy=%s, Factor=%.2f, Ticks=%d, Pos=(%.1f,%.1f,%.1f), Speed=%.0f, Ping=%.0fms, Loss=%.0f%%, AnimFresh=%.1f, Jitter=%s, State=%s, DirChange=%.2f, Accel=%.2f, Confidence=%.0f, Misses=%d", -- бляя ну хз мб работает :((
            entity.get_player_name(enemy), prediction_factor, ticks_ahead, pred_x, pred_y, pred_z, speed, latency * 1000, loss, anim_freshness,
            detect_jitter_pattern(data.yaw_history or {}) and "Yes" or "No", state, direction_change_factor, accel_factor, data.confidence, data.miss_count
        ))
    end

    return pred_x, pred_y, pred_z
end


local function choose_prediction(enemy, local_x, local_y, local_z, bullet_speed, is_jump_scout)
    local data = resolver_data[enemy] or {}
    local mode = ui.get(ui_elements.adaptive_prediction) and adaptive_modes[adaptive_mode_index] or (ui.get(ui_elements.predict_beta) and "beta" or "dynamic")
    if data.avg_speed < 10 and not data.flick_detected then
        return predict_position_simple(enemy)
    elseif mode == "beta" then
        return predict_position_beta(enemy, local_x, local_y, local_z, bullet_speed, is_jump_scout)
    elseif mode == "static" then
        return predict_position_simple(enemy)
    else
        return predict_position(enemy, local_x, local_y, local_z, bullet_speed, is_jump_scout)
    end
end


local function calculate_hit_chance(enemy, pred_x, pred_y, pred_z, local_x, local_y, local_z, weapon_id)
    local ex, ey, ez = entity.hitbox_position(enemy, 0)
    local distance = math.sqrt((pred_x - local_x)^2 + (pred_y - local_y)^2 + (pred_z - local_z)^2)
    local hitbox_radius = 5
    local error_margin = 8
    local distance_factor = clamp(1 - (distance / 1000), 0.5, 1.0)
    local weapon_accuracy_factor = is_fast_firing_weapon(weapon_id) and 0.8 or 1.0
    local hit_chance = math.min(100, math.max(0, (100 - (distance / hitbox_radius) * error_margin) * distance_factor * weapon_accuracy_factor))

    return hit_chance
end

local function n3r4z1m_resolver()
    if not ui.get(ui_resolver_enabled) then return end
    local latency = client.latency()
    if latency > 0.2 then
        client.color_log(255, 0, 0, string.format("[PR0KLADKI] Warning: High latency (%.0fms) may cause issues", latency * 1000))
    end
    if mode == "Custom" then
end
    local local_player = entity.get_local_player()
    if not local_player or not entity.is_alive(local_player) then return end

    local local_x, local_y, local_z = entity.get_prop(local_player, "m_vecOrigin")
    local weapon = entity.get_player_weapon(local_player)
    if not weapon then return end
    local weapon_id = entity.get_prop(weapon, "m_iItemDefinitionIndex")
    local bullet_speed = get_bullet_speed(weapon_id)
    local weapon_damage = get_weapon_damage(weapon_id)
    local is_scout = weapon_id == 40
    local optimize_jump_scout = ui.get(ui_elements.jump_scout_opt) and is_scout
    local enemies = entity.get_players(true)
    local local_hp = entity.get_prop(local_player, "m_iHealth")

    debug_info = {}
    handle_entities()
    -- bruteforse 'xd'
    for _, enemy in ipairs(entity.get_players(true)) do
        init_brute_data(enemy)
    end

    if not resolved_target or not entity.is_alive(resolved_target) then
        resolved_target = nil
        for _, enemy in ipairs(enemies) do
            if resolver_data[enemy] and (resolver_data[enemy].hit_count > 0 or resolver_data[enemy].miss_count < 3) then
                resolved_target = enemy
                client.color_log(255, 255, 255, "[PR0KLADKI] пидарас: " .. entity.get_player_name(enemy))
                break
            end
        end
        if not resolved_target and #enemies > 0 then
            resolved_target = enemies[1]
            client.color_log(255, 255, 255, "[PR0KLADKI] Resolved target: " .. entity.get_player_name(enemies[1]))
        end
        if not resolved_target then
            client.color_log(255, 255, 255, "[PR0KLADKI] No resolved_target selected")
        end
    end

    if resolved_target then
        enemies = {resolved_target}
    end



    for _, enemy in ipairs(enemies) do
        if entity.is_alive(enemy) then
            local should_process = update_enemy_data_fix(enemy) or (ui.get(ui_elements.dormant_aimbot) and enemy == resolved_target)
            local is_visible = entity.get_prop(enemy, "m_bSpotted") == 1 or (ui.get(ui_elements.dormant_aimbot) and enemy == resolved_target)
            -- brute helper '-'
            if ui.get(ui_elements.a_brute) then
               init_brute_data(enemy)
                if brute_data[enemy].state == "BRUTEFORCE" then
                    apply_brute_angles(enemy)
                end
            end

            if should_process then
                local data = resolver_data[enemy]
                local enemy_hp = entity.get_prop(enemy, "m_iHealth")
                local pred_x, pred_y, pred_z = choose_prediction(enemy, local_x, local_y, local_z, bullet_speed, optimize_jump_scout)

                if ui.get(ui_elements.fakelag_optimization) then
                    pred_x, pred_y, pred_z = predict_fakelag_position(enemy, pred_x, pred_y, pred_z)
                end
                local distance = math.sqrt((pred_x - local_x)^2 + (pred_y - local_y)^2 + (pred_z - local_z)^2)
                pred_x, pred_y, pred_z = compensate_spread(weapon_id, get_player_state(enemy), pred_x, pred_y, pred_z, distance)
                local eye_yaw = entity.get_prop(enemy, "m_angEyeAngles[1]") or 0
                local lby = get_lower_body_yaw(enemy)
                local vx = entity.get_prop(enemy, "m_vecVelocity[0]") or 0
                local vy = entity.get_prop(enemy, "m_vecVelocity[1]") or 0
                local vel_yaw = math.deg(math.atan2(vy, vx))
                local yaw_diff = angle_difference(eye_yaw, vel_yaw)
                local lby_diff = angle_difference(eye_yaw, lby)
                local pose_yaw = get_real_yaw_from_animations(enemy)
                local final_yaw = pose_yaw
                local freshness_factor, freshness_ticks = calculate_anim_freshness(enemy)
                if freshness_factor < 0.3 then
                    final_yaw = extrapolate_yaw_from_anim_history(enemy, data)
                    data.confidence = math.max(30, data.confidence - 10)
                end
                table.insert(data.yaw_history, eye_yaw)
                if #data.yaw_history > 10 then table.remove(data.yaw_history, 1) end
                table.insert(data.lby_history, lby)
                if #data.lby_history > 10 then table.remove(data.lby_history, 1) end

                local is_jittering = detect_jitter_pattern(data.yaw_history)
                if is_jittering then
                    data.confidence = math.max(50, data.confidence - 3)
                    data.aa_pattern = "jitter"
                else
                    data.confidence = math.min(100, data.confidence + 3)
                end
                if mode == "Custom" then
                    if ui.get(ui_elements.alternative_jitter) then
                        local jitter_pattern, jitter_amount = AlternativeDetectJitterPattern(enemy, data)
                        if jitter_pattern ~= "unknown" and jitter_amount > 0 then
                            local desync_side = data.desync_side or 0
                            if jitter_pattern == "random" then
                                local adjust = math.random(-jitter_amount * 0.5, jitter_amount * 0.5)
                                final_yaw = normalize_angle(pose_yaw + adjust)
                            elseif jitter_pattern == "switch" then
                                final_yaw = normalize_angle(pose_yaw + (desync_side > 0 and jitter_amount or -jitter_amount))
                            elseif jitter_pattern == "static" then
                                final_yaw = lby
                            end
                            data.aa_pattern = "jitter_" .. jitter_pattern
                            data.confidence = math.max(50, data.confidence - 5)
                        else
                            final_yaw = should_use_lby(enemy, lby, eye_yaw, state, data.last_lby_update) and lby or pose_yaw
                        end
                    else
                        final_yaw = should_use_lby(enemy, lby, eye_yaw, state, data.last_lby_update) and lby or pose_yaw
                    end
                else
                    if should_use_lby(enemy, lby, eye_yaw, state, data.last_lby_update) then
                        final_yaw = lby
                        data.confidence = math.min(100, data.confidence + 10)
                        data.last_lby_update = globals.curtime()
                    elseif detect_fakelag(enemy) then
                        final_yaw = pose_yaw
                        data.confidence = math.max(60, data.confidence - 5)
                    end
                end
                final_yaw = enhanced_defensive_fix(enemy, final_yaw)
                if is_shooting(enemy) then
                    final_yaw = pose_yaw
                    data.confidence = 100
                end
                if anim_state == "running" then
                    final_yaw = normalize_angle(final_yaw + 3)
                elseif anim_state == "crouching" then
                    final_yaw = normalize_angle(final_yaw - 3)
                end
                if ui.get(ui_elements.resolver_correction) then
                    local correction_intensity = ui.get(ui_elements.resolver_correction_intensity) / 100
                    local latency = client.latency()
                    local ping_factor = math.clamp(latency / 0.1, 0.5, 1.5)
                    local speed = math.sqrt((entity.get_prop(enemy, "m_vecVelocity[0]") or 0)^2 + (entity.get_prop(enemy, "m_vecVelocity[1]") or 0)^2)
                    local speed_factor = math.clamp(1 + (speed / 250), 1.0, 1.5)
                    local sim_time = entity.get_prop(enemy, "m_flSimulationTime") or 0
                    local anim_freshness = sim_time > 0 and (globals.curtime() - sim_time) / globals.tickinterval() or 0
                    local freshness_factor = math.clamp(1 - (anim_freshness / 9), 0.5, 1.0)
                    local pose_yaw = entity.get_prop(enemy, "m_flPoseParameter", 11) or 0
                    pose_yaw = (pose_yaw * 360) - 180

                    local adaptive_correction = 58 * correction_intensity * ping_factor * speed_factor * freshness_factor
                    final_yaw = math.lerp(data.last_yaw or final_yaw, normalize_angle(pose_yaw + (data.desync_side * adaptive_correction)), 0.5)
                    data.last_yaw = final_yaw
                end
                local anim_state = get_animation_state(enemy)
                local state = get_player_state(enemy)
                local mode = ui.get(ui_mode_select)
                if mode == "Custom" then
                    if ui.get(ui_elements.alternative_jitter) then
                        local jitter_pattern, jitter_amount = AlternativeDetectJitterPattern(enemy, data)
                        if jitter_pattern ~= "unknown" and jitter_amount > 0 then
                            local desync_side = data.desync_side or 0
                            if jitter_pattern == "random" then

                                local adjust = math.random(-jitter_amount * 0.5, jitter_amount * 0.5)
                                final_yaw = normalize_angle(pose_yaw + adjust)
                            elseif jitter_pattern == "switch" then
                                -- м с учетом стороны десинхрона
                                final_yaw = normalize_angle(pose_yaw + (desync_side > 0 and jitter_amount or -jitter_amount))
                            elseif jitter_pattern == "static" then
                                -- для статичного джиттера LBY
                                final_yaw = lby
                            end
                            data.aa_pattern = "jitter_" .. jitter_pattern
                            data.confidence = math.max(50, data.confidence - 5)
                            if ui.get(ui_new_logs_enable) then
                                client.color_log(255, 165, 0, string.format(
                                    "[PR0KLADKI] Jitter: Enemy=%s, Pattern=%s, Amount=%.1f, Yaw=%.1f, Confidence=%.0f",
                                    entity.get_player_name(enemy), jitter_pattern, jitter_amount, final_yaw, data.confidence
                                ))
                            end
                        else
                            final_yaw = should_use_lby(enemy, lby, eye_yaw, state, data.last_lby_update) and lby or pose_yaw
                        end
                    else
                        final_yaw = should_use_lby(enemy, lby, eye_yaw, state, data.last_lby_update) and lby or pose_yaw
                    end
                end
                    if ui.get(ui_elements.neural_mode) then
                    run_neural_network(enemies)
                else
                    table.insert(data.yaw_history, eye_yaw)
                    if #data.yaw_history > 10 then table.remove(data.yaw_history, 1) end
                    table.insert(data.lby_history, lby)
                    if #data.lby_history > 10 then table.remove(data.lby_history, 1) end
                    local is_jittering = detect_jitter_pattern(data.yaw_history)
                    if is_jittering then
                        data.confidence = math.max(30, data.confidence - 5)
                        data.aa_pattern = "jitter"
                    else
                        data.confidence = math.min(100, data.confidence + 5)
                    end
                    if ui.get(ui_elements.jitter_detection) and is_jittering then
                        local desync_side = detect_desync_pattern(data.yaw_history)
                        if desync_side ~= 0 then
                            local lby_stability = std_dev(data.lby_history)
                            if lby_stability < ui.get(ui_elements.jitter_lby_threshold) then
                                final_yaw = lby
                                data.confidence = math.min(100, data.confidence + 20)
                                data.aa_pattern = "jitter_lby"
                            else
                                final_yaw = normalize_angle(pose_yaw + (desync_side * ui.get(ui_elements.desync_range)))
                                data.confidence = math.max(40, data.confidence - 10)
                            end
                        end
                    end
                    if should_use_lby(enemy, lby, eye_yaw, state, data.last_lby_update) then
                        final_yaw = lby
                        data.confidence = math.min(100, data.confidence + 15)
                        data.last_lby_update = globals.curtime()
                    elseif trace_to_lby(enemy, lby) then
                        final_yaw = lby
                        data.confidence = math.min(100, data.confidence + 20)
                    elseif detect_fakelag(enemy) then
                        final_yaw = pose_yaw
                        data.confidence = math.max(40, data.confidence - 10)
                    end

                    if anim_state == "running" then
                        final_yaw = normalize_angle(final_yaw + 5)
                        data.confidence = math.max(50, data.confidence - 5)
                    elseif anim_state == "crouching" then
                        final_yaw = normalize_angle(final_yaw - 5)
                    end

                    final_yaw = smart_yaw_correction(enemy, final_yaw, data, yaw_diff, is_jittering, is_visible)

                    if ui.get(ui_elements.desync_detection) then
                        local desync_side = detect_desync_pattern(data.yaw_history)
                        if desync_side ~= 0 then
                            local desync_range = ui.get(ui_elements.desync_range)
                            final_yaw = normalize_angle(final_yaw + desync_range * desync_side)
                            data.desync_side = desync_side
                        elseif state == "standing" and not detect_fakelag(enemy) then
                            final_yaw = lby
                        end
                    end

                    if is_shooting(enemy) then
                        final_yaw = pose_yaw
                        data.confidence = 100
                    end

--                    if ui.get(ui_elements.experimental_mode) and ui.get(ui_elements.flick_detection) and is_visible then
--                        local current_time = globals.realtime()
--                        local time_delta = globals.tickinterval()
--                        local angular_velocity = angle_difference(eye_yaw, data.last_yaw) / time_delta
--                        table.insert(data.angular_velocities, angular_velocity)
--                        if #data.angular_velocities > 5 then table.remove(data.angular_velocities, 1) end
--
--                        local reaction_time = current_time - data.last_non_flick_time
--                        local is_reaction_flick = reaction_time < ui.get(ui_elements.flick_reaction_time) / 1000
--                        local consistency_check = #data.angular_velocities >= 3 and std_dev(data.angular_velocities) < 10
--
--                        if angular_velocity > ui.get(ui_elements.flick_velocity_threshold) and (consistency_check or is_reaction_flick) then
--                            if ui.get(ui_elements.flick_mode) == "Fake Flicks" then
--                                final_yaw = normalize_angle(final_yaw + (data.desync_side * ui.get(ui_elements.flick_yaw_correction)))
--                            elseif ui.get(ui_elements.flick_mode) == "Defensive Flicks" then
--                                final_yaw = normalize_angle(final_yaw - (data.desync_side * ui.get(ui_elements.flick_yaw_correction)))
--                            end
--                            data.flick_detected = true
--                            data.confidence = math.max(40, data.confidence - 10)
--                        else
--                            data.flick_detected = false
--                            data.last_non_flick_time = current_time
--                        end
--                        data.last_yaw = eye_yaw
--                        data.last_time = current_time
--                    end

                    final_yaw = enhanced_defensive_fix(enemy, final_yaw)
                    if ui.get(ui_elements.experimental_mode) and is_visible and data.confidence > 50 then
                        if math.random() > 0.7 then
                            plist.set(enemy, "Override preferred hitbox", "Chest")
                        end
                    end
                    if ui.get(ui_elements.resolver_correction) then
                        local latency = client.latency()
                        local tick_rate = globals.tickinterval()
                        local data = resolver_data[enemy] or {}
                        local state = get_player_state(enemy)
                        local loss = globals.packet_loss and globals.packet_loss() or 0 -- потери пакетов
                        local sim_time = entity.get_prop(enemy, "m_flSimulationTime") or 0
                        local anim_freshness = sim_time > 0 and (globals.curtime() - sim_time) / tick_rate or 0
                        -- проверка валидности
                        if not data or not pose_yaw or not yaw_diff then return end
                        -- автоматическая интенсивность коррекции
                        local ping_factor = math.clamp(latency / 0.08, 0.5, 3.0) -- увеличен для высоких пингов
                        local loss_factor = math.clamp(1 + (loss / 10), 1.0, 1.5) -- усилен учет потерь
                        local state_factor = state_scores[state] or 1.0
                        local speed = math.sqrt((entity.get_prop(enemy, "m_vecVelocity[0]") or 0)^2 + (entity.get_prop(enemy, "m_vecVelocity[1]") or 0)^2)
                        local speed_factor = math.clamp(1 + (speed / 250), 1.0, 1.7)
                        local anim_factor = math.clamp(1 - (anim_freshness / 10), 0.5, 1.0)


                        local correction_intensity = math.clamp(ping_factor * state_factor * loss_factor * speed_factor * anim_factor, 0.5, 2.5)
                        local base_correction = 58 -- базовое yaw
                        local adaptive_factor = math.clamp(1 + (data.miss_count or 0) * 0.05, 1.0, 1.3) * math.clamp(data.confidence / 100, 0.5, 1.0)
                        local yaw_correction = base_correction * correction_intensity * adaptive_factor


                        local yaw_history = data.yaw_history or {}
                        local yaw_std_dev = calculate_std_dev(yaw_history) or 0
                        local yaw_prediction = 0
                        if #yaw_history >= 3 and yaw_std_dev > 10 then

                            local last_yaw = yaw_history[#yaw_history] or pose_yaw
                            local second_last_yaw = yaw_history[#yaw_history - 1] or last_yaw
                            local yaw_trend = normalize_angle(last_yaw - second_last_yaw)
                            yaw_prediction = yaw_trend * math.clamp(ping_factor, 0.5, 1.5) * 0.5
                            yaw_correction = yaw_correction + yaw_prediction
                        end


                        if is_jittering then
                            yaw_correction = yaw_correction * 1.2
                            data.confidence = math.max(30, data.confidence - 5)
                        end
--                        if ui.get(ui_elements.flick_detection) and data.flick_detected then
--                            local flick_adjust = ui.get(ui_elements.flick_yaw_correction) * (data.desync_side > 0 and 1.5 or -1.5)
--                            yaw_correction = yaw_correction + flick_adjust
--                            data.confidence = math.max(40, data.confidence - 3)
--                        end
                        if ui.get(ui_elements.desync_detection) and data.desync_side ~= 0 then
                            local desync_adjust = data.desync_side * math.clamp(20 + yaw_std_dev, 15, 45)
                            yaw_correction = yaw_correction + desync_adjust
                        end


                        local yaw_diff_threshold = math.clamp(25 + (latency * 250), 20, 70)
                        if yaw_diff > yaw_diff_threshold or is_jittering or data.flick_detected then
                            -- усиленное сглаживание для хай пингов
                            local lerp_factor = math.clamp(0.3 * ping_factor * (1 + loss / 20), 0.2, 0.9)
                            final_yaw = math.lerp(data.last_yaw or final_yaw, normalize_angle(pose_yaw + yaw_correction), lerp_factor)


                            data.last_yaw = final_yaw
                            data.confidence = math.max(30, (data.confidence or 100) - (is_jittering and 5 or 3))
                            resolver_data[enemy] = data


                            if ui.get(ui_toggle_logs) then
                                client.color_log(255, 255, 255, (string.format(
                                    "[PR0KLADKI] Yaw correction for %s: %.1f° (Ping: %.0fms, Loss: %.0f%%, State: %s, Speed: %.0f, AnimFresh: %.1f, PredYaw: %.1f, Confidence: %.0f%%)", --- бляяя лан похуй
                                    entity.get_player_name(enemy), yaw_correction, latency * 1000, loss, state, speed, anim_freshness, yaw_prediction, data.confidence
                                )))
                            end
                        end
                    end
                    if not (ui.get(ui_elements.experimental_mode) and ui.get(ui_elements.flick_detection)) or not data.flick_detected then
                        final_yaw = lerp(data.last_yaw, final_yaw and 0.7 or 0.5)
                    end
                    data.last_yaw = final_yaw

                    local hit_chance = calculate_hit_chance(enemy, pred_x, pred_y, pred_z, local_x, local_y, local_z, weapon_id)
                    local min_hit_chance = hit_chance_enabled and ui.get(ui_elements.hit_chance_override) or 75
                    local should_shoot = hit_chance >= min_hit_chance and (data.confidence >= ui.get(ui_elements.confidence_threshold) or (is_visible and data.confidence >= 30))
--[[
                    --
                    if not should_shoot then
--                        client.delay_call(ui.get(ui_elements.low_confidence_delay) / 1000, function()
                            if entity.is_alive(enemy) then
                                plist.set(enemy, "Force body yaw", true)
                                plist.set(enemy, "Force body yaw value", clamp(final_yaw, -60, 60))
                            end
--                        end)
                        plist.set(enemy, "Force body yaw", false) -- ъаъаъаъа для прикола оставил

                        plist.set(enemy, "Override preferred hitbox", nil) ]]-- !
                    if not should_shoot then
                        local data = resolver_data[enemy] or { confidence = 100, last_yaw = final_yaw }
                        local safe_yaw = math.lerp(data.last_yaw or final_yaw, final_yaw, 0.3)
                        if entity.is_alive(enemy) then
                            plist.set(enemy, "Force body yaw", true)
                            plist.set(enemy, "Force body yaw value", clamp(safe_yaw, -60, 60))
                            local safe_hitbox = (data.confidence > 50 and ui.get(ui_elements.smart_head_aim)) and "Head" or "Chest"
                            plist.set(enemy, "Override preferred hitbox", safe_hitbox)
                        end
                        if ui.get(ui_elements.dormant_aimbot) and data.is_dormant then
                            local pred_x, pred_y, pred_z = choose_prediction(enemy, local_x, local_y, local_z, bullet_speed, ui.get(ui_elements.jump_scout_opt) and is_scout)
                            -- апасненька гейсекс апи гавно
--                            plist.set(enemy, "Override aimbot position", pred_x, pred_y, pred_z) -- !!
                        end
                        if ui.get(ui_new_logs_enable) then
                            client.color_log(255, 165, 0, string.format(
                                "[PR0KLADKI] Low confidence: Enemy=%s, SafeYaw=%.1f, Hitbox=%s, Confidence=%.0f, Dormant=%s",
                                entity.get_player_name(enemy), safe_yaw, safe_hitbox, data.confidence, data.is_dormant and "Yes" or "No"
                            ))
                        end
                        data.last_yaw = safe_yaw
                        resolver_data[enemy] = data
                    else
                        if is_visible then
                            plist.set(enemy, "Force body yaw", true)
                            plist.set(enemy, "Force body yaw value", clamp(final_yaw, -60, 60))

                            if ui.get(ui_elements.smart_body_aim) then
                                local should_force_body = enemy_hp <= ui.get(ui_elements.smart_body_hp_threshold)
                                pred_x, pred_y, pred_z = apply_body_hitbox_correction(enemy, pred_x, pred_y, pred_z, final_yaw)
                                plist.set(enemy, "Force body yaw value", clamp(final_yaw + (resolver_data[enemy].desync_side or 0) * 58, -60, 60))
                                if ui.get(ui_elements.smart_body_lethal) and enemy_hp <= weapon_damage then
                                    should_force_body = true
                                end
                                if ui.get(ui_elements.smart_body_multi_kill) and can_multi_kill(local_player, weapon_damage, enemies) then
                                    should_force_body = true
                                end
                                if should_force_body and data.confidence > 50 then
                                    plist.set(enemy, "Override preferred hitbox", "Chest")
                                else
                                    plist.set(enemy, "Override preferred hitbox", "Head")
                                end
                            end
                            -- bruteforse '?' [tts]
                            if ui.get(ui_elements.a_brute) then
                                init_brute_data(enemy)
                                local brute = brute_data[enemy]
                                brute.state = "BRUTEFORCE"
                                brute.end_tick = globals.tickcount() + ui.get(ui_elements.brute_duration)
                                brute.yaw_index = (brute.yaw_index % #brute_angles.yaw) + 1
                                if ui.get(ui_new_logs_enable) then
                                    client.color_log(255, 165, 0, string.format(
                                        "[PR0KLADKI] Brute activated on shootable: Enemy=%s", entity.get_player_name(enemy)
                                    ))
                                end
                                brute_data[enemy] = brute
                            end
                            if ui.get(ui_elements.smart_head_aim) and local_hp <= ui.get(ui_elements.smart_head_hp_threshold) then
                                if not is_fast_firing_weapon(weapon_id) and enemy_hp > weapon_damage then
                                    plist.set(enemy, "Override preferred hitbox", "Head")
                                end
                            end

                            if ui.get(ui_elements.dormant_aimbot) and data.is_dormant and weapon_damage < ui.get(ui_elements.dormant_min_damage) then
                                plist.set(enemy, "Minimum damage", ui.get(ui_elements.dormant_min_damage))
                            end
                        end
                    end
                end
                if ui.get(ui_elements.indicators) then
                    local distance = math.sqrt((pred_x - local_x)^2 + (pred_y - local_y)^2 + (pred_z - local_z)^2)
                    local real_x, real_y, real_z = entity.hitbox_position(enemy, 0)
                    table.insert(debug_info, {
                        name = entity.get_player_name(enemy),
                        yaw = final_yaw,
                        speed = data.avg_speed,
                        pred = ui.get(ui_elements.prediction_factor),
                        flick = data.flick_detected and "Yes" or "No",
                        angular_velocity = data.angular_velocities[#data.angular_velocities] or 0,
                        fakelag = ui.get(ui_elements.fakelag_optimization) and detect_fakelag(enemy) and "Yes" or "No",
                        visibility = is_visible and "Full" or "Partial",
                        misses = data.miss_count,
                        hits = data.hit_count,
--                        aa_pattern = ui.get(ui_elements.persist_mode) and data.aa_pattern or "N/A",
                        hit_chance = calculate_hit_chance(enemy, pred_x, pred_y, pred_z, local_x, local_y, local_z, weapon_id),
                        is_dormant = data.is_dormant and "Yes" or "No",
                        distance = distance,
                        resolver_correction = ui.get(ui_elements.resolver_correction) and (ui.get(ui_elements.resolver_correction_intensity) / 100) or "Off",
                        confidence = data.confidence,
                        lby = lby,
                        anim_state = anim_state,
                        jitter_detection = ui.get(ui_elements.jitter_detection) and is_jittering and "Active" or "Inactive",
                        lby_stability = ui.get(ui_elements.jitter_detection) and std_dev(data.lby_history) or 0,
                        pose_error = data.pose_error and "Yes" or "No",
                        pred_x = pred_x, pred_y = pred_y, pred_z = pred_z,
                        real_x = real_x, real_y = real_y, real_z = real_z,
--                        neural_mode = ui.get(ui_elements.neural_mode) and "Active" or "Inactive"
                    })
                end
            end
        else
            if resolver_data[enemy] and (globals.realtime() - resolver_data[enemy].last_seen > 3.0) then
                resolver_data[enemy] = nil
                if enemy == resolved_target then resolved_target = nil end
                if enemy == persist_target then persist_target = nil end
            end
        end
    end
end



local refs = { dt = { ui.reference("RAGE", "Aimbot", "Double tap") } }
local function vec_3(_x, _y, _z) return { x = _x or 0, y = _y or 0, z = _z or 0 } end
local function ticks_to_time(ticks) return globals.tickinterval() * ticks end

local function player_will_peek()
    local enemies = entity.get_players(true)
    if #enemies == 0 then return false end

    local eye_position = vec_3(client.eye_position())
    local velocity_prop_local = vec_3(entity.get_prop(entity.get_local_player(), "m_vecVelocity[0]") or 0, entity.get_prop(entity.get_local_player(), "m_vecVelocity[1]") or 0, entity.get_prop(entity.get_local_player(), "m_vecVelocity[2]") or 0)
    local predicted_eye_position = vec_3(
        eye_position.x + velocity_prop_local.x * ticks_to_time(1),
        eye_position.y + velocity_prop_local.y * ticks_to_time(1),
        eye_position.z + velocity_prop_local.z * ticks_to_time(1)
    )

    for _, player in ipairs(enemies) do
        local velocity_prop = vec_3(entity.get_prop(player, "m_vecVelocity[0]") or 0, entity.get_prop(player, "m_vecVelocity[1]") or 0, entity.get_prop(player, "m_vecVelocity[2]") or 0)
        local origin = vec_3(entity.get_prop(player, "m_vecOrigin"))
        local predicted_origin = vec_3(
            origin.x + velocity_prop.x * ticks_to_time(1),
            origin.y + velocity_prop.y * ticks_to_time(1),
            origin.z + velocity_prop.z * ticks_to_time(1)
        )
        entity.set_prop(player, "m_vecOrigin", predicted_origin.x, predicted_origin.y, predicted_origin.z)
        local head_origin = vec_3(entity.hitbox_position(player, 0))
        entity.set_prop(player, "m_vecOrigin", origin.x, origin.y, origin.z)

        local _, damage = client.trace_bullet(
            entity.get_local_player(),
            predicted_eye_position.x, predicted_eye_position.y, predicted_eye_position.z,
            head_origin.x, head_origin.y, head_origin.z
        )
        if damage > 0 then return true end
    end
    return false
end
local function on_hit(e)
    if not ui.get(ui_resolver_enabled) then return end
    local target = client.userid_to_entindex(e.target)
    if not target or not entity.is_alive(target) or not entity.is_enemy(target) then return end
    local data = resolver_data[target] or {}
    data.miss_count = 0
    data.confidence = math.min(100, data.confidence + 10)
    if nn_network then
        local inputs = get_neural_inputs(target)
        local expected_yaw = entity.get_prop(target, "m_angEyeAngles[1]") or 0
        nn_network:train(inputs, {expected_yaw / 360, 1, 0, 0}) --  хит
    end
    resolver_data[target] = data
end
-- миссваре
local function on_miss(e)
    if not ui.get(ui_resolver_enabled) then return end
    local target = client.userid_to_entindex(e.target)
    if not target or not entity.is_alive(target) or not entity.is_enemy(target) then return end
    local data = resolver_data[target] or {}
    data.miss_count = (data.miss_count or 0) + 1
    data.confidence = math.max(30, data.confidence - 8)
    --[[
    if nn_network then
        local inputs = get_neural_inputs(target)
        local expected_yaw = entity.get_prop(target, "m_angEyeAngles[1]") or 0
        nn_network:train(inputs, {expected_yaw / 360, 0, 0, 0})
    end]]
    if ui.get(ui_elements.a_brute) then
        init_brute_data(target)
        local brute = brute_data[target]
        brute.misses = brute.misses + 1
        if brute.misses >= 2 then
            brute.state = "BRUTEFORCE"
            brute.end_tick = globals.tickcount() + ui.get(ui_elements.brute_duration)
            brute.yaw_index = (brute.yaw_index % #brute_angles.yaw) + 1
            if ui.get(ui_new_logs_enable) then
                client.color_log(255, 165, 0, string.format(
                    "[PR0KLADKI] Brute activated on miss: Enemy=%s, Misses=%d",
                    entity.get_player_name(target), brute.misses
                ))
            end
        end
        brute_data[target] = brute
    end
    resolver_data[target] = data
    if ui.get(ui_new_logs_enable) then
        local reason = e.reason or "unknown"
        local hitgroup = e.hitgroup or 0
        local state = get_player_state(target) or "unknown"
        local aa_pattern = data.aa_pattern or "unknown"
        client.color_log(255, 100, 100, string.format(
            "[PR0KLADKI] Miss: Enemy=%s, Reason=%s, Hitgroup=%d, State=%s, AA=%s, Confidence=%.0f, MissCount=%d",
            entity.get_player_name(target), reason, hitgroup, state, aa_pattern, data.confidence, data.miss_count
        ))
    end
end
client.set_event_callback('paint_ui', function()
    if not ui.get(ui_elements.neural_mode) or not ui.get(ui_elements.neural_visualization) then return end
    if not resolved_target or not entity.is_alive(resolved_target) then
    resolved_target = nil
    for _, enemy in ipairs(enemies) do
        if resolver_data[enemy] and (resolver_data[enemy].hit_count > 0 or resolver_data[enemy].miss_count < 3) then
            resolved_target = enemy
            client.color_log(255, 255, 255, "[PR0KLADKI] Selected resolved target: " .. entity.get_player_name(enemy))
            break
        end
    end
    if not resolved_target and #enemies > 0 then
        resolved_target = enemies[1]
        client.color_log(255, 255, 255, "[PR0KLADKI] Resolved target: " .. entity.get_player_name(enemies[1]))
    end
    if not resolved_target then
        client.color_log(255, 255, 255, "[PR0KLADKI] No resolved target")
    end
end
    if not nn_network then
        client.color_log(255, 255, 255, "[PR0KLADKI] Error: Neural network not initialized")
        return
    end
    local scr_w, scr_h = client.screen_size()
    renderer.text(scr_w - 300, scr_h - 50, 255, 255, 255, 255, nil, 0, "[PR0KLADKI] Rendering Neural Network") -- АХУЕТЬ НЕРАЗИМ
    nn_network:render()
end)
    end)
    if not success then
        client.color_log(255, 255, 255, "[PR0KLADKI] Critical error in resolver: ", err)
    end
end


pcall(function()
    require('zzbalenca2part')
end)
