**Subject:** Smart Commenter build plan ready

Hey MacKenzie,

Took your ask and put together the build plan for the Instagram Smart Commenter. Here's the high-level overview so you can decide if you want to move forward.

**What it does**

AI that replies to comments on @futureof_education in your voice. Trained entirely from your existing content: captions, comment replies, podcast transcripts, videos. Webhooks auto-ingest new content so the voice model never goes stale. Everything runs through Instagram's official API.

**Every comment gets triaged**

This is the part that matters most for an education account. Before any reply is generated, every comment runs through a decision tree:

- Mentions a child, mental health, abuse, or legal issue → hard skip, always
- Verified or high-profile account → flagged for you, never auto-replies
- Troll, spam, or off-topic → skipped
- Relevant to post or Alpha School → replies in your voice, factual claims only if they're pre-approved in the knowledge base

The first matching rule wins. Sensitive content is caught before anything else is evaluated.

**Timing**

- First 3 hours after posting: active replies. This is where engagement compounds algorithmically.
- 3 hours to 3 days: only high-value questions (enrollment, direct Alpha inquiries)
- After 3 days: nothing. Replying to old posts looks unnatural.

**Rollout**

This isn't a flip switch. It rolls out in phases:

- Week 1: Slack approval mode. Bot drafts replies, human approves before anything posts.
- Week 2: Safe categories go auto. Sensitive categories stay in approval mode.
- Week 3+: Full auto, tuned on the edit data from weeks 1-2. Daily Slack digest of everything posted.

**What I need from you**

1. **Authorize the Meta App** (~5 min, I'll walk you through it). Meta's review process takes 2-6 weeks, likely faster for a verified account your size. This is the only blocker. Everything else builds in parallel.
2. **Sign off on messaging rules.** I'll send over what the bot can and can't say publicly for your review.

Visual walkthrough attached if you want to flip through it: [deck link]

Yash
