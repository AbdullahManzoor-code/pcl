# Next.js API Analysis

## Phase 2: Courses and Languages

### Next.js File Locations
- **Languages API**: `lib/api/languages.ts`
- **Curriculum API**: `lib/api/curriculum.ts`
- **Dashboard API**: `lib/api/dashboard.ts`

### API Endpoint Summary Table

| Feature | Next.js API Endpoint | Method | Request Payload | Response Interface |
|---------|----------------------|--------|-----------------|---------------------|
| **Language Portfolio** | `/api/user/languages` | `GET` | None | `LanguagePortfolio` (contains `LanguageStats[]`) |
| **Add/Enroll Language** | `/api/user/languages` | `POST` | `{ language_id: string, difficulty_level: string }` | `AddLanguageResponse` |
| **Full Curriculum** | `/curriculum/all` | `GET` | None | `LanguageCurriculum[]` |
| **Student Progress** | `/api/user/languages/{languageId}/progress` | `GET` | Path param | `StudentProgressResponse` |
| **Mastery Data** | `/api/user/mastery/{languageId}` | `GET` | Path param | `MasteryData[]` |

### Data Models
**Language Portfolio:**
```typescript
interface LanguagePortfolio {
  primary_language: string | null;
  languages: LanguageStats[];
  total_languages: number;
}
```

**Language Stats:**
```typescript
interface LanguageStats {
  language_id: string;
  language_name: string;
  avg_mastery: number;
  topics_completed: number;
  topics_in_progress: number;
  total_topics: number;
  last_practiced: string | null;
  total_sessions: number;
  avg_accuracy: number;
  is_primary: boolean;
}
```

**Curriculum & Progress:**
```typescript
interface LanguageCurriculum {
  language_id: string;
  name: string;
  roadmap: CurriculumTopic[];
}

interface StudentProgressResponse {
  language_id: string;
  language_name: string;
  topics: TopicProgress[];
  stats: StudentProgressStats;
}
```

### Mock vs Real API Comparison

| Feature | Mock Implementation (`MockApiService`) | Real API Equivalent |
|---------|----------------------------------------|----------------------|
| **Courses Data** | Hardcoded list (`_courses`) mimicking Next.js "My Learning Paths" | `GET /api/user/languages` mapping to `LanguageStats` |
| **Course Details** | Finding in `_courses` by id | Filter through `GET /curriculum/all` or `progress` endpoints |
| **Progress/Topics** | Local mock topic tree (`_topics`) | `GET /api/user/languages/{languageId}/progress` for user-specific state |
| **Adding Course** | Simulates delay and updates local state | `POST /api/user/languages` |

### Next Steps for Flutter Migration
1. Implement `course_service.dart` mapping exactly to these Next.js models.
2. Remove usage of `MockApiService` for course retrieval in `CoursesController` and `MyCoursesController`.
3. Wire the real `course_service` endpoints to update GetX observable state.
