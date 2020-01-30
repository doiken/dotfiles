--- === RedmineWatcher ===
---
--- Watch Redmine Updates
---
--- Download: [https://github.com/doiken/Spoons/raw/master/Spoons/RedmineWatcher.spoon.zip](https://github.com/doiken/Spoons/raw/master/Spoons/RedmineWatcher.spoon.zip)

local obj = {}

-- Metadata
obj.name = "RedmineWatcher"
obj.version = "1.0"
obj.author = "doiken"
obj.homepage = "https://github.com/doiken/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local getSetting = function(label, default) return hs.settings.get(obj.name.."."..label) or default end
local setSetting = function(label, value)   hs.settings.set(obj.name.."."..label, value); return value end

-- icon displayed in menubar
obj.icon = hs.image.imageFromURL("data:image/x-icon;base64,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HwD/g/8A/4H/AP///wD///8A////ACgAAAAgAAAAQAAAAAEAIAAAAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKFMAAChpwAAoacAAKGnAAChpwAAoacAAKJ+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA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AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA6AsAAN8IAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA////////////////////////////////g///gAH//4AB//+AAf//gQH//4EB//+Bj///8f3//3/x//8PwP//A8D//wPA//4H4P//B+P//c//P/j//B/wf/gP4D/8CDA//hgYf/8wHP//8A////Af//////////////////////8="):setSize({h=18, w=18})
-- watch every [interval] mins
obj.interval = 5
-- path to env file which define GITHUB_TOKEN
obj.envFile = '/dev/null'
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new(obj.name)

-- Internal variable - menubar instance
obj._menuBar = hs.menubar.new()
-- Internal variable - issues fetched previously
obj._issueUpdates = getSetting('issues', {})
-- Internal variable - timer instance
obj._timer = nil
-- Internal variable - task instance
obj._task = nil

-- Internal function - persist the current issues so it survives across restarts
local function _persistIssues()
    setSetting("issues", obj._issueUpdates)
end

local function fetchApis()
    local issues = {}
    local sh = debug.getinfo(2, "S").source:sub(2):gsub(".lua$", ".sh")
    obj._task = hs.task.new(sh, obj.fetchCallback, {obj.envFile}):start()
end

local function buildIssues(exitCode, stdOut, stdErr, prevIssueUpdates)
    if (exitCode ~= 0) then
        obj.logger:e("task failed " .. stdErr)
        return {}
    end
    local issues = {
        issue_count = 0,
        is_updated = false,
        types = {},
    }
    local json = hs.json.decode(stdOut)

    for _,issue in ipairs(json) do
        local type = issue['type']
        local id = issue['id']
        -- initialize
        issues["types"][type] = issues["types"][type] or {
            issue_count = 0,
            issues = {},
        }
        if (issues["types"][type]["issues"][id] == nil) then
            issues["issue_count"] = issues["issue_count"] + 1
            issues["types"][type]["issue_count"] = issues["types"][type]["issue_count"] + 1
            local y, m, d, h, i = issue["updated_at"]:match("^(%d+)-0?(%d+)-0?(%d+)T0?(%d+):0?(%d+)")
            local updated_at = os.time({year=y, month=m, day=d, hour=h, min=i}) + 3600 * 9 -- + 9 hour for time zone
            local is_update = issue["updated_by"] ~= "me" and updated_at >= (prevIssueUpdates[id] or 0)
            issues["is_updated"] = issues["is_updated"] or is_update
            issues["types"][type]["issues"][id] = {
                title = issue["title"],
                updated_at = updated_at,
                url = issue["url"],
                id = id,
                is_updated = is_update,
            }
        end
    end
    return issues
end

local function buildIssueUpdates(issues, prevIssueUpdates)
    local issueUpdates = {}
    for _,repo in pairs(issues["types"]) do
        for id,review in pairs(repo["issues"]) do
            issueUpdates[id] = review["updated_at"] > (prevIssueUpdates[id] or 0)
                and review["updated_at"]
                or (prevIssueUpdates[id] or 0)
        end
    end

    return issueUpdates
end

local function buildMenu(issues)
    local menu = {}
    for type,repo in hs.fnutils.sortByKeys(issues["types"]) do
        table.insert(menu, { title = ("➠ %s: %s"):format(type, repo["issue_count"]), disabled = true })
        table.insert(menu, { title = "-", disabled = true })

        local i = 0
        for id,review in hs.fnutils.sortByKeys(repo["issues"], function(a, b) return a > b end) do
            i = i + 1
            local prefix = i == repo["issue_count"] and "└" or "├"
            local comming = review["is_updated"] and '✧' or ''
            table.insert(menu, {
                title = ("%s %s %d %s"):format(prefix, comming, review["id"], review["title"]),
                fn = function ()
                    obj._issueUpdates[id] = os.time()
                    hs.urlevent.openURL(review["url"])
                end,
            })
        end
        table.insert(menu, { title = "-", disabled = true })
    end
    return menu
end

function obj.fetchCallback(exitCode, stdOut, stdErr)
    local prevIssueUpdates = obj._issueUpdates
    local issues = buildIssues(exitCode, stdOut, stdErr, prevIssueUpdates)
    obj.logger:d("issues: " .. hs.inspect(issues))
    local menu = buildMenu(issues)
    obj.logger:d("menu: " .. hs.inspect(menu))

    local title = issues["is_updated"]
        and ("\27[31m%d\27[0m"):format(issues["issue_count"])
        or tostring(issues["issue_count"])
    obj._menuBar
        :setIcon(obj.icon)
        :setTitle(hs.styledtext.ansi(title))
        :setMenu(menu)

    obj._issueUpdates = buildIssueUpdates(issues, prevIssueUpdates)
    _persistIssues()
end

--- RedmineWatcher:start()
--- Method
--- Start Timer
---
--- Parameters:
---  * None
---
--- Returns:
---  * RedmineWatcher
function obj:start()
    fetchApis()
    obj._timer = hs.timer.doEvery(obj.interval * 60, function()
        fetchApis()
    end)
    return obj
end

--- RedmineWatcher:stop()
--- Method
--- Stop Timer
---
--- Parameters:
---  * None
---
--- Returns:
---  * RedmineWatcher
function obj:stop()
  obj._timer:stop()
  obj._menubar:removeFromMenuBar()
  return obj
end

function obj:refresh()
    obj._issueUpdates = {}
    _persistIssues()
end

return obj