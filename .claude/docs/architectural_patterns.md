# Architectural Patterns

Patterns that recur across the codebase. Each one names the canonical files
to read before adding a new instance — copy that shape rather than inventing
a new one.

## 1. LWC ↔ Apex controller (`@AuraEnabled` + `@wire`)

LWCs talk to Apex through `@AuraEnabled` static methods, never via REST.
Read-only methods are `cacheable=true` and consumed with `@wire`; mutating
methods are imperative and `await`ed.

- Apex: `SMSController.cls:3` (cacheable wire target),
  `SMSController.cls:44` (imperative POST), `SMSTemplateController.cls:7`,
  `SMSTemplateController.cls:66`.
- LWC consumers: `sendSMS/sendSMS.js:4-5,22,55,108`,
  `smsInterface/smsInterface.js:2,18`,
  `smsTemplateForm/smsTemplateForm.js:3-5,54,76,180`.

When adding a new method, match the existing rule: if it returns data and is
safe to cache, mark it `cacheable=true` and consume with `@wire`; if it has
side-effects (insert/update/callout that mutates external state), leave
caching off and call imperatively.

## 2. Aura quick-action wrapper around an LWC

An LWC cannot directly implement `force:lightningQuickAction`, so each LWC
that needs to be a record-page button gets a tiny Aura wrapper whose only
job is to host the LWC, override modal CSS, and fire
`e.force:closeQuickAction` when the LWC dispatches `close`.

- Wrapper components: `force-app/main/default/aura/SmsActionWrapper/sendActionWrapper.cmp`,
  `force-app/main/default/aura/SmsTemplateBridge/SmsTemplateBridge.cmp`.
- Controllers (one-liner each): `SmsActionWrapper/sendActionWrapperController.js:2-4`,
  `SmsTemplateBridge/SmsTemplateBridgeController.js`.
- LWC side of the contract — dispatch `close` on cancel/save:
  `sendSMS/sendSMS.js:155-160`, `smsTemplateForm/smsTemplateForm.js:227-231`.

The newer pattern in `sendSMS` *also* dispatches `CloseActionScreenEvent`
from `lightning/actions` (`sendSMS.js:6,157`) so the LWC works even when
launched directly as a `lightning__RecordAction` without an Aura wrapper.
Prefer that for new components and keep the Aura wrapper only as a
compatibility layer.

## 3. JSON-payload `@AuraEnabled` for write methods

Mutating `@AuraEnabled` methods take a single `String payloadJson` instead
of a long parameter list, and `JSON.deserializeUntyped` it into a
`Map<String, Object>`. Keeps the Apex signature stable as the LWC form
grows.

- Apex: `SMSTemplateController.cls:66-89` (`saveTemplate`),
  `SMSController.cls:44-55` (`sendSMSMessage`).
- Caller: `smsTemplateForm/smsTemplateForm.js:170-180`,
  `sendSMS/sendSMS.js:114-123`.

If you add a new field, add a `payload.containsKey('foo')` guard on the
Apex side (see `SMSTemplateController.cls:77-86`) so old clients don't break.

## 4. External callouts via `Http` + `HttpRequest`

The SMS feature talks to a Hono worker hosted at
`https://server.shivam207.workers.dev`. The shape is consistent across all
three callouts:

- `SMSController.cls:17-28` (GET `/templates`),
- `SMSController.cls:30-42` (GET `/history`),
- `SMSController.cls:44-55` (POST `/send-sms`).

When adding a new endpoint, copy this shape: build `HttpRequest`, set
endpoint/method/headers, `http.send`, and on read paths
`JSON.deserializeUntyped` the body inside an `if (statusCode == 200)` guard
returning an empty list on failure.

The endpoint is hardcoded. If multi-environment support is needed, move it
to a Custom Setting and follow the `Dreamhouse_Settings__c.getOrgDefaults()`
pattern at `EinsteinVisionController.cls:4` and
`SlackOpportunityPublisher.cls:3`. Remote Site Settings / Named Credentials
must be configured in the org for callouts to work.

## 5. Async Apex shapes (practice code reference)

The practice classes show the canonical shape for each async type. Reuse
these as templates when a real feature needs them:

- **Batchable + Stateful:** `UpdateAccountBatch.cls:1` — `start` returns
  `Database.QueryLocator`, `execute` processes the scope chunk, `finish`
  sends a completion email.
- **Schedulable:** `ScheduleUpdateNumOfContact.cls:1` — implements
  `Schedulable`, single `execute(SchedulableContext)`.
- **Queueable + Callouts:** `SlackOpportunityPublisher.cls:17-41` —
  `implements System.Queueable, Database.AllowsCallouts`, enqueued from an
  invocable so the callout doesn't run inline with the trigger.
- **Invocable:** `SlackOpportunityPublisher.cls:5-15` — `@InvocableMethod`
  takes `List<Id>`, used from Flow / Process Builder.

## 6. Test-mode callout guard

Apex tests cannot make real HTTP callouts, so production callout sites are
wrapped in `if (!Test.isRunningTest())`:

- `EinsteinVisionController.cls:37-39`,
- `SlackOpportunityPublisher.cls:35-38`.

Note the SMS controller does *not* do this — its tests rely on a mock HTTP
callout (or have none yet). When you add tests for `SMSController` methods,
register an `HttpCalloutMock` rather than guarding with `Test.isRunningTest()`;
that's the better pattern when feasible. Use the guard only when JWT / OAuth
flows make mocking impractical.

## 7. LWC error-flattening helper

Apex errors come back as `error.body.message` for AuraHandledExceptions but
plain `error.message` for JS errors. Components that touch Apex include a
small `reduceError`/inline equivalent so toast messages are always
human-readable.

- `smsTemplateForm/smsTemplateForm.js:251-256` (named helper),
- `sendSMS/sendSMS.js:138-143` (inline).

Use the named-helper form for any new component. Pair it with
`ShowToastEvent` for user feedback (see
`smsTemplateForm/smsTemplateForm.js:247-249`).

## 8. Schema describe for dynamic object/field pickers

`SMSTemplateController` builds the object & field pickers in the template
form by walking `Schema.getGlobalDescribe()` and the per-object field map,
then sorting by label via inline `Comparator` classes.

- `SMSTemplateController.cls:7-29` (filtered global describe),
- `SMSTemplateController.cls:35-60` (per-object fields with
  `hasChildren = field.getType() == REFERENCE` for lookup-aware UIs),
- `SMSTemplateController.cls:93-103` (private `Comparator` inner classes).

When adding a similar dynamic picker, reuse this shape — including the
`isQueryable && isCreateable && !isCustomSetting` filter, which is the right
default for "objects a user can write a template against."
