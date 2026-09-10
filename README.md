# SPARK (Student Project Acceleration & Resource Kit)

![Status: In Progress](https://img.shields.io/badge/Status-In%20Progress-blue) ![Deadline: Sep 16 2026](https://img.shields.io/badge/Deadline-Sep%2016%202026-red) ![Stack: SharePoint + Power Automate](https://img.shields.io/badge/Stack-SharePoint%20%2B%20Power%20Automate-brightgreen)

## Project Overview
SPARK is a centralized, zero-code internal portal designed to match Visteon Freshers and Risers with hands-on technical opportunities offered by Mentors and Managers. Built entirely on SharePoint and M365 (Power Automate), SPARK fosters internal mobility, skill development, and cross-functional collaboration.

## Architecture Summary
SPARK leverages a SharePoint Communication Site as its front-end, utilizing out-of-the-box web parts customized with JSON formatting for a modern UI. Data is stored in 4 interconnected SharePoint Lists. Business logic and automation are handled by 4 Power Automate flows, integrating seamlessly with Outlook and Teams.

## Quick Start

### Prerequisites
- Site Collection Administrator access to the target SharePoint site.
- PnP PowerShell installed (`Install-Module -Name PnP.PowerShell -Scope CurrentUser`).
- Power Automate Premium license (optional, but recommended for advanced connectors, though flows use standard M365 connectors).

### Run Scripts in Order
1. Execute `01-Setup-Site.ps1` to configure site settings, theme, and navigation.
2. Execute `02-Create-Lists.ps1` to provision the 4 core lists, columns, and apply JSON list formatting.
3. Execute `03-Create-Pages.ps1` to build the 6 pages with required web parts.
4. Execute `04-Seed-Data.ps1` to populate lists with sample data.
5. Import Power Automate flow zip packages via the Power Automate portal.

## Site Structure
1. **Home**: Landing page with hero banner, quick stats, and featured opportunities.
2. **Explore**: Detailed gallery of all open opportunities, sortable and filterable.
3. **Opportunity Details**: Deep-dive page into a specific project, mentor info, and skills required.
4. **Manager Hub**: Dashboard for mentors to track their postings and applicant statuses.
5. **My Applications**: Dashboard for freshers to track their application statuses.
6. **Hall of Fame**: Showcase of completed projects and top contributors.

## List Summary
- **Opportunities**: Stores project details (Title, Tech Stack, Mentor, Status, Max Applicants).
- **Applications**: Tracks fresher applications to projects (Lookup to Opportunities, Status, Applicant Name).
- **Spotlight**: Highlights featured opportunities or top freshers.
- **Rewards**: Tracks internal currency/badges awarded upon project completion.

## Flow Summary
1. **Application Submitted Notification**: Alerts mentor when a new application is submitted.
2. **Applicant Status Update**: Notifies fresher when their application status changes (e.g., Shortlisted, Accepted).
3. **Project Completion -> Rewards**: Drafts a reward entry when an opportunity is marked 'Completed'.
4. **Weekly Digest**: Sends a weekly summary of new opportunities to all freshers.

## Test Users
- **Admin**: System Administrator
- **Manager/Mentor**: Jane Doe (jdoe@visteon.com)
- **Fresher/Riser**: John Smith (jsmith@visteon.com)

## Assumptions
- The organization uses Microsoft 365.
- Users have standard E3/E5 licenses.
- No custom SPFx components are permitted (strict zero-code policy).

## Contacts
- SPARK Platform Team: spark-support@visteon.com
