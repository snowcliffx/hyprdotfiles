return function(registry)
	registry:RegisterType("freeze", registry.Cmdr.Util.MakeEnumType("FreezeOption", { "Freeze", "Thaw" }))
end
