# System Diagrams

> Frontend-only prototype; backend, auth, and DB are conceptual. Update when backend contracts finalize.

## Use Case Diagram
```mermaid
flowchart LR
  actor[Student]:::actor
  subgraph UseCases
    U1((Register / Login))
    U2((Select Language & Difficulty))
    U3((Create/Resume Learning Path))
    U4((Start Adaptive MCQ Test))
    U5((View Results & Explanations))
    U6((See Recommendations))
    U7((Schedule / Review Topics))
    U8((View Analytics Dashboard))
    U9((Manage Settings & Theme))
    U10((Receive Alerts / Reminders))
  end
  actor-->U1-->U2-->U3-->U4-->U5
  actor-->U6
  actor-->U7
  actor-->U8
  actor-->U9
  System([Backend / RL Engine]):::system
  System---U4
  System---U5
  System---U6
  System---U7
  System---U8
  System---U10
  classDef actor fill:#f0f9ff,stroke:#2563eb,stroke-width:2
  classDef system fill:#ecfdf3,stroke:#16a34a,stroke-width:2
```

## Sequence Diagram – Adaptive Test Session
```mermaid
sequenceDiagram
  autonumber
  participant S as Student (UI)
  participant FE as Next.js Frontend
  participant API as Backend API
  participant RL as RL/Recommendation
  participant QB as Question Bank
  participant PR as Progress Service

  S->>FE: Start test / practice CTA
  FE->>API: POST /session/init {language, concept, difficulty}
  API->>RL: build_state_vector(user, concept)
  RL-->>API: recommended difficulty, question mix
  API->>QB: fetch_questions(params)
  QB-->>API: questions batch
  API-->>FE: session payload {questions, timer, session_id}
  loop per answer
    S->>FE: submit answer
    FE->>API: POST /session/{id}/answer {qid, answer, time}
    API->>RL: update mastery/reward
    RL-->>API: mastery delta, next difficulty
    API-->>FE: feedback {correct?, explanation, updated mastery}
  end
  FE->>API: POST /session/{id}/submit
  API->>PR: persist results + mastery_state
  PR-->>API: ok
  API-->>FE: summary {score, accuracy, recommendations}
  FE-->>S: show results + suggested next topics
```

## Activity Diagram – MCQ Session Flow
```mermaid
flowchart TD
  A[Start Session]-->B{Questions remaining?}
  B--No-->C[Show Summary]
  B--Yes-->D[Render Question + Options]
  D-->E{Timer running?}
  E--No-->F[Auto-submit unanswered]
  E--Yes-->G{Student selects option}
  G--No-->H[Allow navigation / pause?]
  H-->E
  G--Yes-->I[Send answer]
  I-->J[Receive correctness + explanation]
  J-->K[Update progress bar]
  K-->L[Update mastery / difficulty (RL)]
  L-->B
  C-->M[Display score, analytics, recommendations]
```

## Database Diagram (Conceptual)
```mermaid
erDiagram
  USERS ||--o{ LEARNING_PATHS : owns
  USERS ||--o{ SESSIONS : takes
  USERS ||--o{ SETTINGS : has
  LEARNING_PATHS ||--o{ PATH_TOPICS : includes
  LEARNING_PATHS ||--o{ SESSIONS : generates
  PATH_TOPICS ||--o{ QUESTION_BANK : maps_to
  SESSIONS ||--o{ ANSWERS : records
  SESSIONS ||--|| RESULTS : yields
  USERS ||--o{ MASTERY_STATE : tracks
  USERS ||--o{ RECOMMENDATIONS : receives
  USERS ||--o{ ALERTS : receives

  USERS {
    uuid id
    text email
    text name
    text password_hash
    text default_language
    timestamp created_at
  }
  LEARNING_PATHS {
    uuid id
    uuid user_id
    text language_id
    numeric difficulty
    int total_topics
    int completed_topics
    numeric accuracy
    timestamp updated_at
  }
  PATH_TOPICS {
    uuid id
    uuid path_id
    text concept_id
    text subtopic
    numeric target_difficulty
    numeric mastery
  }
  QUESTION_BANK {
    uuid id
    text language_id
    text concept_id
    text subtopic
    text stem
    json options
    int correct_index
    json metadata
  }
  SESSIONS {
    uuid id
    uuid user_id
    uuid path_id
    text mode
    int question_count
    timestamp started_at
    timestamp submitted_at
  }
  ANSWERS {
    uuid id
    uuid session_id
    uuid question_id
    int selected_index
    boolean correct
    numeric time_spent_seconds
  }
  RESULTS {
    uuid session_id
    numeric score_pct
    numeric accuracy_pct
    int correct_count
    int incorrect_count
    json per_concept_stats
  }
  MASTERY_STATE {
    uuid id
    uuid user_id
    text concept_id
    numeric mastery
    timestamp last_practiced
    numeric decay_rate
  }
  RECOMMENDATIONS {
    uuid id
    uuid user_id
    text concept_id
    text reason
    numeric target_difficulty
    numeric est_time_minutes
    timestamp created_at
  }
  ALERTS {
    uuid id
    uuid user_id
    text type
    text message
    boolean read
    timestamp created_at
  }
  SETTINGS {
    uuid id
    uuid user_id
    text theme
    boolean notifications_enabled
    text locale
  }
```

## Flow Diagram – Navigation
```mermaid
flowchart LR
  Landing[/Landing/]-->Register[/Register/]
  Landing-->Login[/Login/]
  Register-->Onboarding[Onboarding: Language/Difficulty]
  Login-->Dashboard[/Dashboard/]
  Onboarding-->Dashboard
  Dashboard-->Learnings[/Learnings/]
  Learnings-->LearningDetail[/Learnings/:id/]
  LearningDetail-->Practice[/Practice/]
  Practice-->Test[/Test/:id/]
  Test-->Results[/Results/:id/]
  Dashboard-->Analytics[/Analytics/]
  Dashboard-->Settings[/Settings/]
  Settings-->Dashboard
  Results-->Dashboard
```

## Component/Service Interaction (Frontend)
```mermaid
flowchart TD
  Navbar-->Pages
  Sidebar-->DashboardPages
  DashboardPages-->Components[Heatmap, Alerts, Recommendations, RecentSessions]
  Components-->ThemeProvider
  ThemeProvider-->LocalStorage[(LocalStorage)]
  Pages-->EnvVar[NEXT_PUBLIC_SITE_NAME]
```
