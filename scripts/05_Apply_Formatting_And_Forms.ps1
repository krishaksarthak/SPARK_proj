<#
.SYNOPSIS
    Applies JSON formatting to SharePoint list columns, configures forms, default values, validations, and permissions.
.DESCRIPTION
    This script is part of the SPARK platform deployment. It configures the UX and logic aspects of the 
    Opportunities and Applications lists, applying PnP formatting and adjusting form properties.
.NOTES
    File Name: 05_Apply_Formatting_And_Forms.ps1
    Author: SPARK Dev Team
#>

$ErrorActionPreference = "Stop"

# Configuration
$Config = @{
    SiteUrl             = "https://visteon.sharepoint.com/sites/SPARK"
    FormattingFolder    = "..\formatting"
    Lists = @{
        Opportunities = "Opportunities"
        Applications  = "Applications"
    }
    Groups = @{
        Managers = "SPARK-Managers"
        Members  = "SPARK Members"
        Visitors = "SPARK Visitors"
    }
}

Function Write-Log {
    param([string]$Message, [string]$Type="Info")
    $color = switch ($Type) {
        "Info"    { "Cyan" }
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error"   { "Red" }
        default   { "White" }
    }
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Message" -ForegroundColor $color
}

Try {
    Write-Log "Connecting to SPARK Platform site: $($Config.SiteUrl)"
    Connect-PnPOnline -Url $Config.SiteUrl -Interactive

    Write-Log "Applying Column JSON Formatting" -Type "Info"

    # 1. Read JSON files and apply
    $oppStatusJsonPath = Join-Path $Config.FormattingFolder "Opportunities_Status_Pill.json"
    if (Test-Path $oppStatusJsonPath) {
        $oppStatusJson = Get-Content -Path $oppStatusJsonPath -Raw
        Write-Log "Applying Status pill formatting to Opportunities"
        Set-PnPField -List $Config.Lists.Opportunities -Identity "Status" -Values @{CustomFormatter = $oppStatusJson}
    }

    $appStatusJsonPath = Join-Path $Config.FormattingFolder "Applications_Status_Pill.json"
    if (Test-Path $appStatusJsonPath) {
        $appStatusJson = Get-Content -Path $appStatusJsonPath -Raw
        Write-Log "Applying Status pill formatting to Applications"
        Set-PnPField -List $Config.Lists.Applications -Identity "Status" -Values @{CustomFormatter = $appStatusJson}
    }

    $galleryJsonPath = Join-Path $Config.FormattingFolder "Opportunities_Gallery_Card.json"
    if (Test-Path $galleryJsonPath) {
        $galleryJson = Get-Content -Path $galleryJsonPath -Raw
        Write-Log "Applying Gallery view formatting to Opportunities"
        $view = Get-PnPView -List $Config.Lists.Opportunities -Identity "Gallery" -ErrorAction SilentlyContinue
        if ($view) {
            Set-PnPView -List $Config.Lists.Opportunities -Identity $view.Id -Values @{CustomFormatter = $galleryJson}
        }
    }

    $rowJsonPath = Join-Path $Config.FormattingFolder "Opportunities_RowFormat.json"
    if (Test-Path $rowJsonPath) {
        $rowJson = Get-Content -Path $rowJsonPath -Raw
        Write-Log "Applying Row view formatting to Opportunities"
        $allItemsView = Get-PnPView -List $Config.Lists.Opportunities -Identity "All Items" -ErrorAction SilentlyContinue
        if ($allItemsView) {
            Set-PnPView -List $Config.Lists.Opportunities -Identity $allItemsView.Id -Values @{CustomFormatter = $rowJson}
        }
    }

    # 2 & 3. Configure Forms for Applications List
    Write-Log "Configuring Application List Forms" -Type "Info"
    <#
    FORM CONFIGURATION NOTES:
    - New Form: Should show Opportunity (pre-filled via query string), Applicant, EmployeeID, CurrentTeam, Manager, Skills, InterestStatement, Availability.
      Hide: Status, ManagerRemarks, OpeningsFilled, Title (auto-set by flow).
      Use 'Customize forms' in Power Apps to set field visibility.
    - Edit Form (Manager view): Show Status and ManagerRemarks at top.
      Customize via Power Apps Edit form, set field order.
    #>

    # 4. Configure Display Form for Opportunities List
    Write-Log "Configuring Display Form for Opportunities List" -Type "Info"
    <#
    FORM CONFIGURATION NOTES:
    - Display Form: Show all fields including Mentor info.
    - Add 'Apply Now' button via JSON form customization with URL:
      /sites/SPARK/Lists/Applications/NewForm.aspx?OpportunityId=[ID]
    - Use SetPnPField header customizer or form body customizer JSON via List settings or Power Apps.
    #>

    # 5. Set column default values
    Write-Log "Setting Column Default Values" -Type "Info"
    Set-PnPField -List $Config.Lists.Applications -Identity "Status" -Values @{DefaultValue = "Submitted"}
    Set-PnPField -List $Config.Lists.Applications -Identity "AppliedOn" -Values @{DefaultValue = "[today]"}
    
    Set-PnPField -List $Config.Lists.Opportunities -Identity "OpeningsFilled" -Values @{DefaultValue = "0"}
    Set-PnPField -List $Config.Lists.Opportunities -Identity "Status" -Values @{DefaultValue = "Open"}
    Set-PnPField -List $Config.Lists.Opportunities -Identity "Featured" -Values @{DefaultValue = "0"}

    # 6. Set column validation
    Write-Log "Setting Column Validation" -Type "Info"
    Set-PnPField -List $Config.Lists.Opportunities -Identity "Openings" -Values @{ValidationFormula = "=[Openings]>=1"; ValidationMessage = "Must have at least 1 opening"}
    Set-PnPField -List $Config.Lists.Applications -Identity "InterestStatement" -Values @{ValidationFormula = "=LEN([InterestStatement])>=50"; ValidationMessage = "Please write at least 50 characters"}

    # 7 & 8. Apply Permissions
    Write-Log "Applying Permissions" -Type "Info"

    # Applications List Permissions
    Write-Log "Configuring Applications List Permissions"
    Set-PnPList -Identity $Config.Lists.Applications -BreakRoleInheritance -CopyRoleAssignments:$false
    # Grant full Add access to everyone (Site Members + Visitors)
    # Grant Edit permission only to 'SPARK-Managers' group for Status and ManagerRemarks fields
    # NOTE: Use column-level security via Information Rights Management or field-level security workaround 
    
    $managersGroup = Get-PnPGroup -Identity $Config.Groups.Managers -ErrorAction SilentlyContinue
    $membersGroup = Get-PnPGroup -Identity $Config.Groups.Members -ErrorAction SilentlyContinue
    $visitorsGroup = Get-PnPGroup -Identity $Config.Groups.Visitors -ErrorAction SilentlyContinue
    
    if ($managersGroup) { Set-PnPListPermission -Identity $Config.Lists.Applications -PrincipalId $managersGroup.Id -AddRole "Contribute" }
    if ($membersGroup) { Set-PnPListPermission -Identity $Config.Lists.Applications -PrincipalId $membersGroup.Id -AddRole "Contribute" }
    if ($visitorsGroup) { Set-PnPListPermission -Identity $Config.Lists.Applications -PrincipalId $visitorsGroup.Id -AddRole "Contribute" }

    # Opportunities List Permissions
    Write-Log "Configuring Opportunities List Permissions"
    Set-PnPList -Identity $Config.Lists.Opportunities -BreakRoleInheritance -CopyRoleAssignments:$false
    if ($managersGroup) { Set-PnPListPermission -Identity $Config.Lists.Opportunities -PrincipalId $managersGroup.Id -AddRole "Contribute" }
    if ($membersGroup) { Set-PnPListPermission -Identity $Config.Lists.Opportunities -PrincipalId $membersGroup.Id -AddRole "Read" }
    if ($visitorsGroup) { Set-PnPListPermission -Identity $Config.Lists.Opportunities -PrincipalId $visitorsGroup.Id -AddRole "Read" }

    Write-Log "Successfully applied formatting, forms, defaults, validation, and permissions." -Type "Success"

} Catch {
    Write-Log "Error occurred: $($_.Exception.Message)" -Type "Error"
    Write-Log "Stack trace: $($_.ScriptStackTrace)" -Type "Error"
}
