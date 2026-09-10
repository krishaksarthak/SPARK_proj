<#
.SYNOPSIS
    Provisions the SPARK SharePoint Communication Site and applies custom Visteon branding.

.DESCRIPTION
    This script connects to the SharePoint tenant, creates the SPARK Communication Site,
    applies a custom theme, configures navigation, creates a media library with folders,
    sets up permissions, and creates necessary groups.

.NOTES
    Requires PnP.PowerShell module. Run as Administrator if installing the module for the first time.
#>

# ==============================================================================
# CONFIGURATION VARIABLES
# ==============================================================================
$TenantName = "visteon" # e.g., "contoso"
$AdminCenterUrl = "https://$TenantName-admin.sharepoint.com"
$SiteUrl = "https://$TenantName.sharepoint.com/sites/SPARK"
$SiteTitle = "SPARK"
$SiteDescription = "Visteon Opportunity Marketplace & Recognition Hub"
$SiteOwner = "admin@$TenantName.onmicrosoft.com" # Admin UPN
$SiteLogoPath = "C:\Path\To\Your\Logo.png" # Placeholder - update with actual logo path
$PrimaryColor = "#005BAB" # Visteon blue
$BackgroundColor = "#F5F7FA"
$HeaderBackground = "#1A1A2E"

# ==============================================================================
# PRE-REQUISITES CHECK
# ==============================================================================
Write-Host "Checking for PnP.PowerShell module..." -ForegroundColor Cyan
if (!(Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Write-Host "PnP.PowerShell module not found. Installing..." -ForegroundColor Yellow
    try {
        Install-Module -Name PnP.PowerShell -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
        Write-Host "PnP.PowerShell module installed successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to install PnP.PowerShell module. Error: $_" -ForegroundColor Red
        Exit
    }
} else {
    Write-Host "PnP.PowerShell module is already installed." -ForegroundColor Green
}

Import-Module PnP.PowerShell

# ==============================================================================
# SCRIPT EXECUTION
# ==============================================================================
try {
    # 1. Connect to SharePoint Tenant Admin
    Write-Host "`n1. Connecting to SharePoint Admin Center ($AdminCenterUrl)..." -ForegroundColor Cyan
    Connect-PnPOnline -Url $AdminCenterUrl -Interactive -ErrorAction Stop

    # 2. Create Communication Site
    Write-Host "`n2. Checking if site '$SiteUrl' exists..." -ForegroundColor Cyan
    $siteExists = Get-PnPTenantSite | Where-Object { $_.Url -eq $SiteUrl }
    
    if (-not $siteExists) {
        Write-Host "Creating Communication Site '$SiteTitle'..." -ForegroundColor Yellow
        $site = New-PnPSite -Type CommunicationSite -Title $SiteTitle -Url $SiteUrl -Description $SiteDescription -Owner $SiteOwner -Wait
        Write-Host "Site created successfully." -ForegroundColor Green
    } else {
        Write-Host "Site already exists at $SiteUrl." -ForegroundColor Green
    }

    # Re-connect to the newly created site
    Write-Host "Connecting to the SPARK site..." -ForegroundColor Cyan
    Connect-PnPOnline -Url $SiteUrl -Interactive -ErrorAction Stop

    # 3. Apply Visteon Brand Theme
    Write-Host "`n3. Applying Visteon Brand Theme..." -ForegroundColor Cyan
    $palette = @{
        "themePrimary" = $PrimaryColor;
        "themeLighterAlt" = "#f0f6fb";
        "themeLighter" = "#c5dcf0";
        "themeLight" = "#96bfe3";
        "themeTertiary" = "#4489c7";
        "themeSecondary" = "#1468b3";
        "themeDarkAlt" = "#00529a";
        "themeDark" = "#004582";
        "themeDarker" = "#003360";
        "neutralLighterAlt" = $BackgroundColor;
        "neutralLighter" = "#f1f3f6";
        "neutralLight" = "#e7e9ec";
        "neutralQuaternaryAlt" = "#d7d9dc";
        "neutralQuaternary" = "#cecfd2";
        "neutralTertiaryAlt" = "#c6c7ca";
        "neutralTertiary" = "#595959";
        "neutralSecondary" = "#373737";
        "neutralPrimaryAlt" = "#2f2f2f";
        "neutralPrimary" = "#000000";
        "neutralDark" = "#151515";
        "black" = "#0b0b0b";
        "white" = "#ffffff";
    }

    $themeName = "Visteon SPARK Theme"
    try {
        # Add theme to tenant
        Add-PnPTenantTheme -Identity $themeName -Palette $palette -IsInverted:$false -Overwrite -ErrorAction Stop
        # Apply theme to current web
        Set-PnPWebTheme -Theme $themeName -ErrorAction Stop
        Write-Host "Theme applied successfully." -ForegroundColor Green
    } catch {
        Write-Host "Warning: Failed to apply theme. Note: Tenant themes may take some time to propagate or require specific permissions. Error: $_" -ForegroundColor Yellow
    }

    # 4. Set Site Logo
    Write-Host "`n4. Setting Site Logo..." -ForegroundColor Cyan
    if (Test-Path $SiteLogoPath) {
        # Upload the logo to SiteAssets
        $uploadedLogo = Add-PnPFile -Path $SiteLogoPath -Folder "SiteAssets" -ErrorAction Stop
        # Set the logo URL
        Set-PnPWeb -SiteLogoUrl $uploadedLogo.ServerRelativeUrl -ErrorAction Stop
        Write-Host "Site logo configured." -ForegroundColor Green
    } else {
        Write-Host "Placeholder: Please upload the site logo PNG and configure its path ($SiteLogoPath)." -ForegroundColor Yellow
    }

    # 5. Create Top Navigation Links
    Write-Host "`n5. Configuring Navigation..." -ForegroundColor Cyan
    $navNodes = @(
        @{ Title="Home"; Url="$SiteUrl" },
        @{ Title="Opportunities"; Url="$SiteUrl/SitePages/Explore.aspx" },
        @{ Title="Manager Hub"; Url="$SiteUrl/SitePages/Manager-Hub.aspx" },
        @{ Title="Rewards"; Url="$SiteUrl/SitePages/Rewards.aspx" },
        @{ Title="FAQ"; Url="$SiteUrl/SitePages/FAQ-Help.aspx" }
    )

    try {
        # Clear existing navigation (optional but clean for fresh provision)
        $existingNav = Get-PnPNavigationNode -Location TopNavigationBar
        foreach ($node in $existingNav) {
            Remove-PnPNavigationNode -Identity $node -Force
        }

        foreach ($node in $navNodes) {
            Add-PnPNavigationNode -Location TopNavigationBar -Title $node.Title -Url $node.Url | Out-Null
            Write-Host "Added navigation link: $($node.Title)" -ForegroundColor DarkGray
        }
        Write-Host "Navigation configured." -ForegroundColor Green
    } catch {
        Write-Host "Error configuring navigation: $_" -ForegroundColor Red
    }

    # 6. Create Document Library 'SPARK-Media' with folders
    Write-Host "`n6. Creating Document Library 'SPARK-Media'..." -ForegroundColor Cyan
    $libName = "SPARK-Media"
    $list = Get-PnPList -Identity $libName -ErrorAction SilentlyContinue
    if (-not $list) {
        New-PnPList -Title $libName -Template DocumentLibrary -ErrorAction Stop | Out-Null
        Write-Host "Library '$libName' created." -ForegroundColor Green
    } else {
        Write-Host "Library '$libName' already exists." -ForegroundColor Green
    }

    $folders = @("banners", "thumbnails", "winners", "demos")
    foreach ($folder in $folders) {
        Resolve-PnPFolder -SiteRelativePath "$libName/$folder" | Out-Null
        Write-Host "Created/Verified folder: $folder" -ForegroundColor DarkGray
    }

    # 7. Create M365 Group 'SPARK-Managers'
    Write-Host "`n7. M365 Group Creation..." -ForegroundColor Cyan
    Write-Host "NOTE: Creating an M365 group via script requires Azure AD admin privileges." -ForegroundColor Yellow
    $groupName = "SPARK-Managers"
    $groupMailNickname = "sparkmanagers"
    
    $group = Get-PnPMicrosoft365Group -Identity $groupMailNickname -ErrorAction SilentlyContinue
    if (-not $group) {
        try {
            Write-Host "Attempting to create M365 Group '$groupName'..." -ForegroundColor Yellow
            $group = New-PnPMicrosoft365Group -DisplayName $groupName -Description "Managers for the SPARK platform" -MailNickname $groupMailNickname -IsPrivate:$true -Owners $SiteOwner -ErrorAction Stop
            Write-Host "M365 Group '$groupName' created successfully." -ForegroundColor Green
        } catch {
            Write-Host "Failed to create M365 group. Ensure you have the required permissions. Error: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "M365 Group '$groupName' already exists." -ForegroundColor Green
    }

    # 8. Set Site Permissions
    Write-Host "`n8. Configuring Site Permissions..." -ForegroundColor Cyan
    
    # Visitors = All company read
    try {
        # 'c:0-.f|rolemanager|spo-grid-all-users' is usually 'Everyone except external users'
        $everyoneClaim = "c:0-.f|rolemanager|spo-grid-all-users"
        $visitorGroup = Get-PnPGroup -AssociatedVisitorGroup
        Add-PnPUserToGroup -LoginName $everyoneClaim -Identity $visitorGroup.Title -ErrorAction Stop
        Write-Host "Added 'Everyone except external users' to Visitors group." -ForegroundColor Green
    } catch {
        Write-Host "Warning: Failed to add everyone to Visitors. Claim might be different or already added. Error: $_" -ForegroundColor Yellow
    }

    # Members = SPARK-Managers
    try {
        if ($group) {
            $memberGroup = Get-PnPGroup -AssociatedMemberGroup
            # Add the M365 group as a member of the SharePoint Members group
            # Format: c:0o.c|federateddirectoryclaimprovider|{GroupId}
            $groupClaim = "c:0o.c|federateddirectoryclaimprovider|$($group.Id)"
            Add-PnPUserToGroup -LoginName $groupClaim -Identity $memberGroup.Title -ErrorAction Stop
            Write-Host "Added M365 Group '$groupName' to Members group." -ForegroundColor Green
        }
    } catch {
        Write-Host "Warning: Failed to add SPARK-Managers to Members group. Error: $_" -ForegroundColor Yellow
    }

    # Owners = SharePoint Admins
    # Note: Site collection admins are already owners, but to ensure a specific admin group, you could add them here.
    try {
        $ownerGroup = Get-PnPGroup -AssociatedOwnerGroup
        # Assuming SharePoint Admins or specific users are handled via standard SP Admin setup
        Write-Host "Owners group managed via standard site creation/SharePoint Admins." -ForegroundColor Green
    } catch {
        Write-Host "Warning: Failed to process Owners group. Error: $_" -ForegroundColor Yellow
    }

    Write-Host "`n==============================================================================" -ForegroundColor Green
    Write-Host "SPARK Provisioning Script Completed Successfully!" -ForegroundColor Green
    Write-Host "==============================================================================" -ForegroundColor Green

} catch {
    Write-Host "`nAn error occurred during script execution:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
} finally {
    Write-Host "`nDisconnecting from SharePoint..." -ForegroundColor Cyan
    Disconnect-PnPOnline
}
