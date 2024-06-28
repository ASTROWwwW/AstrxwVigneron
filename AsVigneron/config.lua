Config = {}
Config.BannerColor = {127, 0, 255, 100}  -- Couleur de la bannière du menu
Config.Locale = 'fr'
Config.VenteInterval = 10000  -- Intervalle entre chaque vente en ms
Config.VenteCooldown = 60000  -- Délai avant de pouvoir vendre à nouveau en ms
Config.VentePricePerItem = 100  -- Montant reçu par item vendu

Config.Zones = {
    Vignoble = {
        Pos = {x = -1910.45, y = 2044.78, z = 140.0},  -- Remplacez par les coordonnées de votre zone
        Size = {x = 20.0, y = 20.0, z = 20.0},
        Color = {r = 0, g = 255, b = 0},
        Type = 1,
    
    Blip = {
        Sprite = 85,  -- Icône du blip
        Color = 2,  -- Couleur du blip
        Scale = 0.8,  -- Échelle du blip
        Name = "Vignoble"  -- Nom du blip
    },
    Marker = {
        Type = 20,  -- Type de marker
        Scale = {x = 0.7, y = 0.7, z = 0.7},  -- Échelle du marker
        Color = {r = 0, g = 255, b = 0, a = 100}  -- Couleur du marker
    }

},
TraitementVin = {
    Pos = {x = -1921.45, y = 2039.78, z = 140.0},  -- Remplacez par les coordonnées de votre zone de traitement
    Size = {x = 2.0, y = 2.0, z = 2.0},  -- Taille de la zone de traitement
    Color = {r = 255, g = 0, b = 0},
    Type = 1,  -- Type de marker
    Blip = {
        Sprite = 85,  -- Icône du blip
        Color = 1,  -- Couleur du blip
        Scale = 0.8,  -- Échelle du blip
        Name = "Traitement du Vin"  -- Nom du blip
    },
    Marker = {
        Type = 20,  -- Type de marker
        Scale = {x = 0.3, y = 0.3, z = 0.3},  -- Échelle du marker
        Color = {r = 255, g = 0, b = 0, a = 100}  -- Couleur du marker
    }
}
}

Config.GarageMarker = {
    Pos = {x = -1895.0, y = 2034.0, z = 140.0}, -- Coordonnées du marker du garage
    Size = {x = 1.5, y = 1.5, z = 1.0},
    Color = {r = 0, g = 255, b = 0},
    Type = 1 -- Type de marker
}

Config.SpawnPoint = {
    Pos = {x = -1885.0, y = 2044.0, z = 140.0}, -- Coordonnées du point de spawn des véhicules
    Heading = 70.0 -- Orientation du véhicule spawné
}

Config.DeletePoint = {
    Pos = {x = -1875.0, y = 2034.0, z = 140.0}, -- Coordonnées du point de suppression des véhicules
    Size = {x = 3.0, y = 3.0, z = 1.0},
    Color = {r = 255, g = 0, b = 0},
    Type = 1 -- Type de marker
}



-- Configuration du point d'accès pour la gestion des employés
Config.BossMarker = {
    Pos = {x = -1885.0, y = 2044.0, z = 140.0}, -- Coordonnées du marker pour le boss
    Size = {x = 1.5, y = 1.5, z = 1.0},
    Color = {r = 255, g = 0, b = 0},
    Type = 1 -- Type de marker
}

-- Configuration de la gestion des employés
Config.EmployeeManagement = {
    Enable = true, -- Activer ou désactiver la gestion des employés
    BossOnly = true -- Si true, seule la personne avec le grade 'boss' peut gérer les employés
}





Config.EntrepriseVehicles = {
    {label = "Yosemite", model = "yosemite3"},
    {label = "Bison", model = "bison"},
    {label = "Sadler", model = "sadler"}
}
Config.VentePoints = {
    {x = -562.15, y = 286.79, z = 82.18},  
    {x = 25.65, y = -1347.37, z = 29.49}, 
    {x = 2557.46, y = 382.28, z = 108.62}, 
    {x = -47.42, y = -1758.67, z = 29.42}, 
    {x = 1163.37, y = -323.80, z = 69.21}, 
    {x = -707.50, y = -914.26, z = 19.22}, 
    {x = 1698.38, y = 4924.40, z = 42.06},
    {x = 1729.28, y = 6414.37, z = 35.03}, 
    {x = -3243.98, y = 1001.51, z = 12.83},
    {x = -3038.93, y = 585.95, z = 7.91},
    {x = 1135.57, y = -982.20, z = 46.41},
    {x = -1222.91, y = -907.09, z = 12.33},
    {x = -1487.55, y = -379.10, z = 40.16}, 
    {x = 1986.18, y = 3054.55, z = 47.21}, 
    {x = 1392.57, y = 3606.29, z = 34.98}, 
    {x = -2968.24, y = 390.91, z = 15.04},
    {x = 2678.91, y = 3280.67, z = 55.24}, 
    {x = -1820.57, y = 792.51, z = 138.11},
    {x = 2584.28, y = 316.82, z = 108.45} 
}

Config.VenteVehicle =  'bison' -- véhicule pour vendre
Config.BlipsVisibleForAll = false -- true = meme les civils peuvent voir les points de récolte, vente



Config.DiscordWebhookURL = "TON WEBHOOK"
Config.Embed = {
    title = "ASTRXW QUI DEV",
    color = 3066993, -- Couleur de l'embed (ici, vert <3)
    footer = {
        text = "ASTRXWRLD",
        icon_url = "LOGO"
    }
}










