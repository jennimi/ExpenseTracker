# Kira — Project Plan & Progress Tracker

Oct 15, 2026 · @Karyna

## Status

Phase 1 (planning) is in progress: the brief is reviewed and the plan below is waiting on your answers to the open questions.

- **Current phase:** 1 of 5, planning and project review
- **Done:** brief reviewed, stack confirmed, MVP architecture and schema proposed
- **Next:** you answer the open questions and share your design references, then we start Phase 2 (core app)
- **Blocked on:** design references (needed before any SwiftUI screens), and the decisions in Open questions

## Decisions so far

These come from your brief and from this chat; anything not listed here is still open.

| Decision | Choice | Source |
| --- | --- | --- |
| Frontend | SwiftUI, native iOS, Swift Charts | Brief |
| Backend | Supabase (PostgreSQL), separate from the app | Brief |
| AI | Gemini, called only from a Supabase Edge Function | Brief |
| Users | Personal app on your own iPhone, no login screen | This chat |
| Currency | IDR by default, schema allows other currencies later | Brief |
| Totals | Derived from expense records, never stored | Brief |
| AI writes | AI only proposes; a tap confirms; backend validates | Brief |
| Savings | Not an expense, deferred to a future version | Brief |
| UI | Your design references are the source of truth | Brief |

## Open questions

The first one matters most, because dropping the login screen changes how the database is secured. My recommendation is in each line; reply or comment with your pick.

1. **How should the app identify you without a login screen?** Supabase Row Level Security needs a user identity. Recommended: create one real user in the Supabase dashboard and have the app sign in silently with credentials kept in the Keychain. Data then survives reinstalls, which matters because apps installed with a free Apple developer account expire after 7 days. Alternative: anonymous sign-in, which is simpler but loses all data if the app is reinstalled.
2. **Which iOS version is the minimum?** Recommended: iOS 17, which gives you the Observation framework and Swift Charts pie and donut charts (SectorMark).
3. **What happens when a month has no budget?** Recommended: Kira suggests copying last month's amount and asks you to confirm, rather than silently reusing it.
4. **Which time zone defines a month?** Recommended: store the expense date as a plain date in your local time zone (Asia/Jakarta?) so late-night entries land on the right day.
5. **Which icon library?** Recommended: SF Symbols, stored as a name string; the AI picks only from an allowed list.
6. **Is Needs/Wants fixed forever?** Recommended: keep it as a fixed two-value type and let subcategories be fully customisable. Custom main categories would be a later migration.
7. **Do you want budgets per category?** The brief has one monthly budget only. Recommended: stay with one total for the MVP.
8. **Should chat history be saved?** Recommended: yes from the first AI release, so the assistant can follow a conversation across app launches.
9. **Which Gemini model and tier?** Recommended: a fast, low-cost Flash-class model; confirm the current model name and free-tier limits in Google's docs, and check how that tier handles your data, since financial records will be sent to it.
10. **Offline use?** Recommended: online-only for the MVP; offline sync is a large extra piece of work.
11. **Recap regeneration:** overwrite the saved recap, or keep older versions? Recommended: keep only the latest and show a "new expenses since this recap" notice.
12. **When can you share the design references?** Needed before Phase 2 screens, not before the database work.

## MVP architecture

The iOS app handles screens and simple reads and writes; the Edge Function handles everything involving Gemini; the database does the money maths.

| Concern | Where it runs | Why |
| --- | --- | --- |
| Screens, navigation, charts | iOS client | Native UI |
| Form validation (amount, title) | iOS client, then database constraints | Fast feedback plus a hard guarantee |
| Expense and budget create, edit, delete | iOS client straight to Supabase | Protected by RLS, no server code needed |
| Month totals, remaining budget, category breakdown | Postgres SQL functions | One source of truth for Insights and the AI |
| Gemini calls and the API key | Edge Function only | The key never reaches the phone |
| AI expense proposal validation | Edge Function, then the database again on save | Never trust model output |
| Saving a confirmed AI expense | iOS client, as a normal insert | Keeps AI code without write access |
| Monthly recap generation and storage | Edge Function writes to `monthly_recaps` | Needs Gemini and privileged access |

**How the AI answers questions.** The Edge Function gives Gemini a few read-only tools (month summary, category breakdown, list expenses) backed by the SQL functions. The model never does the arithmetic itself, so figures cannot be invented. For "I just spent Rp45,000 on lunch" it returns a typed JSON proposal (title, amount, date, subcategory id from your real list, icon) or a follow-up question when a field is unclear. The chat shows that as a confirmation card; only the **Add Expense** tap saves anything.

**Suggested app structure.**

- `App/`: entry point, dependency setup, config
- `Core/`: Supabase client, Money and Date helpers, errors
- `Models/`: Codable types matching the tables
- `Repositories/`: all Supabase calls (ExpenseRepository, BudgetRepository, InsightsRepository, KiraRepository)
- `Features/Home`, `Features/Expenses`, `Features/Insights`, `Features/Kira`, `Features/Recap`: each with a View and an `@Observable` view model
- `DesignSystem/`: reusable components built from your design references

Views never call Supabase directly; view models call repositories. Supabase migrations and Edge Functions live in a `supabase/` folder in the same git repo.

## Initial database schema

Seven tables, all owned by one `user_id` and protected by RLS. Money is stored as whole minor units (a `bigint`) plus a currency code, which avoids rounding errors and fits IDR now and other currencies later.

