--!strict

type Class = "Knight" | "Archer" | "Mage" | "Assassin"

type Stats = {
    Health: number,
    Attack: number,
    Mobility: number
}

type ClassStats = {
    [Class]: {[string]: Stats}
}

local ClassStats: ClassStats = {
    Knight = {
        BaseKnight = {
            Health = 100,
            Attack = 100,
            Mobility = 100
        },

        TrueKnight = {
            Health = 120,
            Attack = 50,
            Mobility = 150
        },

        ValiantKnight = {
            Health = 80,
            Attack = 120,
            Mobility = 120,
        },

        BomboclatKnight = {
            Health = 150,
            Attack = 60,
            Mobility = 80
        }
    }
}