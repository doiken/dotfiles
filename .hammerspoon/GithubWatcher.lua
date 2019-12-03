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
                    _persistPulls()
                    hs.urlevent.openURL(review["url"])
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
        or pulls["review_count"]
    obj._menuBar
        :setTitle(hs.styledtext.ansi(("〓 %s"):format(title)))
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