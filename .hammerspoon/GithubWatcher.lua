--- === GithubWatcher ===
---
--- Watch Github Pull Requests
--- jq command required
---
--- Download: [https://github.com/doiken/Spoons/raw/master/Spoons/GithubWatcher.spoon.zip](https://github.com/doiken/Spoons/raw/master/Spoons/GithubWatcher.spoon.zip)

local obj = {}

-- Metadata
obj.name = "GithubWatcher"
obj.version = "1.0"
obj.author = "doiken"
obj.homepage = "https://github.com/doiken/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local getSetting = function(label, default) return hs.settings.get(obj.name.."."..label) or default end
local setSetting = function(label, value)   hs.settings.set(obj.name.."."..label, value); return value end

-- icon displayed in menubar
obj.icon = hs.image.imageFromURL('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyRpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NDkxMSwgMjAxMy8xMC8yOS0xMTo0NzoxNiAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RERCMUIwOUY4NkNFMTFFM0FBNTJFRTMzNTJEMUJDNDYiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RERCMUIwOUU4NkNFMTFFM0FBNTJFRTMzNTJEMUJDNDYiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoTWFjaW50b3NoKSI+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOkU1MTc4QTJBOTlBMDExRTI5QTE1QkMxMDQ2QTg5MDREIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOkU1MTc4QTJCOTlBMDExRTI5QTE1QkMxMDQ2QTg5MDREIi8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+jUqS1wAAApVJREFUeNq0l89rE1EQx3e3gVJoSPzZeNEWPKgHoa0HBak0iHiy/4C3WvDmoZ56qJ7txVsPQu8qlqqHIhRKJZceesmhioQEfxTEtsoSpdJg1u/ABJ7Pmc1m8zLwgWTmzcw3L+/te+tHUeQltONgCkyCi2AEDHLsJ6iBMlgHL8FeoqokoA2j4CloRMmtwTmj7erHBXPgCWhG6a3JNXKdCiDl1cidVbXZkJoXQRi5t5BrxwoY71FzU8S4JuAIqFkJ2+BFSlEh525b/hr3+k/AklDkNsf6wTT4yv46KIMNpsy+iMdMc47HNWxbsgVcUn7FmLAzzoFAWDsBx+wVP6bUpp5ewI+DOeUx0Wd9D8F70BTGNjkWtqnhmT1JQAHcUgZd8Lo3rQb1LAT8eJVUfgGvHQigGp+V2Z0iAUUl8QH47kAA1XioxIo+bRN8OG8F/oBjwv+Z1nJgX5jpdzQDw0LCjsPmrcW7I/iHScCAEDj03FtD8A0EyuChHgg4KTlJQF3wZ7WELppnBX+dBFSVpJsOBWi1qiRgSwnOgoyD5hmuJdkWCVhTgnTvW3AgYIFrSbZGh0UW/Io5Vp+DQoK7o80pztWMemZbgxeNwCNwDbw1fIfgGZjhU6xPaJgBV8BdsMw5cbZoHsenwYFxkZzl83xTSKTiviCAfCsJLysH3POfC8m8NegyGAGfLP/VmGmfSChgXroR0RSWjEFv2J/nG84cuKFMf4sTCZqXuJd4KaXFVjEG3+tw4eXbNK/YC9oXXs3O8NY8y99L4BXY5cvLY/Bb2VZ58EOJVcB18DHJq9lRsKr8inyKGVjlmh29mtHs3AHfuhCwy1vXT/Nu2GKQt+UHsGdctyX6eQyNvc+5sfX9Dl7Pe2J/BRgAl2CpwmrsHR0AAAAASUVORK5CYII='):setSize({w=18,h=18})
-- watch every [interval] mins
obj.interval = 5
-- path to env file which define GITHUB_TOKEN
obj.envFile = '/dev/null'
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('GithubWatcher')

-- Internal variable - menubar instance
obj._menuBar = hs.menubar.new()
-- Internal variable - pulls fetched previously
obj._pullUpdates = getSetting('pull_updates', {})
-- Internal variable - timer instance
obj._timer = nil
-- Internal variable - task instance
obj._task = nil

-- Internal function - persist the current pulls so it survives across restarts
local function _persistPulls()
   setSetting("pull_updates", obj._pullUpdates)
end

local function fetchPulls()
    local pulls = {}
    local sh = debug.getinfo(2, "S").source:sub(2):gsub(".lua$", ".sh")
    obj._task = hs.task.new(sh, fetchCallback, {obj.envFile}):start()
end

local function buildPull(exitCode, stdOut, stdErr, prevPullUpdates)
    if (exitCode ~= 0) then
        obj.logger:e("task failed " .. stdErr)
        return {}
    end
    local pulls = {
        review_count = 0,
        is_updated = false,
        repos = {},
    }
    local json = hs.json.decode(stdOut)

    for _,pull in ipairs(json) do
        local repo_name = pull['url']:match("repos%/(.+)%/issues")
        local id = pull['url']:match("issues%/([0-9]+)$")
        -- initialize
        pulls["repos"][repo_name] = pulls["repos"][repo_name] or {
            review_count = 0,
            reviews = {},
        }
        if (pulls["repos"][repo_name]["reviews"][id] == nil) then
            pulls["review_count"] = pulls["review_count"] + 1
            pulls["repos"][repo_name]["review_count"] = pulls["repos"][repo_name]["review_count"] + 1
            local y, m, d, h, i = pull["updated_at"]:match("^(%d+)-0?(%d+)-0?(%d+)T0?(%d+):0?(%d+)")
            local updated_at = os.time({year=y, month=m, day=d, hour=h, min=i}) + 3600 * 9 -- + 9 hour for time zone
            is_update = updated_at >= (prevPullUpdates[id] or 0)
            pulls["is_updated"] = pulls["is_updated"] or is_update
            pulls["repos"][repo_name]["reviews"][id] = {
                title = pull["title"],
                updated_at = updated_at,
                url = pull["url"]:gsub("issues", "pull"):gsub("api.", ""):gsub("repos/", ""),
                id = id,
                is_updated = is_update,
            }
        end
    end
    return pulls
end

local function buildPullUpdates(pulls, prevPullUpdates)
    local pullUpdates = {}
    for _,repo in pairs(pulls["repos"]) do
        for id,review in pairs(repo["reviews"]) do
            pullUpdates[id] = review["updated_at"] > (prevPullUpdates[id] or 0)
                and review["updated_at"]
                or (prevPullUpdates[id] or 0)
        end
    end

    return pullUpdates
end

local function buildMenu(pulls)
    local menu = {}
    for repo_name,repo in pairs(pulls["repos"]) do
        table.insert(menu, { title = ("➠ %s: %s"):format(repo_name, repo["review_count"]), disabled = true })
        table.insert(menu, { title = "-", disabled = true })

        table.sort(repo["reviews"], function(a,b) return (a["id"] > b["id"]) end)
        local i = 0
        for id,review in pairs(repo["reviews"]) do
            i = i + 1
            local prefix = i == repo["review_count"] and "└" or "├"
            local comming = review["is_updated"] and '✧' or ''
            table.insert(menu, {
                title = ("%s %s %d %s"):format(prefix, comming, review["id"], review["title"]),
                fn = function ()
                    obj._pullUpdates[id] = os.time()
                    hs.urlevent.openURL(review["url"])
                    fetchPulls()
                end,
            })
        end
        table.insert(menu, { title = "-", disabled = true })
    end
    return menu
end

function fetchCallback(exitCode, stdOut, stdErr)
    local prevPullUpdates = obj._pullUpdates
    local pulls = buildPull(exitCode, stdOut, stdErr, prevPullUpdates)
    obj.logger:d("pulls: " .. hs.inspect(pulls))
    local menu = buildMenu(pulls)
    obj.logger:d("menu: " .. hs.inspect(menu))

    local title = pulls["is_updated"]
        and ("\27[31m%d\27[0m"):format(pulls["review_count"])
        or tostring(pulls["review_count"])
    obj._menuBar
        :setIcon(obj.icon)
        :setTitle(hs.styledtext.ansi(title))
        :setMenu(menu)

    obj._pullUpdates = buildPullUpdates(pulls, prevPullUpdates)
    _persistPulls()
end

--- GithubWatcher:start()
--- Method
--- Start Timer
---
--- Parameters:
---  * None
---
--- Returns:
---  * GithubWatcher
function obj:start()
    fetchPulls()
    obj._timer = hs.timer.doEvery(obj.interval * 60, function()
        fetchPulls()
    end)
    return obj
end

--- GithubWatcher:stop()
--- Method
--- Stop Timer
---
--- Parameters:
---  * None
---
--- Returns:
---  * GithubWatcher
function obj:stop()
  obj._timer:stop()
  obj._menubar:removeFromMenuBar()
  return obj
end

function obj:refresh()
    obj._pullUpdates = {}
    _persistPulls()
end

return obj