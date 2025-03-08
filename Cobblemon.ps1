$SevenZipPath = "C:\Program Files\7-Zip\7z.exe"
$DownloadUrl = "https://www.7-zip.org/a/7z2409-x64.exe"
$InstallerPath = "$env:TEMP\7zInstaller.exe"
$InstalledByScript = $false

Write-Host "Vérification de la présence de 7-Zip..."

if (-Not (Test-Path $SevenZipPath)) {
    Write-Host "7-Zip n'est pas installé. Téléchargement en cours..."
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $InstallerPath
    
    if (Test-Path $InstallerPath) {
        Write-Host "Installation de 7-Zip..."
        Start-Process -FilePath $InstallerPath -ArgumentList "/S" -NoNewWindow -Wait
        Start-Sleep -Seconds 5

        if (Test-Path $SevenZipPath) {
            $InstalledByScript = $true
            Write-Host "7-Zip a été installé avec succès."
        } else {
            Write-Host "Erreur : L'installation de 7-Zip a échoué."
            exit 1
        }
    } else {
        Write-Host "Erreur : Impossible de télécharger l'installateur de 7-Zip."
        exit 1
    }
} else {
    Write-Host "7-Zip est déjà installé."
}

# Vérification du chemin de l'instance Cobblemon Star Academy
$DefaultInstancePath = "$env:USERPROFILE\curseforge\minecraft\Instances\Cobblemon Star Academy"

if (-Not (Test-Path $DefaultInstancePath)) {
    Write-Host "Le dossier de l'instance Cobblemon Star Academy n'a pas été trouvé."
    $UserInstancePath = Read-Host "Veuillez entrer le chemin correct de l'instance Minecraft"
    
    while (-Not (Test-Path $UserInstancePath)) {
        Write-Host "Le chemin spécifié est invalide. Essayez à nouveau."
        $UserInstancePath = Read-Host "Veuillez entrer le chemin correct de l'instance Minecraft"
    }

    $InstancePath = $UserInstancePath
} else {
    Write-Host "Instance détectée à : $DefaultInstancePath"
    $InstancePath = $DefaultInstancePath
}

# Téléchargement des fichiers
$UrlCobbFR = "https://transfer.exomedia.io/api/shares/hn1uvVu4/files/3415a106-c400-4a4c-a9d3-429c90f53ce7"
$OutputPathCobbFR = "$env:USERPROFILE\Downloads\CobblemonFR.rar"

$UrlIcons = "https://transfer.exomedia.io/api/shares/hn1uvVu4/files/2f8cb99b-d91e-4259-803b-abdb23d1a8d7"
$OutputPathIcons = "$env:USERPROFILE\Downloads\CobblemonIcons Pokerayou corrected v14.zip"

Write-Host "Téléchargement de CobblemonFR en cours..."
Start-BitsTransfer -Source $UrlCobbFR -Destination $OutputPathCobbFR
if (Test-Path $OutputPathCobbFR) {
    Write-Host "Téléchargement terminé : $OutputPathCobbFR"
} else {
    Write-Host "Erreur : Échec du téléchargement de CobblemonFR."
    exit 1
}

Write-Host "Téléchargement de CobblemonIcons en cours..."
Start-BitsTransfer -Source $UrlIcons -Destination $OutputPathIcons
if (Test-Path $OutputPathIcons) {
    Write-Host "Téléchargement terminé : $OutputPathIcons"
} else {
    Write-Host "Erreur : Échec du téléchargement de CobblemonIcons."
    exit 1
}

# Extraction des fichiers
$DestinationCobbFR = "$InstancePath\resourcepacks\CobblemonFR"
$DestinationIcons = "$InstancePath\resourcepacks"

Write-Host "Extraction de CobblemonFR..."
& $SevenZipPath x "`"$OutputPathCobbFR`"" -o"`"$DestinationCobbFR`"" -y
if (Test-Path $DestinationCobbFR) {
    Write-Host "Extraction réussie : $DestinationCobbFR"
} else {
    Write-Host "Erreur : Échec de l'extraction de CobblemonFR."
    exit 1
}

Write-Host "Extraction de CobblemonIcons..."
& $SevenZipPath x "`"$OutputPathIcons`"" -o"`"$DestinationIcons`"" -y
if (Test-Path $DestinationIcons) {
    Write-Host "Extraction réussie : $DestinationIcons"
} else {
    Write-Host "Erreur : Échec de l'extraction de CobblemonIcons."
    exit 1
}

# Suppression de 7-Zip si installé par le script
if ($InstalledByScript) {
    Write-Host "Suppression de 7-Zip..."
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c rmdir /s /q `"C:\Program Files\7-Zip`"" -NoNewWindow -Wait
    if (-Not (Test-Path $SevenZipPath)) {
        Write-Host "7-Zip a été supprimé avec succès."
    } else {
        Write-Host "Attention : Échec de la suppression de 7-Zip."
    }
}

Write-Host "Script terminé avec succès."