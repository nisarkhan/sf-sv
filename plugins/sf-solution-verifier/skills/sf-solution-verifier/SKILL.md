---
name: sf-solution-verifier
description: Fact-check a Salesforce solution document, design, ADR, or recommendation against current official Salesforce sources only. Use when the user asks to verify, validate, fact-check, or cross-check a document or solution involving Agentforce, Data Cloud or Data 360, Flex Credits, Apex, SOQL, LWC, Salesforce CLI, licensing, editions, or limits.
argument-hint: <path to solution document>
allowed-tools: Read, Write, WebSearch, WebFetch
---

# Salesforce Solution Verifier

SKILL VERSION: 1.2.0 (2026-09-23)

## Step 0: Announce the version
Before anything else, print exactly this line:

    Running sf-solution-verifier skill v1.2.0

This line is hardcoded in this file. If the user expected a different
version, the plugin cache is stale and they should run
/plugin marketplace update sf-sv, then restart Claude Code.

Document to verify: $ARGUMENTS
If no path was given, ask the user which file to verify.

## Allowed sources (Salesforce documentation only)
Evidence may come ONLY from the sources below. Anything else is not proof.

Context7 libraries (use these IDs directly, never search for other libraries):
- /llmstxt/developer_salesforce_llms_txt  (Apex, SOQL, APIs, metadata,
  Agent Script, Agentforce, Data Cloud developer docs; the default)
- /salesforce/lwc                         (LWC framework behavior)
- /salesforcecli/cli                      (Salesforce CLI commands)
Never use /oracle/apex or /nvidia/apex. They are not Salesforce.

Web domains (the only sites you may search or fetch):
- developer.salesforce.com   (developer guides, API references)
- help.salesforce.com        (feature behavior, setup, limits, editions,
                              release notes, Data 360 billing)
- architect.salesforce.com   (Well-Architected, decision guides)
- www.salesforce.com         (pricing pages, Flex Credits Rate Card PDFs)
Every WebSearch call MUST set allowed_domains to exactly this list.
Never WebFetch a URL outside this list. If the only evidence you can find
is on another site (blogs, partners, forums, Trailblazer Community, other
AI tools), the verdict is "Not found", and you say where a human should look.

## Step 0: Confidentiality
Before any lookup, note customer names, people, and org-specific details in
the document. Never put them in a Context7 query or web search. Queries
describe the Salesforce feature only.

## Step 1: Read the document
Use the Read tool to open the file.

## Step 2: Extract claims
List every checkable statement as one short, numbered claim.
Checkable means: a feature exists or behaves a certain way, a limit or number,
a license or edition requirement, a cost or consumption rule, GA/beta/pilot
status, or an API, CLI, or metadata fact. Skip opinions and design choices.
Print the numbered claim list before checking anything.

## Step 3: Check each claim
- Technical claims: call the Context7 query-docs tool (its name ends in
  "query-docs") with a library ID from the list above and a specific query
  naming the class, method, clause, or feature.
- Behavior, permissions, editions, limits, GA status: WebSearch on
  help.salesforce.com, then WebFetch the article.
- Flex Credits, Data 360 credits, pricing: WebSearch www.salesforce.com for
  the newest "Flex Credits Rate Card" PDF, WebFetch it, record its date.
- Customer contract or entitlement facts: do not check. Verdict is
  "Needs account team".
Budget: at most 2 Context7 calls and 2 fetches per claim.

## Step 4: Verdicts
Exactly one per claim: Confirmed, Partly right, Contradicted, Outdated,
Not found, Needs account team.
Never mark Confirmed from memory. No allowed source, no Confirmed.
If the document estimates credits or cost, recompute from the rate card and
show the math.

## Step 5: Report
Do NOT design a report. Use the template that ships with this plugin:
${CLAUDE_PLUGIN_ROOT}/assets/report-template.html

1. Copy the template to <document-name>-verification.html in the same folder
   as the document being verified.
2. Replace ONLY the JSON inside <script id="report-data">. Keep every key,
   and set "skillVersion" to 1.2.0 so the report records what produced it.
3. Never edit the CSS, the JavaScript, or the page structure. Never restyle,
   recolour, or "improve" the layout. The template carries the team's house
   style: gradient hero band, numbered section badges, white cards with
   uppercase header bars, a two-column question grid, and a green closing
   callout. Every report must look identical, so the layout is not yours
   to change. If the user wants a different look, they edit the template.
4. Verdict values must be spelled exactly: Confirmed, Partly right,
   Contradicted, Outdated, Not found, Needs account team.
5. Every claim needs sourceUrl (an allowed Salesforce domain) and tool
   ("Context7", "Web", or "Context7 + Web"). Only a Not found or Needs
   account team claim may have an empty sourceUrl.
6. No em dashes anywhere in the JSON. Before saving, re-read the JSON and
   replace any em dash with a comma or a hyphen.

Then reply in chat with the tally, the top three fixes, and the report path.
Do not edit the original document unless the user asks.
