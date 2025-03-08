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
    $UserInstancePath = Read-Host "Veuillez entrer le chemin du modpack"
    
    while (-Not (Test-Path $UserInstancePath)) {
        Write-Host "Le chemin specifie est invalide. Essayez a nouveau."
        $UserInstancePath = Read-Host "Veuillez entrer le chemin du modpack"
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

# Suppression de l'ancienne version de CobblemonIcons, si elle existe
$ExistingIconsFolder = Get-ChildItem -Path $InstancePath\resourcepacks -Directory | Where-Object { $_.Name -match "CobblemonIcons" }

if ($ExistingIconsFolder) {
    Write-Host "Suppression de l'ancienne version de CobblemonIcons..."
    Remove-Item -Path $ExistingIconsFolder.FullName -Recurse -Force
    Write-Host "Ancienne version de CobblemonIcons supprimee."
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
