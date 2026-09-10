# SPARK Platform: Power Automate Flows Guide

This document outlines the architecture, triggers, and step-by-step configurations for the four primary Power Automate flows supporting the SPARK internal portal.

---

## Flow 1: New Application Notification
**Purpose:** Notifies the Opportunity Mentor, the Applicant's Line Manager, and sends a Teams message when a new application is submitted.

### Trigger
- **Connector:** SharePoint
- **Event:** When an item is created
- **List Name:** `SPARK_Applications`

### Step-by-Step Actions
1. **SharePoint - Get item:** Fetch the newly created application details using the `ID` from the trigger.
2. **SharePoint - Get item:** Fetch the related Opportunity details from the `SPARK_Opportunities` list using the `OpportunityId` from the application.
3. **Office 365 Users - Get user profile (V2):** Get the profile of the `ApplicantEmail`.
4. **Office 365 Users - Get manager (V2):** Get the manager of the `ApplicantEmail`.
5. **Office 365 Outlook - Send an email (V2):** Send email to the Mentor.
6. **Office 365 Outlook - Send an email (V2):** Send email to the Line Manager.
7. **Microsoft Teams - Post message in a chat or channel:** Post to the SPARK Mentors Team channel.

### Email Templates
**To Mentor:**
- **Subject:** New Application Received: {{OpportunityTitle}}
- **Body (HTML):**
  ```html
  <p>Hello {{MentorName}},</p>
  <p>You have received a new application for your opportunity: <strong>{{OpportunityTitle}}</strong>.</p>
  <p><strong>Applicant:</strong> {{ApplicantName}}<br>
  <strong>Department:</strong> {{ApplicantDepartment}}</p>
  <p>Please review the application in the <a href="{{ManagerHubUrl}}">Manager Hub</a> within 5 business days.</p>
  <p>Thank you,<br>SPARK Admin</p>
  ```

**To Line Manager:**
- **Subject:** FYI: {{ApplicantName}} applied for a SPARK Opportunity
- **Body (HTML):**
  ```html
  <p>Hello {{ManagerName}},</p>
  <p>This is a courtesy notification that {{ApplicantName}} has applied for an internal SPARK opportunity: <strong>{{OpportunityTitle}}</strong>.</p>
  <p>Expected Effort: {{EffortHours}} hrs/week.</p>
  <p>No action is required from you at this time.</p>
  ```

---

## Flow 2: Application Status Change Notification
**Purpose:** Notifies the applicant when their application status is updated by the mentor (e.g., Interviewing, Accepted, Rejected).

### Trigger
- **Connector:** SharePoint
- **Event:** When an item or a file is modified
- **List Name:** `SPARK_Applications`

### Step-by-Step Actions
1. **Condition:** Check if `Status Value` has changed. (Use trigger body output). If false, terminate flow.
2. **Switch Case:** Based on `Status Value` (Interviewing, Accepted, Rejected).
3. **Office 365 Outlook - Send an email (V2):** (Inside each switch case)

### Email Templates
**Case: Accepted**
- **Subject:** Congratulations! Your SPARK Application is Accepted
- **Body (HTML):**
  ```html
  <p>Hi {{ApplicantName}},</p>
  <p>Great news! Your application for <strong>{{OpportunityTitle}}</strong> has been accepted.</p>
  <p>Your mentor, {{MentorName}}, will reach out to you shortly to discuss the onboarding process.</p>
  ```

**Case: Rejected**
- **Subject:** Update on your SPARK Application
- **Body (HTML):**
  ```html
  <p>Hi {{ApplicantName}},</p>
  <p>Thank you for applying to <strong>{{OpportunityTitle}}</strong>. At this time, the mentor has decided to move forward with other candidates.</p>
  <p>We encourage you to explore other open opportunities on the SPARK platform!</p>
  ```

---

## Flow 3: New Opportunity Open Notification
**Purpose:** Alerts subscribed users when a newly approved opportunity is published.

### Trigger
- **Connector:** SharePoint
- **Event:** When an item or a file is modified
- **List Name:** `SPARK_Opportunities`

### Step-by-Step Actions
1. **Condition:** Check if `Status` equals 'Open' AND `Status` previously was 'Draft/Pending'.
2. **SharePoint - Get items:** Fetch users from `SPARK_Subscribers` list where interests match the Opportunity's `TechnologyTags` or `Category`.
3. **Apply to each:** Iterate over subscribers.
4. **Office 365 Outlook - Send an email (V2):** Send alert.

### Email Templates
- **Subject:** New SPARK Opportunity: {{OpportunityTitle}}
- **Body (HTML):**
  ```html
  <p>Hi {{SubscriberName}},</p>
  <p>A new opportunity matching your interests has been posted!</p>
  <h2>{{OpportunityTitle}}</h2>
  <p><strong>Category:</strong> {{Category}}<br>
  <strong>Skills:</strong> {{Skills}}</p>
  <p><a href="{{OpportunityUrl}}">View Details and Apply</a></p>
  ```

---

## Flow 4: Project Completed -> Rewards Draft Creation
**Purpose:** Automates the creation of a draft reward nomination when an opportunity is marked as completed.

### Trigger
- **Connector:** SharePoint
- **Event:** When an item or a file is modified
- **List Name:** `SPARK_Opportunities`

### Step-by-Step Actions
1. **Condition:** Check if `Status` equals 'Completed'.
2. **SharePoint - Get items:** Get all Applications for this Opportunity where `Status` is 'Accepted'.
3. **Apply to each:** Iterate through accepted applicants.
4. **SharePoint - Create item:** Create a new record in `SPARK_Rewards` list.
   - Set `Nominee` to the Applicant.
   - Set `Project` to `OpportunityTitle`.
   - Set `Status` to 'Draft'.
5. **Office 365 Outlook - Send an email (V2):** Prompt mentor to complete the nomination.

### Email Templates
- **Subject:** Action Required: Submit Rewards for {{OpportunityTitle}}
- **Body (HTML):**
  ```html
  <p>Hi {{MentorName}},</p>
  <p>Congratulations on completing <strong>{{OpportunityTitle}}</strong>!</p>
  <p>Draft reward nominations have been generated for your team members. Please visit the <a href="{{RewardsUrl}}">Rewards Dashboard</a> to add your feedback and submit them for the SPARK Innovation Awards.</p>
  ```

### Error Handling & Testing
- **Error Handling:** Add a 'Configure run after' on failure for critical email steps to log errors to a `Flow_Errors` SharePoint list.
- **Testing:** Manually create items in lists to ensure triggers fire. Verify HTML rendering in Outlook web and desktop clients. Ensure Teams adaptive cards (if upgraded later) have valid JSON payloads.
