--!strict
--!optimize 2
--!native

local HitServiceCommon = require(script.HitServiceCommon)
local Hitbox = require(script.Hitbox)

export type Hitbox = HitServiceCommon.Hitbox

type HitService = {
	Hitboxes: { [Instance]: { Hitbox } },
	CreateHitbox: (self: HitService, instance: Instance, params: RaycastParams?) -> Hitbox,
}

local HitService = {
	Hitboxes = {},
} :: HitService

function HitService:CreateHitbox(instance: Instance, params: RaycastParams?): Hitbox
	local NewHitbox = Hitbox.new(instance, params)

	if not self.Hitboxes[instance] then
		self.Hitboxes[instance] = {}
	end

	table.insert(self.Hitboxes[instance], NewHitbox)

	NewHitbox.OnDestroying:Connect(function()
		if not self.Hitboxes[instance] then
			return
		end

		local TotalHitboxCount = #self.Hitboxes[instance]

		for i = TotalHitboxCount, 1, -1 do
			if self.Hitboxes[instance][i] == NewHitbox then
				table.remove(self.Hitboxes[instance], i)

				if TotalHitboxCount == 1 then
					self.Hitboxes[instance] = nil
				end
			end
		end
	end)

	return NewHitbox
end


return HitService