| Table | Key columns | Notes |
| --- | --- | --- |
| `profiles` | `user_id` (PK, FK to auth.users), `display_name`, `default_currency`, `timezone` | One row per user |
| `subcategories` | `id`, `user_id`, `kind` (`need` or `want`), `name`, `icon`, `sort_order`, `is_archived` | Needs/Wants is a fixed type; each subcategory carries its parent. Unique per user on kind + name |
| `monthly_budgets` | `id`, `user_id`, `month` (first day of month), `currency`, `amount_minor` | Unique on `user_id` + `month`; amount must be zero or more |
| `expenses` | `id`, `user_id`, `title`, `amount_minor`, `currency`, `expense_date` (date), `subcategory_id`, `icon`, `note`, `source` (`manual` or `ai`), `proposal_id`, `created_at`, `updated_at` | Amount must be above zero; title 1 to 100 characters; `proposal_id` is unique so a double tap cannot save an AI proposal twice |
| `ai_conversations` | `id`, `user_id`, `title`, `created_at` | Phase 4 |
| `ai_messages` | `id`, `conversation_id`, `role`, `content`, `proposal` (jsonb), `proposal_status` | Phase 4; status is pending, confirmed or dismissed |
| `monthly_recaps` | `id`, `user_id`, `month`, `content`, `model`, `generated_at`, `expense_count`, `total_minor` | Unique on `user_id` + `month`; the count and total at generation time show when a recap is stale |

**Relationships and deletion**

- `expenses.subcategory_id` uses `ON DELETE RESTRICT`. Subcategories are archived, not deleted, so old expenses keep their category.
- Everything with a `user_id` cascades if that user is deleted.
- `ai_messages` cascade when their conversation is deleted.

**Indexes:** `expenses (user_id, expense_date desc)` for month lists and totals, and `expenses (user_id, subcategory_id)` for breakdowns.

**Derived numbers.** Two SQL functions that run with the caller's permissions (so RLS still applies) replace stored totals: `month_summary(month)` returns budget, spent, remaining and percent used; `category_breakdown(month)` returns amount and share per subcategory. Insights, Home and the AI tools all call these.

**RLS.** One policy per table: a row is visible and writable only when `user_id = auth.uid()`. The seed function that creates the starter Needs and Wants subcategories is called once on first launch.

## Risks and suggested improvements

The biggest risk is the missing login screen: without a real user identity, RLS cannot protect your data, and the public Supabase key inside the app would give anyone who extracts it full access.

| Risk | Suggested fix |
| --- | --- |
| No login means no RLS identity | Silent sign-in to one real account (see Open questions, item 1); keep RLS on and keep `user_id` columns |
| The model invents or miscalculates figures | SQL functions compute all numbers; Gemini only reads them through tools |
| Prompt injection through expense titles or notes | Treat stored text as data; the Edge Function has read-only tools and cannot write expenses |
| Bad or duplicate AI proposals | Validate against a typed schema, check the subcategory belongs to you, use `proposal_id` for idempotency, validate again on save |
| Month boundaries and time zones | Plain `date` column in your local zone; month = first of month |
| Deleting a subcategory orphans history | Archive instead of delete |
| Negative remaining budget | Design an over-budget state early (colour, wording, progress bar past 100%) |
| Gemini cost, latency and rate limits | Flash-class model, small tool results, loading and retry states in the chat |
| Financial data sent to Google | Check the data-use terms of your Gemini tier before sending real records |
| Scope creep from the AI features | Ship Phases 2 and 3 as a usable app first; AI comes after |

**Improvements to the brief**

- Give each subcategory a default icon so an expense needs no icon pick; the expense icon becomes an optional override, which saves a step.
- Add a quick-add path: amount first, title and category defaulting to your most recent combination.
- Use `supabase-swift` and keep all calls in repositories so the backend stays swappable.
- Keep migrations as SQL files in git so the database can be rebuilt from scratch.

## Implementation order

Build the app so it is useful after Phase 3, with the AI layered on top. Tick items off here as we go.

**Phase 1: Planning (current)**

- [x] Review the product brief
- [x] Propose architecture, schema and order
- [ ] Answer the open questions
- [ ] Share design references

**Phase 2: Core app**

- [ ] Create Supabase project, set up the CLI and a `supabase/` folder in git
- [ ] Migration 1: tables, constraints, indexes, RLS policies, seed function
- [ ] Xcode project, folder structure, Supabase client, silent sign-in
- [ ] Design system components from your references
- [ ] Monthly budget: set and edit per month
- [ ] Expense create, edit, delete, list by month, detail view
- [ ] SQL functions for month summary; Home screen connected to real data

**Phase 3: Insights**

- [ ] `category_breakdown` function
- [ ] Month picker, Needs vs Wants split, pie chart, top subcategories
- [ ] Empty states for months without expenses

**Phase 4: Kira assistant**

- [ ] Edge Function with Gemini key stored as a secret
- [ ] Read-only tools backed by the SQL functions
- [ ] Chat UI and saved conversations
- [ ] Structured expense proposal, confirmation card, follow-up questions
- [ ] Server validation, then save on tap with `proposal_id`

**Phase 5: Recap and polish**

- [ ] Recap generation, storage, history, regeneration and stale notice
- [ ] Loading, error and empty states throughout
- [ ] Security and data checks: RLS test with a second user, validation edge cases, key exposure review
