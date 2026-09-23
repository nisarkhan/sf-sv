# Solution Recommendation: Northwind Health Member Service Agent

## Customer challenge
Northwind Health's member services team handles about 40,000 inquiries a month,
mostly eligibility and claim status questions. Wait times are long and agents
spend most of their day looking up the same data in three systems.

## Proposed solution
- Build an Agentforce service agent grounded in member data unified in Data Cloud.
- An Apex invocable action retrieves member eligibility by running SQL against
  Data Cloud using `ConnectApi.CdpQuery.queryAnsiSqlV2`.
- All Apex SOQL queries use `WITH SECURITY_ENFORCED`, which is Salesforce's
  recommended way to enforce user permissions in SOQL.
- The member portal is built with Lightning Web Components. Every component
  property is decorated with `@track` so the UI re-renders when values change.
- Deployments use `sfdx force:source:deploy`, the current recommended
  Salesforce CLI command.

## Cost and consumption
- Under Flex Credits, each standard agent action consumes 20 Flex Credits.
- Testing the agent in a full sandbox does not consume any Flex Credits.
- Consumption can be monitored in Digital Wallet by users with the
  View Consumption permission.
- Northwind's current contract includes 1,000,000 Flex Credits, which covers
  the first year of usage.
