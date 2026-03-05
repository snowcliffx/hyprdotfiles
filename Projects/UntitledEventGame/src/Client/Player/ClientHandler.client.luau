--[ SERVICES ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Services = Shared.Services

--[ TYPES ]--
type CmdrClient = typeof(require(Shared.Libraries.Cmdr.CmdrClient))

--[ MODULES ]--
local Cmdr = require(Shared.Libraries.Cmdr) :: CmdrClient

--[ SERVICES ]-- [ DONT DELETE EVEN IF THEY'RE NOT USED, SOME OF THEM SIMPLY NEED TO BE LOADED ]
local _NotificationService = require(Services.NotificationService.NotificationServiceClient)

--[ CONSTANTS ]--
local ACTIVATION_KEYS = {
	Enum.KeyCode.F2,
}

--[ MAIN ]--

Cmdr:SetActivationKeys(ACTIVATION_KEYS)
