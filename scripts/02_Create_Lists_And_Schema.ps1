<#
.SYNOPSIS
    Provisions Microsoft Lists and their schema for the SPARK Platform.
.DESCRIPTION
    Creates 4 lists: Opportunities, Applications, Spotlight_Winners, Subscribers.
    Adds all required fields and views using PnP PowerShell.
#>

$ErrorActionPreference = "Stop"

# ==========================================
# Configuration
# ==========================================
$SiteUrl = "https://visteon.sharepoint.com/sites/SPARK" # Update as needed

try {
    Write-Host "Connecting to $SiteUrl..." -ForegroundColor Cyan
    # Connect-PnPOnline -Url $SiteUrl -Interactive # Assuming connection is already established or interactive auth
    
    Write-Host "Starting list provisioning..." -ForegroundColor Cyan

    # Helper function to create list if not exists
    function Ensure-List {
        param (
            [string]$ListName
        )
        $list = Get-PnPList -Identity $ListName -ErrorAction SilentlyContinue
        if (-not $list) {
            Write-Host "Creating list: $ListName" -ForegroundColor Green
            $list = New-PnPList -Title $ListName -Template GenericList -Url "Lists/$ListName" -EnableVersioning
        } else {
            Write-Host "List $ListName already exists." -ForegroundColor Gray
        }
        return $list
    }

    # ==========================================
    # 1. Opportunities List
    # ==========================================
    $listName = "Opportunities"
    $list = Ensure-List -ListName $listName

    Write-Host "Adding columns to $listName..." -ForegroundColor Yellow
    
    # Title is default, ensure it's required
    Set-PnPField -List $listName -Identity "Title" -Values @{Required=$true} -ErrorAction SilentlyContinue
    
    $descXml = '<Field Type="Note" DisplayName="Description" Required="TRUE" RichText="TRUE" RichTextMode="FullHtml" StaticName="Description" Name="Description" />'
    Add-PnPFieldFromXml -List $listName -FieldXml $descXml -ErrorAction SilentlyContinue

    Add-PnPField -List $listName -DisplayName "Category" -InternalName "Category" -Type Choice -Choices "Innovation", "Process Improvement", "Learning Sprint", "Client POC" -Required -AddToDefaultView -ErrorAction SilentlyContinue
    
    $techXml = '<Field Type="MultiChoice" DisplayName="Technology" Required="FALSE" StaticName="Technology" Name="Technology"><CHOICES><CHOICE>Python</CHOICE><CHOICE>AI/ML</CHOICE><CHOICE>SharePoint</CHOICE><CHOICE>Power Platform</CHOICE><CHOICE>.NET</CHOICE><CHOICE>Embedded C</CHOICE><CHOICE>Power BI</CHOICE><CHOICE>UI/UX</CHOICE></CHOICES></Field>'
    Add-PnPFieldFromXml -List $listName -FieldXml $techXml -ErrorAction SilentlyContinue

    Add-PnPField -List $listName -DisplayName "RequiredSkills" -InternalName "RequiredSkills" -Type Note -AddToDefaultView -ErrorAction SilentlyContinue
    Add-PnPField -List $listName -DisplayName "Team" -InternalName "Team" -Type Text -AddToDefaultView -ErrorAction SilentlyContinue
    Add-PnPField -List $listName -DisplayName "Location" -InternalName "Location" -Type Choice -Choices "Chennai", "Bangalore", "Goa", "Remote", "Hybrid" -AddToDefaultView -ErrorAction SilentlyContinue
    Add-PnPField -List $listName -DisplayName "Duration" -InternalName "Duration" -Type Text -AddToDefaultView -ErrorAction SilentlyContinue
    Add-PnPField -List $listName -DisplayName "ExpectedEffort" -InternalName "ExpectedEffort" -Type Choice -Choices "2 hrs/week", "5 hrs/week", "Full Sprint" -AddToDefaultView -ErrorAction SilentlyContinue
    
    $openingsXml = '<Field Type="Number" DisplayName="Openings" Required="FALSE" Min="1" StaticName="Openings" Name="Openings" />'
    Add-PnPFieldFromXml -List $listName -FieldXml $openingsXml -ErrorAction SilentlyContinue

    $openingsFilledXml = '<Field Type="Number" DisplayName="OpeningsFilled" Required="FALSE" StaticName="OpeningsFilled" Name="OpeningsFilled"><Default>0</Default></Field>'
    Add-PnPFieldFromXml -List $listName -FieldXml $openingsFilledXml -ErrorAction SilentlyContinue

    Add-PnPField -List $listName -DisplayName "MentorName" -InternalName "MentorName" -Type User -AddToDefaultView -ErrorAction SilentlyContinue
    Add-PnPField -List $listName -DisplayName "MentorBio" -InternalName "MentorBio" -Type Note -AddToDefaultView -ErrorAction SilentlyContinue
    
    $statusXml = '<Field Type="Choice" DisplayName="Status" Required="FALSE" Format="Dropdown" StaticName="Status" Name="Status"><Default>Open</Default><CHOICES><CHOICE>Draft</CHOICE><CHOICE>Open</CHOICE><CHOICE>Under Review</CHOICE><CHOICE>Hold</CHOICE><CHOICE>Closed</CHOICE><CHOICE>Completed</CHOICE></CHOICES></Field>'
    Add-PnPFieldFromXml -List $listName -FieldXml $statusXml -ErrorAction SilentlyContinue

    Add-PnPField -List $listName -DisplayName "StartDate" -InternalName "StartDate" -Type DateTime -AddToDefaultView -ErrorAction SilentlyContinue
    Add-PnPField -List $listName -DisplayName "EndDate" -InternalName "EndDate" -Type DateTime -AddToDefaultView -ErrorAction SilentlyContinue
    
    $thumbnailXml = '<Field Type="Thumbnail" DisplayName="Thumbnail" StaticName="Thumbnail" Name="Thumbnail" />'
    Add-PnPFieldFromXml -List $listName -FieldXml $thumbnailXml -ErrorAction SilentlyContinue
    
    Add-PnPField -List $listName -DisplayName "Featured" -InternalName "Featured" -Type Boolean -AddToDefaultView -ErrorAction SilentlyContinue

    Write-Host "Creating views for $listName..." -ForegroundColor Yellow
    Add-PnPView -List $listName -Title "Open Now" -Fields "Title", "Category", "Technology", "Status" -Query "<Where><Eq><FieldRef Name='Status'/><Value Type='Choice'>Open</Value></Eq></Where>" -ErrorAction SilentlyContinue
    # By Technology
    Add-PnPView -List $listName -Title "By Technology" -Fields "Title", "Category", "Technology", "Status" -Query "<GroupBy Collapse='TRUE'><FieldRef Name='Technology' /></GroupBy>" -ErrorAction SilentlyContinue
    # Manager_Mine
    Add-PnPView -List $listName -Title "Manager_Mine" -Fields "Title", "Category", "Technology", "Status" -Query "<Where><Eq><FieldRef Name='MentorName'/><Value Type='Integer'><UserID/></Value></Eq></Where>" -ErrorAction SilentlyContinue
    # Completed
    Add-PnPView -List $listName -Title "Completed" -Fields "Title", "Category", "Technology", "Status" -Query "<Where><Eq><FieldRef Name='Status'/><Value Type='Choice'>Completed</Value></Eq></Where>" -ErrorAction SilentlyContinue

    # ==========================================
    # 2. Applications List
    # ==========================================
    $listName = "Applications"
    $list = Ensure-List -ListName $listName

    Write-Host "Adding columns to $listName..." -ForegroundColor Yellow
    
    $oppList = Get-PnPList -Identity "Opportunities"
    Add-PnPField -List $listName -DisplayName "Opportunity" -InternalName "Opportunity" -Type Lookup -List $oppList.Id -LookupField "Title" -AddToDefaultView -ErrorAction SilentlyContinue
    Add-PnPField -List $listName -DisplayName "Opportunity:MentorName" -InternalName "Opportunity_MentorName" -Type Lookup -List $oppList.Id -LookupField "MentorName" -AddToDefaultView -ErrorAction SilentlyContinue
    
    Add-PnPField -List $listName -DisplayName "Applicant" -InternalName "Applicant" -Type User -AddToDefaultView -ErrorAction SilentlyContinue
    Add-PnPField -List $listName -DisplayName "EmployeeID" -InternalName "EmployeeID" -Type Text -Required -AddToDefaultView -ErrorAction SilentlyContinue
    Add-PnPField -List $listName -DisplayName "CurrentTeam" -InternalName "CurrentTeam" -Type Text -Required -AddToDefaultView -ErrorAction SilentlyContinue
    Add-PnPField -List $listName -DisplayName "Manager" -InternalName "Manager" -Type User -Required -AddToDefaultView -ErrorAction SilentlyContinue
    Add-PnPField -List $listName -DisplayName "Skills" -InternalName "Skills" -Type Note -AddToDefaultView -ErrorAction SilentlyContinue
    Add-PnPField -List $listName -DisplayName "InterestStatement" -InternalName "InterestStatement" -Type Note -Required -AddToDefaultView -ErrorAction SilentlyContinue
    
    Add-PnPField -List $listName -DisplayName "Availability" -InternalName "Availability" -Type Choice -Choices "Immediate", "2hrs/week", "5hrs/week", "Next Sprint" -AddToDefaultView -ErrorAction SilentlyContinue
    
    $statusXml = '<Field Type="Choice" DisplayName="Status" Required="FALSE" Format="Dropdown" StaticName="Status" Name="Status"><Default>Submitted</Default><CHOICES><CHOICE>Submitted</CHOICE><CHOICE>Under Review</CHOICE><CHOICE>Discussion Scheduled</CHOICE><CHOICE>Shortlisted</CHOICE><CHOICE>Rejected</CHOICE><CHOICE>Onboarded</CHOICE><CHOICE>Withdrawn</CHOICE></CHOICES></Field>'
    Add-PnPFieldFromXml -List $listName -FieldXml $statusXml -ErrorAction SilentlyContinue

    Add-PnPField -List $listName -DisplayName "ManagerRemarks" -InternalName "ManagerRemarks" -Type Note -AddToDefaultView -ErrorAction SilentlyContinue
    
    $appliedOnXml = '<Field Type="DateTime" DisplayName="AppliedOn" StaticName="AppliedOn" Name="AppliedOn"><Default>[today]</Default></Field>'
    Add-PnPFieldFromXml -List $listName -FieldXml $appliedOnXml -ErrorAction SilentlyContinue

    Write-Host "Creating views for $listName..." -ForegroundColor Yellow
    Add-PnPView -List $listName -Title "By Opportunity" -Fields "Title", "Opportunity", "Applicant", "Status" -Query "<OrderBy><FieldRef Name='Created' Ascending='FALSE' /></OrderBy><GroupBy Collapse='TRUE'><FieldRef Name='Opportunity' /></GroupBy>" -ErrorAction SilentlyContinue
    Add-PnPView -List $listName -Title "My Applications" -Fields "Title", "Opportunity", "Status" -Query "<Where><Eq><FieldRef Name='Applicant'/><Value Type='Integer'><UserID/></Value></Eq></Where>" -ErrorAction SilentlyContinue
    Add-PnPView -List $listName -Title "Pending Review" -Fields "Title", "Opportunity", "Applicant", "Status" -Query "<Where><In><FieldRef Name='Status'/><Values><Value Type='Choice'>Submitted</Value><Value Type='Choice'>Under Review</Value></Values></In></Where>" -ErrorAction SilentlyContinue

    # ==========================================
    # 3. Spotlight_Winners List
    # ==========================================
    $listName = "Spotlight_Winners"
    $list = Ensure-List -ListName $listName

    Write-Host "Adding columns to $listName..." -ForegroundColor Yellow
    
    Add-PnPField -List $listName -DisplayName "Person" -InternalName "Person" -Type User -AddToDefaultView -ErrorAction SilentlyContinue
    Add-PnPField -List $listName -DisplayName "Award" -InternalName "Award" -Type Choice -Choices "Rising Star", "Innovation Champion", "Best Collaborator", "Performer of Week", "Performer of Month" -AddToDefaultView -ErrorAction SilentlyContinue
    
    Add-PnPField -List $listName -DisplayName "Project" -InternalName "Project" -Type Lookup -List $oppList.Id -LookupField "Title" -AddToDefaultView -ErrorAction SilentlyContinue
    
    $storyXml = '<Field Type="Note" DisplayName="Story" RichText="TRUE" RichTextMode="FullHtml" StaticName="Story" Name="Story" />'
    Add-PnPFieldFromXml -List $listName -FieldXml $storyXml -ErrorAction SilentlyContinue

    Add-PnPField -List $listName -DisplayName "Month" -InternalName "Month" -Type DateTime -AddToDefaultView -ErrorAction SilentlyContinue
    
    $photoXml = '<Field Type="Thumbnail" DisplayName="Photo" StaticName="Photo" Name="Photo" />'
    Add-PnPFieldFromXml -List $listName -FieldXml $photoXml -ErrorAction SilentlyContinue

    # ==========================================
    # 4. Subscribers List
    # ==========================================
    $listName = "Subscribers"
    $list = Ensure-List -ListName $listName

    Write-Host "Adding columns to $listName..." -ForegroundColor Yellow
    
    Add-PnPField -List $listName -DisplayName "Person" -InternalName "Person" -Type User -AddToDefaultView -ErrorAction SilentlyContinue
    
    $interestTechXml = '<Field Type="MultiChoice" DisplayName="InterestTech" Required="FALSE" StaticName="InterestTech" Name="InterestTech"><CHOICES><CHOICE>Python</CHOICE><CHOICE>AI/ML</CHOICE><CHOICE>SharePoint</CHOICE><CHOICE>Power Platform</CHOICE><CHOICE>.NET</CHOICE><CHOICE>Embedded C</CHOICE><CHOICE>Power BI</CHOICE><CHOICE>UI/UX</CHOICE></CHOICES></Field>'
    Add-PnPFieldFromXml -List $listName -FieldXml $interestTechXml -ErrorAction SilentlyContinue

    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "Provisioning completed successfully." -ForegroundColor Green
}
catch {
    Write-Host "An error occurred during provisioning: $_" -ForegroundColor Red
}
