--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Services = ReplicatedStorage.Shared.Services

local _RoundService = require(Services.RoundService.RoundServiceClient)
local _DuelService = require(Services.DuelService.DuelServiceClient)