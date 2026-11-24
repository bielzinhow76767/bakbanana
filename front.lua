local route = getgenv().__BANANA_SCRIPT_ROUTE
if not route then
    local p = game:GetService("Players").LocalPlayer
    if p then p:Kick("No script route specified.") end
    return
end
return loadstring(game:HttpGet("https://raw.githubusercontent.com/bielzinhow76767/bakbanana/refs/heads/main/final.lua"))()
