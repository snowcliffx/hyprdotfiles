return function(registry)
	registry:RegisterType("ranks", registry.Cmdr.Util.MakeEnumType("Ranks", { "Owner", "Host" }))
end
