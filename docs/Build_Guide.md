# SPARK Build Guide

This guide details the step-by-step process to manually assemble the SPARK platform.

## Phase 1: Site + Theme
1. Navigate to the **SharePoint Admin Center** (`https://[tenant]-admin.sharepoint.com`).
2. Click **Active sites** > **Create**.
3. Select **Communication site**.
4. Choose the **Topic** design.
5. Name the site **SPARK Platform** and click **Finish**.
6. Once provisioned, go to the site.
7. Click the **Gear icon** (Settings) > **Change the look** > **Theme**.
8. Select the custom Visteon corporate theme or customize colors (Primary: Blue, Accent: Orange).
9. Click **Save**.

## Phase 2: Lists + Schema
*Alternatively, run `02-Create-Lists.ps1`.*
1. Go to **Site contents** > **New** > **List** > **Blank list**.
2. Name it **Opportunities**.
3. Add columns:
   - **Tech Stack** (Choice: AI/ML, React, Python, etc.)
   - **Mentor** (Person)
   - **Status** (Choice: Open, In Progress, Completed)
   - **Max Applicants** (Number)
4. Repeat to create **Applications**, **Spotlight**, and **Rewards** lists.
5. To apply JSON formatting:
   - Go to the **Opportunities** list.
   - Click the view dropdown (e.g., *All Items*) > **Format current view**.
   - Click **Advanced mode**.
   - Paste the provided gallery-view JSON formatting code.
   - Click **Save**.

## Phase 3: Pages + Web Parts
1. Go to **Site contents** > **Site Pages** > **New** > **Site Page**.
2. Name the page **Home**.
3. Add a Hero web part: Click **+** > **Add web part** > **Hero** > Settings panel: Layout = 3 tiles.
4. Add a List web part: Click **+** > **Add web part** > **List** > Select **Opportunities** list.
   - Settings panel: Filter by Status = Open, Layout = Gallery, Show 4 items.
5. Publish the page.
6. Repeat for **Explore**, **Opportunity Details**, **Manager Hub**, **My Applications**, and **Hall of Fame**, configuring List web parts to show specific filtered views.
7. For example, on the Explore page: Click **+** > **Add web part** > **List** > Settings panel: Filter by Status = Open, Layout = Gallery, Show 4 items.

## Phase 4: Power Automate
1. Navigate to **Power Automate** (`make.powerautomate.com`).
2. Go to **My flows** > **Import** > **Import Package (Legacy)**.
3. Upload the SPARK Flow ZIP file (e.g., `Application-Submitted-Flow.zip`).
4. During import, configure the **SharePoint Connection** and **Outlook Connection** to point to your active credentials or service account.
5. Click **Import**.
6. Open the newly imported flow, verify the Site Address and List Name map to your newly created site, and click **Save**.
7. Turn the flow **On**.
8. Test by manually adding a test item to the list.

## Phase 5: Polish + Launch
1. Update the Global Navigation: Click **Edit** on the top navigation bar.
2. Add links to all 6 pages.
3. Configure site permissions: **Gear icon** > **Site permissions**.
   - Add all employees to Visitors.
   - Add Mentors/Managers to Members.
4. Draft and send the launch communication email to the organization.
