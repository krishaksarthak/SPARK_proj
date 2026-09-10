# Architecture Overview

## Architecture Diagram

```mermaid
flowchart TD
    %% Users
    subgraph Users[User Personas]
        F[Fresher/Riser]
        M[Manager/Mentor]
        A[Admin]
    end

    %% Front End
    subgraph Frontend[SharePoint Communication Site]
        P1(Home Page)
        P2(Explore Page)
        P3(Opportunity Details)
        P4(Manager Hub)
        P5(My Applications)
        P6(Hall of Fame)
    end

    %% Backend Data
    subgraph Backend[SharePoint Lists]
        L1[(Opportunities)]
        L2[(Applications)]
        L3[(Spotlight)]
        L4[(Rewards)]
        
        L2 -->|Lookup| L1
        L3 -->|Lookup| L1
    end

    %% Automation
    subgraph Automation[Power Automate Flows]
        F1[[Application Submitted]]
        F2[[Status Update]]
        F3[[Project Completion]]
        F4[[Weekly Digest]]
    end

    %% External Systems
    subgraph External[External M365 Systems]
        O[Outlook]
        T[Teams]
        C[Copilot Studio]
    end

    %% Connections
    F -->|Browses| Frontend
    F -->|Submits| L2
    M -->|Creates| L1
    M -->|Manages| L2
    A -->|Configures| Frontend
    A -->|Maintains| Backend

    Frontend -->|Reads/Writes| Backend
    
    L2 -->|Trigger: New Item| F1
    L2 -->|Trigger: Item Modified| F2
    L1 -->|Trigger: Status = Completed| F3
    
    F1 -->|Action: Email/Message| O
    F1 -->|Action: Message| T
    F2 -->|Action: Email| O
    F3 -->|Action: Create Draft| L4
    
    C -.->|Queries| Frontend
```

## Maintenance Guide

**No code to maintain. Zero-code architecture. Maintenance = only add List items. Flows self-heal.**

### Philosophy
The SPARK platform is built strictly using out-of-the-box Microsoft 365 capabilities. There is absolutely no custom server-side code (C#), no custom front-end frameworks (React/Angular), and no SPFx web parts to compile, update, or maintain.

### Routine Maintenance
- **Content Updates**: All dynamic content on the site is driven by SharePoint Lists. To update the site, simply add, edit, or delete items in the underlying Lists (`Opportunities`, `Spotlight`, etc.).
- **Permissions**: Managed via standard SharePoint Groups (Owners, Members, Visitors).
- **Flow Resiliency**: Power Automate flows are designed to be idempotent and self-healing. If a flow fails due to a temporary service disruption, it can be resubmitted via the Power Automate run history portal. Connections use service accounts or shared connections.
