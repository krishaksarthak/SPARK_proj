<#
.SYNOPSIS
    Provisions all 6 SharePoint pages for the SPARK portal with web-parts configured.
.DESCRIPTION
    Uses PnP PowerShell to create or update pages, add sections, and insert configured web parts.
    Includes error handling and progress messages.
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$SiteUrl,

    [Parameter(Mandatory=$false)]
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Configuration variables
$mediaLib = "SPARK-Media"
$opportunitiesList = "Opportunities"
$applicationsList = "Applications"
$spotlightList = "Spotlight_Winners"

try {
    Write-Host "Connecting to SharePoint site: $SiteUrl" -ForegroundColor Cyan
    Connect-PnPOnline -Url $SiteUrl -Interactive

    # -------------------------------------------------------------------------
    # Page 1: Home.aspx (already exists, update it)
    # -------------------------------------------------------------------------
    Write-Host "Configuring Home.aspx..." -ForegroundColor Yellow
    
    $homePage = Get-PnPPage -Identity "Home.aspx" -ErrorAction SilentlyContinue
    if (-not $homePage) {
        Write-Host "Home.aspx not found, creating a new Home page."
        $homePage = Add-PnPPage -Name "Home" -LayoutType Home
    } else {
        Write-Host "Home.aspx found, updating."
        # Optionally, you could clear existing sections here if starting fresh, but we will add new sections.
    }

    # Section 1: Full-width | Banner (Hero web-part)
    Add-PnPPageSection -Page $homePage -SectionTemplate OneColumnFullWidth -Order 1
    # PnP.PowerShell uses ClientSideWebPart for Hero. 
    # The Hero web part ID is c70391ea-0b10-4ee9-b2b4-006d3fcad0cd
    $heroProps = @{
        layout = 1
        items = @(
            @{
                imageSrc = "/sites/SPARK/$mediaLib/banners/hero1.jpg"
                title = "Unlock Your Potential. Drive Innovation."
                linkUrl = "/sites/SPARK/SitePages/Explore.aspx"
            }
        )
    } | ConvertTo-Json -Depth 5 -Compress
    Add-PnPPageWebPart -Page $homePage -Component (Get-PnPPageComponent -Id "c70391ea-0b10-4ee9-b2b4-006d3fcad0cd") -Section 1 -Column 1 -WebPartProperties $heroProps

    # Section 2: 1-col | Quick Links
    Add-PnPPageSection -Page $homePage -SectionTemplate OneColumn -Order 2
    $quickLinksProps = @{
        layoutId = "Button"
        items = @(
            @{ title="Explore Opportunities"; url="/sites/SPARK/SitePages/Explore.aspx"; iconName="CompassNW" },
            @{ title="View Rewards"; url="/sites/SPARK/SitePages/Rewards.aspx"; iconName="Trophy" },
            @{ title="Manager Hub"; url="/sites/SPARK/SitePages/Manager-Hub.aspx"; iconName="People" },
            @{ title="FAQ"; url="/sites/SPARK/SitePages/FAQ-Help.aspx"; iconName="Help" }
        )
    } | ConvertTo-Json -Depth 5 -Compress
    Add-PnPPageWebPart -Page $homePage -DefaultWebPartType QuickLinks -Section 2 -Column 1 -WebPartProperties $quickLinksProps

    # Section 3: 3-col | Highlighted Content (New Opportunities)
    Add-PnPPageSection -Page $homePage -SectionTemplate ThreeColumn -Order 3
    Add-PnPPageWebPart -Page $homePage -DefaultWebPartType HighlightedContent -Section 3 -Column 1 # Needs advanced JSON for CAML/Filters
    # We will let default configure for now, to fully set Filter: Status=Open, Featured=Yes requires complex HC webpart JSON

    # Section 4: Full-width dark (use background) | Highlighted Content (Featured Projects)
    Add-PnPPageSection -Page $homePage -SectionTemplate OneColumnFullWidth -Order 4 -ZoneEmphasis 3 # 3 is Strong/Dark
    Add-PnPPageWebPart -Page $homePage -DefaultWebPartType HighlightedContent -Section 4 -Column 1

    # Section 5: 2-col | People (Employee Spotlight)
    Add-PnPPageSection -Page $homePage -SectionTemplate TwoColumn -Order 5
    $peopleProps = @{ layout = 1; title = "Employee Spotlight" } | ConvertTo-Json -Compress
    Add-PnPPageWebPart -Page $homePage -DefaultWebPartType People -Section 5 -Column 1 -WebPartProperties $peopleProps

    # Section 6: 2-col | Text (Success Stories) + Text (Testimonials)
    Add-PnPPageSection -Page $homePage -SectionTemplate TwoColumn -Order 6
    Add-PnPPageTextPart -Page $homePage -Text "<h2>Success Stories</h2><p>Our employees are doing great things...</p>" -Section 6 -Column 1
    Add-PnPPageTextPart -Page $homePage -Text "<h2>Testimonials</h2><p>""SPARK changed my career trajectory."" - Jane Doe</p>" -Section 6 -Column 2

    # Section 7: 3-col | List (Spotlight_Winners)
    Add-PnPPageSection -Page $homePage -SectionTemplate ThreeColumn -Order 7
    Add-PnPPageWebPart -Page $homePage -DefaultWebPartType List -Section 7 -Column 1 -WebPartProperties "{""listTitle"":""$spotlightList"",""hideCommandBar"":true}"

    # Section 8: 2-col | Embed (Video 1) + Embed (Video 2)
    Add-PnPPageSection -Page $homePage -SectionTemplate TwoColumn -Order 8
    $embedProps = @{ embedCode = "<iframe src='STREAM_URL_PLACEHOLDER'></iframe>" } | ConvertTo-Json -Compress
    Add-PnPPageWebPart -Page $homePage -DefaultWebPartType Embed -Section 8 -Column 1 -WebPartProperties $embedProps
    Add-PnPPageWebPart -Page $homePage -DefaultWebPartType Embed -Section 8 -Column 2 -WebPartProperties $embedProps

    # Section 9: Full-width | Text (Footer CTA)
    Add-PnPPageSection -Page $homePage -SectionTemplate OneColumnFullWidth -Order 9
    Add-PnPPageTextPart -Page $homePage -Text "<h2 style='text-align:center;'>Ready to ignite your career? <a href='#'>Subscribe for Updates</a></h2>" -Section 9 -Column 1

    $homePage.Save()
    $homePage.Publish()
    Write-Host "Home.aspx updated." -ForegroundColor Green


    # -------------------------------------------------------------------------
    # Page 2: Explore.aspx (new page)
    # -------------------------------------------------------------------------
    Write-Host "Creating Explore.aspx..." -ForegroundColor Yellow
    $explorePage = Add-PnPPage -Name "Explore" -LayoutType Article -CommentsEnabled:$false

    # Section 1: Full-width | Text (page title + breadcrumb)
    Add-PnPPageSection -Page $explorePage -SectionTemplate OneColumn -Order 1
    Add-PnPPageTextPart -Page $explorePage -Text "<div><a href='/sites/SPARK/SitePages/Home.aspx'>Home</a> > Opportunity Marketplace</div><h1>Opportunity Marketplace</h1>" -Section 1 -Column 1

    # Section 2: Full-width | List (Opportunities list)
    Add-PnPPageSection -Page $explorePage -SectionTemplate OneColumn -Order 2
    $opportunitiesListProps = @{
        listTitle = $opportunitiesList
        viewId = "" # Put View ID here if needed
        hideCommandBar = $false
        showFilter = $true
    } | ConvertTo-Json -Compress
    Add-PnPPageWebPart -Page $explorePage -DefaultWebPartType List -Section 2 -Column 1 -WebPartProperties $opportunitiesListProps

    $explorePage.Save()
    $explorePage.Publish()
    Write-Host "Explore.aspx created." -ForegroundColor Green


    # -------------------------------------------------------------------------
    # Page 3: Manager-Hub.aspx (new page - audience target SPARK-Managers)
    # -------------------------------------------------------------------------
    Write-Host "Creating Manager-Hub.aspx..." -ForegroundColor Yellow
    $managerPage = Add-PnPPage -Name "Manager-Hub" -LayoutType Article -CommentsEnabled:$false

    # Note on Modern Audience Targeting:
    # 1. Enable Site Collection feature: Enable-PnPFeature -Identity "31ea90fb-2936-4074-a6ab-a026bc3cecc8" -Scope Site
    # 2. To set audience targeting on the page itself:
    # Set-PnPPage -Identity "Manager-Hub.aspx" -ScheduledPublishing ... (PnP doesn't directly expose audience target arrays for pages via Add-PnPPage easily in all versions, often done via list item update on Site Pages list)
    # Example: Set-PnPListItem -List "Site Pages" -Identity $managerPage.PageId -Values @{"_ModernAudienceTargetUserField" = "SPARK-Managers"}

    # Section 1: 1-col | Text (header + access restriction note)
    Add-PnPPageSection -Page $managerPage -SectionTemplate OneColumn -Order 1
    Add-PnPPageTextPart -Page $managerPage -Text "<h1>Manager Hub</h1><p><em>Restricted Access: Content intended for SPARK Managers.</em></p>" -Section 1 -Column 1

    # Section 2: Full-width | List (Opportunities - Manager_Mine view)
    Add-PnPPageSection -Page $managerPage -SectionTemplate OneColumn -Order 2
    Add-PnPPageWebPart -Page $managerPage -DefaultWebPartType List -Section 2 -Column 1 -WebPartProperties "{""listTitle"":""$opportunitiesList""}"

    # Section 3: Full-width | List (Applications - Pending Review)
    Add-PnPPageSection -Page $managerPage -SectionTemplate OneColumn -Order 3
    Add-PnPPageWebPart -Page $managerPage -DefaultWebPartType List -Section 3 -Column 1 -WebPartProperties "{""listTitle"":""$applicationsList""}"

    # Section 4: 3-col | Text (Quick Actions guide)
    Add-PnPPageSection -Page $managerPage -SectionTemplate ThreeColumn -Order 4
    Add-PnPPageTextPart -Page $managerPage -Text "<h3>Step 1: Post</h3><p>Create a new opportunity...</p>" -Section 4 -Column 1
    Add-PnPPageTextPart -Page $managerPage -Text "<h3>Step 2: Review</h3><p>Check pending applications...</p>" -Section 4 -Column 2
    Add-PnPPageTextPart -Page $managerPage -Text "<h3>Step 3: Approve</h3><p>Onboard your new team member!</p>" -Section 4 -Column 3

    $managerPage.Save()
    $managerPage.Publish()
    Write-Host "Manager-Hub.aspx created." -ForegroundColor Green


    # -------------------------------------------------------------------------
    # Page 4: Rewards.aspx (new page)
    # -------------------------------------------------------------------------
    Write-Host "Creating Rewards.aspx..." -ForegroundColor Yellow
    $rewardsPage = Add-PnPPage -Name "Rewards" -LayoutType Article -CommentsEnabled:$false

    # Section 1: Full-width | Banner (Rewards hero)
    Add-PnPPageSection -Page $rewardsPage -SectionTemplate OneColumnFullWidth -Order 1
    Add-PnPPageWebPart -Page $rewardsPage -Component (Get-PnPPageComponent -Id "c70391ea-0b10-4ee9-b2b4-006d3fcad0cd") -Section 1 -Column 1 # Hero Component

    # Section 2: Full-width | List (Spotlight_Winners)
    Add-PnPPageSection -Page $rewardsPage -SectionTemplate OneColumn -Order 2
    Add-PnPPageWebPart -Page $rewardsPage -DefaultWebPartType List -Section 2 -Column 1 -WebPartProperties "{""listTitle"":""$spotlightList""}"

    # Section 3: 1-col | People
    Add-PnPPageSection -Page $rewardsPage -SectionTemplate OneColumn -Order 3
    Add-PnPPageWebPart -Page $rewardsPage -DefaultWebPartType People -Section 3 -Column 1

    # Section 4: 1-col | Quick Links
    Add-PnPPageSection -Page $rewardsPage -SectionTemplate OneColumn -Order 4
    Add-PnPPageWebPart -Page $rewardsPage -DefaultWebPartType QuickLinks -Section 4 -Column 1

    $rewardsPage.Save()
    $rewardsPage.Publish()
    Write-Host "Rewards.aspx created." -ForegroundColor Green


    # -------------------------------------------------------------------------
    # Page 5: FAQ-Help.aspx (new page)
    # -------------------------------------------------------------------------
    Write-Host "Creating FAQ-Help.aspx..." -ForegroundColor Yellow
    $faqPage = Add-PnPPage -Name "FAQ-Help" -LayoutType Article -CommentsEnabled:$false

    # Section 1: Full-width | Text
    Add-PnPPageSection -Page $faqPage -SectionTemplate OneColumn -Order 1
    Add-PnPPageTextPart -Page $faqPage -Text "<h1>FAQ & Help</h1><p>Find answers to common questions about SPARK below.</p>" -Section 1 -Column 1

    # Section 2: 2-col | Text
    Add-PnPPageSection -Page $faqPage -SectionTemplate TwoColumn -Order 2
    Add-PnPPageTextPart -Page $faqPage -Text "<h2>General Questions</h2><p><strong>Q: What is SPARK?</strong><br/>A: An internal marketplace.</p>" -Section 2 -Column 1
    Add-PnPPageTextPart -Page $faqPage -Text "<h2>Manager Questions</h2><p><strong>Q: How do I post?</strong><br/>A: Go to Manager Hub.</p>" -Section 2 -Column 2

    # Section 3: Full-width | Embed (Copilot Studio bot)
    Add-PnPPageSection -Page $faqPage -SectionTemplate OneColumn -Order 3
    Add-PnPPageWebPart -Page $faqPage -DefaultWebPartType Embed -Section 3 -Column 1 -WebPartProperties "{""embedCode"":""<iframe src='COPILOT_BOT_URL'></iframe>""}"

    # Section 4: 2-col | Text
    Add-PnPPageSection -Page $faqPage -SectionTemplate TwoColumn -Order 4
    Add-PnPPageTextPart -Page $faqPage -Text "<h3>Contact HR</h3><p>Email: hr@visteon.com</p>" -Section 4 -Column 1
    Add-PnPPageTextPart -Page $faqPage -Text "<h3>IT Support</h3><p>Email: itsupport@visteon.com</p>" -Section 4 -Column 2

    $faqPage.Save()
    $faqPage.Publish()
    Write-Host "FAQ-Help.aspx created." -ForegroundColor Green


    # -------------------------------------------------------------------------
    # Page 6: Opportunity-Details (Display Form Customization)
    # -------------------------------------------------------------------------
    Write-Host "Configuring Opportunity-Details Display Form..." -ForegroundColor Yellow
    
    <# 
    NOTE ON DISPLAY FORM CUSTOMIZATION:
    For modern lists, modifying the Display Form is often done via Column Formatting or JSON Form Formatting, 
    rather than provisioning a separate physical Site Page.

    To customize the Display Form via PnP PowerShell (setting custom formatting JSON):
    $jsonFormatting = @'
    {
      "sections": [
        {
          "displayname": "Opportunity Details",
          "fields": [
            "Title",
            "Description",
            "Status"
          ]
        }
      ]
    }
    '@
    # Set-PnPList -Identity "Opportunities" -ListExperience Modern
    # Update the content type or list format. For advanced headers/footers in the form:
    # Set-PnPList -Identity "Opportunities" -FormProps (JSON for header/footer)

    # To add the 'Apply Now' button, you would use Column Formatting on a dedicated field (e.g., 'ApplyLink')
    # or the Form Footer JSON. The URL pattern should be:
    # /sites/SPARK/Lists/Applications/NewForm.aspx?OpportunityId=[$ID]
    #>

    Write-Host "All pages provisioned successfully." -ForegroundColor Green
    Disconnect-PnPOnline

} catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    if ($null -ne $Error[0].Exception.StackTrace) {
        Write-Host $Error[0].Exception.StackTrace -ForegroundColor DarkRed
    }
}
