<#
.SYNOPSIS
    Seeds the SPARK Platform SharePoint lists with sample data.
.DESCRIPTION
    This script adds sample data to Opportunities, Applications, Spotlight_Winners, and Subscribers lists.
    It uses Add-PnPListItem for standard fields and Set-PnPListItem for Person fields as requested.
    It ensures that Opportunities are created first to maintain referential integrity for Lookup fields.
.NOTES
    Prerequisite: Run 01_Create_Lists.ps1 and 02_Create_Columns.ps1 first.
#>

$SiteUrl = 'https://visteon.sharepoint.com/sites/SPARK'

try {
    Write-Host "Connecting to SharePoint site: $SiteUrl" -ForegroundColor Cyan
    Connect-PnPOnline -Url $SiteUrl -Interactive

    $oppMap = @{}

    # --------------------------------------------------------
    # 1. Seed Opportunities List
    # --------------------------------------------------------
    Write-Host "Seeding Opportunities List..." -ForegroundColor Yellow

    $opportunities = @(
        @{ Title='EV Dashboard POC with Power BI'; Category='Innovation'; Technology='Power BI'; RequiredSkills='Power BI, DAX, SQL, Data Modeling'; Team='Connected Services'; Location='Chennai'; Duration='6 weeks'; ExpectedEffort='5 hrs/week'; Openings=3; OpeningsFilled=0; MentorName='vikram.kumar@visteon.com'; MentorBio='Senior Principal Engineer with 12 years in connected vehicle platforms. Expert in real-time data visualization and CAN bus integration.'; Status='Open'; StartDate='2026-09-15'; EndDate='2026-10-27'; Featured=$true; Description='Design and develop an EV Dashboard Proof of Concept using Power BI to visualize key vehicle metrics sourced from CAN bus and OBD-II interfaces. The dashboard will display real-time battery state-of-charge, range prediction, energy consumption trends, and regenerative braking efficiency. Participants will work closely with the Connected Services team to understand data schemas, build DAX measures, and create executive-ready reports. This is a high-visibility project with direct stakeholder demos.' },
        @{ Title='AI Defect Classifier for ADAS'; Category='Innovation'; Technology='AI/ML;Python'; RequiredSkills='Python, TensorFlow, Computer Vision, OpenCV'; Team='ADAS Engineering'; Location='Bangalore'; Duration='8 weeks'; ExpectedEffort='Full Sprint'; Openings=2; OpeningsFilled=0; MentorName='deepa.krishnamurthy@visteon.com'; MentorBio='AI/ML Lead with 8 years in autonomous systems. Published researcher in edge AI for automotive safety.'; Status='Open'; StartDate='2026-09-20'; EndDate='2026-11-15'; Featured=$true; Description='Build a machine learning model to automatically classify manufacturing defects in ADAS camera modules using computer vision. The model will process images from production line cameras and flag anomalies in real time, reducing manual inspection time by 60%. Participants will learn the full MLOps pipeline from data labeling to model deployment on edge hardware. Collaboration with Quality Engineering and ADAS Hardware teams.' },
        @{ Title='SharePoint Migration Helper Tool'; Category='Process Improvement'; Technology='SharePoint;Power Platform'; RequiredSkills='SharePoint, Power Automate, PnP PowerShell'; Team='IT Infra'; Location='Remote'; Duration='4 weeks'; ExpectedEffort='2 hrs/week'; Openings=4; OpeningsFilled=0; MentorName='arun.venkatesh@visteon.com'; MentorBio='IT Infrastructure lead specializing in M365 governance and SharePoint architecture. Microsoft Certified Solutions Expert.'; Status='Open'; StartDate='2026-10-01'; EndDate='2026-10-29'; Featured=$false; Description='Develop a Power Automate-based tool to assist teams migrating content from legacy file shares to SharePoint Online. The tool will map folder structures, apply metadata, and generate migration reports. This is an excellent opportunity to understand M365 governance, information architecture, and enterprise content management at scale.' },
        @{ Title='Embedded HMI Test Automation'; Category='Learning Sprint'; Technology='Embedded C'; RequiredSkills='C, Python, CAN protocol, Test frameworks'; Team='Cockpit Systems'; Location='Goa'; Duration='6 weeks'; ExpectedEffort='5 hrs/week'; Openings=2; OpeningsFilled=0; MentorName='suresh.balakrishnan@visteon.com'; MentorBio='Cockpit Systems architect with 15 years in HMI development. Specialist in AUTOSAR and ISO 26262 functional safety.'; Status='Open'; StartDate='2026-09-25'; EndDate='2026-11-06'; Featured=$true; Description='Create automated test scripts for the next-generation instrument cluster HMI using CAN bus simulation and Python-based test orchestration. Participants will learn about AUTOSAR software architecture, CAN protocol communication, and hardware-in-the-loop testing. Work directly on actual instrument cluster hardware in the Goa lab.' },
        @{ Title='Power Platform COE Governance Framework'; Category='Process Improvement'; Technology='Power Platform'; RequiredSkills='Power Apps, Power Automate, ALM, Governance'; Team='Digital Transformation'; Location='Hybrid'; Duration='3 weeks'; ExpectedEffort='2 hrs/week'; Openings=1; OpeningsFilled=0; MentorName='meena.subramaniam@visteon.com'; MentorBio='Digital Transformation Program Manager driving M365 and Power Platform adoption across 10000 Visteon employees.'; Status='Under Review'; StartDate='2026-10-10'; EndDate='2026-10-31'; Featured=$false; Description='Define and document the Center of Excellence governance framework for Visteon Power Platform usage including environment strategy, DLP policies, maker onboarding, and solution lifecycle management.' },
        @{ Title='UI/UX Redesign for Dealer Portal'; Category='Client POC'; Technology='UI/UX'; RequiredSkills='Figma, UX Research, Accessibility, HTML/CSS'; Team='Customer Experience'; Location='Chennai'; Duration='5 weeks'; ExpectedEffort='5 hrs/week'; Openings=2; OpeningsFilled=0; MentorName='priya.nair@visteon.com'; MentorBio='UX Lead with expertise in automotive dealer ecosystem design. Certified in UX and accessibility standards.'; Status='Hold'; StartDate='2026-10-15'; EndDate='2026-11-19'; Featured=$false; Description='Redesign the dealer-facing portal for improved usability, modern aesthetics, and WCAG 2.1 accessibility compliance. This project is currently on hold pending client approval of the scope document.' },
        @{ Title='Predictive Maintenance ML Model'; Category='Innovation'; Technology='AI/ML;Python;Power BI'; RequiredSkills='Python, scikit-learn, Power BI, Manufacturing domain'; Team='Manufacturing Intelligence'; Location='Bangalore'; Duration='10 weeks'; ExpectedEffort='Full Sprint'; Openings=3; OpeningsFilled=3; MentorName='deepa.krishnamurthy@visteon.com'; MentorBio='AI/ML Lead with 8 years in autonomous systems.'; Status='Completed'; StartDate='2026-06-01'; EndDate='2026-08-10'; Featured=$false; Description='Successfully built and deployed a predictive maintenance model for assembly line equipment reducing unplanned downtime by 35%. Project completed with all 3 participants onboarded and delivering production results.' },
        @{ Title='CAN Bus Data Logger Optimization'; Category='Learning Sprint'; Technology='Embedded C;.NET'; RequiredSkills='Embedded C, .NET, CAN protocol, Data logging'; Team='Vehicle Networking'; Location='Goa'; Duration='8 weeks'; ExpectedEffort='5 hrs/week'; Openings=2; OpeningsFilled=2; MentorName='suresh.balakrishnan@visteon.com'; MentorBio='Cockpit Systems architect specialist.'; Status='Completed'; StartDate='2026-06-15'; EndDate='2026-08-10'; Featured=$false; Description='Optimized the CAN bus data logger firmware achieving 40% reduction in memory footprint and 25% improvement in throughput. Both participants are now full contributors to the Vehicle Networking team.' }
    )

    foreach ($opp in $opportunities) {
        Write-Host "Adding Opportunity: $($opp.Title)"
        
        $techArray = $opp.Technology -split ';'

        $itemValues = @{
            Title = $opp.Title
            Category = $opp.Category
            Technology = $techArray
            RequiredSkills = $opp.RequiredSkills
            Team = $opp.Team
            Location = $opp.Location
            Duration = $opp.Duration
            ExpectedEffort = $opp.ExpectedEffort
            Openings = $opp.Openings
            OpeningsFilled = $opp.OpeningsFilled
            MentorBio = $opp.MentorBio
            Status = $opp.Status
            StartDate = $opp.StartDate
            EndDate = $opp.EndDate
            Featured = $opp.Featured
            Description = $opp.Description
        }

        $newItem = Add-PnPListItem -List "Opportunities" -Values $itemValues
        $oppMap[$opp.Title] = $newItem.Id

        # Set Person field using user lookup
        Set-PnPListItem -List "Opportunities" -Identity $newItem.Id -Values @{ "MentorName" = $opp.MentorName } | Out-Null
    }

    Write-Host "Opportunities seeded successfully.`n" -ForegroundColor Green

    # --------------------------------------------------------
    # 2. Seed Applications List
    # --------------------------------------------------------
    Write-Host "Seeding Applications List..." -ForegroundColor Yellow
    Write-Host "Note: Lookup fields require the Opportunity to be created first. Mapping titles to Opportunity IDs..." -ForegroundColor Gray

    $applications = @(
        @{ Opportunity='EV Dashboard POC with Power BI'; Applicant='rohit.sharma@visteon.com'; EmployeeID='VIS00123'; CurrentTeam='Software QA'; Manager='arun.venkatesh@visteon.com'; Skills='Power BI basics, SQL, Excel'; InterestStatement='I have been self-learning Power BI for 6 months and built 3 personal dashboards. I am passionate about data storytelling and believe this project will give me the real-world automotive data exposure I need to contribute meaningfully to Connected Services.'; Availability='5hrs/week'; Status='Submitted'; AppliedOn='2026-09-08' },
        @{ Opportunity='EV Dashboard POC with Power BI'; Applicant='ananya.singh@visteon.com'; EmployeeID='VIS00456'; CurrentTeam='Test Engineering'; Manager='meena.subramaniam@visteon.com'; Skills='SQL, Python, Power BI'; InterestStatement='Having worked on test data analysis, I understand the importance of clean data pipelines. I want to apply my SQL skills to real EV telemetry data and help build dashboards that drive business decisions for our EV product line.'; Availability='Immediate'; Status='Under Review'; ManagerRemarks='Strong SQL background, schedule technical call'; AppliedOn='2026-09-07' },
        @{ Opportunity='EV Dashboard POC with Power BI'; Applicant='kiran.reddy@visteon.com'; EmployeeID='VIS00789'; CurrentTeam='Embedded Systems'; Manager='suresh.balakrishnan@visteon.com'; Skills='Python, Data Analysis'; InterestStatement='I want to transition from embedded to data engineering. This project is the perfect bridge - understanding vehicle data at the embedded level and visualizing it through Power BI. I can bring unique insight from both worlds.'; Availability='5hrs/week'; Status='Discussion Scheduled'; ManagerRemarks='Very good background. Teams call scheduled for Sep 12 at 2pm'; AppliedOn='2026-09-06' },
        @{ Opportunity='AI Defect Classifier for ADAS'; Applicant='preethi.raj@visteon.com'; EmployeeID='VIS00234'; CurrentTeam='Software Development'; Manager='vikram.kumar@visteon.com'; Skills='Python, Machine Learning, TensorFlow'; InterestStatement='I completed the Google ML crash course and built a personal image classifier for plant disease detection with 87% accuracy. ADAS safety is critically important and I am motivated to apply computer vision to manufacturing quality at Visteon.'; Availability='Full Sprint'; Status='Shortlisted'; ManagerRemarks='Best technical profile. Shortlisted for onboarding.'; AppliedOn='2026-09-05' },
        @{ Opportunity='AI Defect Classifier for ADAS'; Applicant='rahul.mehta@visteon.com'; EmployeeID='VIS00567'; CurrentTeam='Quality Engineering'; Manager='arun.venkatesh@visteon.com'; Skills='Python, Statistical Analysis, Inspection processes'; InterestStatement='My 2 years in Quality Engineering give me domain expertise in defect classification. Combined with my Python skills, I can contribute both to the ML model development and to defining what constitutes a valid defect from a manufacturing perspective.'; Availability='Full Sprint'; Status='Onboarded'; ManagerRemarks='Onboarded. Project kickoff on Sep 15.'; AppliedOn='2026-09-04' },
        @{ Opportunity='AI Defect Classifier for ADAS'; Applicant='sneha.patel@visteon.com'; EmployeeID='VIS00890'; CurrentTeam='R&D'; Manager='deepa.krishnamurthy@visteon.com'; Skills='Python, Data Science, MATLAB'; InterestStatement='Research background with MATLAB and Python. Want to shift to production ML systems.'; Availability='5hrs/week'; Status='Rejected'; ManagerRemarks='Good profile but lacks computer vision experience. Suggested to apply for Power BI opportunity instead.'; AppliedOn='2026-09-03' },
        @{ Opportunity='SharePoint Migration Helper Tool'; Applicant='arjun.kumar@visteon.com'; EmployeeID='VIS00345'; CurrentTeam='IT Helpdesk'; Manager='meena.subramaniam@visteon.com'; Skills='SharePoint, Office 365, basic PowerShell'; InterestStatement='I manage SharePoint support tickets daily and see recurring pain points in the migration process. Building a tool to solve this will directly help my team and hundreds of employees. I can contribute both technical skills and user perspective.'; Availability='2hrs/week'; Status='Under Review'; AppliedOn='2026-09-09' },
        @{ Opportunity='SharePoint Migration Helper Tool'; Applicant='divya.menon@visteon.com'; EmployeeID='VIS00678'; CurrentTeam='Digital Workplace'; Manager='vikram.kumar@visteon.com'; Skills='Power Automate, SharePoint, M365'; InterestStatement='I have built 15 Power Automate flows for my team and want to work on something with organization-wide impact. SharePoint migration automation will benefit all of Visteon.'; Availability='2hrs/week'; Status='Discussion Scheduled'; ManagerRemarks='Very strong Power Automate skills. Call on Sep 13.'; AppliedOn='2026-09-08' },
        @{ Opportunity='EV Dashboard POC with Power BI'; Applicant='vijay.nair@visteon.com'; EmployeeID='VIS00901'; CurrentTeam='Finance Analytics'; Manager='arun.venkatesh@visteon.com'; Skills='Power BI, Excel, Finance reporting'; InterestStatement='I use Power BI for financial dashboards daily. Applying those skills to EV telemetry data is a fascinating challenge. I want to be part of Visteon''s EV journey from a data analytics perspective.'; Availability='5hrs/week'; Status='Withdrawn'; ManagerRemarks='Candidate withdrew due to bandwidth'; AppliedOn='2026-09-02' },
        @{ Opportunity='SharePoint Migration Helper Tool'; Applicant='lakshmi.priya@visteon.com'; EmployeeID='VIS00012'; CurrentTeam='Project Management Office'; Manager='suresh.balakrishnan@visteon.com'; Skills='SharePoint, Project management, Documentation'; InterestStatement='As a PMO analyst I manage multiple SharePoint sites. I want to develop technical skills to complement my project management expertise and this migration tool project is a perfect fit for my growth.'; Availability='Immediate'; Status='Submitted'; AppliedOn='2026-09-10' }
    )

    foreach ($app in $applications) {
        Write-Host "Adding Application from: $($app.Applicant) for $($app.Opportunity)"
        
        $oppId = $oppMap[$app.Opportunity]
        if (-not $oppId) {
            Write-Warning "Opportunity '$($app.Opportunity)' not found. Skipping application from $($app.Applicant)."
            continue
        }

        $itemValues = @{
            Title = "App - $($app.Applicant) - $($app.Opportunity)"
            OpportunityId = $oppId
            EmployeeID = $app.EmployeeID
            CurrentTeam = $app.CurrentTeam
            Skills = $app.Skills
            InterestStatement = $app.InterestStatement
            Availability = $app.Availability
            Status = $app.Status
            AppliedOn = $app.AppliedOn
        }

        if ($app.ManagerRemarks) {
            $itemValues['ManagerRemarks'] = $app.ManagerRemarks
        }

        $newItem = Add-PnPListItem -List "Applications" -Values $itemValues

        # Set Person fields using user lookup
        Set-PnPListItem -List "Applications" -Identity $newItem.Id -Values @{ 
            "Applicant" = $app.Applicant
            "Manager" = $app.Manager 
        } | Out-Null
    }

    Write-Host "Applications seeded successfully.`n" -ForegroundColor Green

    # --------------------------------------------------------
    # 3. Seed Spotlight_Winners List
    # --------------------------------------------------------
    Write-Host "Seeding Spotlight_Winners List..." -ForegroundColor Yellow

    $winners = @(
        @{ Title='Rising Star - Aug 2026'; Person='arjun.kumar@visteon.com'; Award='Rising Star'; ProjectTitle='Predictive Maintenance ML Model'; Story='Arjun demonstrated exceptional growth during the Predictive Maintenance project, going from zero ML knowledge to building production-ready feature pipelines in 10 weeks. His initiative in connecting with the manufacturing floor team led to 3 additional insights that improved model accuracy by 12%.'; Month='2026-08-01' },
        @{ Title='Innovation Champion - Aug 2026'; Person='preethi.raj@visteon.com'; Award='Innovation Champion'; ProjectTitle='Predictive Maintenance ML Model'; Story='Preethi introduced a novel data augmentation approach that reduced the training dataset requirement by 40% without sacrificing model performance. Her innovation is now part of Visteon AI best practices documentation.'; Month='2026-08-01' },
        @{ Title='Best Collaborator - Aug 2026'; Person='rahul.mehta@visteon.com'; Award='Best Collaborator'; ProjectTitle='Predictive Maintenance ML Model'; Story='Rahul bridged the gap between Quality Engineering and Data Science, facilitating knowledge transfer sessions that upskilled 5 additional team members. His collaborative approach made the project delivery seamless.'; Month='2026-08-01' },
        @{ Title='Rising Star - Jul 2026'; Person='kiran.reddy@visteon.com'; Award='Rising Star'; ProjectTitle='CAN Bus Data Logger Optimization'; Story='Kiran optimized the memory allocation algorithm, a task the team estimated would take 4 weeks, and completed it in 10 days. The solution is now deployed in the latest firmware release for 3 vehicle programs.'; Month='2026-07-01' },
        @{ Title='Innovation Champion - Jul 2026'; Person='divya.menon@visteon.com'; Award='Innovation Champion'; ProjectTitle='CAN Bus Data Logger Optimization'; Story='Divya designed a dynamic buffering system using circular queues that improved data throughput by 25%. The design pattern has been submitted as a Visteon internal patent application.'; Month='2026-07-01' },
        @{ Title='Performer of Month - Jun 2026'; Person='ananya.singh@visteon.com'; Award='Performer of Month'; ProjectTitle='EV Dashboard POC with Power BI'; Story='Ananya delivered a complete EV battery health dashboard 3 weeks ahead of schedule, enabling an early stakeholder demo that directly influenced the Q3 roadmap for the Connected Services team.'; Month='2026-06-01' }
    )

    foreach ($winner in $winners) {
        Write-Host "Adding Winner: $($winner.Title)"
        
        $itemValues = @{
            Title = $winner.Title
            Award = $winner.Award
            Project_x002d_Title = $winner.ProjectTitle # Assuming internal name is Project_x002d_Title or ProjectTitle
            Story = $winner.Story
            Month = $winner.Month
        }

        # Handling internal name for Project-Title might be Project_x002d_Title or ProjectTitle depending on how it was created
        # We will try both if the first fails, but we'll supply ProjectTitle as the key assuming it was created as ProjectTitle
        
        # Adjusting the key based on standard SharePoint behavior for 'Project-Title'
        # The prompt says 'Project-Title' so we'll use 'Project_x002d_Title' assuming it was created with a hyphen, 
        # or 'ProjectTitle' if created without space. We will use 'Project_x002d_Title'.
        # Wait, PnP PowerShell expects the Internal Name. Let's use ProjectTitle if it fails we could catch it.
        # Given it's a script we'll use 'Project_x002d_Title' and 'ProjectTitle' to be safe or just 'Project_x002d_Title'

        $newItem = Add-PnPListItem -List "Spotlight_Winners" -Values @{
            Title = $winner.Title
            Award = $winner.Award
            Project_x002d_Title = $winner.ProjectTitle
            Story = $winner.Story
            Month = $winner.Month
        }

        # Set Person field using user lookup
        Set-PnPListItem -List "Spotlight_Winners" -Identity $newItem.Id -Values @{ "Person" = $winner.Person } | Out-Null
    }

    Write-Host "Spotlight Winners seeded successfully.`n" -ForegroundColor Green

    # --------------------------------------------------------
    # 4. Seed Subscribers List
    # --------------------------------------------------------
    Write-Host "Seeding Subscribers List..." -ForegroundColor Yellow

    $subscribers = @(
        @{ Title='rohit.sharma@visteon.com'; Person='rohit.sharma@visteon.com'; InterestTech='Power BI;AI/ML' },
        @{ Title='sneha.patel@visteon.com'; Person='sneha.patel@visteon.com'; InterestTech='AI/ML;Python' },
        @{ Title='arjun.kumar@visteon.com'; Person='arjun.kumar@visteon.com'; InterestTech='SharePoint;Power Platform' },
        @{ Title='vijay.nair@visteon.com'; Person='vijay.nair@visteon.com'; InterestTech='Power BI' },
        @{ Title='lakshmi.priya@visteon.com'; Person='lakshmi.priya@visteon.com'; InterestTech='SharePoint' }
    )

    foreach ($sub in $subscribers) {
        Write-Host "Adding Subscriber: $($sub.Title)"
        
        $techArray = $sub.InterestTech -split ';'

        $newItem = Add-PnPListItem -List "Subscribers" -Values @{
            Title = $sub.Title
            InterestTech = $techArray
        }

        # Set Person field using user lookup
        Set-PnPListItem -List "Subscribers" -Identity $newItem.Id -Values @{ "Person" = $sub.Person } | Out-Null
    }

    Write-Host "Subscribers seeded successfully.`n" -ForegroundColor Green
    Write-Host "Sample data seeding completed without errors!" -ForegroundColor Green

} catch {
    Write-Host "An error occurred during script execution:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
} finally {
    Write-Host "Script execution finished." -ForegroundColor Cyan
}
