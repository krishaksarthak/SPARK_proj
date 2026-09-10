# Copilot Studio Setup Guide: SPARK Assistant

## 1. Create new Copilot Studio Agent
- Go to [Copilot Studio](https://copilotstudio.microsoft.com/).
- Click **Create** > **New copilot**.
- Name the bot: **SPARK Assistant**.
- Select the default language and environment, then click **Create**.

## 2. Ground Bot on SPARK SharePoint Site
- Navigate to the **Generative AI** settings or **Knowledge** tab in your bot.
- Add a new Knowledge Source: **SharePoint site**.
- Provide the URL: `https://visteon.sharepoint.com/sites/SPARK`.
- Save and ensure indexing starts.

## 3. Create 5 Essential Topics

### Topic 1: Find Opportunity
- **Trigger Phrases**: 
  - "I want to find a project"
  - "Show me available opportunities"
  - "Find an opportunity"
  - "Looking for a new role"
  - "What projects are open?"
- **Nodes**: Message -> "You can browse all open opportunities on the [SPARK Opportunities Board](https://visteon.sharepoint.com/sites/SPARK/Lists/Opportunities/AllItems.aspx)."

### Topic 2: How to Apply
- **Trigger Phrases**: 
  - "How do I apply?"
  - "What is the application process?"
  - "Submit application"
  - "I want to apply for a project"
  - "Application steps"
- **Nodes**: Message -> "To apply, go to the opportunity page and click 'Apply'. Ensure your skills and interest statement are up to date! Read more in our [Apply Guide](https://visteon.sharepoint.com/sites/SPARK/SitePages/HowToApply.aspx)."

### Topic 3: Application Status
- **Trigger Phrases**: 
  - "Check my application status"
  - "Is my application reviewed?"
  - "Application update"
  - "Did I get selected?"
  - "Where is my application?"
- **Nodes**: Message -> "You can view the real-time status of all your applications in the [My Applications Dashboard](https://visteon.sharepoint.com/sites/SPARK/SitePages/MyApplications.aspx)."

### Topic 4: Manager Review Process
- **Trigger Phrases**: 
  - "How do managers review applications?"
  - "Manager review steps"
  - "What happens after I apply?"
  - "Review timeline"
  - "Who reviews my application?"
- **Nodes**: Message -> "Managers review applications via the Manager Hub. They assess skills and may schedule a discussion. You'll receive email updates as your status changes from 'Under Review' to 'Shortlisted' or others."

### Topic 5: Contact Help
- **Trigger Phrases**: 
  - "I need help"
  - "Contact support"
  - "Talk to a human"
  - "SPARK helpdesk"
  - "Who do I contact?"
- **Nodes**: Message -> "For further assistance, please contact the SPARK administration team at sparkadmin@visteon.com or post in the SPARK Teams Channel."

## 5. Publishing and Embedding
- Go to the **Publish** tab and click **Publish**.
- After publishing, go to **Channels** > **Custom website**.
- Copy the HTML `iframe` snippet provided.
- In SharePoint, edit the main page, add an **Embed** web part, and paste the code.

## 6. Testing Checklist
- [ ] Ensure all 5 topics trigger correctly.
- [ ] Test the generative AI fallback by asking questions directly answerable by the SharePoint site content.
- [ ] Verify links open correctly.
- [ ] Test bot within the SharePoint page directly.

## 7. Maintenance Guide
- To add new topics, navigate to **Topics**, click **New topic**, define at least 5 varied trigger phrases, and design the conversation nodes. Always republish to see changes live.
- Monitor analytics regularly to catch failed queries and create topics for them.
