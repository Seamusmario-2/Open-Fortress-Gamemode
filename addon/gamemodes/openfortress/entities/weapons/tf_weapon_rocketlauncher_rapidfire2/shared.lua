if SERVER then
	AddCSLuaFile( "shared.lua" )
	
end

if CLIENT then

SWEP.PrintName			= "Quad Launcher"
SWEP.Slot				= 0
SWEP.RenderGroup 		= RENDERGROUP_BOTH

function SWEP:ClientStartCharge()
	self.ClientCharging = true
	self.ClientChargeStart = CurTime()
end

function SWEP:ClientEndCharge()
	self.ClientCharging = false
end

end

function SWEP:OnEquipAttribute(a, owner)
	if a.attribute_class == "set_weapon_mode" then
		if a.value == 1 then
			if CLIENT then
				self.CustomHUD = {HudBowCharge = true}
			end
		end
	end
end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/v_models/v_quad.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_quadtest.mdl"
SWEP.Crosshair = "tf_crosshair3"

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "Team Fortress 2"

SWEP.MuzzleEffect = "muzzle_pipelauncher"
PrecacheParticleSystem("muzzle_pipelauncher")

SWEP.ShootSound = Sound("weapons/quake_rpg_fire_remastered.wav")
SWEP.ShootCritSound = Sound("weapons/quake_rpg_fire_remastered.wav")
SWEP.ChargeSound = Sound("Weapon_StickyBombLauncher.ChargeUp")
SWEP.ReloadSound = Sound("weapons/tommy_bolt_forward.wav")

SWEP.Primary.ClipSize		= 4
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Delay          = 0.1

SWEP.IsRapidFire = true
SWEP.ReloadSingle = false

SWEP.HoldType = "PRIMARY"
SWEP.HoldTypeHL2 = "rpg"

SWEP.ProjectileShootOffset = Vector(0, 13, -4)

SWEP.PunchView = Angle( 0, 0, 0 )
 
SWEP.Properties = {}

SWEP.ChargeTime = 2
SWEP.MinForce = 150
SWEP.MaxForce = 2800
SWEP.BaseDamage = 40
SWEP.MinAddPitch = -1
SWEP.MaxAddPitch = -6

SWEP.MinGravity = 1
SWEP.MaxGravity = 1
SWEP.BulletSpread = 7
SWEP.ReloadTime = 5
function SWEP:Deploy()
	if CLIENT then
		HudBowCharge:SetProgress(0)
	end
	
	return self:CallBaseFunction("Deploy")
end
 
function SWEP:Think()
	self:CallBaseFunction("Think")
	
	if self.WeaponMode ~= 1 then return end
	
	if CLIENT then
		if self.ClientCharging and self.ClientChargeStart then
			HudBowCharge:SetProgress((CurTime()-self.ClientChargeStart) / self.ChargeTime)
		else
			HudBowCharge:SetProgress(0)
		end
	end 
	
	if self.Charging then
		if (not self.Owner:KeyDown(IN_ATTACK) or CurTime() - self.ChargeStartTime > self.ChargeTime) then
			self.Charging = false
			
			self:SendWeaponAnim(self.VM_PRIMARYATTACK)
			self.Owner:DoAttackEvent()
			
			self.NextIdle = CurTime() + self:SequenceDuration()
			
			self:ShootProjectile()
			self:TakePrimaryAmmo(1)
			
			self.Delay =  CurTime() + self.Primary.Delay
			self.QuickDelay =  CurTime() + self.Primary.QuickDelay
			
			if SERVER then
				self:CallOnClient("ClientEndCharge", "")
			end
			
			if self:Clip1() <= 0 then
				self:Reload()
			end
			
			if SERVER and not self.Primary.NoFiringScene then
				self.Owner:Speak("TLK_FIREWEAPON", true)
			end
			
			self:RollCritical() -- Roll and check for criticals first
			
			if (game.SinglePlayer() or CLIENT) and self.ChargeUpSound then
				self.ChargeUpSound:Stop()
				self.ChargeUpSound = nil
			end
			
			self.LockAttackKey = true
		else
			if (game.SinglePlayer() or CLIENT) and not self.ChargeUpSound then
				self.ChargeUpSound = CreateSound(self, self.ChargeSound)
				self.ChargeUpSound:PlayEx(1, 400 / self.ChargeTime)
			end
		end
	end
	self:Inspect()
end

function SWEP:ShootProjectile()
	if SERVER then
		local rocket = ents.Create("tf_projectile_rocket")
		rocket:SetPos(self:ProjectileShootPos())
		local ang = self.Owner:EyeAngles()
		
		rocket.BaseSpeed = 2200
		
		rocket:SetAngles(ang)
		rocket.ExplosionSound = Sound(")weapons/quake_explosion_remastered1.wav")
		if self:Critical() then
			rocket.critical = true
		end
		
		for k,v in pairs(self.Properties) do
			rocket[k] = v
		end
		
		rocket:SetOwner(self.Owner)
		self:InitProjectileAttributes(rocket)
		
		rocket:Spawn()
		rocket:Activate() 
	end
	
	self:ShootEffects()
end

function SWEP:OnRemove()
	if (game.SinglePlayer() or CLIENT) and self.ChargeUpSound then
		self.ChargeUpSound:Stop()
		self.ChargeUpSound = nil
	end
end
