-- 加载Orion库
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Qanuir/orion-ui/refs/heads/main/source.lua"))()

-- 创建主窗口
local Window = OrionLib:MakeWindow({
    Name = "北极星",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MyScript"
})

-- 创建公告标签页
local AnnouncementTab = Window:MakeTab({
    Name = "公告",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

AnnouncementTab:AddLabel("════════════════════════")
AnnouncementTab:AddLabel("  欢 迎 使 用 北 极 星")
AnnouncementTab:AddLabel("════════════════════════")
AnnouncementTab:AddLabel("  本脚本由无数个日夜")
AnnouncementTab:AddLabel("  交错制作而成")
AnnouncementTab:AddLabel("  谢谢您的游玩！")
AnnouncementTab:AddLabel("════════════════════════")
AnnouncementTab:AddLabel("  ✨ 制作团队 ✨")
AnnouncementTab:AddLabel("════════════════════════")
AnnouncementTab:AddLabel("  主程序：开发者")
AnnouncementTab:AddLabel("  测试：测试团队")
AnnouncementTab:AddLabel("  美术：设计组")
AnnouncementTab:AddLabel("  特别感谢：所有玩家")
AnnouncementTab:AddLabel("════════════════════════")

-- 创建通用标签页
local GeneralTab = Window:MakeTab({
    Name = "通用",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

GeneralTab:AddLabel("════════════════════════")
GeneralTab:AddLabel("  功 能 列 表")
GeneralTab:AddLabel("════════════════════════")

-- ====== 玩家初始化 ======
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

-- ====== 变量 ======
local InfiniteJumpEnabled = false
local JumpConnection = nil
local CurrentWalkSpeed = 16
local SpeedMode = 1
local AutoJumpEnabled = false
local AutoJumpConnection = nil
local AutoJumpSpeed = 0.5
local AutoJumpTimer = 0
local CameraWallEnabled = false

-- ====== 重生监听 ======
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    if InfiniteJumpEnabled then
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    end
    if Humanoid and CurrentWalkSpeed then
        Humanoid.WalkSpeed = CurrentWalkSpeed
    end
end)

-- ====== 1. 无限跳跃 ======
GeneralTab:AddToggle({
    Name = "无限跳跃",
    Default = false,
    Callback = function(Value)
        InfiniteJumpEnabled = Value
        if Value then
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            if not JumpConnection then
                JumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                    if InfiniteJumpEnabled and Humanoid and Humanoid.Parent then
                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            end
            print("无限跳跃已开启")
        else
            if JumpConnection then
                JumpConnection:Disconnect()
                JumpConnection = nil
            end
            print("无限跳跃已关闭")
        end
    end
})

-- ====== 2. 第一版移速 ======
GeneralTab:AddSlider({
    Name = "第一版移速 (上限360)",
    Min = 16,
    Max = 360,
    Default = 16,
    Color = Color3.fromRGB(100, 200, 255),
    Increment = 1,
    ValueName = "速度",
    Callback = function(Value)
        if SpeedMode == 1 then
            CurrentWalkSpeed = Value
            if Humanoid then
                Humanoid.WalkSpeed = Value
            end
            print("第一版移速已设为:", Value)
        end
    end
})

-- ====== 3. 第二版移速 ======
GeneralTab:AddSlider({
    Name = "第二版移速 (上限99999)",
    Min = 16,
    Max = 99999,
    Default = 16,
    Color = Color3.fromRGB(255, 200, 100),
    Increment = 1,
    ValueName = "速度",
    Callback = function(Value)
        if SpeedMode == 2 then
            CurrentWalkSpeed = Value
            if Humanoid then
                Humanoid.WalkSpeed = Value
            end
            print("第二版移速已设为:", Value)
        end
    end
})

-- ====== 4. 移速版本切换 ======
GeneralTab:AddToggle({
    Name = "启用第二版移速",
    Default = false,
    Callback = function(Value)
        SpeedMode = Value and 2 or 1
        print("已切换到", SpeedMode == 1 and "第一版移速" or "第二版移速")
    end
})

-- ====== 5. 视野控制 ======
GeneralTab:AddSlider({
    Name = "视野控制 (FOV)",
    Min = 70,
    Max = 120,
    Default = 70,
    Color = Color3.fromRGB(0, 255, 255),
    Increment = 1,
    ValueName = "°",
    Callback = function(Value)
        if Camera then
            Camera.FieldOfView = Value
            print("视野已设为:", Value, "°")
        end
    end
})

-- ====== 6. 重置视野 ======
GeneralTab:AddButton({
    Name = "重置视野 (70°)",
    Callback = function()
        if Camera then
            Camera.FieldOfView = 70
            print("视野已重置为70°")
        end
    end
})

-- ====== 7. 凝固视角（相机穿墙） ======
GeneralTab:AddToggle({
    Name = "凝固视角",
    Default = false,
    Callback = function(Value)
        CameraWallEnabled = Value
        if Camera then
            if Value then
                Camera.CameraType = Enum.CameraType.Scriptable
                print("凝固视角已开启")
            else
                Camera.CameraType = Enum.CameraType.Custom
                print("凝固视角已关闭")
            end
        end
    end
})

-- ====== 8. 自动跳跃 ======
function StartAutoJump()
    if AutoJumpConnection then
        AutoJumpConnection:Disconnect()
        AutoJumpConnection = nil
    end
    if AutoJumpEnabled then
        AutoJumpTimer = 0
        AutoJumpConnection = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
            if AutoJumpEnabled and Humanoid and Humanoid.Parent then
                AutoJumpTimer = AutoJumpTimer + deltaTime
                if Humanoid.FloorMaterial ~= Enum.Material.Air and AutoJumpTimer >= AutoJumpSpeed then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    AutoJumpTimer = 0
                end
            end
        end)
    end
end

GeneralTab:AddToggle({
    Name = "自动跳跃",
    Default = false,
    Callback = function(Value)
        AutoJumpEnabled = Value
        if Value then
            StartAutoJump()
            print("自动跳跃已开启，间隔:", AutoJumpSpeed, "秒")
        else
            if AutoJumpConnection then
                AutoJumpConnection:Disconnect()
                AutoJumpConnection = nil
            end
            print("自动跳跃已关闭")
        end
    end
})

-- ====== 9. 自动跳跃速度 ======
GeneralTab:AddSlider({
    Name = "自动跳跃速度",
    Min = 0.01,
    Max = 1,
    Default = 0.5,
    Color = Color3.fromRGB(255, 200, 0),
    Increment = 0.01,
    ValueName = "秒",
    Callback = function(Value)
        AutoJumpSpeed = Value
        print("自动跳跃间隔已设为:", Value, "秒")
        if AutoJumpEnabled then
            StartAutoJump()
        end
    end
})

GeneralTab:AddLabel("════════════════════════")
GeneralTab:AddLabel("  状 态 监 控")
GeneralTab:AddLabel("════════════════════════")

-- ====== 初始化 ======
OrionLib:Init()

wait(0.5)
OrionLib:MakeNotification({
    Name = "🌟 欢迎使用北极星",
    Content = "本脚本由无数个日夜交错制作\n\n谢谢您的游玩！",
    Image = "rbxassetid://4483345998",
    Time = 5
})