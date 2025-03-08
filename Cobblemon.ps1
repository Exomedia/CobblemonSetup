$SevenZipPath = "C:\Program Files\7-Zip\7z.exe"
$DownloadUrl = "https://www.7-zip.org/a/7z2409-x64.exe"
$InstallerPath = "$env:TEMP\7zInstaller.exe"
$InstalledByScript = $false

Write-Host "Verification de la presence de 7-Zip..."

if (-Not (Test-Path $SevenZipPath)) {
    Write-Host "7-Zip n'est pas installe. Telechargement en cours..."
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $InstallerPath
    
    if (Test-Path $InstallerPath) {
        Write-Host "Installation de 7-Zip..."
        Start-Process -FilePath $InstallerPath -ArgumentList "/S" -NoNewWindow -Wait
        Start-Sleep -Seconds 5

        if (Test-Path $SevenZipPath) {
            $InstalledByScript = $true
            Write-Host "7-Zip a ete installe avec succes."
        } else {
            Write-Host "Erreur : L'installation de 7-Zip a echoue."
            exit 1
        }
    } else {
        Write-Host "Erreur : Impossible de telecharger l'installateur de 7-Zip."
        exit 1
    }
} else {
    Write-Host "7-Zip est deja installe."
}

# Verification du chemin de l'instance Cobblemon Star Academy
$DefaultInstancePath = "$env:USERPROFILE\curseforge\minecraft\Instances\Cobblemon Star Academy"

if (-Not (Test-Path $DefaultInstancePath)) {
    Write-Host "Le dossier de l'instance Cobblemon Star Academy n'a pas ete trouve."
    $UserInstancePath = Read-Host "Veuillez entrer le chemin correct de l'instance Minecraft"
    
    while (-Not (Test-Path $UserInstancePath)) {
        Write-Host "Le chemin specifie est invalide. Essayez a nouveau."
        $UserInstancePath = Read-Host "Veuillez entrer le chemin correct de l'instance Minecraft"
    }

    $InstancePath = $UserInstancePath
} else {
    Write-Host "Instance detectee a : $DefaultInstancePath"
    $InstancePath = $DefaultInstancePath
}

# Telechargement des fichiers
$UrlCobbFR = "https://transfer.exomedia.io/api/shares/hn1uvVu4/files/3415a106-c400-4a4c-a9d3-429c90f53ce7"
$OutputPathCobbFR = "$env:USERPROFILE\Downloads\CobblemonFR.rar"

$UrlIcons = "https://transfer.exomedia.io/api/shares/hn1uvVu4/files/2f8cb99b-d91e-4259-803b-abdb23d1a8d7"
$OutputPathIcons = "$env:USERPROFILE\Downloads\CobblemonIcons.zip"

Write-Host "Telechargement de CobblemonFR en cours..."
Start-BitsTransfer -Source $UrlCobbFR -Destination $OutputPathCobbFR
if (Test-Path $OutputPathCobbFR) {
    Write-Host "Telechargement termine : $OutputPathCobbFR"
} else {
    Write-Host "Erreur : Echec du telechargement de CobblemonFR."
    exit 1
}

Write-Host "Telechargement de CobblemonIcons en cours..."
Start-BitsTransfer -Source $UrlIcons -Destination $OutputPathIcons
if (Test-Path $OutputPathIcons) {
    Write-Host "Telechargement termine : $OutputPathIcons"
} else {
    Write-Host "Erreur : Echec du telechargement de CobblemonIcons."
    exit 1
}

# Extraction des fichiers
$DestinationCobbFR = "$InstancePath\resourcepacks\CobblemonFR"
$DestinationIcons = "$InstancePath\resourcepacks"

Write-Host "Extraction de CobblemonFR..."
& $SevenZipPath x "`"$OutputPathCobbFR`"" -o"`"$DestinationCobbFR`"" -y
if (Test-Path $DestinationCobbFR) {
    Write-Host "Extraction reussie : $DestinationCobbFR"
} else {
    Write-Host "Erreur : Echec de l'extraction de CobblemonFR."
    exit 1
}

Write-Host "Extraction de CobblemonIcons..."
& $SevenZipPath x "`"$OutputPathIcons`"" -o"`"$DestinationIcons`"" -y
if (Test-Path $DestinationIcons) {
    Write-Host "Extraction reussie : $DestinationIcons"
} else {
    Write-Host "Erreur : Echec de l'extraction de CobblemonIcons."
    exit 1
}

# Trouver le nom du dossier CobblemonIcons extrait
$ExtractedIconsFolders = Get-ChildItem -Path $DestinationIcons -Directory | Where-Object { $_.Name -match "CobblemonIcons" }

if ($ExtractedIconsFolders.Count -eq 0) {
    Write-Host "Erreur : Impossible de trouver le dossier CobblemonIcons."
    exit 1
} else {
    $NewIconsFolder = $ExtractedIconsFolders[0].Name
    Write-Host "Nouveau dossier detecte : $NewIconsFolder"
}

# Construire la ligne de resourcePacks avec le dossier correct
$ResourcePacksLine = 'resourcePacks:["vanilla","fabric","cobbreeding:pasturefix","convenientdecor:hydrated_farmland","file/Boenk\u0027s_Cobblemon_Item_Description_V1.5.0.zip","file/Theone\u0027s Items Pack v0.8.zip","file/Cobblemon Interface v1.1.1.zip","file/Journeymap-Cobblemon3.01_1.20.1_MythicalNetwork.zip","file/EmbellishedStone-1.20.1-1.0.0.zip","file/VidyaPokeCriesCobblemon-V1.2.zip","file/EclecticTrove-1.20.1-1.3.0","file/Border-Makeover-Style-9","file/SmoothFont_1.20.zip","file/bopack","file/' + $NewIconsFolder + '","file/CobblemonFR","file/CobbleCafe","file/Vivillon Pride Patterns v1.0","file/BattleBond [V1.4]","file/Star Academy","Moonlight Mods Dynamic Assets"]'

# Modifier le fichier options.txt
$OptionsFilePath = "$InstancePath\options.txt"

if (-Not (Test-Path $OptionsFilePath)) {
    Write-Host "Erreur : Le fichier options.txt est introuvable."
    exit 1
}

# Lire le contenu du fichier
$OptionsContent = Get-Content $OptionsFilePath -Raw

# Remplacer la ligne de resourcePacks avec la nouvelle version
$UpdatedContent = $OptionsContent -replace 'resourcePacks:\[.*\]', $ResourcePacksLine

# Écrire les modifications dans options.txt
Set-Content -Path $OptionsFilePath -Value $UpdatedContent
Write-Host "Le fichier options.txt a ete mis a jour."

# Suppression de 7-Zip si installe par le script
if ($InstalledByScript) {
    Write-Host "Suppression de 7-Zip..."
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c rmdir /s /q `"C:\Program Files\7-Zip`"" -NoNewWindow -Wait
    if (-Not (Test-Path $SevenZipPath)) {
        Write-Host "7-Zip a ete supprime avec succes."
    } else {
        Write-Host "Attention : Echec de la suppression de 7-Zip."
    }
}

Write-Host "Script termine avec succes."
