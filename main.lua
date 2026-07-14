-- ============================================
-- AUTO BLOCK - SEVEN SINS BTTG
-- Ativa block quando inimigo se aproxima
-- ============================================

-- ============================================
-- 1. CONFIGURAÇÕES
-- ============================================

local CONFIG = {
    DISTANCIA_DETECCAO = 15,        -- Distância para ativar block
    DELAY_REACAO = 0.15,            -- Tempo de reação (segundos)
    TECLA_BLOCK = "F",              -- Tecla usada para block
    MODO_AGRESSIVO = false,         -- Block mais rápido
    AUTO_ATIVAR = false,            -- Iniciar automaticamente
    TECLA_ATALHO = "F2",            -- Atalho para toggle
}

-- ============================================
-- 2. SERVIÇOS
-- ============================================

local UIS = game:GetService("UserInputService")
local player = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")

if not player then
    warn("[AUTO BLOCK] ❌ Jogador não encontrado!")
    return
end

-- ============================================
-- 3. ESTADO
-- ============================================

local estado = {
    ativo = false,
    executando = false,
    inimigoProximo = false,
    ultimoBlock = 0,
    inimigosDetectados = 0,
}

-- ============================================
-- 4. FUNÇÃO DE BLOCK
-- ============================================

local function realizarBlock()
    pcall(function()
        local evento = {
            KeyCode = Enum.KeyCode[CONFIG.TECLA_BLOCK],
            UserInputType = Enum.UserInputType.Keyboard,
        }
        UIS:SetKeyDown(evento)
        task.wait(0.05)
        UIS:SetKeyUp(evento)
        estado.ultimoBlock = tick()
    end)
end

-- ============================================
-- 5. DETECTAR INIMIGOS PRÓXIMOS
-- ============================================

local function detectarInimigos()
    local char = player.Character
    if not char then return false end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    local inimigosProximos = 0
    
    for _, outro in ipairs(game:GetService("Players"):GetPlayers()) do
        if outro ~= player and outro.Character then
            local outroRoot = outro.Character:FindFirstChild("HumanoidRootPart")
            if outroRoot then
                local dist = (root.Position - outroRoot.Position).Magnitude
                if dist < CONFIG.DISTANCIA_DETECCAO then
                    inimigosProximos = inimigosProximos + 1
                end
            end
        end
    end
    
    estado.inimigosDetectados = inimigosProximos
    return inimigosProximos > 0
end

-- ============================================
-- 6. CICLO PRINCIPAL
-- ============================================

local function cicloAutoBlock()
    print("[AUTO BLOCK] 🔄 Ciclo iniciado!")
    estado.executando = true
    
    while estado.ativo do
        local inimigoPerto = detectarInimigos()
        estado.inimigoProximo = inimigoPerto
        
        if inimigoPerto then
            local tempoDecorrido = tick() - estado.ultimoBlock
            if tempoDecorrido >= CONFIG.DELAY_REACAO then
                realizarBlock()
                
                -- Atualizar UI
                if ui and ui.StatusLabel then
                    ui.StatusLabel.Text = "🛡️ BLOCK!"
                    ui.StatusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
                end
            end
        else
            if ui and ui.StatusLabel and estado.ativo then
                ui.StatusLabel.Text = "👀 ESPERANDO"
                ui.StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 50)
            end
        end
        
        -- Atualizar contador de inimigos
        if ui and ui.CountLabel then
            ui.CountLabel.Text = "👤 " .. estado.inimigosDetectados
        end
        
        -- Aguardar próximo ciclo
        local delay = CONFIG.MODO_AGRESSIVO and 0.05 or 0.1
        task.wait(delay)
    end
    
    estado.executando = false
    print("[AUTO BLOCK] ⏹️ Ciclo finalizado!")
end

-- ============================================
-- 7. FUNÇÕES DE CONTROLE
-- ============================================

local function iniciar()
    if estado.ativo then
        print("[AUTO BLOCK] ⚠️ Já está rodando!")
        return
    end
    
    estado.ativo = true
    estado.ultimoBlock = 0
    print("[AUTO BLOCK] ▶️ Iniciado!")
    print("[AUTO BLOCK] 📏 Distância: " .. CONFIG.DISTANCIA_DETECCAO .. "m")
    
    task.spawn(cicloAutoBlock)
    atualizarUI()
end

local function parar()
    if not estado.ativo then
        print("[AUTO BLOCK] ⚠️ Não está rodando!")
        return
    end
    
    estado.ativo = false
    estado.inimigoProximo = false
    print("[AUTO BLOCK] ⏹️ Parado!")
    atualizarUI()
end

local function toggle()
    if estado.ativo then
        parar()
    else
        iniciar()
    end
end

-- ============================================
-- 8. INTERFACE
-- ============================================

local ui = nil

local function criarInterface()
    local oldGui = player.PlayerGui:FindFirstChild("AutoBlockGUI")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoBlockGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 150, 0, 160)
    frame.Position = UDim2.new(0.02, 0, 0.5, -80)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 70, 70)
    frame.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 2)
    title.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    title.BackgroundTransparency = 0.3
    title.Text = "🛡️ AUTO BLOCK"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 13
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Parent = frame
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Name = "StatusLabel"
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0.18, 0)
    status.BackgroundTransparency = 1
    status.Text = "⏹️ PARADO"
    status.TextColor3 = Color3.fromRGB(200, 50, 50)
    status.TextSize = 11
    status.Font = Enum.Font.Gotham
    status.TextScaled = true
    status.Parent = frame
    
    -- Contador de inimigos
    local count = Instance.new("TextLabel")
    count.Name = "CountLabel"
    count.Size = UDim2.new(1, 0, 0, 18)
    count.Position = UDim2.new(0, 0, 0.32, 0)
    count.BackgroundTransparency = 1
    count.Text = "👤 0"
    count.TextColor3 = Color3.fromRGB(180, 180, 200)
    count.TextSize = 11
    count.Font = Enum.Font.Gotham
    count.TextScaled = true
    count.Parent = frame
    
    -- Botão Toggle
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Size = UDim2.new(0.85, 0, 0, 32)
    toggleBtn.Position = UDim2.new(0.075, 0, 0.48, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    toggleBtn.BackgroundTransparency = 0.2
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "▶ INICIAR"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 13
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextScaled = true
    toggleBtn.AutoButtonColor = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggleBtn
    
    -- Info
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 16)
    info.Position = UDim2.new(0, 0, 0.85, 0)
    info.BackgroundTransparency = 1
    info.Text = "📏 " .. CONFIG.DISTANCIA_DETECCAO .. "m | ⌨️ " .. CONFIG.TECLA_ATALHO
    info.TextColor3 = Color3.fromRGB(150, 150, 180)
    info.TextSize = 9
    info.Font = Enum.Font.Gotham
    info.TextScaled = true
    info.Parent = frame
    
    toggleBtn.Parent = frame
    frame.Parent = screenGui
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    return {
        ScreenGui = screenGui,
        ToggleBtn = toggleBtn,
        StatusLabel = status,
        CountLabel = count,
    }
end

-- ============================================
-- 9. ATUALIZAR UI
-- ============================================

local function atualizarUI()
    if not ui then return end
    
    if estado.ativo then
        ui.StatusLabel.Text = "🟢 ATIVADO"
        ui.StatusLabel.TextColor3 = Color3.fromRGB(0, 200, 80)
        ui.ToggleBtn.Text = "⏹ PARAR"
        ui.ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ui.ToggleBtn.BorderColor3 = Color3.fromRGB(200, 50, 50)
    else
        ui.StatusLabel.Text = "⏹️ PARADO"
        ui.StatusLabel.TextColor3 = Color3.fromRGB(200, 50, 50)
        ui.ToggleBtn.Text = "▶ INICIAR"
        ui.ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        ui.ToggleBtn.BorderColor3 = Color3.fromRGB(255, 70, 70)
    end
end

-- ============================================
-- 10. CONFIGURAR EVENTOS
-- ============================================

local function configurarEventos()
    if not ui then return end
    
    ui.ToggleBtn.MouseButton1Click:Connect(function()
        toggle()
        atualizarUI()
    end)
    
    ui.ToggleBtn.TouchTap:Connect(function()
        ui.ToggleBtn.MouseButton1Click:Fire()
    end)
    
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[CONFIG.TECLA_ATALHO] then
            toggle()
            atualizarUI()
        end
    end)
end

-- ============================================
-- 11. ATUALIZAÇÃO PERIÓDICA
-- ============================================

local function loopAtualizacao()
    while true do
        task.wait(0.5)
        if ui and ui.CountLabel then
            ui.CountLabel.Text = "👤 " .. estado.inimigosDetectados
        end
    end
end

-- ============================================
-- 12. INICIALIZAÇÃO
-- ============================================

local function iniciarScript()
    ui = criarInterface()
    if not ui then
        warn("[AUTO BLOCK] ❌ Falha ao criar interface!")
        return
    end
    
    configurarEventos()
    task.spawn(loopAtualizacao)
    
    _G.AutoBlock = {
        Iniciar = iniciar,
        Parar = parar,
        Toggle = toggle,
        Status = function()
            return {
                ativo = estado.ativo,
                inimigoProximo = estado.inimigoProximo,
                inimigos = estado.inimigosDetectados,
            }
        end,
        Configurar = function(config)
            for k, v in pairs(config) do
                if CONFIG[k] ~= nil then
                    CONFIG[k] = v
                end
            end
            print("[AUTO BLOCK] ✅ Configurações atualizadas!")
        end
    }
    
    print("========================================")
    print("   🛡️ AUTO BLOCK - SEVEN SINS BTTG    ")
    print("========================================")
    print("   ✅ Interface criada!")
    print("   📏 Distância: " .. CONFIG.DISTANCIA_DETECCAO .. "m")
    print("   ⚡ Delay: " .. CONFIG.DELAY_REACAO .. "s")
    print("   ⌨️ Atalho: " .. CONFIG.TECLA_ATALHO)
    print("========================================")
    
    atualizarUI()
    
    if CONFIG.AUTO_ATIVAR then
        task.wait(1)
        iniciar()
        atualizarUI()
    end
end

-- ============================================
-- 13. EXECUTAR
-- ============================================

pcall(iniciarScript)

print("")
print("╔═══════════════════════════════════════╗")
print("║   🛡️ AUTO BLOCK - SEVEN SINS BTTG  ║")
print("╠═══════════════════════════════════════╣")
print("║   ✅ Interface no canto esquerdo    ║")
print("║   📏 Detecta inimigos em " .. CONFIG.DISTANCIA_DETECCAO .. "m")
print("║   ⌨️ Pressione " .. CONFIG.TECLA_ATALHO .. " para toggle")
print("╚═══════════════════════════════════════╝")
print("")

print("[AUTO BLOCK] 📋 Comandos:")
print("  _G.AutoBlock.Iniciar()")
print("  _G.AutoBlock.Parar()")
print("  _G.AutoBlock.Toggle()")
print("  _G.AutoBlock.Status()")
print("  _G.AutoBlock.Configurar({ DISTANCIA_DETECCAO = 20 })")
print("")
